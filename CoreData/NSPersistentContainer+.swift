//
//  NSPersistentContainer+.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 31.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

extension NSPersistentContainer {
    func wrappedNewBackgroundContext() -> NSManagedObjectContext {
        let moc = newBackgroundContext()
        moc.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        moc.automaticallyMergesChangesFromParent = true
        return moc
    }
}
