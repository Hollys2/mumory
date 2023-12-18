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
    
    @ObservedObject var locationManager: LocationManager2 = .init()
    @Binding var annotationItem: AnnotationItem?
    
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
        context.coordinator.setPin()
        
        mapView.delegate = context.coordinator
        
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
//        print("@@updateUIView")
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(parent: self, annotationItem: $annotationItem)
    }
}

extension SearchLocationMapViewRepresentable {
    
    class MapViewCoordinator: NSObject {
        
        let parent: SearchLocationMapViewRepresentable
        var mapView: MKMapView?
        var startPlace: String = ""
        private let completer = MKLocalSearchCompleter()
        var results: [MKLocalSearchCompletion] = [MKLocalSearchCompletion]()
//        var annotationItem: AnnotationItem?
        
        @Binding var annotationItem: AnnotationItem?
        
        var isChanging: Bool = false {
            didSet {
                setPin()
            }
        }
        
        init(parent: SearchLocationMapViewRepresentable, annotationItem: Binding<AnnotationItem?>) {
            self.parent = parent
            self._annotationItem = annotationItem // Use the passed binding here
            super.init()
            //            completer.delegate = self
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
        
        func setPin() {
            guard let mapView = self.mapView else { return }
            
            mapView.subviews.compactMap { $0 as? UIImageView }.forEach { $0.removeFromSuperview() }
            
            let imageView = UIImageView(image: SharedAsset.chooseSearchLocation.image)
            imageView.contentMode = .scaleAspectFit
            let imageViewSize: CGFloat = 62

            if isChanging {
                print("isChanging is true")
                imageView.frame = CGRect(x: UIScreen.main.bounds.width / 2 - 31, y: (mapView.frame.height) / 2 - 31 - 5, width: imageViewSize, height: imageViewSize)
                imageView.alpha = 0.3
            } else {
                print("isChanging is false")
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
        
//        mapView.setRegion(region, animated: true)
    }

    // 사용자가 지도를 움직이고 난 후
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("regionDidChangeAnimated in MKMapViewDelegate")

        isChanging = false
        
        let geocoder = CLGeocoder()
        let centerCoordinate = mapView.centerCoordinate
        let location = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if error != nil {
                return
            }

            guard let placemark = placemarks?.first else { return }
            
            self.annotationItem = AnnotationItem(title: "타이틀없음@", subTitle: (placemark.locality ?? "로컬티없음") + " " + (placemark.name ?? "이름없음"), latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        }
    }
}
