//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Ivan Hadzhiiliev on 2020-03-15.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addPin(gestureRecognizer:)))
        longPress.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPress)
        // Do any additional setup after loading the view.
    }

    @objc func addPin(gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            let coordinates = mapView.convert(gestureRecognizer.location(in: mapView), toCoordinateFrom: mapView)
            createPin(forCoordinate: coordinates)
        default:
            break
        }
    }
    
    private func createPin(forCoordinate coordinate: CLLocationCoordinate2D) {
        let locationAnnotation = MKPointAnnotation()
        locationAnnotation.coordinate = coordinate
        mapView.addAnnotation(locationAnnotation)
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
}

