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
    
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var locationManager: LocationManager
    
    func makeUIView(context: Context) -> UIViewType {
        print("@@makeUIView")

        let mapView: MKMapView = .init()

        mapView.mapType = .mutedStandard
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.isPitchEnabled = false
//        mapView.userTrackingMode = .follow 권한 동의 후에
        
        mapView.setRegion(MKCoordinateRegion(center: MapConstant.defaultCoordinate2D, span: MapConstant.defaultSpan), animated: true)
        
        if let currentLocation = locationManager.currentLocation {
            mapView.setRegion(MKCoordinateRegion(center: currentLocation.coordinate, span: MapConstant.defaultSpan), animated: true)
        }
        
        context.coordinator.mapView = mapView
        context.coordinator.setGPSButton()
        context.coordinator.setCompassButton()
        
        mapView.delegate = context.coordinator
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tappedMap))
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
//        uiView.removeAnnotations(uiView.annotations)
        
        for annotation in mumoryDataViewModel.mumoryAnnotations {
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
        
        init(parent: HomeMapViewRepresentable) {
            self.parent = parent
            super.init()
        }
        
        @objc func tappedMap(sender: UITapGestureRecognizer) {
            guard let mapView = self.mapView else { return }
            
            if !parent.annotationSelected {
                print("탭맵")
                if let selectedAnnotation = mapView.selectedAnnotations.first {
                    mapView.deselectAnnotation(selectedAnnotation, animated: false)
                }
            }
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
    
    // 사용자의 현재 위치가 변할 때
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        print("didUpdate in MKMapViewDelegate")
        
//        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
//
//        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "MumoryAnnotation") ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "MumoryAnnotation")
        
        if annotation is MumoryAnnotation {
            annotationView.image = SharedAsset.musicPin.image
            annotationView.frame = CGRect(x: 0, y: 0, width: 74, height: 81)
            
            let artwork = AsyncImageView()
            artwork.frame = CGRect(x: 6.74, y: 6.74, width: 60.65238, height: 60.65238)
            artwork.layer.cornerRadius = 12
            artwork.clipsToBounds = true
            
//            if let url = parent.mumoryDataViewModel.createdMumoryAnnotation?.musicModel.artworkUrl {
//                artwork.loadImage(from: url)
//                annotationView.addSubview(artwork)
//            } else {
//                print("ERROR: NO URL")
//            }
            
            for i in parent.mumoryDataViewModel.mumoryAnnotations {
                if let url = i.musicModel.artworkUrl {
                    artwork.loadImage(from: url)
                    annotationView.addSubview(artwork)
                } else {
                    print("ERROR: NO URL222")
                }
            }
            
            
        } else if annotation is MKUserLocation {
            annotationView.image = SharedAsset.userLocation.image
            if let image = annotationView.image {
                annotationView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            }
        }
//        annotationView.canShowCallout = false
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        print("didSelect")
        if annotation is MumoryAnnotation {
            self.parent.annotationSelected = true
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("didDeselect")
        self.parent.annotationSelected = false
    }
}

class AsyncImageView: UIImageView {
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                }
            }
        }.resume()
    }
}
