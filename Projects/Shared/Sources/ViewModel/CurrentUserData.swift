//
//  CurrentUserData.swift
//  Feature
//
//  Created by 제이콥 on 2/10/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import Core

public class CurrentUserData: ObservableObject {
    //사용자 정보 및 디바이스 크기 정보
    @Published public var uId: String = "" {
        didSet {
            DispatchQueue.main.async {
                Task{
                    self.user = await MumoriUser(uId: self.uId)
                }
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
    @Published public var friendRequests: [MumoriUser] = []
    @Published public var recievedRequests: [MumoriUser] = []
    @Published public var recievedNewFriends: Bool = false
    @Published public var recievedNewNotifications: Bool = false
    
    //삭제 예정...
    @Published public var favoriteGenres: [Int] = []
    @Published public var topInset: CGFloat = 0
    @Published public var bottomInset: CGFloat = 0
    @Published public var playlistArray: [MusicPlaylist] = []
    
    
    func FriendRequestListener() {
        DispatchQueue.main.async {
            
            let db = FBManager.shared.db
            db.collection("User").document(self.uId).collection("Friend").addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {return}
                snapshot.documentChanges.forEach { documentChange in
                    switch documentChange.type {
                    case .added:
                        let data = documentChange.document.data()
                        guard let type = data["type"] as? String else {return}
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
                    default: break
                    }
                }
            }
        }
    }
    
    func FriendUpdateListener() {
        DispatchQueue.main.async {
            let db = FBManager.shared.db
            db.collection("User").document(self.uId).addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {return}
                guard let friendIds = snapshot.get("friends") as? [String] else {return}
                self.friends.removeAll()
                friendIds.forEach { uid in
                    Task {
                        let user = await MumoriUser(uId: uid)
                        DispatchQueue.main.async {
                            self.friends.append(user)
                        }
                    }
                    
                }
            }
        }
    }
    
    func NotificationListener() {
        DispatchQueue.main.async {
            let db = FBManager.shared.db
            db.collection("User").document(self.uId).collection("Notification").addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {return}
                snapshot.documentChanges.forEach { documentChange in
                    switch documentChange.type {
                    case .added:
                        let data = documentChange.document.data()
                        DispatchQueue.main.async {
                            self.recievedNewNotifications = true
                        }
                    default: break
                    }
                }
            }
        }
    }
    
    public init(){
    }

}
