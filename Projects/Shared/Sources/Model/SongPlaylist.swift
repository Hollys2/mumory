//
//  SongPlaylist.swift
//  Shared
//
//  Created by 제이콥 on 2/12/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import MusicKit

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
    
    public init(id: String, data: [String: Any]) {
        self.id = id
        self.title = data["title"] as? String ?? ""
        self.isPublic = data["isPublic"] as? Bool ?? false
        self.createdDate = (data["date"] as? FirebaseManager.Timestamp)?.dateValue() ?? Date()
        self.songs = []
        
        let songDataList = data["songs"] as? [[String: String]] ?? [[:]]
        for songData in songDataList {
            let id: String = songData["id"] ?? ""
            let title: String = songData["title"] ?? ""
            let artist: String = songData["artist"] ?? ""
            let artworkURL: String = songData["artworkUrl"] ?? ""
            let song: SongModel = SongModel(id: id, title: title, artist: artist, artworkUrl: URL(string: artworkURL))
            self.songs.append(song)
        }
    }
    
    public var id: String
    public var title: String
    public var songs: [SongModel]
    public var isPublic: Bool
    public var createdDate: Date
}
