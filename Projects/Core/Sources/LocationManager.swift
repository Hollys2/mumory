//
//  LocationManager.swift
//  Core
//
//  Created by 다솔 on 2023/11/14.
//  Copyright © 2023 hollys. All rights reserved.
//


import CoreLocation
import MapKit
import Shared

final public class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    var startPlace: String = ""
    @Published public var userLocation: CLLocationCoordinate2D?
    var mapView: MKMapView?
    @Published var isChanging: Bool = false // 지도의 움직임 여부를 저장하는 프로퍼티
    @Published var currentPlace: String = "" // 현재 위치의 도로명 주소를 저장하는 프로퍼티
    
    override public init() {
        //        print("override public init in LocationManager")
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        //        self.configureLocationManager()
    }
    
    public func setMapView(_ mapView: MKMapView) {
        self.mapView = mapView
        self.mapView?.delegate = self // delegate 설정
        //       configureLocationManager()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if userLocation != nil { return }
        guard let location = locations.last else { return }
        
        userLocation = location.coordinate
        //        print("locationManager didUpdateLocations: \(location)")
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

extension LocationManager: MKMapViewDelegate {
    
    
    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        //        print("regionWillChangeAnimated in MKMapViewDelegate")
    }
    
    public func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        //                print("mapViewDidChangeVisibleRegion in MKMapViewDelegate")
        DispatchQueue.main.async {
            self.isChanging = true
        }
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let location: CLLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        //        print("regionDidChangeAnimated in MKMapViewDelegate: \(location)")
        
        self.convertLocationToAddress(location: location)
        print("self.startPlace: \(self.startPlace)")
        
        DispatchQueue.main.async {
            self.isChanging = false
        }
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            let image = SharedAsset.userLocation.image.resized(to: CGSize(width: 45, height: 45))
            annotationView.image = image
            return annotationView
        }
        return nil
    }
    
//    func configureLocationManager() {
//        mapView?.delegate = self
//        locationManager.delegate = self
//
//        let status = locationManager.authorizationStatus
//
//        if status == .notDetermined {
//            locationManager.requestAlwaysAuthorization()
//        } else if status == .authorizedAlways || status == .authorizedWhenInUse {
//            mapView?.showsUserLocation = true // 사용자의 현재 위치를 확인할 수 있도록
//        }
//    }
    
    
    func convertLocationToAddress(location: CLLocation) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if error != nil {
                return
            }
            
            guard let placemark = placemarks?.first else { return }
            self.startPlace = "\(placemark.locality ?? "") \(placemark.name ?? "")"
        }
    }
}

//open var name: String? { get } // eg. Apple Inc.
//
//open var thoroughfare: String? { get } // street name, eg. Infinite Loop
//
//open var subThoroughfare: String? { get } // eg. 1
//
//open var locality: String? { get } // city, eg. Cupertino
//
//open var subLocality: String? { get } // neighborhood, common name, eg. Mission District
//
//open var administrativeArea: String? { get } // state, eg. CA
//
//open var subAdministrativeArea: String? { get } // county, eg. Santa Clara
