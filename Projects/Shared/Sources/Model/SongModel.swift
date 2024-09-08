//
//  SongModel.swift
//  Shared
//
//  Created by 제이콥 on 7/8/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation

public struct SongModel: Equatable, Hashable, Identifiable {
    public init(id: String, title: String, artist: String, artworkUrl: URL?) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artworkUrl = artworkUrl
    }
    
    public init (_ data: [String: Any]) {
        self.id = data["id"] as? String ?? ""
        self.title = data["title"] as? String ?? ""
        self.artist = data["artist"] as? String ?? ""
        self.artworkUrl = URL(string: data["artworkUrl"] as? String ?? "")

    }
    public let id: String
    public let title: String
    public let artist: String
    public let artworkUrl: URL?
}
