//
//  HealthKitSync.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 01.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import HealthKit
import os.log

/// Service provides HealthKit data syncronization with medsenger
final class HealthKitSync: ObservableObject {
    static let shared = HealthKitSync()
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: HealthKitSync.self)
    )
    
    // Published varibles for statistic in SettingsView
    @Published var lastHealthSyncStepsCount: String?
    @Published var lastHealthSyncHeartRate: String?
    @Published var lastHealthSyncOxygenSaturation: String?
    @Published var lastHealthSyncRespiratoryRate: String?
    
    let isHealthDataAvailable = HKHealthStore.isHealthDataAvailable()
    private let healthKitStore = HKHealthStore()
    
    private var availibleHealthKitTypes: Set<HKSampleType> = []
    
    /// Date from start synchronization
    private var healthKitSyncStartDate: Date? {
        if let lastHealthSync = User.getLastHelthSync() {
            return lastHealthSync
        } else {
            // Get the date two weeks ago.∫
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: Date())
            components.day = components.day! - 14
            return calendar.date(from: components)
        }
    }
    
    /// Request and fetch samples with specific type
    /// - Parameters:
    ///   - sampleType: The type of sample to search for.
    ///   - startDate: The start date for the target time interval.
    ///   - completionHandler: A block that is called when the query finishes executing. `samoles` parameter is return samples.
    private func getSamplesForType(sampleType: HKSampleType, withStart startDate: Date?, completionHandler: @escaping (_ samples: [HKQuantitySample]?) -> Void) {
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: HKQueryOptions())
        let query = HKSourceQuery(sampleType: sampleType, samplePredicate: datePredicate) { [weak self] query, sources, error in
            if let error = error {
                HealthKitSync.logger.error("HealthKitSync source query error: \(error.localizedDescription)")
                completionHandler(nil)
                return
            }
            guard let sources = sources else {
                completionHandler(nil)
                return
            }
            var storeSamples: [HKQuantitySample]?
            let group = DispatchGroup()
            for source in sources {
                group.enter()
                let sourcePredicate = HKQuery.predicateForObjects(from: source)
                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, sourcePredicate])
                let query = HKAnchoredObjectQuery(type: sampleType, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { query, samples, deletedObjects, queryAnchor, error in
                    defer {
                        group.leave()
                    }
                    if let error = error {
                        HealthKitSync.logger.error("HealthKitSync samples query error: \(error.localizedDescription)")
                        return
                    }
                    guard let samples = samples as? [HKQuantitySample] else {
                        return
                    }
                    guard let currentStepCountSamples = storeSamples else {
                        storeSamples = samples
                        return
                    }
                    if samples.count > currentStepCountSamples.count {
                        storeSamples = samples
                    }
                }
                self?.healthKitStore.execute(query)
            }
            group.notify(queue: .main) {
                completionHandler(storeSamples)
            }
        }
        healthKitStore.execute(query)
    }
    
    /// Submit HTTP request with samples to medsenger server
    /// - Parameter records: Codable records array to submit
    private func submitHealthRecordsToMedsenger(_ records: [HealthKitRecord]) {
        
        Task(priority: .background) {
            let healthRecordsResource = HealthRecordsResource(values: records)
            do {
                let data = try await APIRequest(healthRecordsResource).executeWithResult()
                try await User.updateLastHealthSync(lastHealthSync: data.lastHealthSync)
                HealthKitSync.logger.info("HealthKitSync submited")
            } catch {
                _ = await processRequestError(error, "submit HealthKit records")
            }
        }
    }
    
    /// Create observer query for type
    /// - Parameter sampleType: The type of sample to search for.
    private func startObservingHKChanges(for sampleType: HKSampleType) {
        let query = HKObserverQuery(sampleType: sampleType, predicate: nil, updateHandler: updateHandler)
        healthKitStore.execute(query)
        healthKitStore.enableBackgroundDelivery(for: sampleType, frequency: .immediate) { succeeded, error in
            if let error = error {
                HealthKitSync.logger.error("HealthKitSync enableBackgroundDeliveryForType error: \(error.localizedDescription)")
            }
            if succeeded {
                HealthKitSync.logger.info("HealthKitSync enableBackgroundDeliveryForType succeeded")
            } else {
                HealthKitSync.logger.notice("HealthKitSync enableBackgroundDeliveryForType failed")
            }
        }
    }
    
    /// A block that is called when a matching sample is saved to or deleted from the HealthKit store.
    /// - Parameters:
    ///   - query: A reference to the query calling this block.
    ///   - completionHandler: Call this completion handler as soon as you are done processing the incoming data. This tells HealthKit that you have successfully received the background update.
    ///   - error: If an error occurs, this parameter contains an object describing the error; otherwise, it is nil.
    private func updateHandler(_ query: HKObserverQuery, _ completionHandler: @escaping HKObserverQueryCompletionHandler, _ error: Error?) {
        defer {
            completionHandler()
        }
        if let error = error {
            HealthKitSync.logger.error("HealthKitSync updateHandler error: \(error.localizedDescription)")
        }
        guard let objectType = query.objectType, let sampleType = objectType as? HKSampleType else {
            HealthKitSync.logger.error("HealthKitSync updateHandler failed to get HKSampleType")
            return
        }
        getSamplesForType(sampleType: sampleType, withStart: healthKitSyncStartDate, completionHandler: submitHealthKitSamples)
    }
    
    /// Process samples and submit it to Medsenger
    /// - Parameter samples: The samples to submit
    private func submitHealthKitSamples(_ samples: [HKQuantitySample]?) {
        guard let samples = samples else {
            return
        }
        var records = [HealthKitRecord]()
        for sample in samples {
            if let record = HealthKitRecord(from: sample) {
                records.append(record)
            }
        }
        if let lastRecord = records.last {
            switch lastRecord.categoryName {
            case .steps:
                lastHealthSyncStepsCount = lastRecord.value
            case .pulse:
                lastHealthSyncHeartRate = lastRecord.value
            case .spo2:
                lastHealthSyncOxygenSaturation = lastRecord.value
            case .respiration_rate:
                lastHealthSyncRespiratoryRate = lastRecord.value
            case .unknown:
                break
            }
        }
        
        if !records.isEmpty {
            self.submitHealthRecordsToMedsenger(records)
        }
    }
    
    /// Requests permission to save and read the specified data types.
    /// - Parameter completion: A block called after the user finishes responding to the request with granted boolean varible
    func authorizeHealthKit(completion: @escaping (_ granted: Bool) -> Void) {
        guard isHealthDataAvailable else {
            completion(false)
            return
        }
        
        if let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount) {
            availibleHealthKitTypes.update(with: stepCount)
        }
        if let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate) {
            availibleHealthKitTypes.update(with: heartRate)
        }
        if let oxygenSaturation = HKObjectType.quantityType(forIdentifier: .oxygenSaturation) {
            availibleHealthKitTypes.update(with: oxygenSaturation)
        }
        if let respiratoryRate = HKObjectType.quantityType(forIdentifier: .respiratoryRate) {
            availibleHealthKitTypes.update(with: respiratoryRate)
        }
        
        healthKitStore.requestAuthorization(toShare: [], read: availibleHealthKitTypes) { success, error in
            if let error = error {
                HealthKitSync.logger.error("HealthKitSync requestAuthorization error: \(error.localizedDescription)")
            }
            completion(success)
        }
    }
    
    /// One time sync HealthKit records with Medsenger
    /// - Parameter completionHandler: completion block call after process finish
    func syncDataFromHealthKit(completionHandler: @escaping () -> Void) {
        let group = DispatchGroup()
        for availibleHealthKitType in availibleHealthKitTypes {
            group.enter()
            getSamplesForType(sampleType: availibleHealthKitType, withStart: healthKitSyncStartDate) { [weak self] samples in
                self?.submitHealthKitSamples(samples)
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completionHandler()
        }
    }
    
    /// Start background fetch HealthKit records with Medsenger
    func startObservingHKChanges() {
        for availibleHealthKitType in availibleHealthKitTypes {
            startObservingHKChanges(for: availibleHealthKitType)
        }
    }
}
