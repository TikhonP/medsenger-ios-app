//
//  HealthKitRecord.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 01.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import HealthKit

/// Store `HealthKit` record for submit it to Medsenger server
struct HealthKitRecord: Encodable {
    enum CategoryName: String, Encodable {
        case steps, pulse, spo2, respiration_rate, unknown
        
        init(from quantityType: HKQuantityType) {
            switch quantityType {
            case HKObjectType.quantityType(forIdentifier: .stepCount):
                self = .steps
            case HKObjectType.quantityType(forIdentifier: .heartRate):
                self = .pulse
            case HKObjectType.quantityType(forIdentifier: .oxygenSaturation):
                self = .spo2
            case HKObjectType.quantityType(forIdentifier: .respiratoryRate):
                self = .respiration_rate
            default:
                self = .unknown
            }
        }
    }
    
    let categoryName: CategoryName
    let source: String = "health"
    
    /// `Date` as time since 1970
    let time: Date
    
    let value: String
    
    init?(from sample: HKQuantitySample) {
        let category = CategoryName(from: sample.quantityType)
        
        let value: Double
        switch category {
        case .steps:
            value = sample.quantity.doubleValue(for: HKUnit.count())
        case .pulse:
            value = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
        case .spo2:
            value = sample.quantity.doubleValue(for: HKUnit(from: "%"))
        case .respiration_rate:
            value = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
        case .unknown:
            return nil
        }
        
        self.categoryName = category
        self.time = sample.endDate
        self.value = String(value)
    }
}
