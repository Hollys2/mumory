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
    public static func == (lhs: MumoriUser, rhs: MumoriUser) -> Bool {
        return lhs.uId == rhs.uId
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uId)
    }
    
    public var uId: String = ""
    public var nickname: String = "탈퇴계정"
    public var id: String = ""
    public var profileImageURL: URL?
    public var backgroundImageURL: URL?
    public var bio: String = ""
    public var defaultProfileImage: Image = randomProfiles[0]
    
    public var friends: [String] = []//deprecated
    
    public init() {}
    
    public init(uId: String) async {
        self.uId = uId
        
        let db = FBManager.shared.db
        
        if uId.isEmpty {
            nickname = "(알수없음)"
            return
        }else {
            let query = db.collection("User").whereField("uid", isEqualTo: uId)
            guard let snapshot = try? await query.getDocuments() else {return}
            guard let userDoc = snapshot.documents.first else {
                nickname = "탈퇴계정"
                return
            }
            let data = userDoc.data()
            
            self.nickname = data["nickname"] as? String ?? ""
            self.id = data["id"] as? String ?? ""
            self.profileImageURL = URL(string: data["profileImageURL"] as? String ?? "")
            self.backgroundImageURL = URL(string: data["backgroundImageURL"] as? String ?? "")
            self.bio = data["bio"] as? String ?? ""
            let profileIndex: Int = data["profileIndex"] as? Int ?? 0
            self.defaultProfileImage = randomProfiles[profileIndex]
        }
    }

}

public let randomProfiles: [Image] = [SharedAsset.profileRed.swiftUIImage, SharedAsset.profilePurple.swiftUIImage, SharedAsset.profileYellow.swiftUIImage, SharedAsset.profileOrange.swiftUIImage]
