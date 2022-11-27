//
//  ContentViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

final class ContentViewModel: ObservableObject {
    @Published var isCalling: Bool = false
    @Published var videoCallContractId: Int?
}
