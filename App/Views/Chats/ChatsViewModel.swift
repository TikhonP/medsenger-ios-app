//
//  ChatsViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 31.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

final class ChatsViewModel: ObservableObject {
    
    private var getDoctorsRequest: APIRequest<DoctorsResource>?
    
    func getDoctors() {
        let doctorsResourse = DoctorsResource()
        getDoctorsRequest = APIRequest(resource: doctorsResourse)
        getDoctorsRequest?.execute { data, errorReponse, networkRequestError in
            if let data = data {
                Task {
                    UserDoctorContract.save(doctorContracts: data.data)
                }
            }
            
            if let errorReponse = errorReponse {
                print(errorReponse)
                return
            }
            if let networkRequestError = networkRequestError {
                print(networkRequestError)
                return
            }
        }
    }
}
