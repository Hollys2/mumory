//
//  LocationManager.swift
//  Core
//
//  Created by 다솔 on 2023/11/14.
//  Copyright © 2023 hollys. All rights reserved.
//


import CoreLocation
import MapKit
import Combine
import Shared


final public class LocationManager: NSObject, ObservableObject {
    
    //    var startPlace: String = ""
    
    @Published public var mapView: MKMapView = .init()
    @Published public var locationManager: CLLocationManager = .init()
    
    @Published public var choosedLocation: AnnotationItem?
    @Published public var choosedPlaceMark: CLPlacemark?
    
    @Published public var userLocation: CLLocation?
    
    @Published public var tappedLocation: CLLocationCoordinate2D?
    
    @Published public var isChanging: Bool = false // 지도의 움직임 여부를 저장하는 프로퍼티
    @Published var currentPlace: String = "" // 현재 위치의 도로명 주소를 저장하는 프로퍼티
    
    @Published public var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37, longitude: -121), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    
    override public init() {
        print("override public init in LocationManager")
        super.init()
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    public func checkLocationServices() {
        //        if CLLocationManager.locationServicesEnabled() {
        ////            locationManager.delegate = self
        //        } else {
        //            print("CLLocationManager.locationServicesEnabled() is false")
        //        }
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
            //            locationManager.startUpdatingLocation()
        case .authorizedWhenInUse:
            print(".authorizedWhenInUse")
            //            locationManager.startUpdatingLocation()
            region = MKCoordinateRegion(center: locationManager.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            
            break
        @unknown default:
            break
        }
    }
    
    public func convertLocationToAddress(location: CLLocation) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.last, error == nil else { return }
            
            let address = placemark.description ?? ""
            let latitude = placemark.location?.coordinate.latitude ?? 0.0
            let longitude = placemark.location?.coordinate.longitude ?? 0.0
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = placemark.name
            let search = MKLocalSearch(request: request)
            search.start { response, error in
                guard let response = response, error == nil else {
                    print("Error searching for places at this address:", error?.localizedDescription ?? "Unknown error")
                    return
                }
                for item in response.mapItems {
                    print("Place Name:", item.name ?? "")
                    print("Place title:", item.placemark.title ?? "")
                    print("Place Coordinate:", item.placemark.coordinate.latitude, item.placemark.coordinate.longitude)
                    
                    let address = item.placemark.title ?? ""
                    let separated = address.components(separatedBy: " ")
                    let result = separated.dropFirst().joined(separator: " ")

                    self.choosedLocation = AnnotationItem(title: item.name ?? "", subTitle: result, latitude: item.placemark.coordinate.latitude , longitude: item.placemark.coordinate.longitude)
                }
                
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    // 현재 위치
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations in CLLocationManagerDelegate")
        guard let location = locations.last else { return }
        
        self.userLocation = location
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func handleLocationManagerDidChangeAuthorizationError() {
        
    }
}

//extension LocationManager: MKMapViewDelegate {
//
//    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        print("didUpdate in MKMapViewDelegate")
//        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
//
//        self.mapView.setRegion(region, animated: true)
//    }
//
//    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
//        //        print("regionWillChangeAnimated in MKMapViewDelegate")
//    }
//
//    public func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
////        print("mapViewDidChangeVisibleRegion in MKMapViewDelegate")
//        DispatchQueue.main.async {
//            self.isChanging = true
//            self.objectWillChange.send()
//            print("self.isChanging: \(self.isChanging)")
//        }
//
//        let imageSize: CGFloat = 50 // 이미지의 크기
//        let imageOriginX = (mapView.bounds.width - imageSize) / 2 // 이미지의 x 축 위치
//        let imageOriginY = (mapView.bounds.height - imageSize) / 2 // 이미지의 y 축 위치
//        let imageView = UIImageView(frame: CGRect(x: imageOriginX,
//                                                  y: imageOriginY,
//                                                  width: imageSize,
//                                                  height: imageSize))
//
//        imageView.image = SharedAsset.addressSearchLocation.image
//        mapView.addSubview(imageView) // 맵뷰에 이미지 뷰를 추가합니다
//    }
//
//    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        let location: CLLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
//
//        self.convertLocationToAddress(location: location)
//        //        print("self.startPlace: \(self.startPlace)")
//
//        DispatchQueue.main.async {
//            self.isChanging = false
//            self.objectWillChange.send()
//            print("self.isChanging: \(self.isChanging)")
//        }
//
//        let centerCoordinate = mapView.centerCoordinate
//
//        // 이미지 뷰를 생성합니다.
//        let imageSize: CGFloat = 50 // 이미지의 크기
//        let imageOriginX = (mapView.bounds.width - imageSize) / 2 // 이미지의 x 축 위치
//        let imageOriginY = (mapView.bounds.height - imageSize) / 2 // 이미지의 y 축 위치
//        let imageView = UIImageView(frame: CGRect(x: imageOriginX,
//                                                  y: imageOriginY,
//                                                  width: imageSize,
//                                                  height: imageSize))
//
////        imageView.image = SharedAsset.chooseSearchLocation.image // 이미지 뷰에 이미지를 설정합니다.
//
//        if isChanging {
//                  imageView.image = SharedAsset.chooseSearchLocation.image
//              } else {
//                  imageView.image = SharedAsset.addressSearchLocation.image
//              }
//        mapView.addSubview(imageView) // 맵뷰에 이미지 뷰를 추가합니다
//    }
//
//    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
////        let identifier = "CustomPinAnnotationView"
////        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKAnnotationView
////
////        if annotationView == nil {
////            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
////        } else {
////            annotationView?.annotation = annotation
////        }
////
////        // Set your custom image for the annotation view
////        annotationView?.image = SharedAsset.chooseSearchLocation.image
////        annotationView?.centerOffset = CGPoint(x: 0, y: -annotationView!.frame.size.height / 2)
////
////        return annotationView
////
////        if annotation is MKUserLocation {
////            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
////            let image = SharedAsset.userLocation.image.resized(to: CGSize(width: 45, height: 45))
////            annotationView.image = image
////            return annotationView
////        }
//                return nil
//    }
//
//    //    func configureLocationManager() {
//    //        mapView?.delegate = self
//    //        locationManager.delegate = self
//    //
//    //        let status = locationManager.authorizationStatus
//    //
//    //        if status == .notDetermined {
//    //            locationManager.requestAlwaysAuthorization()
//    //        } else if status == .authorizedAlways || status == .authorizedWhenInUse {
//    //            mapView?.showsUserLocation = true // 사용자의 현재 위치를 확인할 수 있도록
//    //        }
//    //    }
//
//
//    public func convertLocationToAddress(location: CLLocation) {
//        let geocoder = CLGeocoder()
//
//        geocoder.reverseGeocodeLocation(location) { placemarks, error in
//            if error != nil {
//                return
//            }
//
//            guard let placemark = placemarks?.last else { return }
//            self.startPlace = "\(placemark.locality ?? "") \(placemark.name ?? "") \(placemark.thoroughfare)"
//
////            print("name: \(placemark.name)")
////            print("thoroughfare: \(placemark.thoroughfare)")
////            print("subThoroughfare: \(placemark.subThoroughfare)")
////            print("locality: \(placemark.locality)")
////            print("subLocality: \(placemark.subLocality)")
////            print("administrativeArea: \(placemark.administrativeArea)")
//
//            let request = MKLocalSearch.Request()
//            request.naturalLanguageQuery = placemark.name
//            let search = MKLocalSearch(request: request)
//                search.start { response, error in
//                    guard let response = response, error == nil else {
//                        print("Error searching for places at this address:", error?.localizedDescription ?? "Unknown error")
//                        return
//                        return
//                    }
//
//                    // Handle the search results
//                    for item in response.mapItems {
//                        print("Place Name:", item.name ?? "")
//                        print("Place Address:", item.placemark.title ?? "")
//                        print("Place item.placemark:", item.placemark ?? "")
//                        print("Place Coordinate:", item.placemark.coordinate.latitude, item.placemark.coordinate.longitude)
//                        // Access more details or properties of the found places as needed
////                        self.address = item.placemark.title ?? ""
//                    }
//
//                }
//        }
//    }
//}

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
