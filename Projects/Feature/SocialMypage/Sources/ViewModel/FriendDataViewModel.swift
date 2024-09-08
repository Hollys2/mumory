//
//  class FriendDataViewModel.swift
//  Feature
//
//  Created by 제이콥 on 4/1/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import Shared
import MusicKit

class FriendDataViewModel: ObservableObject {
    @Published var friend: UserProfile = UserProfile()
    @Published var playlists: [SongPlaylist] = []
    @Published var isPlaylistLoading: Bool = false
    @Published var isMumoryLoading: Bool = false
    
    init() {
        self.friend = UserProfile()
        self.playlists = []
        self.isPlaylistLoading = false
        self.isMumoryLoading = false
    }
    
    public func savePlaylist() async {
        playlists.removeAll()
        
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        
        let query = db.collection("User").document(friend.uId).collection("Playlist")
            .order(by: "date", descending: false)
        
        guard let snapshot = try? await query.getDocuments() else {return}
        
        for document in snapshot.documents {
            let playlist = SongPlaylist(id: document.documentID, data: document.data())
            
            if playlist.isPublic {
                DispatchQueue.main.async {
                    self.playlists.append(playlist)
                }
            }
            
        }
    }
    
}
