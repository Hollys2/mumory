//
//  HomeMapView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/17.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import MapKit
import Core
import Shared

struct HomeMapView: UIViewRepresentable {
    
    typealias UIViewType = MKMapView
    
    @Binding var tappedLocation: CLLocationCoordinate2D?
    @Binding var isChanging: Bool?
    @ObservedObject var locationManager: LocationManager = .init()
    
    private let defaultRegion = MKCoordinateRegion(center: MapConstant.startingLocation, span: MapConstant.defaultSpan)
    
    
    func makeUIView(context: Context) -> UIViewType {
        print("@@makeUIView")
        let mapView: MKMapView = .init()
        
        if #available(iOS 16.0, *) {
            mapView.preferredConfiguration = MKStandardMapConfiguration(elevationStyle: .flat, emphasisStyle: .muted)
        } else {
            mapView.isPitchEnabled = false
            mapView.mapType = .mutedStandard
        }
        mapView.setRegion(defaultRegion, animated: true)
//        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        
        locationManager.setMapView(mapView)

        let compassButton = MKCompassButton(mapView: mapView)
        compassButton.compassVisibility = .adaptive
        compassButton.frame = CGRect(x: 10, y: mapView.bounds.height - compassButton.bounds.height - 30,
                                     width: compassButton.bounds.width, height: compassButton.bounds.height)
        compassButton.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin] // 오른쪽과 위쪽 여백 유지
        mapView.addSubview(compassButton)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(MapViewCoordinator.tappedOnMap(_:)))
        mapView.addGestureRecognizer(tapGesture)

        context.coordinator.mapView = mapView
        context.coordinator.setGPSButton()
        
//        context.coordinator.moveFocusOnUserLocation()
        
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
//        print("@@updateUIView")
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(parent: self, tappedLocation: $tappedLocation, isChanging: $isChanging)
    }
}

extension HomeMapView {
    
    class MapViewCoordinator: NSObject {
        let parent: HomeMapView
        var mapView: MKMapView?
        @Binding var tappedLocation: CLLocationCoordinate2D?
        @Binding var isChanging: Bool?
        var startPlace: String
        
        init(parent: HomeMapView, tappedLocation: Binding<CLLocationCoordinate2D?>, isChanging: Binding<Bool?>) {
            self.parent = parent
            self._tappedLocation = tappedLocation
            self._isChanging = isChanging
            self.startPlace = ""
        }
        
        func setGPSButton() {
            guard let mapView = self.mapView else { return }
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: mapView.bounds.width - 48 - 22, y: mapView.bounds.height - 48 - 24, width: 48, height: 48)
            button.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
//            button.setImage(UIImage(named: "gps"), for: .normal)
            button.setImage(SharedAsset.gps.image, for: .normal)
            button.addTarget(self, action:#selector(self.tappedGPSButton), for:.touchUpInside)
            
            mapView.addSubview(button)
        }
        
        func setPlayingMusicBar() {
            
        }
        
        @objc private func tappedGPSButton() {
            guard let mapView = mapView, let userLocation = mapView.userLocation.location else { return }

            let regionRadius : CLLocationDistance = 1000
            let region = MKCoordinateRegion(center: userLocation.coordinate,
                                            latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            mapView.setRegion(region, animated: true)
        }
        
        @objc func tappedOnMap(_ sender: UITapGestureRecognizer) {
            guard let mapView = sender.view as? MKMapView else { return }
            
            print("tappedOnMap")
            
            let touchLocation = sender.location(in: sender.view)
            
            let locationCoordiate = mapView.convert(touchLocation, toCoordinateFrom: sender.view)
            
            let annotation = MKPointAnnotation()
//            annotation.coordinate = .init(latitude: locationCoordiate.latitude, longitude: locationCoordiate.longitude)
            annotation.coordinate = locationCoordiate
            self.tappedLocation = locationCoordiate
            
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(annotation)
        }
        
        func convertLocationToAddress(location: CLLocation) {
            let geocoder = CLGeocoder()
            
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if error != nil {
                    return
                }
                
                guard let placemark = placemarks?.first else { return }
                
                self.startPlace = "\(placemark.country ?? "") \(placemark.locality ?? "") \(placemark.name ?? "")"
            }
        }
        
        func moveFocusOnUserLocation() {
            guard let mapView = self.mapView else { return }
            print("moveFocusOnUserLocation")
            mapView.showsUserLocation = true
            mapView.setUserTrackingMode(.follow, animated: true)
        }
        
    }
}

//extension HomeMapView.MapViewCoordinator: MKMapViewDelegate {
//
//
//    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
////        print("regionWillChangeAnimated in MKMapViewDelegate")
//    }
//
//    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
//        //        print("mapViewDidChangeVisibleRegion in MKMapViewDelegate")
//        DispatchQueue.main.async {
//            self.isChanging = true
//        }
//    }
//
//    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//
//        let location: CLLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
////        print("regionDidChangeAnimated in MKMapViewDelegate: \(location)")
//
//        self.convertLocationToAddress(location: location)
//        print("self.startPlace: \(self.startPlace)")
//
//        DispatchQueue.main.async {
//            self.isChanging = false
//        }
//    }
//
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if annotation is MKUserLocation {
//            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
//            let image = SharedAsset.userLocation.image.resized(to: CGSize(width: 45, height: 45))
//            annotationView.image = image
//            return annotationView
//        }
//        return nil
//    }
//}

