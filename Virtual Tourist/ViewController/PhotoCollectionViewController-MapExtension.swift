//
//  PhotoCollectionViewController-MapExtension.swift
//  Virtual Tourist
//
//  Created by Ivan Hadzhiiliev on 2020-03-29.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import MapKit

extension PhotoCollectionViewController: MKMapViewDelegate {
    
    func initMapLocation() {
        let mapLocation = CLLocationCoordinate2D(latitude: location!.latitude, longitude: location!.longitude)
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "location"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}
