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


public struct MumoriUser: Hashable{
    public static func == (lhs: MumoriUser, rhs: MumoriUser) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    public var uid: String = ""
    public var nickname: String = ""
    public var id: String = ""
    public var profileImageURL: URL?
    public var backgroundImageURL: URL?
    public var bio: String = ""
    
    public init() {}
    
    public init(uid: String) async {
        self.uid = uid
        
        let db = FBManager.shared.db
        
        guard let document = try? await db.collection("User").document(uid).getDocument() else {
            return
        }
        guard let data = document.data() else {
            return
        }
        
        self.nickname = data["nickname"] as? String ?? ""
        self.id = data["id"] as? String ?? ""
        self.profileImageURL = URL(string: data["profileImageURL"] as? String ?? "")
        self.backgroundImageURL = URL(string: data["backgroundImageURL"] as? String ?? "")
        self.bio = data["bio"] as? String ?? ""
    }
}

extension MumoriUser {
    
//    static func fromDocumentDataToMumory(_ documentData: [String: Any], uId: String) async -> MumoriUser? {
//        
//        guard let id = documentData["id"] as? String,
//              let nickname = documentData["nickname"] as? String,
//              let profileImageURL = documentData["profileImageURL"] as? URL else { return nil }
//        
//        return await self.init(uid: uId)
//    }
}
