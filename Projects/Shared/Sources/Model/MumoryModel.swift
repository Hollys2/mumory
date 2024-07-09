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
    public var likes: [String]
    public var commentCount: Int
    public var myCommentCount: Int

    public init(id: String, uId: String, date: Date, songModel: SongModel, locationModel: LocationModel, tags: [String]? = nil, content: String? = nil, imageURLs: [String]? = nil, isPublic: Bool, likes: [String], commentCount: Int, myCommentCount: Int) {
        self.id = id
        self.uId = uId
        self.date = date
        self.song = songModel
        self.location = locationModel
        self.tags = tags
        self.content = content
        self.imageURLs = imageURLs
        self.isPublic = isPublic
        self.likes = likes
        self.commentCount = commentCount
        self.myCommentCount = myCommentCount
    }
    
    public override convenience init() {
        self.init(id: "", uId: "UNKNOWN", date: Date(), songModel: SongModel(), locationModel: LocationModel(geoPoint: GeoPoint(latitude: .zero, longitude: .zero), locationTitle: "UNKNOWN", locationSubtitle: "", country: "", administrativeArea: ""), isPublic: false, likes: [], commentCount: 0,  myCommentCount: 0)
    }
    
    func copy(from other: Mumory) {
        self.date = other.date
        self.song = other.song
        self.location = other.location
        self.tags = other.tags
        self.content = other.content
        self.imageURLs = other.imageURLs
        self.isPublic = other.isPublic
        self.likes = other.likes
    }
}

extension Mumory {
    
//    static func fromDocumentDataToMumory(_ documentData: [String: Any], mumoryDocumentID: String) async -> Mumory? {
//        
//        guard let userDocumentID = documentData["uId"] as? String,
//              let songID = documentData["songId"] as? String,
//              let locationTitle = documentData["locationTitle"] as? String,
//              let latitude = documentData["latitude"] as? CLLocationDegrees,
//              let longitude = documentData["longitude"] as? CLLocationDegrees,
//              let coutry = documentData["coutry"] as? String,
//              let administrativeArea = documentData["administrativeArea"] as? String,
//              let date = documentData["date"] as? FirebaseManager.Timestamp,
//              let tags = documentData["tags"] as? [String],
//              let content = documentData["content"] as? String,
//              let imageURLs = documentData["imageURLs"] as? [String],
//              let isPublic = documentData["isPublic"] as? Bool,
//              let likes = documentData["likes"] as? [String],
//              let commentCount = documentData["commentCount"] as? Int,
//              let myCommentCount = documentData["myCommentCount"] as? Int else {
//            print("something is nil in Mumory")
//            return nil
//        }
//        
//        let musicItemID = MusicItemID(rawValue: songID)
//        let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
//        async let musicResponse = request.response()
//        
//        do {
//            let response = await (try musicResponse)
//            guard let song = response.items.first else {
//                throw NSError(domain: "MMR", code: 1, userInfo: [NSLocalizedDescriptionKey: "Song or Placemark not found"])
//            }
//            let musicModel = SongModel(songId: musicItemID, title: song.title, artist: song.artistName, artworkUrl: song.artwork?.url(width: 500, height: 500))
//            
//            let location = CLLocation(latitude: latitude, longitude: longitude)
//            let locationModel = LocationModel(geoPoint: GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), locationTitle: locationTitle, locationSubtitle: "", country: coutry, administrativeArea: administrativeArea)
//            
//            return Mumory(id: mumoryDocumentID, uId: userDocumentID, date: date.dateValue(), songId: songID, musicModel: musicModel, locationModel: locationModel, tags: tags, content: content, imageURLs: imageURLs, isPublic: isPublic, likes: likes, commentCount: commentCount, myCommentCount: myCommentCount)
//        } catch {
//            print("Error fetching music or location:", error.localizedDescription)
//            return nil
//        }
//    }
}

public struct SongModel: Identifiable, Hashable, Codable {
    
    public var id = UUID()
    
    public var songId: String
    public var title: String
    public var artist: String
    public var artworkUrl: URL?
    
    
    public init(songId: String, title: String, artist: String, artworkUrl: URL?) {
        self.songId = songId
        self.title = title
        self.artist = artist
        self.artworkUrl = artworkUrl
    }
    
    public init() {
        self.songId = "UNKNOWN"
        self.title = "UNKNOWN"
        self.artist = "UNKNOWN"
    }
}

public struct LocationModel: Identifiable, Codable {
    
    public var id = UUID()
    
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
        self.locationTitle = ""
        self.locationSubtitle = ""
        self.country = ""
        self.administrativeArea = ""
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


