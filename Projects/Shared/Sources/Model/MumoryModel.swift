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


public enum MumoryViewType {
    case mumoryDetailView
    case editMumoryView
}

public struct MumoryView: Hashable {
    
    public let type: MumoryViewType
    public let mumoryAnnotation: Mumory
//    public let songID: MusicItemID?
    
    public init(type: MumoryViewType, mumoryAnnotation: Mumory) {
        self.type = type
        self.mumoryAnnotation = mumoryAnnotation
    }
}

public struct MusicModel: Identifiable, Hashable, Codable {

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
}

public struct LocationModel: Identifiable, Codable {
    
    public var id = UUID()
    
    public var locationTitle: String
    public var locationSubtitle: String
    
    private var latitude: CLLocationDegrees
    private var longitude: CLLocationDegrees
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public init(locationTitle: String, locationSubtitle: String, coordinate: CLLocationCoordinate2D) {
        self.locationTitle = locationTitle
        self.locationSubtitle = locationSubtitle
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}

public struct Comment: Codable, Hashable {
    
    public var id: String
    
    public let userDocumentID: String
    public let parentDocumentID: String?
    public let date: Date
    public let content: String
    public let isPublic: Bool
    
    public init(id: String, userDocumentID: String, parentDocumentID: String? = nil, date: Date, content: String, isPublic: Bool) {
        self.id = id
        self.userDocumentID = userDocumentID
        self.parentDocumentID = parentDocumentID
        self.date = date
        self.content = content
        self.isPublic = isPublic
    }
    
    public init?(id: String, data: [String: Any]) {
        guard let userDocumentID = data["uId"] as? String,
              let date = data["date"] as? FirebaseManager.Timestamp,
              let content = data["content"] as? String,
              let isPublic = data["isPublic"] as? Bool
        else {
            print("Something is nil in Comment")
            return nil
        }

        if let parentDocumentID = data["parentID"] as? String {
            self.parentDocumentID = parentDocumentID
        } else {
            self.parentDocumentID = nil
        }

        self.id = id
        self.userDocumentID = userDocumentID
        self.date = date.dateValue()
        self.content = content
        self.isPublic = isPublic
    }
}

extension Comment {
    public func toDictionary() -> [String: Any] {
        if let parentDocumentID = parentDocumentID {
            return [
                "uId": userDocumentID,
                "parentId": parentDocumentID,
                "date": FirebaseManager.Timestamp(date: date),
                "content": content,
                "isPublic": isPublic
            ]
        } else {
            return [
                "uId": userDocumentID,
                "date": FirebaseManager.Timestamp(date: date),
                "content": content,
                "isPublic": isPublic
            ]
        }
    }
    
    static func fromDocumentData(_ documentData: [String: Any], commentDocumentID: String, comments: [Comment]) -> Comment? {
        guard let userDocumentID = documentData["uId"] as? String,
              let date = documentData["date"] as? FirebaseManager.Timestamp,
              let content = documentData["content"] as? String,
              let isPublic = documentData["isPublic"] as? Bool else {
            return nil
        }
        
        return Comment(id: commentDocumentID, userDocumentID: userDocumentID, date: date.dateValue(), content: content, isPublic: isPublic)
    }
}


public class Mumory: NSObject, MKAnnotation, Identifiable {
    
    public var id: String

    public var userDocumentID: String
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
    public var comments: [Comment]
    
    enum CodingKeys: String, CodingKey {
        case id
        case userDocumentID
        case date
        case musicModel
        case locationModel
        case tags
        case content
        case imageURLs
        case isPublic
        case likes
        case comments
    }

    public init(id: String, userDocumentID: String, date: Date, musicModel: MusicModel, locationModel: LocationModel, tags: [String]? = nil, content: String? = nil, imageURLs: [String]? = nil, isPublic: Bool, likes: [String], commentCount: Int, comments: [Comment]) {
        self.id = id
        self.userDocumentID = userDocumentID
        self.date = date
        self.musicModel = musicModel
        self.locationModel = locationModel
        self.tags = tags
        self.content = content
        self.imageURLs = imageURLs
        self.isPublic = isPublic
        self.likes = likes
        self.commentCount = commentCount
        self.comments = comments
    }
    
    public override convenience init() {
        self.init(id: "", userDocumentID: "UNKNOWN", date: Date(), musicModel: MusicModel(songID: MusicItemID(rawValue: "123"), title: "", artist: ""), locationModel: LocationModel(locationTitle: "", locationSubtitle: "", coordinate: CLLocationCoordinate2D()), isPublic: false, likes: [], commentCount: -1, comments: [])
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
        self.comments = other.comments
    }
}

extension Mumory {
    
    static func fromDocumentData(_ documentData: [String: Any], mumoryDocumentID: String) async -> Mumory? {
        
        guard let userDocumentID = documentData["uId"] as? String,
              let songID = documentData["songID"] as? String,
              let latitude = documentData["latitude"] as? CLLocationDegrees,
              let longitude = documentData["longitude"] as? CLLocationDegrees,
              let date = documentData["date"] as? FirebaseManager.Timestamp,
              let tags = documentData["tags"] as? [String],
              let content = documentData["content"] as? String,
              let imageURLs = documentData["imageURLs"] as? [String],
              let isPublic = documentData["isPublic"] as? Bool,
              let likes = documentData["likes"] as? [String],
              let count = documentData["commentCount"] as? Int else {
            return nil
        }
        
        do {
            let musicItemID = MusicItemID(rawValue: songID)
            let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
            
            async let musicResponse = request.response()
            let location = CLLocation(latitude: latitude, longitude: longitude)
            async let placemarkResults = CLGeocoder().reverseGeocodeLocation(location)
            async let commentCountResult = MumoryDataViewModel.fetchCommentCount(mumoryId: mumoryDocumentID)
            
            let (response, placemarks, commentCount) = await (try musicResponse, try placemarkResults, commentCountResult)
            
            guard let song = response.items.first else {
                throw NSError(domain: "GoogleMapSample", code: 1, userInfo: [NSLocalizedDescriptionKey: "Song not found"])
            }
            let musicModel = MusicModel(songID: musicItemID, title: song.title, artist: song.artistName, artworkUrl: song.artwork?.url(width: 500, height: 500))
            
            guard let placemark = placemarks.first else {
                return nil as Mumory?
            }
            let locationTitle = placemark.name ?? ""
            let locationSubtitle = (placemark.locality ?? "") + " " + (placemark.thoroughfare ?? "") + " " + (placemark.subThoroughfare ?? "")
            let locationModel = LocationModel(locationTitle: locationTitle, locationSubtitle: locationSubtitle, coordinate: location.coordinate)
            

            return Mumory(id: mumoryDocumentID, userDocumentID: userDocumentID, date: date.dateValue(), musicModel: musicModel, locationModel: locationModel, tags: tags, content: content, imageURLs: imageURLs, isPublic: isPublic, likes: likes, commentCount: count, comments: [])
            
        } catch {
            print("Error fetching music or location:", error.localizedDescription)
            return nil
        }
    }
}

//public class MumoryData: Codable {
//
//    public var userDocumentID: String
//    public var date: FirebaseManager.Timestamp
//    public var songID: String
//    public var latitude: CLLocationDegrees
//    public var longitude: CLLocationDegrees
//    public var tags: [String]?
//    public var content: String?
//    public var imageURLs: [String]?
//    public var isPublic: Bool
//    public var likes: [String]
//    public var comments: [String]?
//
//    enum CodingKeys: String, CodingKey {
//        case userDocumentID
//        case timeStamp
//        case songID
//        case latitude
//        case longitude
//        case tags
//        case content
//        case imageURLs
//        case isPublic
//        case likes
//        case comments
//    }
//
//    public init(userDocumentID: String, date: FirebaseManager.Timestamp, songID: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, tags: [String]? = nil, content: String? = nil, imageURLs: [String]? = nil, isPublic: Bool, likes: [String], comments: [String]? = nil) {
//        self.userDocumentID = userDocumentID
//        self.date = date
//        self.songID = songID
//        self.latitude = latitude
//        self.longitude = longitude
//        self.tags = tags
//        self.content = content
//        self.imageURLs = imageURLs
//        self.isPublic = isPublic
//        self.likes = likes
//        self.comments = comments
//    }
//
//    // Codable을 위한 커스텀 init 구현
//    public required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        userDocumentID = try container.decode(String.self, forKey: .userDocumentID)
//        let dateSeconds = try container.decode(Double.self, forKey: .timeStamp)
//        date = Timestamp(seconds: Int64(dateSeconds), nanoseconds: 0)
//        songID = try container.decode(String.self, forKey: .songID)
//        latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
//        longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
//        tags = try container.decodeIfPresent([String].self, forKey: .tags)
//        content = try container.decodeIfPresent(String.self, forKey: .content)
//        imageURLs = try container.decodeIfPresent([String].self, forKey: .imageURLs)
//        isPublic = try container.decode(Bool.self, forKey: .isPublic)
//        likes = try container.decode([String].self, forKey: .likes)
//        comments = try container.decodeIfPresent([String].self, forKey: .comments)
//    }
//
//    // Codable을 위한 커스텀 encode 구현
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(userDocumentID, forKey: .userDocumentID)
//        try container.encode(date.seconds, forKey: .timeStamp)
//        try container.encode(songID, forKey: .songID)
//        try container.encode(latitude, forKey: .latitude)
//        try container.encode(longitude, forKey: .longitude)
//        try container.encode(tags, forKey: .tags)
//        try container.encode(content, forKey: .content)
//        try container.encode(imageURLs, forKey: .imageURLs)
//        try container.encode(isPublic, forKey: .isPublic)
//        try container.encode(likes, forKey: .likes)
//        try container.encode(comments, forKey: .comments)
//    }
//}


public struct UserModel {
//    public var id = UUID()

    public var documentID: String
    public var nickname: String
    public var id: String
    public var profileURL: URL?
    
    public init(documentID: String, nickname: String, id: String, profileURL: URL? = nil) {
        self.documentID = documentID
        self.nickname = nickname
        self.id = id
        self.profileURL = profileURL
    }
    
    public init() {
        self.documentID = ""
        self.nickname = ""
        self.id = ""
//        self.profileURL = nil
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
