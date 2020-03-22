//
//  CoreDataManager.swift
//  Reference: https://cocoacasts.com/setting-up-the-core-data-stack-from-scratch
//  Virtual Tourist
//
//  Created by Ivan Hadzhiiliev on 2020-03-15.
//  Copyright © 2020 Udacity. All rights reserved.
//

import CoreData

final class CoreDataManager {

    // MARK: - Properties
    private let modelName: String
    
    static let instance = CoreDataManager(modelName: "VirtualTourist")

    // MARK: - Initialization
    private init(modelName: String) {
        self.modelName = modelName
    }

    // MARK: - Core Data Stack
    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator

        return managedObjectContext
    }()

    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
            fatalError("Unable to Find Data Model")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to Load Data Model")
        }
        
        return managedObjectModel
    }()

    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)

        let fileManager = FileManager.default
        let storeName = "\(self.modelName).sqlite"

        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)

        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                              configurationName: nil,
                                                              at: persistentStoreURL,
                                                              options: nil)
        } catch {
            fatalError("Unable to Load Persistent Store")
        }
        
        return persistentStoreCoordinator
    }()
    
    func save() {
        managedObjectContext.performAndWait() {
            if self.managedObjectContext.hasChanges {
                do {
                    try self.managedObjectContext.save()
                } catch {
                    fatalError("Error while saving main context: \(error)")
                }
            }
        }
    }


}
