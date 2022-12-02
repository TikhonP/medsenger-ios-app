//
//  ClinicDevice+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ClinicDevice)
public class ClinicDevice: NSManagedObject {
    private class func get(id: Int, for context: NSManagedObjectContext) -> ClinicDevice? {
        let fetchRequest = ClinicDevice.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "ClinicDevice get by id")
        return fetchedResults?.first
    }
}

extension ClinicDevice {
    public var wrappedName: String {
        name ?? "Unknown name"
    }
    
    public var wrappedDescription: String {
        deviceDescription ?? "Unknown description"
    }
}

extension ClinicDevice {
    struct JsonDeserializer: Decodable {
        let id: Int
        let name: String
        let description: String
    }
    
    private class func saveFromJson(_ data: JsonDeserializer, clinic: Clinic, for context: NSManagedObjectContext) -> ClinicDevice {
        let clinicDevice = get(id: data.id, for: context) ?? ClinicDevice(context: context)
        
        clinicDevice.id = Int64(data.id)
        clinicDevice.name = data.name
        clinicDevice.deviceDescription = data.description
        clinicDevice.clinic = clinic
        
        return clinicDevice
    }
    
    class func saveFromJson(_ data: [JsonDeserializer], clinic: Clinic, for context: NSManagedObjectContext) {
        for clinicDeviceData in data {
            _ = saveFromJson(clinicDeviceData, clinic: clinic, for: context)
        }
    }
}
