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


class LocalSearchViewModel: NSObject, ObservableObject {
    
    @Published var results: [MKLocalSearchCompletion] = [MKLocalSearchCompletion]()
    @Published var annotationItems: [MumoryModel] = [MumoryModel]()
    @Published var region: MKCoordinateRegion?
    @Published var coordinate2D : CLLocationCoordinate2D = .init()
    
    private let searchCompleter = MKLocalSearchCompleter()
    
    @Published var queryFragment: String = "" {
        didSet {
            searchCompleter.queryFragment = queryFragment
        }
    }
    
    var cancellable: AnyCancellable?
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        
        cancellable = $queryFragment
            .debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)
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
        
        let request = MKLocalSearch.Request()
//        request.naturalLanguageQuery = localSearchCompletion.subtitle
        request.naturalLanguageQuery = localSearchCompletion.subtitle.contains(localSearchCompletion.title) ? localSearchCompletion.subtitle : localSearchCompletion.title + " " + localSearchCompletion.subtitle
        
            Task {
                do {
                    let response = try await MKLocalSearch(request: request).start()                    
//                    print("response.mapItems.placemark: \(response.mapItems.first?.placemark.name)")
//                    print("response.mapItems.placemark: \(response.mapItems.first?.placemark.title)")
                    if let coordinate = response.mapItems.first?.placemark.coordinate {
                        print("response.mapItems.first is not nil")
                        self.region = MKCoordinateRegion(center: coordinate, span: MapConstant.defaultSpan)
                    } else {
                        print("response.mapItems.first is nil")
                        self.region = response.boundingRegion
                    }

                    completion(self.region)
                } catch {
                    print("Error getting region:", error.localizedDescription)
                    completion(nil)
                }
            }
        }
    
    func getRegion2(localSearchCompletion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request()
        let title = localSearchCompletion.title
        request.naturalLanguageQuery = title
//        let subTitle = localSearchCompletion.subtitle
            
//        request.naturalLanguageQuery = subTitle.contains(title) ? subTitle : title + ", " + subTitle
//        let search = MKLocalSearch(request: request)
        
//        print("getRegion: \(String(describing: request.naturalLanguageQuery))")
        
        Task {
            let response = try await MKLocalSearch(request: request).start()
            await MainActor.run {
                response.mapItems.map {
                    print("getRegion: \($0.placemark)")
//                    AnnotationItem(
//                        latitude: $0.placemark.coordinate.latitude,
//                        longitude: $0.placemark.coordinate.longitude
//                    )
                }
                
//                self.region = response.boundingRegion
//                print("getRegion: \(response.boundingRegion)")
            }
        }
        
    }
}

extension LocalSearchViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results

        print("results = \(self.results)")
        
        if !self.results.isEmpty {
            
//            self.results.map {
//                let searchRequest = MKLocalSearch.Request()
//                searchRequest.naturalLanguageQuery = $0.title
//                let localSearch = MKLocalSearch(request: searchRequest)
//                localSearch.start { (response, error) in
//                    guard let mapItems = response?.mapItems else {
//                        if let error = error {
//                            print("Error occurred in search: \(error.localizedDescription)")
//                        }
//                        return
//                    }
//
//                    // 검색된 장소들의 정보를 확인하고, 첫 번째 장소의 위치 정보를 출력합니다.
//                    if let firstMapItem = mapItems.first {
//                        let placemark = firstMapItem.placemark
//                        let coordinate = placemark.coordinate
//                        let latitude = coordinate.latitude
//                        let longitude = coordinate.longitude
//
//                        print("장소명: \(placemark.name ?? "")")
//                        print("주소: \(placemark.title ?? "")")
//                        print("위도: \(latitude), 경도: \(longitude)")
//                    }
//                }
//                self.annotationItems.append(AnnotationItem(title: $0.title, subTitle: $0.subtitle, latitude: , longitude: <#T##Double#>))

//            }
//            // 여기서 각각의 결과에 대한 처리를 하고 AnnotationItem을 생성
//            for result in self.results {
//                let title = result.title
//                let subTitle = result.subtitle
//                getRegion(localSearchCompletion: result) { coordinate in
//                    guard let latitude = coordinate?.latitude, let longitude = coordinate?.longitude else { return }
//                    self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
//                    let annotationItem = AnnotationItem(
//                        title: title,
//                        subTitle: subTitle,
//                        latitude: latitude,
//                        longitude: longitude
//                    )
//                    self.annotationItems.append(annotationItem)
//                }
//            }
        }
        
//        if !self.results.isEmpty {
//            print("result.title = \(self.results[0].title)")
//            print("result.subtitle = \(self.results[0].subtitle)")
//            getRegion(localSearchCompletion: self.results[0])
//        }
//
//        let request = MKLocalSearch.Request()
//
//        self.annotationItems = self.results.map {
//            let title = $0.title
//            request.naturalLanguageQuery = title
//            Task {
//                let response = try await MKLocalSearch(request: request).start()
//                await MainActor.run {
//                    response.mapItems.map {
//                    }
//                }
//                AnnotationItem(title: $0.title, subTitle: $0.subtitle, latitude: , longitude: <#T##Double#>)
//            }
//        }
    }
}
