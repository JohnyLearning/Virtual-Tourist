//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Ivan Hadzhiiliev on 2020-03-15.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoCollectionViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelStatus: UILabel!
    
    var addedIndices: [IndexPath]!
    var removedIndices: [IndexPath]!
    var updatedIndices: [IndexPath]!
    
    var location: LocationData?
    var fetchedResultsController: NSFetchedResultsController<PhotoData>!
    
    let space: CGFloat = 2.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        
        updateStatus("")
        
        guard let location = location else {
            return
        }
        initMapLocation()
        setupFetchedResultControllerWith(location)
        
        if let photos = location.photos, photos.count == 0 {
            getPhotos(location)
        }
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        for photos in fetchedResultsController.fetchedObjects! {
            CoreDataManager.instance.managedObjectContext.delete(photos)
        }
        CoreDataManager.instance.save()
        getPhotos(location!)
    }
    
    private func setupFetchedResultControllerWith(_ pin: LocationData) {
        
        let fr = NSFetchRequest<PhotoData>(entityName: "PhotoData")
        fr.sortDescriptors = []
        fr.predicate = NSPredicate(format: "location == %@", argumentArray: [pin])
        
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
    
    private func getPhotos(_ pin: LocationData) {
        
        let lat = Double(pin.latitude)
        let lon = Double(pin.longitude)
        
        activityIndicator.startAnimating()
        
        FlickrApi.searchPhotos(longitude: lon, latitude: lat) { (data, error) in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.labelStatus.text = ""
            }
            if let photos = data {
                let numberOfPhotos = photos.photos.photo.count
                self.savePhotos(photos.photos.photo, forPin: pin)
                if numberOfPhotos == 0 {
                    self.updateStatus("No photos found")
                }
            } else {
                self.updateStatus("Photos retrieval failed")
            }
        }
    }
    
    private func updateStatus(_ text: String) {
        DispatchQueue.main.async {
            self.labelStatus.text = text
        }
    }
    
    private func savePhotos(_ photos: [Photo], forPin: LocationData) {
        for photo in photos {
            DispatchQueue.main.async {
                if let url = photo.thumbnailUrl {
                    let photoData = PhotoData(context: CoreDataManager.instance.managedObjectContext)
                    photoData.title = photo.title
                    photoData.imageUrl = url
                    photoData.location = self.location
                    CoreDataManager.instance.save()
                }
            }
        }
    }
    
}
