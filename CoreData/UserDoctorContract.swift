//
//  UserDoctorContract.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 31.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData

//extension Contract {
//    class func save(doctorContracts: [DoctorContract]) {
//        PersistenceController.shared.container.performBackgroundTask { (context) in
//            context.reset()
//
//            // Store got contracts to check if some contractes deleted later
//            var gotContractIds = [Int]()
//
//            for contract in doctorContracts {
//
//                PatientHelper.save(patientHelpers: contract.patient_helpers, contract: userDoctorContract, context: context)
//                DoctorHelper.save(doctorHelpers: contract.doctor_helpers, contract: userDoctorContract, context: context)
//                ContractParam.save(contractParams: contract.params, contract: userDoctorContract, context: context)
//                if let infoMaterials = contract.info_materials {
//                    InfoMaterial.save(infoMaterials: infoMaterials, contract: userDoctorContract, context: context)
//                }
//            }
//
//            if !gotContractIds.isEmpty {
//                cleanRemoved(validContractIds: gotContractIds, context: context)
//            }
//
//            PersistenceController.save(context: context)
//        }
//    }
//}
