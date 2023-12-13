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


public struct AddressItem: Identifiable { // Hashable?
    
    public let id = UUID()
    public let title: String
    public let subTitle: String
    public let latitude: Double
    public let longitude: Double
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public init(title: String, subTitle: String, latitude: Double, longitude: Double) {
        self.title = title
        self.subTitle = subTitle
        self.latitude = latitude
        self.longitude = longitude
    }
}


class LocalSearchViewModel: NSObject, ObservableObject {
    
    @Published var results: [MKLocalSearchCompletion] = [MKLocalSearchCompletion]()
    @Published var addressItems: [AddressItem] = [AddressItem]()
    
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
}

extension LocalSearchViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results

        print("results = \(self.results)")
    }
}
