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
    
    /// Save persistence store
    /// - Parameter detailsForLogging: if error appears while saving provide object that saved for logging and debugging
    func wrappedSave(detailsForLogging: String? = nil) throws {
        if hasChanges {
            do {
                try save()
            } catch let nserror as NSError {
                var errorDescription = ""
                if let detailsForLogging = detailsForLogging {
                    errorDescription = "Core Data: Failed to save model `\(detailsForLogging)`: \(nserror.localizedDescription)"
                } else {
                    errorDescription = "Core Data: Failed to save model: \(nserror.localizedDescription)"
                }
                if let detailed = nserror.userInfo["NSDetailedErrors"] as? NSMutableArray {
                    for nserror in detailed {
                        if let nserror = nserror as? NSError, let entity = nserror.userInfo["NSValidationErrorObject"] {
                            errorDescription += "\nCore Data: Detailed: \(nserror.localizedDescription) Entity: `\(type(of: entity))`."
                        }
                    }
                }
                PersistenceController.logger.error("\(errorDescription)")
                throw nserror
            }
        }
    }
    
    /// Perform fetch request with errors catching
    /// - Parameters:
    ///   - request: The fetch request that specifies the search criteria.
    ///   - detailsForLogging: if error appears while fetching provide object that saved for logging and debugging
    /// - Returns: Returns an array of items of the specified type that meet the fetch request’s critieria nil value returned if error
    func wrappedFetch<T>(_ request: NSFetchRequest<T>, detailsForLogging: String? = nil) throws -> [T] where T : NSFetchRequestResult {
        do {
            return try fetch(request)
        } catch let nserror as NSError {
            if let detailsForLogging = detailsForLogging {
                PersistenceController.logger.error("Core Data: Failed to perform fetch request `\(detailsForLogging)`: \(nserror.localizedDescription)")
            } else {
                PersistenceController.logger.error("Core Data: Failed to perform fetch request: \(nserror.localizedDescription)")
            }
            throw nserror
        }
    }
}
