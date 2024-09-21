//
//  PlaylistViewModel.swift
//  Shared
//
//  Created by 제이콥 on 6/18/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import MusicKit

public class PlaylistViewModel: ObservableObject {
    // MARK: - Object lifecycle
    public init(){}
    public init(uId: String) {
        self.uId = uId
    }
    
    // MARK: - Propoerties
    private var uId: String = ""
    @Published public var favoriteGenres: [Int] = []
    @Published public var playlistArray: [MusicPlaylist] = []

    // MARK: - Methods
    public func savePlaylist() {
        if self.uId.isEmpty {return}
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        Task {
            self.playlistArray = await withTaskGroup(of: MusicPlaylist.self, body: { taskGroup -> [MusicPlaylist] in
                var playlists: [MusicPlaylist] = []
                
                let query = db.collection("User").document(uId).collection("Playlist")
                    .order(by: "date", descending: false)
                
                do {
                    let snapshot = try await query.getDocuments()
                    
                    snapshot.documents.forEach { document in
                        
                        taskGroup.addTask {
                            let data = document.data()
                            let title = data["title"] as? String ?? ""
                            let isPublic = data["isPublic"] as? Bool ?? false
                            let songIDs = data["songIds"] as? [String] ?? []
                            let date = (data["date"] as? FirebaseManager.Timestamp)?.dateValue() ?? Date()
                            let id = document.reference.documentID
                            var playlist = MusicPlaylist(id: id, title: title, songIDs: songIDs, isPublic: isPublic, createdDate: date)
                            
                            let startIndex = 0
                            var endIndex = playlist.songIDs.endIndex < 4 ? playlist.songIDs.endIndex : 4
                            let requestSongIds = Array(songIDs[startIndex..<endIndex])
                            playlist.songs = await FetchManager.shared.fetchSongs(songIds: requestSongIds)
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
    
    public func fetchPlaylistSongs(playlistId: String) async -> [Song]{
        if self.uId.isEmpty {return Array()}
        
        let db = FirebaseManager.shared.db
        let query = db.collection("User").document(uId).collection("Playlist").document(playlistId)
        guard let document = try? await query.getDocument() else {return Array()}
        guard let data = document.data() else {return Array()}
        guard let songIds = data["songIds"] as? [String] else {return Array()}
        
        return await FetchManager.shared.fetchSongs(songIds: songIds)
    }
    
    public func refreshPlaylist(playlistId: String) async {
        if self.uId.isEmpty {return}

        let db = FirebaseManager.shared.db
        let songs = await withTaskGroup(of: Song?.self) { taskGroup -> [Song] in
            var returnValue:[Song] = []
            let query = db.collection("User").document(uId).collection("Playlist").document(playlistId)
            guard let document = try? await query.getDocument() else {return returnValue}
            guard let data = document.data() else {return returnValue}
            
            var songIds = data["songIds"] as? [String] ?? []
            for id in songIds {
                taskGroup.addTask {
                    let musicItemID = MusicItemID(rawValue: id)
                    var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
                    guard let response = try? await request.response() else {return nil}
                    guard let song = response.items.first else {return nil}
                    return song
                }
            }
            
            for await value in taskGroup {
                guard let song = value else {continue}
                returnValue.append(song)
            }
            songIds.removeAll { songId in
                return !returnValue.contains(where: {$0.id.rawValue == songId})
            }
            var songs = songIds.map { songId in
                return returnValue.first(where: {$0.id.rawValue == songId})!
            }
            
            return songs
        }
        guard let index = self.playlistArray.firstIndex(where: {$0.id == playlistId}) else {return}
        DispatchQueue.main.async {
            self.playlistArray[index].songs = songs
        }
    }
    
    public func isFavoriteEmpty() -> Bool {
        guard let favorite = self.playlistArray.first(where: {$0.id == "favorite"}) else {return false}
        return favorite.songs.isEmpty
    }
    
    public func fetchFavoriteGenres() {
        if self.uId.isEmpty {return}
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        let query = db.collection("User").document(self.uId)
        
        query.getDocument { snapshot, error in
            guard let data = snapshot?.data() else {return}
            guard let favoriteGenres = data["favoriteGenres"] as? [Int] else {return}
            DispatchQueue.main.async {
                self.favoriteGenres = favoriteGenres
            }
        }
    }
    
    public func fetchSongIds(playlistId: String) async {
        let db = FirebaseManager.shared.db
        guard let uId = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        let query = db.collection("User").document(uId).collection("Playlist").document(playlistId)
        guard let document = try? await query.getDocument() else {
            return
        }
        guard let data = document.data() else {
            return
        }
        guard let songIds = data["songIds"] as? [String] else {
            return
        }
        
        guard let index = self.playlistArray.firstIndex(where: {$0.id == playlistId}) else {
            return
        }
        
        self.playlistArray[index].songIDs = songIds
    }
}
