//
//  FriendManager.swift
//  Shared
//
//  Created by 다솔 on 2024/03/17.
//  Copyright © 2024 hollys. All rights reserved.
//


import Foundation

public class FriendManager: ObservableObject {
    
//    @Published public var searchedFriend: MumoriUser?
    @Published public var searchedFriends: [MumoriUser] = []
    
    public init() {}
    
    public func searchFriend(nickname: String) {
        let db = FirebaseManager.shared.db
        let userCollection = db.collection("User").whereField("nickname", isGreaterThanOrEqualTo: nickname)
            .whereField("nickname", isLessThan: nickname + "\u{f8ff}")

        
        userCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                if let documents = querySnapshot?.documents {
                    
                    for document in documents {
                        
                        let data = document.data()
                        
                        print("Found user with nickname: \(document.documentID)")
                        
                        DispatchQueue.main.async {
                            Task {
                                self.searchedFriends.append(await MumoriUser(uid: document.documentID))
                            }
                        }
                    }
                } else {
                    print("No documents found with nickname 'solda'")
                }
            }
        }
    }
}
