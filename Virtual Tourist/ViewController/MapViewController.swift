//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Ivan Hadzhiiliev on 2020-03-15.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAnnotations()
        setupInitialMap()
    }
    
    func getAnnotations() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationData")
        do {
            if let mapLocations = try? CoreDataManager.instance.managedObjectContext.fetch(fetchRequest) as? [LocationData] {
                for location in mapLocations {
                    let location = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = location
                    mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    @IBAction func addLocation(_ sender: UIGestureRecognizer) {
        switch sender.state {
        case .began:
            let coordinates = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            createLocation(forCoordinate: coordinates)
        default:
            break
        }
    }
    
    private func createLocation(forCoordinate coordinate: CLLocationCoordinate2D) {
        let locationAnnotation = MKPointAnnotation()
        locationAnnotation.coordinate = coordinate
        mapView.addAnnotation(locationAnnotation)
        let location = LocationData(context: CoreDataManager.instance.managedObjectContext)
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        CoreDataManager.instance.save()
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let location = view.annotation as? MKPointAnnotation {
            if let locationData = retrieveLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) {
                self.performSegue(withIdentifier: "showPhotos", sender: locationData)
            }
        }
    }
    
    func retrieveLocation(latitude: Double, longitude: Double) -> LocationData?{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationData")
        let latitudePredicate = NSPredicate(format: "latitude == %lf", latitude)
        let longitudePredicate = NSPredicate(format: "longitude == %lf", longitude)
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [latitudePredicate, longitudePredicate])
        do {
            if let locations = try? CoreDataManager.instance.managedObjectContext.fetch(fetchRequest) as? [LocationData] {
                return locations[0]
            }
        }
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotos", let photoCollectionController = segue.destination as? PhotoCollectionViewController, sender is LocationData {
            photoCollectionController.locationData = sender as? LocationData
        }
    }
    
    private func setupInitialMap() {
        let mapInitializedBefore = defaults.bool(forKey: MapPersitentKeys.MapInitializedBefore)
        if (mapInitializedBefore) {
            let latitudeFromStorage = defaults.double(forKey: MapPersitentKeys.Latitude)
            let longitudeFromStorage = defaults.double(forKey: MapPersitentKeys.Longitude)
            let latitudeDeltaFromStorage = defaults.double(forKey: MapPersitentKeys.LatitudeDelta)
            let longitudeDeltaFromStorage = defaults.double(forKey: MapPersitentKeys.LongitudeDelta)
            let center = CLLocationCoordinate2D(latitude: latitudeFromStorage, longitude: longitudeFromStorage)
            let span = MKCoordinateSpan(latitudeDelta: latitudeDeltaFromStorage, longitudeDelta: longitudeDeltaFromStorage)
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated: true)
        } else {
            let latitude = 54.5
            let longitude = -3.5
            let latitudeDelta = 10.0
            let longitudeDelta = 10.0
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        defaults.set(mapView.centerCoordinate.latitude, forKey: MapPersitentKeys.Latitude)
        defaults.set(mapView.centerCoordinate.longitude, forKey: MapPersitentKeys.Longitude)
        defaults.set(mapView.region.span.latitudeDelta, forKey: MapPersitentKeys.LatitudeDelta)
        defaults.set(mapView.region.span.longitudeDelta, forKey: MapPersitentKeys.LongitudeDelta)
        defaults.set(true, forKey: MapPersitentKeys.MapInitializedBefore)
    }
}

