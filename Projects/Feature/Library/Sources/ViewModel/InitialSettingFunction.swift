//
//  InitialSettingFunction.swift
//  Feature
//
//  Created by 제이콥 on 4/5/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import MusicKit
import Shared

func setSimilarTaste() async {
    var songs: [Song] = []
    var songIds = songs.map { $0.id.rawValue }
    songIds = Array(songIds.prefix(20))
    try? await  FBManager.shared.db.collection("User").document("adminFavoriteGenres")
        .setData(["favoriteGenres": MusicGenreHelper().genres.map({$0.id})])
    
    try? await FBManager.shared.db.collection("User").document("adminFavoriteGenres").collection("Playlist").document("favorite").setData(["songIds": songIds])
}



