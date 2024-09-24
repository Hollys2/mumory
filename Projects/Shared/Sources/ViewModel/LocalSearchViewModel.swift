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
import Firebase


public class LocalSearchViewModel: NSObject, ObservableObject {
    
    @Published public var recentSearches: [LocationModel] = {
        if let savedData: Data = UserDefaults.standard.data(forKey: "recentLocationSearch"),
           let loadedRecentSearches: [LocationModel] = try? JSONDecoder().decode([LocationModel].self, from: savedData) {
            return loadedRecentSearches
        } else {
            return []
        }
    }()
    @Published public var queryFragment: String = ""
    @Published public var results: [MKLocalSearchCompletion] = [MKLocalSearchCompletion]()
    @Published public var isSearching: Bool = false
    
    private let searchCompleter = MKLocalSearchCompleter()
    private var cancellable: AnyCancellable?
    
    public override init() {
        super.init()
        
        searchCompleter.delegate = self
        searchCompleter.resultTypes = MKLocalSearchCompleter.ResultType.pointOfInterest
        
        cancellable = $queryFragment
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { value in
                self.isSearching = true
                
                if value.isEmpty {
                    self.results = []
                    self.isSearching = false
                }
                
                self.searchCompleter.queryFragment = value
            })
    }
    
    public func getLocation(localSearchCompletion: MKLocalSearchCompletion, completion: @escaping (LocationModel?) -> Void) {
        let request = MKLocalSearch.Request(completion: localSearchCompletion)
        
        Task {
            do {
                let response = try await MKLocalSearch(request: request).start()

                if let placemark = response.mapItems.first?.placemark {

                    let country = placemark.country ?? ""
                    let administrativeArea = placemark.administrativeArea ?? ""
                    let locationTitle = placemark.name ?? ""
                    let locationSubtitle = (placemark.locality ?? "") + " " + (placemark.thoroughfare ?? "") + " " + (placemark.subThoroughfare ?? "")
                    let coordinate = placemark.coordinate
                    
                    completion(LocationModel(geoPoint: GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude), locationTitle: locationTitle, locationSubtitle: locationSubtitle, country: country, administrativeArea: administrativeArea))
                }
            } catch {
                print("Error getting region:", error.localizedDescription)
                completion(nil)
            }
        }
    }
    
    public func addRecentSearch(_ locationModel: LocationModel) {
        self.recentSearches.insert(locationModel, at: 0)
        
        var uniqueRecentSearches: [LocationModel] = []
        for search in self.recentSearches {
            if !uniqueRecentSearches.contains(search) {
                uniqueRecentSearches.append(search)
            }
        }
        if uniqueRecentSearches.count > 10 {
            uniqueRecentSearches = Array(self.recentSearches.prefix(10))
        }
        self.recentSearches = uniqueRecentSearches
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(recentSearches) // RecentLocationSearch 배열을 Data 객체로 인코딩
            UserDefaults.standard.set(data, forKey: "recentLocationSearch")
        } catch {
            print("Encoding Error: \(error)")
        }
    }
    
    public func removeRecentSearch(_ locationModel: LocationModel) {
        self.recentSearches.removeAll { $0 == locationModel }
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self.recentSearches) // RecentLocationSearch 배열을 Data 객체로 인코딩합니다.
            UserDefaults.standard.set(data, forKey: "recentLocationSearch")
        } catch {
            print("Encoding Error: \(error)")
        }
    }
    
    public func clearRecentSearches() {
        self.recentSearches = []
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self.recentSearches) // RecentLocationSearch 배열을 Data 객체로 인코딩합니다.
            UserDefaults.standard.set(data, forKey: "recentLocationSearch")
        } catch {
            print("Encoding Error: \(error)")
        }
    }
}

extension LocalSearchViewModel: MKLocalSearchCompleterDelegate {
    public func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
        self.isSearching = false
    }
    
    public func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("ERROR MKLocalSearchCompleterDelegate: \(error.localizedDescription)")
        self.isSearching = false
    }
}
