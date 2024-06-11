//
//  FetchManager.swift
//  Shared
//
//  Created by 제이콥 on 6/11/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import MusicKit
import SwiftUI

/// 서버 통신 관련 메서드 관리 객체
public class FetchManager {
    public static let shared = FetchManager()
    
   
    
    public func fetchUser(uId: String) async -> UserProfile{
        let db = FirebaseManager.shared.db
        
        let query = db.collection("User").whereField("uid", isEqualTo: uId)
        do {
            let snapshot = try await query.getDocuments()
            guard let document = snapshot.documents.first else {
                let withdrawedUserModel = UserProfile(uId: "",
                                                    nickname: "탈퇴계정",
                                                    id: "",
                                                    defaultProfileImage: SharedAsset.profileWithdrawed.swiftUIImage,
                                                    signUpDate: Date())
                return withdrawedUserModel
            }
            
            let data = document.data()
            let userModel = UserProfile(uId: uId,
                                      nickname: data["nickname"] as? String ?? "기본닉네임",
                                      id: data["id"] as? String ?? "",
                                      profileImageURL: URL(string: data["profileImageURL"] as? String ?? ""),
                                      backgroundImageURL: URL(string: data["backgroundImageURL"] as? String ?? ""),
                                      bio: data["bio"] as? String ?? "",
                                      defaultProfileImage: randomProfiles[data["profileIndex"] as? Int ?? 0],
                                      signUpDate: (data["signUpDate"] as? FirebaseManager.Timestamp)?.dateValue() ?? Date())
            return userModel

        } catch {
            return UserProfile(uId: "",
                             nickname: "UNKNOWN",
                             id: "",
                             defaultProfileImage: SharedAsset.profileWithdrawed.swiftUIImage,
                             signUpDate: Date())
        }
        

        


    }

}
