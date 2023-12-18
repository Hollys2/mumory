//
//  MapViewModel.swift
//  Feature
//
//  Created by 다솔 on 2023/11/30.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import MapKit
import Shared

class ContentViewModel: NSObject, ObservableObject {
    
    @Published private(set) var results: Array<AddressResult> = []
    @Published var searchableText = ""

    private lazy var localSearchCompleter: MKLocalSearchCompleter = {
        let completer = MKLocalSearchCompleter()
        completer.delegate = self
        return completer
    }()
    
    func searchAddress(_ searchableText: String) {
        guard searchableText.isEmpty == false else { return }
        localSearchCompleter.queryFragment = searchableText
    }
}

extension ContentViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
            results = completer.results.map {
                AddressResult(title: $0.title, subtitle: $0.subtitle)
            }
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error)
    }
}



class MapViewModel: ObservableObject {

    @Published var address: String = ""
    @Published var region = MKCoordinateRegion()
    @Published private(set) var annotationItems: [AnnotationItem] = []
    
    init() {
//        self.address = address
//        self.region = region
//        self.annotationItems = annotationItems
    }
    
    func getRegion(localSearchCompletion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request()
        let title = localSearchCompletion.title
        let subTitle = localSearchCompletion.subtitle
            
        request.naturalLanguageQuery = subTitle.contains(title) ? subTitle : title + ", " + subTitle
        
        print("getRegion: \(String(describing: request.naturalLanguageQuery))")
        
        Task {
            let response = try await MKLocalSearch(request: request).start()
            await MainActor.run {
//                self.annotationItems = response.mapItems.map {
//                    AnnotationItem(
//                        latitude: $0.placemark.coordinate.latitude,
//                        longitude: $0.placemark.coordinate.longitude
//                    )
//                }
                
                self.region = response.boundingRegion
            }
        }
    }
    
    func getPlace(from address: AddressResult) {
        let request = MKLocalSearch.Request()
        let title = address.title
        let subTitle = address.subtitle
            
        request.naturalLanguageQuery = subTitle.contains(title)
        ? subTitle : title + ", " + subTitle
        
        print("getPlace: \(String(describing: request.naturalLanguageQuery))")
        
        Task {
            let response = try await MKLocalSearch(request: request).start()
            await MainActor.run {
//                self.annotationItems = response.mapItems.map {
//                    AnnotationItem(
//                        latitude: $0.placemark.coordinate.latitude,
//                        longitude: $0.placemark.coordinate.longitude
//                    )
//                }
                
                self.region = response.boundingRegion
            }
        }
    }
}
