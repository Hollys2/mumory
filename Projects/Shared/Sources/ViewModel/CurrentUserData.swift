//
//  CurrentUserData.swift
//  Feature
//
//  Created by 제이콥 on 2/10/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Core
import MusicKit
import Firebase

public class CurrentUserData: ObservableObject {
    
    //사용자 정보 및 디바이스 크기 정보
    @Published public var uId: String = "" {
        didSet {
            if uId.isEmpty {return}
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
    @Published public var myRewards: [String] = []
    @Published public var favoriteGenres: [Int] = []
    @Published public var playlistArray: [MusicPlaylist] = []

    @Published private var appCoordinator: AppCoordinator = .init()
    
    
    //삭제 예정...
    @Published public var topInset: CGFloat = 0
    @Published public var bottomInset: CGFloat = 0
    @Published public var startAnimation: Bool = false
    
    public init(){}
    
    var friendCollectionListener: ListenerRegistration?
    var friendDocumentListener: ListenerRegistration?
    var notificationListener: ListenerRegistration?
    
    public func fetchRewards(uId: String) {
        DispatchQueue.main.async {
//            self.isUpdating = true
        }
        
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("User").document(uId).collection("Reward")
        
        Task {
            do {
                let snapshot = try await collectionReference.getDocuments()
                
                for document in snapshot.documents {
                    let documentData = document.data()
                    guard let type = documentData["type"] as? String else {
                        DispatchQueue.main.async {
//                            self.isUpdating = false
                        }
                        continue }
                    
                    DispatchQueue.main.async {
                        self.myRewards.append(type)
                    }
                }
                
                print("fetchRewards successfully: \(myRewards)")
            } catch {
                print("Error fetchRewards: \(error.localizedDescription)")
                DispatchQueue.main.async {
//                    self.isUpdating = false
                }
            }
        }
    }
    
    public func fetchRewardListener(user: MumoriUser) -> ListenerRegistration {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("User").document(user.uId).collection("Reward")
        let listener = collectionReference.addSnapshotListener { snapshot, error in
            Task {
                guard let snapshot = snapshot, error == nil else {
                    print("Error fetchRewardListener: \(error!)")
                    return
                }
                
                DispatchQueue.main.async {
                    if !self.myRewards.contains(where: { $0 == "attendance0" }) {
                        self.myRewards.append("attendance0")
                        
                        let data = ["type": "attendance0"]
                        collectionReference.addDocument(data: data)
                        
                        self.reward = .attendance(0)
                        withAnimation(.spring(response: 0.2)) {
                            self.appCoordinator.isRewardPopUpShown = true
                        }
                    }
                }
                
                for documentChange in snapshot.documentChanges {
                    guard documentChange.type == .added else { continue }
                    let documentData = documentChange.document.data()
                    guard let type = documentData["type"] as? String else { continue }
                    let newReward: String = type
                    
                    DispatchQueue.main.async {
                        
                        if !self.myRewards.contains(where: { $0 == type }) {
                            self.myRewards.append(newReward)
                            switch type {
                            case "attendance0":
                                self.reward = .attendance(0)
                            case "attendance1":
                                self.reward = .attendance(1)
                            case "attendance2":
                                self.reward = .attendance(2)
                            case "attendance3":
                                self.reward = .attendance(3)
                            case "attendance4":
                                self.reward = .attendance(4)
                            case "record0":
                                self.reward = .record(0)
                            case "record1":
                                self.reward = .record(1)
                            case "record2":
                                self.reward = .record(2)
                            case "record3":
                                self.reward = .record(3)
                            case "record4":
                                self.reward = .record(4)
                            case "location0":
                                self.reward = .location(0)
                            case "location1":
                                self.reward = .location(1)
                            case "location2":
                                self.reward = .location(2)
                            case "location3":
                                self.reward = .location(3)
                            case "location4":
                                self.reward = .location(4)
                            case "like0":
                                self.reward = .like(0)
                            case "like1":
                                self.reward = .like(1)
                            case "like2":
                                self.reward = .like(2)
                            case "like3":
                                self.reward = .like(3)
                            case "like4":
                                self.reward = .like(4)
                            case "comment0":
                                self.reward = .comment(0)
                            case "comment1":
                                self.reward = .comment(1)
                            case "comment2":
                                self.reward = .comment(2)
                            case "comment3":
                                self.reward = .comment(3)
                            case "comment4":
                                self.reward = .comment(4)
                            default:
                                self.reward = .none
                                break
                            }
                            
                            let pastDate: Date = user.signUpDate
                            let currentDate = Date()
                            
                            let calendar = Calendar.current
                            let components = calendar.dateComponents([.day], from: pastDate, to: currentDate)
                            if let dayDifference = components.day {
                                if dayDifference >= 3 {
                                    let db = FirebaseManager.shared.db
                                    let collectionReference = db.collection("User").document(user.uId).collection("Reward")
                                    let data = ["type": "attendance1"]
                                    collectionReference.addDocument(data: data)
                                }
                                
                                if dayDifference >= 7 {
                                    let db = FirebaseManager.shared.db
                                    let collectionReference = db.collection("User").document(user.uId).collection("Reward")
                                    let data = ["type": "attendance2"]
                                    collectionReference.addDocument(data: data)
                                }
                                
                                if dayDifference >= 14 {
                                    let db = FirebaseManager.shared.db
                                    let collectionReference = db.collection("User").document(user.uId).collection("Reward")
                                    let data = ["type": "attendance3"]
                                    collectionReference.addDocument(data: data)
                                }
                                
                                if dayDifference >= 30 {
                                    let db = FirebaseManager.shared.db
                                    let collectionReference = db.collection("User").document(user.uId).collection("Reward")
                                    let data = ["type": "attendance4"]
                                    collectionReference.addDocument(data: data)
                                }
                            }
                            
                            withAnimation(.spring(response: 0.2)) {
                                self.appCoordinator.isRewardPopUpShown = true
                            }
                            print("fetchRewardListener added: \(self.reward)")
                            
                        }
                    }
                }
            }
        }
        return listener
    }
    
    
    func FriendRequestListener() {
        DispatchQueue.main.async {
            
            let db = FirebaseManager.shared.db
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
        let db = FirebaseManager.shared.db
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
        let db = FirebaseManager.shared.db
        let query = db.collection("User").document(self.uId).collection("Notification")
            .whereField("isRead", isEqualTo: false)
        
        DispatchQueue.main.async {
            self.notificationListener = query.addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {return}
                self.existUnreadNotification = (snapshot.count > 0)
            }
        }
    }
    
    public func savePlaylist() async -> [MusicPlaylist] {
        if self.uId.isEmpty { return [] }
        let Firebase = FirebaseManager.shared
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
                        let date = (data["date"] as? FirebaseManager.Timestamp)?.dateValue() ?? Date()
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
        if self.uId.isEmpty {return}
        let Firebase = FirebaseManager.shared
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
                        let date = (data["date"] as? FirebaseManager.Timestamp)?.dateValue() ?? Date()
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
    
    public func requestMorePlaylistSong(playlistID: String) async -> [Song] {
        if self.uId.isEmpty {return []}

        let db = FirebaseManager.shared.db
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
