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


public struct MusicModel: Identifiable, Hashable {

    public let id = UUID()
    
//    public var song: Song

    public var songID: MusicItemID
    public var title: String
    public var artist: String
    public var artworkUrl: URL?
}

public struct LocationModel: Identifiable {
    
    public let id = UUID()
    
    public var locationTitle: String
    public var locationSubtitle: String
    public var coordinate: CLLocationCoordinate2D
}


public class MumoryAnnotation: NSObject, MKAnnotation, Identifiable {
    
    public var count: Int
    
    public var date: Date
    public var musicModel: MusicModel
    public var locationModel: LocationModel

    public var coordinate: CLLocationCoordinate2D

    public init(count: Int = 0, date: Date, musicModel: MusicModel, locationModel: LocationModel) {
        self.count = count
        self.date = date
        self.musicModel = musicModel
        self.locationModel = locationModel
        self.coordinate = locationModel.coordinate
//        super.init()
    }
    
    // 프리뷰에서 기본 생성자 사용
    public override convenience init() {
        self.init(date: Date(), musicModel: MusicModel(songID: MusicItemID(rawValue: "123"), title: "", artist: ""), locationModel: LocationModel(locationTitle: "", locationSubtitle: "", coordinate: CLLocationCoordinate2D()))
       }
}


