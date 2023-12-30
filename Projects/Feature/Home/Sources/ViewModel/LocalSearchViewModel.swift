//
//  LocalSearchViewModel.swift
//  Feature
//
//  Created by 다솔 on 2023/12/13.
//  Copyright © 2023 hollys. All rights reserved.
//


import Foundation
import Combine
import MapKit
import Shared
import Core


public class LocalSearchViewModel: NSObject, ObservableObject {
    
    @Published var results: [MKLocalSearchCompletion] = [MKLocalSearchCompletion]()
    @Published var queryFragment: String = "" {
        didSet {
            searchCompleter.queryFragment = queryFragment
        }
    }
    
    private let searchCompleter = MKLocalSearchCompleter()
    
    var cancellable: AnyCancellable?
    
    private let locationManager = CLLocationManager()
    
    public override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        searchCompleter.delegate = self
//        searchCompleter.region = MKCoordinateRegion(MKMapRect.world)
        
        cancellable = $queryFragment
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { value in
                self.searchAddress(value)
            })
    }
    
    func searchAddress(_ queryFragment: String) {
        if queryFragment.isEmpty {
            results = []
        } else {
            searchCompleter.queryFragment = queryFragment
        }
    }
    
    func getRegion(localSearchCompletion: MKLocalSearchCompletion, completion: @escaping (MKCoordinateRegion?) -> Void) {
        let request = MKLocalSearch.Request(completion: localSearchCompletion)
        
        Task {
            do {
                let response = try await MKLocalSearch(request: request).start()
                if let coordinate = response.mapItems.first?.placemark.coordinate {
                    print("response.mapItems.first is not nil")
                    let region = MKCoordinateRegion(center: coordinate, span: MapConstant.defaultSpan)
                    completion(region)
                } else {
                    print("response.mapItems.first is nil")
                    let region = response.boundingRegion
                    completion(region)
                }
            } catch {
                print("Error getting region:", error.localizedDescription)
                completion(nil)
            }
        }
    }
}

extension LocalSearchViewModel: MKLocalSearchCompleterDelegate {
    public func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
        
        print("results = \(self.results)")
    }
}

extension LocalSearchViewModel: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//            if let userLocation = locations.first?.coordinate {
//                print("userLocation is not nil")
//                // 사용자의 위치가 업데이트되면 해당 위치를 기반으로 region 설정
//                searchCompleter.region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//            }
        }
        
        // CLLocationManagerDelegate에서 권한 변경 처리
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            if manager.authorizationStatus == .authorizedWhenInUse {
                locationManager.startUpdatingLocation() // 권한이 승인되면 위치 업데이트 시작
            }
        }
}
