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
    public var songIDs: [String]
    public var isPublic: Bool
    public var isAddItme: Bool
    
    public init(id: String, title: String, songIDs: [String], isPublic: Bool, isAddItme: Bool) {
        self.id = id
        self.title = title
        self.songIDs = songIDs
        self.isPublic = isPublic
        self.isAddItme = isAddItme
    }
}
