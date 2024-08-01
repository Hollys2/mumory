//
//  LocationManager.swift
//  Core
//
//  Created by 다솔 on 2023/11/14.
//  Copyright © 2023 hollys. All rights reserved.
//


import CoreLocation
import Combine
import UIKit


// 1. 권한
// 2. 현재 위치
final public class LocationManagerViewModel: NSObject {
    
//    @Published public var currentLocation: CLLocation?
    public var currentLocation: CLLocation?
    
    private let locationManager: CLLocationManager = .init()
    
    override public init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    public static func promptForLocationSettings() {
        let alertController = UIAlertController(
            title: "위치 권한 필요",
            message: "이 기능을 사용하기 위해서는 위치 권한이 필요합니다. 설정으로 이동하여 권한을 허용해 주세요.",
            preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "설정으로 이동", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    // 설정 앱이 열림
                })
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .destructive, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        // 현재 뷰 컨트롤러에서 경고창 표시 (예시)
        //        UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alertController, animated: true, completion: nil)
        } else {
            print("No active window scene found")
        }
    }
    
    public static func checkLocationAuthorizationStatus() -> Bool {
        switch CLLocationManager().authorizationStatus {
        case .notDetermined:
            CLLocationManager().requestWhenInUseAuthorization()
            return false
        case .restricted, .denied:
            LocationManagerViewModel.promptForLocationSettings()
            return false
        case .authorizedAlways, .authorizedWhenInUse:
            CLLocationManager().startUpdatingLocation()
            return true
        @unknown default:
            return false
        }
    }
}

extension LocationManagerViewModel: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.currentLocation = location
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            print("locationManagerDidChangeAuthorization: .notDetermined")
            manager.requestWhenInUseAuthorization()
        case .restricted:
            print("locationManagerDidChangeAuthorization: .restricted")
            LocationManagerViewModel.promptForLocationSettings()
        case .denied:
            print("locationManagerDidChangeAuthorization: .denied")
            LocationManagerViewModel.promptForLocationSettings()
        case .authorizedAlways:
            print("locationManagerDidChangeAuthorization: .authorizedAlways")
            manager.startUpdatingLocation()
        case .authorizedWhenInUse:
            print("locationManagerDidChangeAuthorization: .authorizedWhenInUse")
            manager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError in CLLocationManagerDelegate: \(error)")
    }
}
