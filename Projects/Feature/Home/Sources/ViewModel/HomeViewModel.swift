//
//  HomeViewModel.swift
//  Feature
//
//  Created by 다솔 on 2023/11/08.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import MapKit
import Shared

//enum MapDetails {
//    static let startingLocation = CLLocationCoordinate2D(latitude: 37.50039, longitude: 127.0270)
//    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
//}

final class HomeViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var region = MKCoordinateRegion(
        center: MapConstant.defaultCoordinate2D,
        span: MapConstant.defaultSpan
    )
    
    func updateRegion(_ newRegion: MKCoordinateRegion) {
           DispatchQueue.main.async {
               self.region = newRegion
           }
       }
    
    let locationManager = CLLocationManager() // 위치 서비스
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestAllowOnceLocationPermission() {
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else {
            return
        }
        
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(center: latestLocation.coordinate, span: MapConstant.defaultSpan)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError: \(error.localizedDescription)")
    }
//
//    func checkIfLocationServiceIsEnabled() {
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager = CLLocationManager()
////            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
//            locationManager!.delegate = self
//
////            checkLocationAuthorization()
//        } else {
//            print("checkIfLocationServiceIsEnabled: false")
//        }
//    }
//
//    private func checkLocationAuthorization() {
//        guard let locationManager = locationManager else { return }
//
//        switch locationManager.authorizationStatus {
//
//        case .notDetermined:
//            locationManager.requestWhenInUseAuthorization()
//        case .restricted:
//            print("checkLocationAuthorization: .restricted")
//        case .denied:
//            print("checkLocationAuthorization: .denied")
//        case .authorizedAlways, .authorizedWhenInUse:
//            if let location = locationManager.location {
//                region = MKCoordinateRegion(center: location.coordinate, span: MapDetails.defaultSpan)
//            }
//        @unknown default:
//            break
//        }
//    }
//
//    // MARK: - Delegate
////    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
////        <#code#>
////    }
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        checkLocationAuthorization()
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.last {
//            region = MKCoordinateRegion(center: location.coordinate, span: MapDetails.defaultSpan)
//        }
//    }
}
