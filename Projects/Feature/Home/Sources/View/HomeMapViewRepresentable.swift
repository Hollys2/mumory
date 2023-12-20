//
//  HomeMapView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/17.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import MapKit
import MusicKit
import Core
import Shared

struct HomeMapViewRepresentable: UIViewRepresentable {
    
    typealias UIViewType = MKMapView
        
    @Binding var annotationSelected: Bool
    
    @EnvironmentObject var mumoryViewModel: MumoryDataViewModel
    
    func makeUIView(context: Context) -> UIViewType {
        print("@@makeUIView")

        let mapView: MKMapView = .init()

        mapView.mapType = .mutedStandard
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.isPitchEnabled = false
//        mapView.userTrackingMode = .follow 권한 동의 후에
        mapView.setRegion(MKCoordinateRegion(center: MapConstant.defaultCoordinate2D, span: MapConstant.defaultSpan), animated: true)
        
        context.coordinator.mapView = mapView
        context.coordinator.setGPSButton()
        context.coordinator.setCompassButton()
        
        mapView.delegate = context.coordinator
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator,
                                                        action: #selector(Coordinator.tappedMap))
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        //        print("@@updateUIView")
        
        for annotation in mumoryViewModel.mumoryAnnotations {
            uiView.addAnnotation(annotation)
        }
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(parent: self)
    }
}

extension HomeMapViewRepresentable {
    
    class MapViewCoordinator: NSObject {
    
        let parent: HomeMapViewRepresentable
        var mapView: MKMapView?
        var startPlace: String = ""
        private let completer = MKLocalSearchCompleter()
        var results: [MKLocalSearchCompletion] = [MKLocalSearchCompletion]()
        var annotationItem: MumoryModel?
        
//        @EnvironmentObject var locationManager: LocationManager
        
        init(parent: HomeMapViewRepresentable) {
            self.parent = parent

            super.init()
//            completer.delegate = self
        }
        
        @objc func tappedMap(sender: UITapGestureRecognizer) {
            guard let mapView = self.mapView else { return }
            
            if !parent.annotationSelected {
                print("탭맵")
                if let selectedAnnotation = mapView.selectedAnnotations.first {
                    mapView.deselectAnnotation(selectedAnnotation, animated: true)
//                    parent.annotationSelected.toggle()
//                    print("탭맵")
                }
            }
//            mapView.deselectAnnotation(AnnotationModel, animated: true)
            // mapView.deselectAnnotation(yourSelectedAnnotation, animated: true)
        }
        
        func setGPSButton() {
            guard let mapView = self.mapView else { return }
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: mapView.bounds.width - 48 - 22, y: mapView.bounds.height - 48 - 24, width: 48, height: 48)
            button.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
            button.setImage(SharedAsset.gps.image, for: .normal)
            button.addTarget(self, action:#selector(self.tappedGPSButton), for:.touchUpInside)
            
            mapView.addSubview(button)
        }
        
        func setCompassButton() {
            guard let mapView = self.mapView else { return }
            
            let compassButton = MKCompassButton(mapView: mapView)
            compassButton.compassVisibility = .adaptive
            compassButton.frame = CGRect(x: mapView.bounds.width - compassButton.bounds.width - 22, y: mapView.bounds.height - compassButton.bounds.height - 87, width: 48, height: 48)
            compassButton.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
            
            mapView.addSubview(compassButton)
        }
        
        func setPlayingMusicBar() {
            
        }
        
        @objc private func tappedGPSButton() {
            guard let mapView = mapView, let userLocation = mapView.userLocation.location else { return }
            
            let regionRadius: CLLocationDistance = 1000
            let region = MKCoordinateRegion(center: userLocation.coordinate,
                                            latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            mapView.setRegion(region, animated: true)
        }
        
        func moveFocusOnUserLocation() {
            guard let mapView = self.mapView else { return }
            print("moveFocusOnUserLocation")
            mapView.showsUserLocation = true
            mapView.setUserTrackingMode(.follow, animated: true)
        }
        
    }
}

extension HomeMapViewRepresentable.MapViewCoordinator: MKMapViewDelegate {
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
    }
    
    // 사용자의 현재 위치가 변할 때
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("didUpdate in MKMapViewDelegate")
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        mapView.setRegion(region, animated: true)
    }
    
    // 사용자가 지도를 움직일 때
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        print("regionDidChangeAnimated in MKMapViewDelegate")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "MumoryAnnotation") ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "MumoryAnnotation")
        
        if annotation is MumoryAnnotation {
            annotationView.image = SharedAsset.musicPin.image
            annotationView.frame = CGRect(x: 0, y: 0, width: 74, height: 81)
        } else {
            annotationView.image = SharedAsset.userLocation.image
            if let image = annotationView.image {
                annotationView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            }
        }
//        annotationView.canShowCallout = true // 터치
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        print("didSelect")
        
        if annotation is MumoryAnnotation {
            parent.annotationSelected = true
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("didDeselect")
        parent.annotationSelected = false
    }
}

extension HomeMapViewRepresentable.MapViewCoordinator: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        print("completerDidUpdateResults in MKLocalSearchCompleterDelegate, HomeMapViewRepresentable.MapViewCoordinator")
        self.results = completer.results
    }
}
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

