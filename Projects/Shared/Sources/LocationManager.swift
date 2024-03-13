//
//  LocationManager.swift
//  Core
//
//  Created by 다솔 on 2023/11/14.
//  Copyright © 2023 hollys. All rights reserved.
//


import CoreLocation
import Combine


// 1. 권한
// 2. 현재 위치
final public class LocationManager: NSObject, ObservableObject {
    
    @Published public var currentLocation: CLLocation?
    
    private let locationManager: CLLocationManager = .init()
    
    override public init() {
        super.init()
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        print("init LocationManager")
    }
}

extension LocationManager: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
//        guard currentLocation == nil, let location = locations.last else { return }
        
        self.currentLocation = location
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            print(".notDetermined")
            manager.requestWhenInUseAuthorization()
        case .restricted:
            print(".restricted")
        case .denied:
            print(".denied")
        case .authorizedAlways:
            print(".authorizedAlways")
            manager.startUpdatingLocation()
        case .authorizedWhenInUse:
            print(".authorizedWhenInUse")
            manager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError in CLLocationManagerDelegate: \(error)")
    }
}
