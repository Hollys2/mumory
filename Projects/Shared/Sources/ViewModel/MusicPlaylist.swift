//
//  SongPlaylist.swift
//  Shared
//
//  Created by 제이콥 on 2/12/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import MusicKit

//public struct SongPlaylist: Equatable, Hashable {
//    public var id: String
//    public var title: String
//    public var songIDs: [String]
//    public var isPublic: Bool
//    public var songs: [Song] = []
//    public var createdDate: Date
//    
//    public init(id: String, title: String, songIDs: [String], isPublic: Bool, createdDate: Date) {
//        self.id = id
//        self.title = title
//        self.songIDs = songIDs
//        self.isPublic = isPublic
//        self.createdDate = createdDate
//    }
//    
//    public init(id: String, title: String, songIDs: [String], isPublic: Bool, songs: [Song], createdDate: Date) {
//        self.id = id
//        self.title = title
//        self.songIDs = songIDs
//        self.isPublic = isPublic
//        self.songs = songs
//        self.createdDate = createdDate
//    }
//}

public struct SongPlaylist: Equatable, Hashable {
    public static func == (lhs: SongPlaylist, rhs: SongPlaylist) -> Bool {
        return lhs.id == lhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public init(id: String, title: String, songs: [SongModel], isPublic: Bool, createdDate: Date) {
        self.id = id
        self.title = title
        self.songs = songs
        self.isPublic = isPublic
        self.createdDate = createdDate
    }
    
    public var id: String
    public var title: String
    public var songs: [SongModel]
    public var isPublic: Bool
    public var createdDate: Date
}
