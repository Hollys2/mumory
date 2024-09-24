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
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift // @DocumentID


public class OldMumory: NSObject, MKAnnotation, Identifiable, Codable {
    
    @DocumentID public var id: String?

    public var uId: String
    public var date: Date
    public var songId: String
    public var locationTitle: String
    public var latitude: Double
    public var longitude: Double
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }

    @ExplicitNull public var tags: [String]?
    @ExplicitNull public var content: String?
    @ExplicitNull public var imageURLs: [String]?
    
    public var isPublic: Bool
    
    @ExplicitNull public var likes: [String]?
    
    public var commentCount: Int
    public var myCommentCount: Int
}

public class Mumory: NSObject, MKAnnotation, Identifiable, Codable {
    
    @DocumentID public var id: String?

    public var uId: String
    public var date: Date
    public var song: SongModel
    public var location: LocationModel
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.location.geoPoint.latitude, longitude: self.location.geoPoint.longitude)
    }

    @ExplicitNull public var tags: [String]?
    @ExplicitNull public var content: String?
    @ExplicitNull public var imageURLs: [String]?
    
    public var isPublic: Bool
    
    @ExplicitNull public var likes: [String]?
    
    public var commentCount: Int

    public init(uId: String, date: Date, song: SongModel, location: LocationModel, isPublic: Bool, tags: [String]? = nil, content: String? = nil, imageURLs: [String]? = nil, likes: [String]? = nil, commentCount: Int) {
        self.uId = uId
        self.date = date
        self.song = song
        self.location = location
        self.isPublic = isPublic
        
        self.tags = tags
        self.content = content
        self.imageURLs = imageURLs
        self.likes = likes
        self.commentCount = commentCount
    }
    
    public override convenience init() {
        self.init(uId: "UNKNOWN", date: Date(), song: SongModel(), location: LocationModel(), isPublic: false, tags: nil, imageURLs: nil, likes: nil, commentCount: 0)
    }
    
    public static func create(oldMumory: OldMumory) async -> Mumory? {
        guard let song = await fetchSong(songID: oldMumory.songId) else {
            print("Error fetching song")
            return nil
        }
        
        let songModel = SongModel(id: oldMumory.songId, title: song.title, artist: song.artistName, artworkUrl: song.artwork?.url(width: 300, height: 300))
        
        let location = CLLocation(latitude: oldMumory.latitude, longitude: oldMumory.longitude)
        
        if let locationModel = await MapManager.getLocationModel2(location: location) {
            let newMumory = Mumory(
                uId: oldMumory.uId,
                date: oldMumory.date,
                song: songModel,
                location: locationModel,
                isPublic: oldMumory.isPublic,
                tags: oldMumory.tags,
                content: oldMumory.content,
                imageURLs: oldMumory.imageURLs,
                likes: oldMumory.likes,
                commentCount: oldMumory.commentCount
            )
            
            return newMumory
        }
        
        return nil
    }
}

public func fetchSong(songID: String) async -> Song? {
    let musicItemID = MusicItemID(rawValue: songID)
    var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
    guard let response = try? await request.response() else {
        return nil
    }
    guard let song = response.items.first else {
        return nil
    }
    return song
}

public struct SongModel: Identifiable, Hashable, Codable {
    
//    public var id = UUID()
    
    public var id: String
    public var title: String
    public var artist: String
    public var artworkUrl: URL?
    
    public init(id: String, title: String, artist: String, artworkUrl: URL?) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artworkUrl = artworkUrl
    }
    
    public init() {
        self.id = "UNKNOWN"
        self.title = "UNKNOWN"
        self.artist = "UNKNOWN"
    }
}

public struct LocationModel: Codable, Hashable {
    
    public var id: CLLocationCoordinate2D {
        self.coordinate
    }
    
    public var geoPoint: GeoPoint
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.geoPoint.latitude, longitude: self.geoPoint.longitude)
    }
    
    public var locationTitle: String
    public var locationSubtitle: String
    
    public var country: String
    public var administrativeArea: String
    
    public init(geoPoint: GeoPoint, locationTitle: String, locationSubtitle: String, country: String, administrativeArea: String) {
        self.geoPoint = geoPoint
        self.locationTitle = locationTitle
        self.locationSubtitle = locationSubtitle
        self.country = country
        self.administrativeArea = administrativeArea
    }
    
    public init() {
        self.geoPoint = GeoPoint(latitude: .zero, longitude: .zero)
        self.locationTitle = "UNKNOWN"
        self.locationSubtitle = "UNKNOWN"
        self.country = "UNKNOWN"
        self.administrativeArea = "UNKNOWN"
    }
    
//    public static func == (lhs: LocationModel, rhs: LocationModel) -> Bool {
//        return lhs.geoPoint == rhs.geoPoint &&
//        lhs.locationTitle == rhs.locationTitle &&
//        lhs.locationSubtitle == rhs.locationSubtitle &&
//        lhs.country == rhs.country &&
//        lhs.administrativeArea == rhs.administrativeArea
//    }
}



extension CLLocationCoordinate2D: Hashable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}


// 파이어스토어 문서의 속성 이름과 일치시킬 수 있음
//    enum CodingKeys: String, CodingKey {
//        case geoPoint
//        case locationTitle
//        case locationSubtitle
////        case coordinate
//        case latitude
//        case longitude
//        case country
//        case administrativeArea
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(self.locationTitle, forKey: .locationTitle)
//    }
//
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.geoPoint = try container.decode(GeoPoint.self, forKey: .geoPoint)
//        self.locationTitle = try container.decode(String.self, forKey: .locationTitle)
//        self.locationSubtitle = try container.decode(String.self, forKey: .locationSubtitle)
//        let latitude = try container.decode(Double.self, forKey: .latitude)
//        let longitude = try container.decode(Double.self, forKey: .longitude)
//        self.country = try container.decode(String.self, forKey: .country)
//        self.administrativeArea = try container.decode(String.self, forKey: .administrativeArea)
//    }


//extension CLLocationCoordinate2D: Codable {
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.unkeyedContainer()
//        try container.encode(latitude)
//        try container.encode(longitude)
//    }
//
//    public init(from decoder: Decoder) throws {
//        var container = try decoder.unkeyedContainer()
//        let latitude = try container.decode(Double.self)
//        let longitude = try container.decode(Double.self)
//        self.init(latitude: latitude, longitude: longitude)
//    }
//}


