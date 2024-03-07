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
    
    @Published var recentSearches: [String] = UserDefaults.standard.stringArray(forKey: "recentLocationSearch") ?? []
    @Published var popularSearches: [String] = []
//    ["망원한강", "망원한강공원공원", "망원한강공원공원", "망원한강공원", "망원한강공원공원공원", "망원한강공원"]
    
    @Published var results: [MKLocalSearchCompletion] = [MKLocalSearchCompletion]()
    @Published var queryFragment: String = "" {
        didSet {
            searchCompleter.queryFragment = queryFragment
        }
    }
    
    private let searchCompleter = MKLocalSearchCompleter()
    
    var cancellable: AnyCancellable?
    private var cancellables: Set = [""]
    
    public override init() {
        super.init()
        
        searchCompleter.delegate = self
//        searchCompleter.region = MKCoordinateRegion(MKMapRect.world)
//        searchCompleter.resultTypes = MKLocalSearchCompleter.ResultType([.address])
        searchCompleter.resultTypes = .pointOfInterest
        
        cancellable = $queryFragment
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
//            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink(receiveValue: { value in
                self.searchAddress(value)
            })
//            .store(in: &cancellables)
    }
    
    func searchAddress(_ queryFragment: String) {
        if queryFragment.isEmpty {
            self.results = []
        } else {
            self.searchCompleter.queryFragment = queryFragment
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
    
    func addRecentSearch(_ searchTerm: String) {
        recentSearches.insert(searchTerm, at: 0)
        
        // Limit the number of recent searches to, for example, 10
        recentSearches = Array(recentSearches.prefix(10))
        
        // Update UserDefaults
        UserDefaults.standard.set(recentSearches, forKey: "recentLocationSearch")
    }
    
    func removeRecentSearch(_ searchTerm: String) {
        recentSearches.removeAll { $0 == searchTerm }
        
        // Update UserDefaults
        UserDefaults.standard.set(recentSearches, forKey: "recentLocationSearch")
    }
    
    func clearRecentSearches() {
        recentSearches = []
        
        // Update UserDefaults
        UserDefaults.standard.set(recentSearches, forKey: "recentLocationSearch")
    }
}

extension LocalSearchViewModel: MKLocalSearchCompleterDelegate {
    public func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
        
        print("results = \(self.results)")
    }
}
