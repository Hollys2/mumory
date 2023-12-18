//
//  MapModel.swift
//  Shared
//
//  Created by 다솔 on 2023/11/30.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import MapKit

public struct AddressResult: Identifiable, Hashable {
    
    public init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
    
    public let id = UUID()
    public let title: String
    public let subtitle: String
}

public struct AnnotationItem: Identifiable, Hashable {
    
    public let id = UUID()
    public let title: String
    public let subTitle: String
    public var latitude: Double
    public var longitude: Double
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

//public struct AddressItem: Identifiable { // Hashable?
//    
//    public let id = UUID()
//    public let title: String
//    public let subTitle: String
//    public let latitude: Double
//    public let longitude: Double
//    public var coordinate: CLLocationCoordinate2D {
//        CLLocationCoordinate2D(latitude: latitude, longitude: longitude) // getter
//    }
//    
//    public init(title: String, subTitle: String, latitude: Double, longitude: Double) {
//        self.title = title
//        self.subTitle = subTitle
//        self.latitude = latitude
//        self.longitude = longitude
//    }
//}


