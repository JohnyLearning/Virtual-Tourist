//
//  PhotoCollectionViewController-CollectionExtension.swift
//  Virtual Tourist
//
//  Created by Ivan Hadzhiiliev on 2020-03-29.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import UIKit

extension PhotoCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sectionInfo = self.fetchedResultsController.sections?[section] {
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as! PhotoCell
        cell.imageView.image = nil
        cell.activityIndicator.startAnimating()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        let photoViewCell = cell as! PhotoCell
        photoViewCell.imageUrl = photo.imageUrl!
        downloadImage(photoCell: photoViewCell, photo: photo, index: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        CoreDataManager.instance.managedObjectContext.delete(photoToDelete)
        CoreDataManager.instance.save()
        guard let photos = location?.photos, photos.count > 0 else {
            updateStatus("No more images found.")
            return
        }
        hideStatus()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying: UICollectionViewCell, forItemAt: IndexPath) {
        if collectionView.cellForItem(at: forItemAt) == nil {
            return
        }
        
        let photo = fetchedResultsController.object(at: forItemAt)
        if let imageUrl = photo.imageUrl {
            FlickrApi.cancelDownload(imageUrl)
        }
    }
    
    private func downloadImage(photoCell: PhotoCell, photo: PhotoData, index: IndexPath) {
        if let imageData = photo.image {
            photoCell.activityIndicator.stopAnimating()
            photoCell.imageView.image = UIImage(data: imageData)
        } else {
            if let imageUrl = photo.imageUrl {
                photoCell.activityIndicator.startAnimating()
                FlickrApi.downloadImage(imageUrl: imageUrl) { (data, error) in
                    if let _ = error {
                        DispatchQueue.main.async {
                            photoCell.activityIndicator.stopAnimating()
                        }
                        return
                    } else if let data = data {
                        DispatchQueue.main.async {
                            
                            if let currentCell = self.collectionView.cellForItem(at: index) as? PhotoCell {
                                if currentCell.imageUrl == imageUrl {
                                    currentCell.imageView.image = UIImage(data: data as Data)
                                    photoCell.activityIndicator.stopAnimating()
                                }
                            }
                            photo.image = data as Data
                            DispatchQueue.global(qos: .background).async {
                                CoreDataManager.instance.save()
                            }
                        }
                    }
                }
            }
        }
    }
}
