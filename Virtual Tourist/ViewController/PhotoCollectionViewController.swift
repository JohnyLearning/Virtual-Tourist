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
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var newCollection: UIButton!
    
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
        setupFetchedResults(location)
        
        if let photos = location.photos, photos.count == 0 {
            getPhotos()
        } else {
            newCollection.isEnabled = true
        }
    }
    
    @IBAction func newCollection(_ sender: Any) {
        for photos in fetchedResultsController.fetchedObjects! {
            CoreDataManager.instance.managedObjectContext.delete(photos)
        }
        CoreDataManager.instance.save()
        if let location = self.location {
            location.pageIndex += 1
            CoreDataManager.instance.save()
        }
        getPhotos()
    }
    
    private func getPhotos() {
        if let location = self.location {
            let lat = Double(location.latitude)
            let lon = Double(location.longitude)
            
            activityIndicator.startAnimating()
            // get next page index based on location
            let pageIndex = location.pageIndex
            FlickrApi.searchPhotos(longitude: lon, latitude: lat, pageIndex: Int(pageIndex)) { (data, error) in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.newCollection.isEnabled = true
                }
                if let photos = data {
                    let numberOfPhotos = photos.photos.photo.count
                    self.savePhotos(photos.photos.photo)
                    if numberOfPhotos == 0 {
                        self.updateStatus("No photos found")
                    }
                } else {
                    self.updateStatus("Photos retrieval failed")
                }
            }
            hideStatus()
        }
    }
    
    internal func updateStatus(_ text: String) {
        DispatchQueue.main.async {
            self.status.text = text
            self.status.isHidden = false
        }
    }
    
    internal func hideStatus() {
        self.status.isHidden = true
    }
    
    private func savePhotos(_ photos: [Photo]) {
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
