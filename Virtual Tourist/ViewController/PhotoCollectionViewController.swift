//
//  PhotoCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Ivan Hadzhiiliev on 2020-03-21.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoCollectionViewController: UIViewController {
    
    var selectedIndexes = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    var locationData: LocationData!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var fetchedResultsController: NSFetchedResultsController<PhotoData>!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mainActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        mapView.delegate = self
        initMapLocation()
        setupDataController()
        if let photos = locationData.photos, photos.count == 0 {
            getPhotos()
        }
    }
    
    private func initMapLocation() {
        let mapLocation = CLLocationCoordinate2D(latitude: locationData.latitude, longitude: locationData.longitude)
        let center = CLLocationCoordinate2D(latitude: mapLocation.latitude, longitude: mapLocation.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapLocation
        let span = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
    }

    private func setupDataController() {
        
        let photosRequest = NSFetchRequest<PhotoData>(entityName: "PhotoData")
        photosRequest.sortDescriptors = []
        photosRequest.predicate = NSPredicate(format: "location == %@", argumentArray: [locationData!])
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: photosRequest, managedObjectContext: CoreDataManager.instance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("error during fetching photos: \(error)")
        }
    }
    
    private func indicateMainProgress(hide: Bool) {
        hide ? mainActivityIndicator.stopAnimating() : mainActivityIndicator.startAnimating()
        mainActivityIndicator.isHidden = hide
    }
    
}

extension PhotoCollectionViewController {
    
    func getPhotos() {
        if let locationData = locationData {
            indicateMainProgress(hide: false)
            FlickrApi.searchPhotos(longitude: locationData.longitude, latitude: locationData.latitude) { searchResponse, error in
                DispatchQueue.main.async {
                    if let photos = searchResponse?.photos.photo {
                        for photo in photos {
                            let photoData = PhotoData(context: CoreDataManager.instance.managedObjectContext)
                            photoData.url = photo.thumbnailUrl
                            photoData.image = nil
                            photoData.location = locationData
                            CoreDataManager.instance.save()
                        }
                    }
                    self.setupDataController()
                    self.indicateMainProgress(hide: true)
                }
            }
        }
    }
    
}

// collection view extension
extension PhotoCollectionViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as! PhotoCell
        let photoData = fetchedResultsController.object(at: indexPath)
        
        if let image = photoData.image {
            cell.imageView.image = UIImage(data: image as Data)
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.isHidden = true
        } else {
            if let url = photoData.url {
                cell.imageView.image = nil
                cell.activityIndicator.startAnimating()
                cell.activityIndicator.isHidden = false
                FlickrApi.downloadImage(imageUrl: url) { data, error in
                    DispatchQueue.main.async {
                        if let imageData = data {
                            photoData.image = imageData as Data
                            CoreDataManager.instance.save()
                            cell.imageView.image = UIImage(data: photoData.image!)
                        }
                    }
                }
            }
        }
        return cell
    }
}
    
extension PhotoCollectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print (indexPath.item + 1)
    }

}

extension PhotoCollectionViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }

        return pinView
    }

}

extension PhotoCollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
        
        switch (type) {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            print("Move an item. We don't expect to see this in this app.")
            break
        default:
            // no-op
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
        }, completion: nil)
    }
    
}

extension PhotoCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = floor (collectionView.bounds.width/3.0)
        let yourHeight = yourWidth

        return CGSize(width: yourWidth, height: yourHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
