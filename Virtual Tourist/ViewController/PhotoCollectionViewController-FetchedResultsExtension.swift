//
//  PhotoCollectionViewController-FetchedResultsExtension.swift
//  Virtual Tourist
//
//  Created by Ivan Hadzhiiliev on 2020-03-29.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import CoreData

extension PhotoCollectionViewController: NSFetchedResultsControllerDelegate {
    
    internal func setupFetchedResults(_ location: LocationData) {
        
        let fr = NSFetchRequest<PhotoData>(entityName: "PhotoData")
        fr.sortDescriptors = []
        fr.predicate = NSPredicate(format: "location == %@", argumentArray: [location])
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: CoreDataManager.instance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("\(#function) Error performing initial fetch: \(error)")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        addedIndices = [IndexPath]()
        removedIndices = [IndexPath]()
        updatedIndices = [IndexPath]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
        
        switch (type) {
        case .insert:
            addedIndices.append(newIndexPath!)
            break
        case .delete:
            removedIndices.append(indexPath!)
            break
        case .update:
            updatedIndices.append(indexPath!)
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.addedIndices {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.removedIndices {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndices {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
        }, completion: nil)
    }
    
}
