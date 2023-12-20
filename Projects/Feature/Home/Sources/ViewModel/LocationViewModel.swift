//
//  LocationViewModel.swift
//  Feature
//
//  Created by 다솔 on 2023/11/30.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import MapKit
import Shared


public class LocationViewModel: NSObject, ObservableObject {
    
    @Published var choosedMumoryModel: MumoryModel?
    
    func chooseMumoryModelLocation(location: CLLocation) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.last, error == nil else { return }
            
//            let address = placemark.description
//            let latitude = placemark.location?.coordinate.latitude ?? 0.0
//            let longitude = placemark.location?.coordinate.longitude ?? 0.0
            
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
                    
                    self.choosedMumoryModel = MumoryModel(locationTitle: item.name ?? "", locationSubtitle: result, coordinate: CLLocationCoordinate2D(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude))
                }
                
            }
        }
    }
}


class ContentViewModel: NSObject, ObservableObject {
    
    //    @Published private(set) var results: Array<AddressResult> = []
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
            //            results = completer.results.map { _ in
            //                AddressResult(title: $0.title, subtitle: $0.subtitle)
            //            }
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error)
    }
}




//                    let annotationModel = AnnotationModel(songID: MusicItemID(rawValue: "1487778081"), title: "임시타이틀", artist: "임시아티스트", artworkUrl: artworkUrl ?? URL(string: "")!, location: item.name ?? "위치없음", latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude)

//                    self.choosedAnnotationItem = annotationModel
