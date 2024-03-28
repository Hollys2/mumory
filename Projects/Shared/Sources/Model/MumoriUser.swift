//
//  User.swift
//  Shared
//
//  Created by 제이콥 on 3/6/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import SwiftUI
import Core


public struct MumoriUser: Hashable {
    
    public var uId: String = ""
    public var nickname: String = ""
    public var id: String = ""
    public var profileImageURL: URL?
    public var backgroundImageURL: URL?
    public var bio: String = ""
    public var friends: [String] = []
    
    public init() {}
    
    public init(uId: String) async {
        let db = FBManager.shared.db
        guard let document = try? await db.collection("User").document(uId).getDocument() else { return }
        guard let data = document.data() else {
            print("uId: \(uId)")
            self.nickname = "탈퇴계정"
            return
        }
        
        self.uId = uId
        self.nickname = data["nickname"] as? String ?? ""
        self.id = data["id"] as? String ?? ""
        self.profileImageURL = URL(string: data["profileImageURL"] as? String ?? "")
        self.backgroundImageURL = URL(string: data["backgroundImageURL"] as? String ?? "")
        self.bio = data["bio"] as? String ?? ""
    }
    
    public static func == (lhs: MumoriUser, rhs: MumoriUser) -> Bool {
        return lhs.uId == rhs.uId
    }
    
    public func fetchFriend(uId: String) async -> MumoriUser {
        let query = FBManager.shared.db.collection("User").document(self.uId)
        guard let data = try? await query.getDocument().data() else {return MumoriUser()}
        guard let friends = data["friends"] as? [String] else {return MumoriUser()}
        
        var newUser = await MumoriUser(uId: uId)
        newUser.friends = friends
        return newUser
    }
}
