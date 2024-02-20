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
    
    @Binding var locationModel: LocationModel
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var locationManager: LocationManager
    
    func makeUIView(context: Context) -> UIViewType {
        let mapView: MKMapView = .init()

        mapView.mapType = .mutedStandard
        mapView.showsCompass = false
        mapView.isPitchEnabled = false
        mapView.showsUserLocation = true
//        mapView.userTrackingMode = .follow 권한 동의 후에
        
        mapView.setRegion(MKCoordinateRegion(center: MapConstant.defaultCoordinate2D, span: MapConstant.defaultSpan), animated: true)
        
        if let currentLocation: CLLocation = locationManager.currentLocation {
            mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude), span: MapConstant.defaultSpan), animated: true)
        }
        
        context.coordinator.mapView = mapView
        context.coordinator.setGPSButton()
        context.coordinator.setCompassButton()
        context.coordinator.setPin()
        mapView.overrideUserInterfaceStyle = .light // 라이트 테마
        
        mapView.delegate = context.coordinator
        
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(parent: self)
    }
}

extension SearchLocationMapViewRepresentable {
    
    class MapViewCoordinator: NSObject {
        
        let parent: SearchLocationMapViewRepresentable
        
        var mapView: MKMapView?
        var isChanging: Bool = false {
            didSet {
                setPin()
            }
        }
                
        init(parent: SearchLocationMapViewRepresentable) {
            self.parent = parent
            super.init()
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
//        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
//        
//        mapView.setRegion(region, animated: true)
    }

    // 사용자가 지도를 움직이고 난 후
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.isChanging = false
        
        let centerCoordinate = mapView.centerCoordinate
        let location = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)

        parent.mumoryDataViewModel.getChoosedeMumoryModelLocation(location: location) { model in
            self.parent.locationModel = model
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKUserLocation else { return nil }
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "UserLocationAnnotation") ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "UserLocationAnnotation")
        
        annotationView.image = SharedAsset.userLocation.image
        annotationView.frame = CGRect(x: 0, y: 0, width: 47, height: 47)

        
//        if let image = annotationView.image {
//            annotationView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
//        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("didSelect")
//        mapView.deselectAnnotation(view.annotation, animated: false)
    }


}
