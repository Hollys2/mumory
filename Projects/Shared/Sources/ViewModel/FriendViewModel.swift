//
//  FriendViewModel.swift
//  Shared
//
//  Created by 제이콥 on 6/18/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import Firebase

public enum FriendStatus{
    case friend
    case notFriend
    case alreadySendRequest
    case alreadyRecieveRequest
    case block
    
}

public class FriendViewModel: ObservableObject {
    // MARK: - Object lifecycle
    public init(){}
    public init(uId: String) {
        self.uId = uId
    }
    
    // MARK: - Propoerties
    private var uId: String = ""
    @Published public var friends: [UserProfile] = []
    @Published public var blockFriends: [UserProfile] = []
    @Published public var friendRequests: [UserProfile] = []
    @Published public var recievedRequests: [UserProfile] = []
    @Published public var recievedNewFriends: Bool = false
    
    var friendCollectionListener: ListenerRegistration?
    var friendDocumentListener: ListenerRegistration?
    var notificationListener: ListenerRegistration?
    
    // MARK: - Methods
    public func FriendRequestListener() {
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
                                let user = await UserProfile()
                                DispatchQueue.main.async {
                                    self.recievedNewFriends = true
                                    self.recievedRequests.append(user)
                                }
                            }
                        } else if type == "request" {
                            guard let friendUId = data["uId"] as? String else {return}
                            Task {
                                let user = await UserProfile()
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
    
    func FriendUpdateListener() {
        let db = FirebaseManager.shared.db
        DispatchQueue.main.async {
            self.friendDocumentListener = db.collection("User").document(self.uId).addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {return}
                let friendIds = snapshot.get("friends") as? [String] ?? []
                let blockFriendIds = snapshot.get("blockFriends") as? [String] ?? []
                Task {
                    self.friends = await FetchManager.shared.fetchUsers(uIds: friendIds)
                    self.blockFriends = await FetchManager.shared.fetchUsers(uIds: blockFriendIds)
                }
            }
        }
        
    }
    

    
    public func getFriendStatus(friend: UserProfile) -> FriendStatus {
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
    
}
