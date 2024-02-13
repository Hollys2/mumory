//
//  MusicPlaylist.swift
//  Shared
//
//  Created by 제이콥 on 2/12/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import MusicKit

public struct MusicPlaylist: Equatable {
    public var id: String
    public var title: String
    public var songs: [Song]
    public var songIDs: [String]
    public var isPrivate: Bool
    public var isFavorite: Bool
    public var isAddItme: Bool
    
    public init(id: String, title: String, songs: [Song], songIDs: [String], isPrivate: Bool, isFavorite: Bool, isAddItme: Bool) {
        self.id = id
        self.title = title
        self.songs = songs
        self.songIDs = songIDs
        self.isPrivate = isPrivate
        self.isFavorite = isFavorite
        self.isAddItme = isAddItme
    }
}
