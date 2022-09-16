//
//  MapView.swift
//
//  Created by Tomas Green on 2020-04-01.
//

import Combine
import SwiftUI
import MapKit
import CoreLocation

// https://www.iosapptemplates.com/blog/swiftui/map-view-swiftui
struct MapView: UIViewRepresentable {
    class LandmarkAnnotation: NSObject, MKAnnotation {
        let title: String?
        let subtitle: String?
        let coordinate: CLLocationCoordinate2D
        init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
            self.title = title
            self.subtitle = subtitle
            self.coordinate = coordinate
        }
    }
    var locationManager:CLLocationManager
    var coordinates:CLLocation?
    func setupManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if coordinates == nil {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func makeUIView(context: Context) -> MKMapView {
        setupManager()
        let mapView = MKMapView(frame: UIScreen.main.bounds)
        mapView.showsUserLocation = true
        mapView.isUserInteractionEnabled = false
        updateAnnotations(in: mapView)
        
        return mapView
    }
    func updateUIView(_ uiView: MKMapView, context: Context) {
        updateAnnotations(in: uiView)
    }
    func updateAnnotations(in view:MKMapView) {
        view.annotations.forEach { (a) in
            view.removeAnnotation(a)
        }
        if let coordinates = coordinates {
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: coordinates.coordinate, span: span)
            view.setRegion(region, animated: false)
            view.addAnnotation(LandmarkAnnotation(title: nil, subtitle: nil, coordinate: coordinates.coordinate))
        } else {
            view.userTrackingMode = .follow
        }
    }
}
