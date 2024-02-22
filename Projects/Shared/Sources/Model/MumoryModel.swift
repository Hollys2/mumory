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

public struct MusicModel: Identifiable, Hashable {

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

public struct LocationModel: Identifiable {
    
    public let id = UUID()
    
    public var locationTitle: String
    public var locationSubtitle: String
    public var coordinate: CLLocationCoordinate2D
    
    public init(locationTitle: String, locationSubtitle: String, coordinate: CLLocationCoordinate2D) {
        self.locationTitle = locationTitle
        self.locationSubtitle = locationSubtitle
        self.coordinate = coordinate
    }
}


public class MumoryAnnotation: NSObject, MKAnnotation, Identifiable {
    
    public var id: String?
    
    public var date: Date
    public var musicModel: MusicModel
    public var locationModel: LocationModel
    

    public var coordinate: CLLocationCoordinate2D

    public var tags: [String]?
    public var content: String?
    public var imageURLs: [String]?
    
    public var isPublic: Bool

    public init(id: String? = nil, date: Date, musicModel: MusicModel, locationModel: LocationModel, tags: [String]? = nil, content: String? = nil, imageURLs: [String]? = nil, isPublic: Bool) {
        self.id = id
        self.date = date
        self.musicModel = musicModel
        self.locationModel = locationModel
        self.coordinate = locationModel.coordinate
        
        self.tags = tags
        self.content = content
        self.imageURLs = imageURLs
        
        self.isPublic = isPublic
//        super.init()
    }
    
    // 프리뷰에서 기본 생성자 사용
    public override convenience init() {
        self.init(id: "", date: Date(), musicModel: MusicModel(songID: MusicItemID(rawValue: "123"), title: "", artist: ""), locationModel: LocationModel(locationTitle: "", locationSubtitle: "", coordinate: CLLocationCoordinate2D()), isPublic: false)
    }
}


