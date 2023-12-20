//
//  SearchLocationMapViewRepresentable.swift
//  Feature
//
//  Created by 다솔 on 2023/12/15.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import MapKit
import Core
import Shared

struct SearchLocationMapViewRepresentable: UIViewRepresentable {
    
    typealias UIViewType = MKMapView
    
    @Binding var mumoryModel: MumoryModel
    
    func makeUIView(context: Context) -> UIViewType {
        print("@@makeUIView")

        let mapView: MKMapView = .init()

        mapView.mapType = .mutedStandard
        mapView.showsCompass = false
        mapView.isPitchEnabled = false
        mapView.showsUserLocation = true
//        mapView.userTrackingMode = .follow 권한 동의 후에
        
        mapView.setRegion(MKCoordinateRegion(center: MapConstant.defaultCoordinate2D, span: MapConstant.defaultSpan), animated: true)
        
        context.coordinator.mapView = mapView
        context.coordinator.setGPSButton()
        context.coordinator.setCompassButton()
        context.coordinator.setPin()
        
        mapView.delegate = context.coordinator
        
//        for musicAnnotation in musicAnnotations {
//            mapView.addAnnotation(musicAnnotation)
//        }
        
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = CLLocationCoordinate2D(latitude: 35.16097, longitude: 129.162577)
//        annotation.title = "Custom Location"
//        mapView.addAnnotation(musicAnnotation)

        
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
//        print("@@updateUIView")
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(parent: self, mumoryModel: self.$mumoryModel)
    }
}

extension SearchLocationMapViewRepresentable {
    
    class MapViewCoordinator: NSObject {
        
        @Binding var mumoryModel: MumoryModel
        
        let parent: SearchLocationMapViewRepresentable
        var mapView: MKMapView?
        var startPlace: String = ""
        private let completer = MKLocalSearchCompleter()
        var results: [MKLocalSearchCompletion] = [MKLocalSearchCompletion]()
        var isChanging: Bool = false {
            didSet {
                setPin()
            }
        }
                
        init(parent: SearchLocationMapViewRepresentable, mumoryModel: Binding<MumoryModel>) {
            self.parent = parent
            self._mumoryModel = mumoryModel
            super.init()
        }
//        init(parent: SearchLocationMapViewRepresentable, annotationItem: Binding<AnnotationItem?>) {
//            self.parent = parent
//            self._annotationItem = annotationItem // Use the passed binding here
//            super.init()
//            //            completer.delegate = self
//        }
        
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
        
        func setPin() {
            guard let mapView = self.mapView else { return }
            
            mapView.subviews.compactMap { $0 as? UIImageView }.forEach { $0.removeFromSuperview() }
            
            let imageView = UIImageView(image: SharedAsset.chooseSearchLocation.image)
            imageView.contentMode = .scaleAspectFit
            let imageViewSize: CGFloat = 62

            if isChanging {
                imageView.frame = CGRect(x: UIScreen.main.bounds.width / 2 - 31, y: (mapView.frame.height) / 2 - 31 - 5, width: imageViewSize, height: imageViewSize)
                imageView.alpha = 0.3
            } else {
                imageView.frame = CGRect(x: UIScreen.main.bounds.width / 2 - 31, y: (mapView.frame.height) / 2 - 31, width: imageViewSize, height: imageViewSize)
            }
            
            mapView.addSubview(imageView)
        }
        
        @objc private func tappedGPSButton() {
            guard let mapView = mapView, let userLocation = mapView.userLocation.location else { return }
            let regionRadius: CLLocationDistance = 1000
            let region = MKCoordinateRegion(center: userLocation.coordinate,
                                            latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            mapView.setRegion(region, animated: true)
        }
    }
}

extension SearchLocationMapViewRepresentable.MapViewCoordinator: MKMapViewDelegate {
    
    // 사용자가 지도를 움직일 때
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        isChanging = true
    }
    
    // 사용자의 현재 위치가 변할 때
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("didUpdate in MKMapViewDelegate")
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        mapView.setRegion(region, animated: true)
    }

    // 사용자가 지도를 움직이고 난 후
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("regionDidChangeAnimated in MKMapViewDelegate")

        self.isChanging = false
        
        let centerCoordinate = mapView.centerCoordinate
        let location = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                print("Error retrieving location information:", error?.localizedDescription ?? "Unknown error")
                return }
            
            let locationTitle = placemark.name ?? ""
            let locationSubtitle = (placemark.locality ?? "") + " " + (placemark.thoroughfare ?? "") + " " + (placemark.subThoroughfare ?? "")
            
            self.mumoryModel = MumoryModel(locationTitle: locationTitle, locationSubtitle: locationSubtitle, coordinate: centerCoordinate)
            
            print("self.mumoryModel regionDidChangeAnimated in MKMapViewDelegate: \(self.mumoryModel)")
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //        guard let userLocation = annotation as? MKUserLocation else { return nil }
//        if annotation is MKUserLocation {
//                return nil // MKUserLocation에 대한 기본 어노테이션 뷰를 사용하고 싶지 않을 때
//            }
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "userLocationAnnotation") ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "userLocationAnnotation")
        
        annotationView.image = SharedAsset.userLocation.image
        if let image = annotationView.image {
            annotationView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("didSelect")
//        mapView.deselectAnnotation(view.annotation, animated: false)
    }


}
