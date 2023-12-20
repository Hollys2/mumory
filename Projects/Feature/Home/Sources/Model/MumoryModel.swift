//
//  MumoryModel.swift
//  Feature
//
//  Created by 다솔 on 2023/11/30.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import MapKit
import MusicKit


public struct MumoryModel: Identifiable {
    
    public let id = UUID()

    public var date: Date?

    public var songID: MusicItemID?
    public var title: String?
    public var artist: String?
    public var artworkUrl: URL?

    public var locationTitle: String?
    public var locationSubtitle: String?
    public var coordinate: CLLocationCoordinate2D?

}

// memberwise initializer도 사용하기 위해
extension MumoryModel {
    
    // MARK: -Music
    public init(songID: MusicItemID, title: String, artist: String, artworkUrl: URL) {
        self.songID = songID
        self.title = title
        self.artist = artist
        self.artworkUrl = artworkUrl
    }
    
    // MARK: -Location
    public init(locationTitle: String, locationSubtitle: String, coordinate: CLLocationCoordinate2D) {
        self.locationTitle = locationTitle
        self.locationSubtitle = locationSubtitle
        self.coordinate = coordinate
    }
}


public class MumoryAnnotation: NSObject, MKAnnotation {

    public var coordinate: CLLocationCoordinate2D
    public let title: String?
    public let subtitle: String?

    public init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.title = nil
        self.subtitle = nil
        
        super.init()
    }
}
