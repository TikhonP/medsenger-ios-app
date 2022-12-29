//
//  NSManagedObjectContext+crossVersionPerform.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 29.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

struct NoDataCrossVersionPerform: Error {}

extension NSManagedObjectContext {
    func crossVersionPerform<T>(
        _ block: @escaping () throws -> T
    ) async throws -> T {
        if #available(iOS 15.0, *) {
            return try await perform {
                return try block()
            }
        } else {
            var performError: Error?
            var result: T?
            performAndWait {
                do {
                    result = try block()
                } catch {
                    performError = error
                }
            }
            guard let result = result else {
                if let performError = performError {
                    throw performError
                } else {
                    throw NoDataCrossVersionPerform()
                }
            }
            return result
        }
    }
}
