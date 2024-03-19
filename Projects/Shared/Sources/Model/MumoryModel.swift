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
import FirebaseFirestore


public struct MusicModel: Identifiable, Hashable {

    public var id = UUID()

    public var songID: MusicItemID
    public var title: String
    public var artist: String
    public var artworkUrl: URL?
    
    public init(songID: MusicItemID, title: String, artist: String, artworkUrl: URL? = nil) {
        self.songID = songID
        self.title = title
        self.artist = artist
        self.artworkUrl = artworkUrl
    }
    
    public init() {
        self.songID = "UNKNOWN"
        self.title = "UNKNOWN"
        self.artist = "UNKNOWN"
        self.artworkUrl = nil
    }
}

public struct LocationModel: Identifiable {
    
    public var id = UUID()
    
    public var locationTitle: String
    public var locationSubtitle: String
    public var coordinate: CLLocationCoordinate2D
    
    public init(locationTitle: String, locationSubtitle: String, coordinate: CLLocationCoordinate2D) {
        self.locationTitle = locationTitle
        self.locationSubtitle = locationSubtitle
        self.coordinate = coordinate
    }
}

public class Mumory: NSObject, MKAnnotation, Identifiable {
    
    public var id: String

    public var uId: String
    public var date: Date
    public var musicModel: MusicModel
    public var locationModel: LocationModel
    public var coordinate: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: self.locationModel.coordinate.latitude, longitude: self.locationModel.coordinate.longitude) }
    public var tags: [String]?
    public var content: String?
    public var imageURLs: [String]?
    public var isPublic: Bool
    public var likes: [String]
    public var commentCount: Int

    public init(id: String, uId: String, date: Date, musicModel: MusicModel, locationModel: LocationModel, tags: [String]? = nil, content: String? = nil, imageURLs: [String]? = nil, isPublic: Bool, likes: [String], commentCount: Int) {
        self.id = id
        self.uId = uId
        self.date = date
        self.musicModel = musicModel
        self.locationModel = locationModel
        self.tags = tags
        self.content = content
        self.imageURLs = imageURLs
        self.isPublic = isPublic
        self.likes = likes
        self.commentCount = commentCount
    }
    
    public override convenience init() {
        self.init(id: "UNKNOWN", uId: "UNKNOWN", date: Date(), musicModel: MusicModel(), locationModel: LocationModel(locationTitle: "UNKNOWN", locationSubtitle: "", coordinate: CLLocationCoordinate2D()), isPublic: false, likes: [], commentCount: 0)
    }
    
    func copy(from other: Mumory) {
        self.date = other.date
        self.musicModel = other.musicModel
        self.locationModel = other.locationModel
        self.tags = other.tags
        self.content = other.content
        self.imageURLs = other.imageURLs
        self.isPublic = other.isPublic
        self.likes = other.likes
    }
}

extension Mumory {
    
    static func fromDocumentDataToMumory(_ documentData: [String: Any], mumoryDocumentID: String) async -> Mumory? {
        
        guard let userDocumentID = documentData["uId"] as? String,
              let songID = documentData["songId"] as? String,
              let locationTitle = documentData["locationTitle"] as? String,
              let latitude = documentData["latitude"] as? CLLocationDegrees,
              let longitude = documentData["longitude"] as? CLLocationDegrees,
              let date = documentData["date"] as? FirebaseManager.Timestamp,
              let tags = documentData["tags"] as? [String],
              let content = documentData["content"] as? String,
              let imageURLs = documentData["imageURLs"] as? [String],
              let isPublic = documentData["isPublic"] as? Bool,
              let likes = documentData["likes"] as? [String],
              let count = documentData["commentCount"] as? Int else {
            print("something is nil in Mumory")
            return nil
        }
        
        do {
            let musicItemID = MusicItemID(rawValue: songID)
            let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
            async let musicResponse = request.response()
            let response = await (try musicResponse)
            guard let song = response.items.first else {
                throw NSError(domain: "MMR", code: 1, userInfo: [NSLocalizedDescriptionKey: "Song or Placemark not found"])
            }
            let musicModel = MusicModel(songID: musicItemID, title: song.title, artist: song.artistName, artworkUrl: song.artwork?.url(width: 500, height: 500))
            
            let location = CLLocation(latitude: latitude, longitude: longitude)
            let locationModel = LocationModel(locationTitle: locationTitle, locationSubtitle: "", coordinate: location.coordinate)
            
            return Mumory(id: mumoryDocumentID, uId: userDocumentID, date: date.dateValue(), musicModel: musicModel, locationModel: locationModel, tags: tags, content: content, imageURLs: imageURLs, isPublic: isPublic, likes: likes, commentCount: count)
            
        } catch {
            print("Error fetching music or location:", error.localizedDescription)
            return nil
        }
    }
}

public struct UserModel {

    public var uId: String
    public var nickname: String
    public var id: String
    public var profileURL: URL?
    
    public init(uId: String, nickname: String, id: String, profileURL: URL? = nil) {
        self.uId = uId
        self.nickname = nickname
        self.id = id
        self.profileURL = profileURL
    }
}

public class Mumory2: NSObject, MKAnnotation, Codable {
    
    public var coordinate: CLLocationCoordinate2D
    
    let name: String
    let state: String?
    let country: String?
    let isCapital: Bool?
    let population: Int64?
    
    enum CodingKeys: String, CodingKey {
        case name
        case state
        case country
        case isCapital = "capital"
        case population
    }
    
    public init(coordinate: CLLocationCoordinate2D, name: String, state: String?, country: String?, isCapital: Bool?, population: Int64?) {
        self.coordinate = coordinate
        self.name = name
        self.state = state
        self.country = country
        self.isCapital = isCapital
        self.population = population
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.state = try container.decodeIfPresent(String.self, forKey: .state)
        self.country = try container.decodeIfPresent(String.self, forKey: .country)
        self.isCapital = try container.decodeIfPresent(Bool.self, forKey: .isCapital)
        self.population = try container.decodeIfPresent(Int64.self, forKey: .population)
        
        self.coordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        //            super.init()
    }
}
