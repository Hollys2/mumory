//
//  LocationManager.swift
//  Core
//
//  Created by 다솔 on 2023/11/14.
//  Copyright © 2023 hollys. All rights reserved.
//

import CoreLocation

final public class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published public var userLocation: CLLocationCoordinate2D?
    
    override public init() {
        print("override public init in LocationManager")
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if userLocation != nil { return }
        guard let location = locations.last else { return }
        
        userLocation = location.coordinate
        print("Updated location: \(location)")
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            // 위치 서비스 권한이 허용된 경우 위치 업데이트 시작
            locationManager.startUpdatingLocation()
        } else if manager.authorizationStatus == .notDetermined {
            // 위치 서비스 권한 상태가 결정되지 않은 경우 권한 요청
            locationManager.requestWhenInUseAuthorization()
        }
    }
}
