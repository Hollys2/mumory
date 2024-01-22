//
//  LocationManager.swift
//  Core
//
//  Created by 다솔 on 2023/11/14.
//  Copyright © 2023 hollys. All rights reserved.
//


import CoreLocation
import MapKit
import MusicKit
import Combine


// 1. 권한
// 2. 현재 위치
final public class LocationManager: NSObject, ObservableObject {
    
    @Published public var locationManager: CLLocationManager = .init()
    @Published public var currentLocation: CLLocation?
    
    override public init() {
        print("override public init in LocationManager")
        super.init()
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            print(".notDetermined")
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print(".restricted")
        case .denied:
            print(".denied")
        case .authorizedAlways:
            print(".authorizedAlways")
            locationManager.startUpdatingLocation()
        case .authorizedWhenInUse:
            print(".authorizedWhenInUse")
            locationManager.startUpdatingLocation()
            
            break
        @unknown default:
            break
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    // 현재 위치
//    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("didUpdateLocations in CLLocationManagerDelegate")
//        guard let location = locations.last else { return }
//        
//        self.currentLocation = location
//    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError in CLLocationManagerDelegate")
    }
    
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("locationManagerDidChangeAuthorization in LocationManager")
        checkLocationAuthorization() // 있어야 권한 확인함
    }
    
    func handleLocationManagerDidChangeAuthorizationError() {
        
    }
}
