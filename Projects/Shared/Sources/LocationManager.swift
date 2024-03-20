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
            promptForLocationSettings()
        case .denied:
            print(".denied")
            promptForLocationSettings()
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
    
    public func promptForLocationSettings() {
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
          UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
      }
}
