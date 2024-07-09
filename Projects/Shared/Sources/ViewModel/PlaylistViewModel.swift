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
    @Published public var playlists: [SongPlaylist] = []

    // MARK: - Methods
//    public func savePlaylist() async -> [SongPlaylist]{
//        if self.uId.isEmpty {return []}
//        let Firebase = FirebaseManager.shared
//        let db = Firebase.db
//        return await withTaskGroup(of: SongPlaylist.self, body: { taskGroup -> [SongPlaylist] in
//            var playlists: [SongPlaylist] = []
//            
//            let query = db.collection("User").document(uId).collection("Playlist")
//                .order(by: "date", descending: false)
//            
//            do {
//                let snapshot = try await query.getDocuments()
//                
//                snapshot.documents.forEach { document in
//                    
//                    taskGroup.addTask {
//                        let data = document.data()
//                        let title = data["title"] as? String ?? ""
//                        let isPublic = data["isPublic"] as? Bool ?? false
//                        let songIDs = data["songIds"] as? [String] ?? []
//                        let date = (data["date"] as? FirebaseManager.Timestamp)?.dateValue() ?? Date()
//                        let id = document.reference.documentID
//                        var playlist = SongPlaylist(id: id, title: title, songIDs: songIDs, isPublic: isPublic, createdDate: date)
//                        let startIndex = 0
//                        var endIndex = playlist.songIDs.endIndex < 4 ? playlist.songIDs.endIndex : 4
//                        let requestSongIds = Array(songIDs[startIndex..<endIndex])
//                        playlist.songs = await FetchManager.shared.fetchSongs(songIds: requestSongIds)
//                        return playlist
//                    }
//                    
//                }
//            } catch {
//                print(error)
//            }
//            
//            for await value in taskGroup {
//                playlists.append(value)
//            }
//            
//            return playlists.sorted(by: {$0.createdDate < $1.createdDate})
//        })
//        
//    }
    
    public func savePlaylist() async {
        if self.uId.isEmpty {return}
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        self.playlists = await withTaskGroup(of: SongPlaylist.self, body: { taskGroup -> [SongPlaylist] in
            var playlists: [SongPlaylist] = []
            let query = db.collection("User").document(uId).collection("Playlist")
                .order(by: "date", descending: false)
            
            do {
                let snapshot = try await query.getDocuments()
                
                snapshot.documents.forEach { document in
                    taskGroup.addTask {
                        let data = document.data()
                        let title = data["title"] as? String ?? ""
                        let isPublic = data["isPublic"] as? Bool ?? false
                        let songs = data["songs"] as? [[String: String]] ?? [[:]]
                        let artistName = data["artistName"] as? String ?? ""
                        let imageURL = data["image"] as? String ?? ""
                        let date = (data["date"] as? FirebaseManager.Timestamp)?.dateValue() ?? Date()
                        let id = document.reference.documentID
                        
                        var songModelList: [SongModel] = []
                        for song in songs {
                            let id: String = song["id"] ?? ""
                            let artistName: String = song["artistName"] ?? ""
                            let imageURL: String = song["image"] ?? ""
                            let title: String = song["image"] ?? ""
                            let songModel = SongModel(id: id, title: title, artistName: artistName, artworkUrl: URL(string: imageURL))
                            songModelList.append(songModel)
                        }
                        return SongPlaylist(id: id, title: title, songs: songModelList, isPublic: isPublic, createdDate: date)
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
    
    public func fetchPlaylistSongs(playlistId: String) async -> [Song]{
        if self.uId.isEmpty {return Array()}
        
        let db = FirebaseManager.shared.db
        let query = db.collection("User").document(uId).collection("Playlist").document(playlistId)
        guard let document = try? await query.getDocument() else {return Array()}
        guard let data = document.data() else {return Array()}
        guard let songIds = data["songIds"] as? [String] else {return Array()}
        
        return await FetchManager.shared.fetchSongs(songIds: songIds)
    }
    
    @MainActor
    public func refreshPlaylist(playlistId: String) async {
        if self.uId.isEmpty {return}
        var songModels: [SongModel] = []

        let db = FirebaseManager.shared.db
        let query = db.collection("User").document(uId).collection("Playlist").document(playlistId)
        guard let document = try? await query.getDocument() else {return}
        guard let data = document.data() else {return}
        
        let songs = data["songs"] as? [[String: String]] ?? [[:]]
        for song in songs {
            let id: String = song["id"] ?? ""
            let artistName: String = song["artistName"] ?? ""
            let imageURL: String = song["image"] ?? ""
            let title: String = song["image"] ?? ""
            let songModel = SongModel(id: id, title: title, artistName: artistName, artworkUrl: URL(string: imageURL))
            songModels.append(songModel)
        }
        
        guard let index = self.playlists.firstIndex(where: {$0.id == playlistId}) else {return}
        self.playlists[index].songs = songModels
    }
    
    public func isFavoriteEmpty() -> Bool {
        guard let favorite = self.playlists.first(where: {$0.id == "favorite"}) else {return false}
        return favorite.songs.isEmpty
    }
    
    public func saveToFavorites(song: Song) {
        let songModel = SongModel(id: song.id.rawValue, title: song.title, artistName: song.artistName, artworkUrl: song.artwork?.url(width: 500, height: 500))
        let songData: [String: Any] = [
            "id": song.id.rawValue,
            "title": song.title,
            "artistName": song.artistName,
            "image": song.artwork?.url(width: 500, height: 500)?.absoluteString
        ]
        let query = FirebaseManager.shared.db.collection("User").document(uId).collection("Playlist").document("favorite")
        query.updateData(["songs": FirebaseManager.Fieldvalue.arrayUnion([songData])])
        guard let favoritePlaylistIndex = self.playlists.firstIndex(where: {$0.id == "favorite"}) else {return}
        self.playlists[favoritePlaylistIndex].songs.append(songModel)
    }
    
    public func getCountOfSongs(id: String) -> Int {
        let playlist: SongPlaylist? = self.playlists.first(where: {$0.id == id})
        let count: Int? = playlist?.songs.count
        return count ?? 0
    }
}
