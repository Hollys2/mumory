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


struct RecentLocationSearch: Codable, Hashable {
    
    var locationTitle: String
    var locationSubTitle: String
    var latitude: Double
    var longitude: Double
    var country: String
    var administrativeArea: String

    static func == (lhs: RecentLocationSearch, rhs: RecentLocationSearch) -> Bool {
        return lhs.locationTitle == rhs.locationTitle &&
               lhs.locationSubTitle == rhs.locationSubTitle &&
               lhs.latitude == rhs.latitude &&
               lhs.longitude == rhs.longitude &&
               lhs.country == rhs.country &&
               lhs.administrativeArea == rhs.administrativeArea
    }
}

public class LocalSearchViewModel: NSObject, ObservableObject {
    
//    @Published var recentSearches: [RecentLocationSearch] = UserDefaults.standard.array(forKey: "recentLocationSearch") ?? []
    @Published var recentSearches: [RecentLocationSearch] = {
        if let savedData = UserDefaults.standard.data(forKey: "recentLocationSearch"),
           let loadedRecentSearches = try? JSONDecoder().decode([RecentLocationSearch].self, from: savedData) {
            return loadedRecentSearches
        } else {
            return []
        }
    }()
    @Published var results: [MKLocalSearchCompletion] = [MKLocalSearchCompletion]()
    @Published var queryFragment: String = "" {
        didSet {
            searchCompleter.queryFragment = queryFragment
        }
    }
    @Published var isSearching: Bool = false
    
    private let searchCompleter = MKLocalSearchCompleter()
    private var cancellable: AnyCancellable?
    
    public override init() {
        super.init()
        
        searchCompleter.delegate = self
//        searchCompleter.region = MKCoordinateRegion(MKMapRect.world)
//        searchCompleter.resultTypes = MKLocalSearchCompleter.ResultType([.address])
        searchCompleter.resultTypes = .pointOfInterest
        searchCompleter.pointOfInterestFilter = .includingAll
        
        cancellable = $queryFragment
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
//            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink(receiveValue: { value in
                self.isSearching = true
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
        self.isSearching = false
    }

    func getRegion(localSearchCompletion: MKLocalSearchCompletion, completion: @escaping (CLLocationCoordinate2D) -> Void) {
        let request = MKLocalSearch.Request(completion: localSearchCompletion)
        Task {
            do {
                let response = try await MKLocalSearch(request: request).start()

                if let placemark = response.mapItems.first?.placemark {

//                    let coutry = placemark.country ?? ""
//                    let administrativeArea = placemark.administrativeArea ?? ""
//                    let locationTitle = placemark.name ?? ""
//                    let locationSubtitle = (placemark.locality ?? "") + " " + (placemark.thoroughfare ?? "") + " " + (placemark.subThoroughfare ?? "")
                    let coordinate = placemark.coordinate
//                    let region = MKCoordinateRegion(center: coordinate, span: MapConstant.defaultSpan)
//                    print("coutry: \(String(describing: coutry))")
//                    print("administrativeArea: \(String(describing: administrativeArea))")
                    completion(coordinate)
                    
//                    completion(LocationModel(locationTitle: locationTitle, locationSubtitle: locationSubtitle, coordinate: coordinate, country: coutry, administrativeArea: administrativeArea))
                }
            } catch {
                print("Error getting region:", error.localizedDescription)
                completion(CLLocationCoordinate2D())
            }
        }
    }
    
    func addRecentSearch(_ locationSearch: RecentLocationSearch) {
        recentSearches.insert(locationSearch, at: 0)
//        recentSearches = Array(Set(recentSearches).prefix(10))
        var uniqueRecentSearches: [RecentLocationSearch] = []
        for search in recentSearches {
            if !uniqueRecentSearches.contains(search) {
                uniqueRecentSearches.append(search)
            }
        }
        if uniqueRecentSearches.count > 10 {
            uniqueRecentSearches = Array(recentSearches.prefix(10))
        }
        recentSearches = uniqueRecentSearches
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(recentSearches) // RecentLocationSearch 배열을 Data 객체로 인코딩합니다.
            UserDefaults.standard.set(data, forKey: "recentLocationSearch")
        } catch {
            print("Encoding Error: \(error)")
        }
    }
    
    func removeRecentSearch(_ locationSearch: RecentLocationSearch) {
        recentSearches.removeAll { $0 == locationSearch }
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(recentSearches) // RecentLocationSearch 배열을 Data 객체로 인코딩합니다.
            UserDefaults.standard.set(data, forKey: "recentLocationSearch")
        } catch {
            print("Encoding Error: \(error)")
        }
    }
    
    func clearRecentSearches() {
        recentSearches = []
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(recentSearches) // RecentLocationSearch 배열을 Data 객체로 인코딩합니다.
            UserDefaults.standard.set(data, forKey: "recentLocationSearch")
        } catch {
            print("Encoding Error: \(error)")
        }
    }
}

extension LocalSearchViewModel: MKLocalSearchCompleterDelegate {
    public func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
    }
}
