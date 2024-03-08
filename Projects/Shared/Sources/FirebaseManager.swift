//
//  FirebaseManager.swift
//  Core
//
//  Created by 다솔 on 2023/11/14.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

public class FirebaseManager: ObservableObject {
    
    public static let shared = FirebaseManager()
    
    public let db: Firestore
    public let auth: Auth
    public let storage: Storage
    
    @Published public var friends: [FriendSearch] = []
    @Published public var friendRequests: [FriendSearch] = []
    @Published public var searchedFriend: FriendSearch?
    
    public init() {
        self.db = Firestore.firestore()
        self.auth = Auth.auth()
        self.storage = Storage.storage()
    }
    
    public typealias Timestamp = FirebaseFirestore.Timestamp
    
    public func timestampToString(timestamp: Timestamp) -> String {
        
        let date = timestamp.dateValue()
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
//        let hour = calendar.component(.hour, from: date)
//        let minute = calendar.component(.minute, from: date)
//        let second = calendar.component(.second, from: date)
//        let weekday = calendar.component(.weekday, from: date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeek = dateFormatter.string(from: date)
        
        let result = "\(year)년 \(month)월 \(day)일 \(dayOfWeek)"
        
        return result
    }
    
    public func sendFriendRequest(receiverUserID: String) {
        
        let friendRequestData = [
            "senderID": "tester",
            "nickname": "테스터",
            "timestamp": ServerValue.timestamp()
        ] as [String : Any]
        
        let databaseRef = Database.database().reference()
        let friendRequestsRef = databaseRef.child("users").child(receiverUserID).child("friendRequests").child("tester")
        
        
        friendRequestsRef.setValue(friendRequestData) { (error, ref) in
            if let error = error {
                print("Error sending friend request: \(error.localizedDescription)")
            } else {
                print("Friend request sent successfully!")
            }
        }
    }
    
    public func observeFriendRequests() {
        let databaseRef = Database.database().reference()
        let friendRequestsRef = databaseRef.child("users").child("JJS").child("friendRequests")
        
        friendRequestsRef.observe(.childAdded) { (snapshot) in
            
            if let friendRequestData = snapshot.value as? [String: Any] {
                let senderUID = friendRequestData["senderID"] as? String
                let nickname = friendRequestData["nickname"] as? String

                let newFriendRequest = FriendSearch(nickname: nickname!, id: senderUID!)
                
                if !self.friendRequests.contains(newFriendRequest) {
                    self.friendRequests.append(newFriendRequest)
                    print("New friend request from sender \(senderUID ?? "") with nickname \(nickname ?? "")")
                }
            }
        }
        
        friendRequestsRef.observe(.childRemoved) { (snapshot) in
            if let friendRequestData = snapshot.value as? [String: Any] {
                let senderUID = friendRequestData["senderID"] as? String
                
                // Find and remove the friend request from your local array
                if let index = self.friendRequests.firstIndex(where: { $0.id == senderUID }) {
                    self.friendRequests.remove(at: index)
                    print("Friend request removed from sender \(senderUID ?? "")")
                }
            }
        }
    }
    
    
    public func deleteFriendRequest(receiverUserID: String) {
        let databaseRef = Database.database().reference()
        let friendRequestRef = databaseRef.child("users").child(receiverUserID).child("friendRequests").child("tester")
        
        friendRequestRef.removeValue { error, _ in
            if let error = error {
                print("Error removing friend request: \(error.localizedDescription)")
            } else {
                
                print("Friend request removed successfully!")
            }
        }
    }
    
    
    public func searchFriend(ID: String) {
        
        let db = FirebaseManager.shared.db
        
        let userCollection = db.collection("User")
        
        userCollection.whereField("id", isEqualTo: ID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                if let documents = querySnapshot?.documents {
                    
                    for document in documents {
                        
                        let data = document.data()
                        print("Found user with nickname: \(data)")
                        self.searchedFriend = FriendSearch(nickname: data["nickname"] as! String, id: data["id"] as! String)
                    }
                } else {
                    print("No documents found with nickname 'solda'")
                }
            }
        }
    }
}

public struct FriendSearch: Identifiable, Equatable, Hashable {
    
    public var uid = UUID()
    
    public var nickname: String
    public var id: String
    
    public init(nickname: String, id: String) {
        self.nickname = nickname
        self.id = id
    }
    
    public static func == (lhs: FriendSearch, rhs: FriendSearch) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


public struct FriendRequest: Identifiable {
    
    public let id: String
    public let senderID: String
    public let senderUsername: String
    
    public init(senderID: String, senderUsername: String) {
        self.id = UUID().uuidString
        self.senderID = senderID
        self.senderUsername = senderUsername
    }
    
    public init?(data: [String: Any]?) {
        guard let id = data?["id"] as? String,
              let senderID = data?["senderID"] as? String,
              let senderUsername = data?["senderNickname"] as? String else {
            return nil
        }
        
        self.id = id
        self.senderID = senderID
        self.senderUsername = senderUsername
    }
    
    public func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "senderID": senderID,
            "senderNickname": senderUsername
        ]
    }
}
