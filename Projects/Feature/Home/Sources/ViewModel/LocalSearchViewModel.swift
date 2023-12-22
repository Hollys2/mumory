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
//    @Published var region: MKCoordinateRegion?
    
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
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
        
        print("results = \(self.results)")
    }
}
