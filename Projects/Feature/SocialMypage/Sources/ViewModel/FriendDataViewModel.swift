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
    @Published var playlistArray: [SongPlaylist] = []
    @Published var isPlaylistLoading: Bool = false
    @Published var isMumoryLoading: Bool = false
    
    init() {
        self.friend = UserProfile()
        self.playlistArray = []
        self.isPlaylistLoading = false
        self.isMumoryLoading = false
    }
    
    public func savePlaylist(uId: String) async -> [SongPlaylist]{
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        return await withTaskGroup(of: SongPlaylist.self, body: { taskGroup -> [SongPlaylist] in
            var playlists: [SongPlaylist] = []
            
            let query = db.collection("User").document(uId).collection("Playlist")
                .order(by: "date", descending: false)
            
            do {
                let snapshot = try await query.getDocuments()
                
                for document in snapshot.documents {
                    let data = document.data()
                    let isPublic = data["isPublic"] as? Bool ?? false
                    if !isPublic {continue}
                    taskGroup.addTask {
                        let data = document.data()
                        let title = data["title"] as? String ?? ""
                        let isPublic = data["isPublic"] as? Bool ?? false
                        let songIDs = data["songIds"] as? [String] ?? []
                        let date = (data["date"] as? FirebaseManager.Timestamp)?.dateValue() ?? Date()
                        let id = document.reference.documentID
                        var playlist = SongPlaylist(id: id, title: title, songIDs: songIDs, isPublic: isPublic, createdDate: date)
                        
                        let startIndex = 0
                        var endIndex = playlist.songIDs.endIndex < 4 ? playlist.songIDs.endIndex : 4
                        let requestSongIds = Array(songIDs[startIndex..<endIndex])
                        playlist.songs = await fetchSongs(songIDs: requestSongIds)
                        
                        return playlist
                    }

                }
    
            } catch {
                print(error)
            }
            
            for await value in taskGroup {
                playlists.append(value)
            }
            
            return playlists.sorted(by: {$0.createdDate < $1.createdDate})
        })
        
    }

}
