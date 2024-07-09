//
//  SongModel.swift
//  Shared
//
//  Created by 제이콥 on 7/8/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation

public struct SongModel: Equatable, Hashable, Identifiable {
    public init(id: String, title: String, artistName: String, artworkUrl: URL?) {
        self.id = id
        self.title = title
        self.artistName = artistName
        self.artworkUrl = artworkUrl
    }
    public let id: String
    public let title: String
    public let artistName: String
    public let artworkUrl: URL?
}
