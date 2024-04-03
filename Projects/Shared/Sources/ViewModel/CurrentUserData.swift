//
//  CurrentUserData.swift
//  Feature
//
//  Created by 제이콥 on 2/10/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import Core
import MusicKit
import Firebase

public class CurrentUserData: ObservableObject {
    
    //사용자 정보 및 디바이스 크기 정보
    @Published public var uId: String = "" {
        didSet {
            guard !uId.isEmpty else {return}
            DispatchQueue.main.async {
                Task {
                    self.FriendRequestListener()
                    self.NotificationListener()
                    self.FriendUpdateListener()
                
                }
            }
        }
    }
    
    @Published public var user: MumoriUser = MumoriUser()
    
    @Published public var friends: [MumoriUser] = []
    @Published public var blockFriends: [MumoriUser] = []
    @Published public var friendRequests: [MumoriUser] = []
    @Published public var recievedRequests: [MumoriUser] = []
    @Published public var recievedNewFriends: Bool = false
    @Published public var existUnreadNotification: Bool = false
    
    @Published public var reward: Reward = .none
    
    //삭제 예정...
    @Published public var favoriteGenres: [Int] = []
    @Published public var topInset: CGFloat = 0
    @Published public var bottomInset: CGFloat = 0
    @Published public var playlistArray: [MusicPlaylist] = []
    @Published public var startAnimation: Bool = false
    public init(){}
    
    var friendCollectionListener: ListenerRegistration?
    var friendDocumentListener: ListenerRegistration?
    var notificationListener: ListenerRegistration?
    
    
    func FriendRequestListener() {
        DispatchQueue.main.async {
            
            let db = FBManager.shared.db
            self.friendCollectionListener = db.collection("User").document(self.uId).collection("Friend").addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {return}
                self.recievedRequests.removeAll()
                self.friendRequests.removeAll()
                snapshot.documentChanges.forEach { documentChange in
                    let data = documentChange.document.data()
                    guard let type = data["type"] as? String else {return}
                    
                    switch documentChange.type {
                    case .added:
                        if type == "recieve" {
                            guard let friendUId = data["uId"] as? String else {return}
                            Task {
                                let user = await MumoriUser(uId: friendUId)
                                DispatchQueue.main.async {
                                    self.recievedNewFriends = true
                                    self.recievedRequests.append(user)
                                }
                            }
                        } else if type == "request" {
                            guard let friendUId = data["uId"] as? String else {return}
                            Task {
                                let user = await MumoriUser(uId: friendUId)
                                DispatchQueue.main.async {
                                    self.friendRequests.append(user)
                                }
                            }
                        }
                    case .removed:
                        guard let friendUId = data["uId"] as? String else {return}
                        if type == "recieve" {
                            Task {
                                DispatchQueue.main.async {
                                    self.recievedRequests.removeAll(where: {$0.uId == friendUId})
                                }
                            }
                        } else if type == "request" {
                            Task {
                                DispatchQueue.main.async {
                                    self.friendRequests.removeAll(where: {$0.uId == friendUId})
                                }
                            }
                        }
                        
                    default: break
                    }
                }
            }
        }
    }
    
    func FriendUpdateListener() {
        let db = FBManager.shared.db
        DispatchQueue.main.async {
            self.friendDocumentListener = db.collection("User").document(self.uId).addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {return}
                let friendIds = snapshot.get("friends") as? [String] ?? []
                let blockFriendIds = snapshot.get("blockFriends") as? [String] ?? []
                Task {
                    self.friends = await self.fetchFriend(friendIds: friendIds)
                    self.blockFriends = await self.fetchFriend(friendIds: blockFriendIds)
                }
            }
        }
        
    }
    
    func NotificationListener() {
        let db = FBManager.shared.db
        let query = db.collection("User").document(self.uId).collection("Notification")
            .whereField("isRead", isEqualTo: false)
        
        DispatchQueue.main.async {
            self.notificationListener = query.addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {return}
                self.existUnreadNotification = (snapshot.count > 0)
            }
        }
    }
    
    public func savePlaylist() async -> [MusicPlaylist]{
        let Firebase = FBManager.shared
        let db = Firebase.db
        return await withTaskGroup(of: MusicPlaylist.self, body: { taskGroup -> [MusicPlaylist] in
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
                        let date = (data["date"] as? FBManager.TimeStamp)?.dateValue() ?? Date()
                        let id = document.reference.documentID
                        var playlist = MusicPlaylist(id: id, title: title, songIDs: songIDs, isPublic: isPublic, createdDate: date)
                        let startIndex = 0
                        var endIndex = playlist.songIDs.endIndex < 4 ? playlist.songIDs.endIndex : 4
                        let requestSongIds = Array(songIDs[startIndex..<endIndex])
                        playlist.songs = await self.fetchSongs(songIDs: requestSongIds)
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
    
    private func savePlaylist() async {
        let Firebase = FBManager.shared
        let db = Firebase.db
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
                        let date = (data["date"] as? FBManager.TimeStamp)?.dateValue() ?? Date()
                        let id = document.reference.documentID
                        var playlist = MusicPlaylist(id: id, title: title, songIDs: songIDs, isPublic: isPublic, createdDate: date)
                        
                        let startIndex = 0
                        var endIndex = playlist.songIDs.endIndex < 4 ? playlist.songIDs.endIndex : 4
                        let requestSongIds = Array(songIDs[startIndex..<endIndex])
                        playlist.songs = await self.fetchSongs(songIDs: requestSongIds)
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
    
    public func requestMorePlaylistSong(playlistID: String) async -> [Song]{
        let db = FBManager.shared.db
        return await withTaskGroup(of: Song?.self) { taskGroup -> [Song] in
            var returnValue:[Song] = []
            let query = db.collection("User").document(uId).collection("Playlist").document(playlistID)
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
    }
    
    public func refreshPlaylist(playlistId: String) async {
        let db = FBManager.shared.db
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
    public enum FriendStatus{
        case friend
        case notFriend
        case alreadySendRequest
        case alreadyRecieveRequest
        case block
        
    }
    public func getFriendStatus(friend: MumoriUser) -> FriendStatus {
        if self.friends.contains(friend) {
            return .friend
        }else if self.blockFriends.contains(friend) {
            return .block
        }else if self.friendRequests.contains(friend) {
            return .alreadySendRequest
        }else if self.recievedRequests.contains(friend) {
            return .alreadyRecieveRequest
        }else {
            return .notFriend
        }
    }
    
    public func removeAllData(){
        uId = ""
        user = MumoriUser()
        friends.removeAll()
        blockFriends.removeAll()
        friendRequests.removeAll()
        recievedRequests.removeAll()
        recievedNewFriends = false
        existUnreadNotification = false
        favoriteGenres.removeAll()
        playlistArray.removeAll()
        friendCollectionListener?.remove()
        friendDocumentListener?.remove()
        notificationListener?.remove()
    }
    
    private func fetchFriend(friendIds: [String]) async -> [MumoriUser] {
        return await withTaskGroup(of: MumoriUser?.self) { taskGroup -> [MumoriUser] in
            var friendList: [MumoriUser] = []
            for friendId in friendIds {
                taskGroup.addTask {
                    let user = await MumoriUser(uId: friendId)
                    print("friend!!!!! nickname: \(user.nickname)")
                    if user.nickname == "탈퇴계정" {return nil}
                    return user
                }
            }
            for await value in taskGroup {
                guard let user = value else {continue}
                friendList.append(user)
            }
            return friendList
        }
    }
    
    public func fetchSongs(songIDs: [String]) async -> [Song]{
        var returnValue: [Song] = []
        var songIds: [String] = songIDs
        return await withTaskGroup(of: Song?.self) { taskGroup -> [Song] in
            for id in songIDs {
                taskGroup.addTask {
                    let musicItemID = MusicItemID(rawValue: id)
                    let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
                    guard let response = try? await request.response() else {return nil}
                    return response.items.first
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

    }
}
