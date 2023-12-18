//
//  HomeMapView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/17.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import MapKit
import Core
import Shared

struct HomeMapViewRepresentable: UIViewRepresentable {
    
    typealias UIViewType = MKMapView
    
//    @Binding var annotationItems: [AnnotationItem]
    
    @ObservedObject var locationManager: LocationManager2 = .init()
    
    func makeUIView(context: Context) -> UIViewType {
        print("@@makeUIView")

        let mapView: MKMapView = .init()

        mapView.mapType = .mutedStandard
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.isPitchEnabled = false
//        mapView.userTrackingMode = .follow 권한 동의 후에
        mapView.setRegion(MKCoordinateRegion(center: MapConstant.defaultCoordinate2D, span: MapConstant.defaultSpan), animated: true)
        
        context.coordinator.mapView = mapView
        context.coordinator.setGPSButton()
        context.coordinator.setCompassButton()
        
        mapView.delegate = context.coordinator
        
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        //        print("@@updateUIView")
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(parent: self)
    }
}

extension HomeMapViewRepresentable {
    
    class MapViewCoordinator: NSObject {
        
        let parent: HomeMapViewRepresentable
        var mapView: MKMapView?
        var startPlace: String = ""
        private let completer = MKLocalSearchCompleter()
        var results: [MKLocalSearchCompletion] = [MKLocalSearchCompletion]()
        var annotationItem: AnnotationItem?
        
        init(parent: HomeMapViewRepresentable) {
            self.parent = parent
            super.init()
//            completer.delegate = self
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
        
        func getAddressFromLocation(latitude: Double, longitude: Double) {
            let location = CLLocation(latitude: latitude, longitude: longitude)
            let geocoder = CLGeocoder()
            
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                guard let placemark = placemarks?.first, error == nil else {
                    print("Error retrieving location information:", error?.localizedDescription ?? "Unknown error")
                    return
                }
                
                // Access various properties of the placemark
                if let name = placemark.name {
                    print("Name:", name)
                }
                
                if let thoroughfare = placemark.thoroughfare {
                    print("Thoroughfare:", thoroughfare)
                }
                
                if let subThoroughfare = placemark.subThoroughfare {
                    print("SubThoroughfare:", subThoroughfare)
                }
                
                if let locality = placemark.locality {
                    print("Locality:", locality)
                }
                
                // Access more properties as needed
                // For a full address, use placemark's properties such as thoroughfare, subThoroughfare, locality, administrativeArea, etc.
                let address = "\(placemark.thoroughfare ?? ""), \(placemark.subThoroughfare ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.country ?? "")"
                print("Address:", address)
            }
        }
        
        func convertLocationToAddress(location: CLLocation) {
            let geocoder = CLGeocoder()
            
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if error != nil {
                    return
                }
                
                guard let placemark = placemarks?.first else { return }
                
                self.startPlace = "\(placemark.country ?? "") \(placemark.locality ?? "") \(placemark.name ?? "")"
            }
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
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
    }
    
    // 사용자의 현재 위치가 변할 때
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("didUpdate in MKMapViewDelegate")
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))

//        mapView.setRegion(region, animated: true)
    }
    
    // 사용자가 지도를 움직일 때
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("regionDidChangeAnimated in MKMapViewDelegate")
        
        let geocoder = CLGeocoder()
        let centerCoordinate = mapView.centerCoordinate
        let location = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if error != nil {
                return
            }
            
            guard let placemark = placemarks?.first else { return }
            
//            print("addressDictionary: \(placemark.addressDictionary)")
            
            self.annotationItem = AnnotationItem(title: "타이틀없음", subTitle: (placemark.locality ?? "로컬티없음") + " " + (placemark.name ?? "이름없음"), latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        }
    }

    func searchNearbyPlaces(at coordinate: CLLocationCoordinate2D) {
        let request = MKLocalSearch.Request()
        request.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        request.naturalLanguageQuery = "할리스"
        Task {
            let response = try await MKLocalSearch(request: request).start()
            await MainActor.run {
                response.mapItems.map {
                    print("searchNearbyPlaces: \($0)")
                    //                    AnnotationItem(
                    //                        latitude: $0.placemark.coordinate.latitude,
                    //                        longitude: $0.placemark.coordinate.longitude
                    //                    )
                }
            }
        }
//        Task {
//            do {
//                let response = try await MKLocalSearch(request: request).start()
//                let name = response.mapItems.first?.placemark.name
//                let title = response.mapItems.first?.placemark.title
//                let coordinate = response.mapItems.first?.placemark.coordinate
//                print("name: \(name)")
//                print("title: \(title)")
//                print("coordinate: \(coordinate)")
//
//            } catch {
//                print("Error getting region:", error.localizedDescription)
//
//            }
//        }
        
//        let search = MKLocalSearch(request: request)
//        search.start { response, error in
//            guard error == nil else {
//                print("Error searching: \(error!.localizedDescription)")
//                return
//            }
//
//            guard let mapItems = response?.mapItems else {
//                print("No results found.")
//                return
//            }
//
//            // 검색 결과 처리
//            for item in mapItems {
//                print("Place: \(item.name ?? ""), Location: \(item.placemark.coordinate.latitude), \(item.placemark.coordinate.longitude)")
//                // 여기서 가져온 정보를 원하는 방식으로 활용할 수 있습니다.
//            }
//        }
    }

}

extension HomeMapViewRepresentable.MapViewCoordinator: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        print("completerDidUpdateResults in MKLocalSearchCompleterDelegate, HomeMapViewRepresentable.MapViewCoordinator")
        self.results = completer.results
    }
}
//
//    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
////        print("regionWillChangeAnimated in MKMapViewDelegate")
//    }
//
//    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
//        //        print("mapViewDidChangeVisibleRegion in MKMapViewDelegate")
//        DispatchQueue.main.async {
//            self.isChanging = true
//        }
//    }
//
//    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//
//        let location: CLLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
////        print("regionDidChangeAnimated in MKMapViewDelegate: \(location)")
//
//        self.convertLocationToAddress(location: location)
//        print("self.startPlace: \(self.startPlace)")
//
//        DispatchQueue.main.async {
//            self.isChanging = false
//        }
//    }
//
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if annotation is MKUserLocation {
//            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
//            let image = SharedAsset.userLocation.image.resized(to: CGSize(width: 45, height: 45))
//            annotationView.image = image
//            return annotationView
//        }
//        return nil
//    }
//}


class LocationManager2: NSObject, ObservableObject {
    
    private let locationManager: CLLocationManager = .init()
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
}

extension LocationManager2: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("didUpdateLocations in CLLocationManagerDelegate")
//        guard !locations.isEmpty else { return }
//        print("didUpdateLocations : \(locations.first)")
//        locationManager.stopUpdatingLocation()
//    }
}
