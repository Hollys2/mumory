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
    public let mumoryAnnotation: MumoryAnnotation?
//    public let songID: MusicItemID?
    
    public init(type: MumoryViewType, mumoryAnnotation: MumoryAnnotation? = nil) {
        self.type = type
        self.mumoryAnnotation = mumoryAnnotation
    }
}

public struct MusicModel: Identifiable, Hashable, Codable {

    public let id = UUID()
    
//    public var song: Song

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
    
    public let id = UUID()
    
    public var locationTitle: String
    public var locationSubtitle: String
    
    private var latitude: CLLocationDegrees
    private var longitude: CLLocationDegrees
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
//    public var coordinate: CLLocationCoordinate2D
    
    public init(locationTitle: String, locationSubtitle: String, coordinate: CLLocationCoordinate2D) {
        self.locationTitle = locationTitle
        self.locationSubtitle = locationSubtitle
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
//    public init(locationTitle: String, locationSubtitle: String, coordinate: CLLocationCoordinate2D) {
//        self.locationTitle = locationTitle
//        self.locationSubtitle = locationSubtitle
//        self.coordinate = coordinate
//    }
}

public struct Comment: Codable, Hashable {
    public let author: String
    public let date: Date
    public let content: String
    public let isPublic: Bool
    
    public init(author: String, date: Date, content: String, isPublic: Bool) {
        self.author = author
        self.date = date
        self.content = content
        self.isPublic = isPublic
    }
    
    public init?(data: [String: Any]) {
        guard let author = data["author"] as? String,
              let date = data["date"] as? FirebaseManager.Timestamp,
              let content = data["content"] as? String,
              let isPublic = data["isPublic"] as? Bool else {
            return nil
        }
        
        self.author = author
        self.date = date.dateValue()
        self.content = content
        self.isPublic = isPublic
    }
}

extension Comment {
    public func toDictionary() -> [String: Any] {
        return [
            "author": author,
            "date": Timestamp(date: date),
            "content": content,
            "isPublic": isPublic
        ]
    }
}


public class MumoryAnnotation: NSObject, MKAnnotation, Identifiable, Codable {
    
    public var author: String

    public var id: String
    
    public var date: Date
    public var musicModel: MusicModel
    public var locationModel: LocationModel

    private var latitude: CLLocationDegrees
    private var longitude: CLLocationDegrees
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
//    public var coordinate: CLLocationCoordinate2D

    public var tags: [String]?
    public var content: String?
    public var imageURLs: [String]?
    
    public var isPublic: Bool
    
    public var likes: [String]
    public var comments: [Comment]
    

    public init(author: String, id: String, date: Date, musicModel: MusicModel, locationModel: LocationModel, tags: [String]? = nil, content: String? = nil, imageURLs: [String]? = nil, isPublic: Bool, likes: [String], comments: [Comment]) {
        self.author = author
        self.id = id
        self.date = date
        self.musicModel = musicModel
        self.locationModel = locationModel
        
        self.latitude = locationModel.coordinate.latitude
        self.longitude = locationModel.coordinate.longitude
//        self.coordinate = locationModel.coordinate
        
        self.tags = tags
        self.content = content
        self.imageURLs = imageURLs
        
        self.isPublic = isPublic
        
        self.likes = likes
        self.comments = comments
        
//        super.init()
    }
    
    // 프리뷰에서 기본 생성자 사용
    public override convenience init() {
        self.init(author: "UNKNOWN", id: "", date: Date(), musicModel: MusicModel(songID: MusicItemID(rawValue: "123"), title: "", artist: ""), locationModel: LocationModel(locationTitle: "", locationSubtitle: "", coordinate: CLLocationCoordinate2D()), isPublic: false, likes: [], comments: [])
    }
    
    func copy(from other: MumoryAnnotation) {

        self.date = other.date
        self.musicModel = other.musicModel
        self.locationModel = other.locationModel
//        self.coordinate = locationModel.coordinate
        
        self.tags = other.tags
        self.content = other.content
        self.imageURLs = other.imageURLs
        
        self.isPublic = other.isPublic
    }
}


