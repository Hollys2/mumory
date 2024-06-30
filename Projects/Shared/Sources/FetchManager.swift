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
    
    public func fetchUsers(uIds: [String]) async -> [UserProfile] {
        return await withTaskGroup(of: UserProfile?.self) { taskGroup -> [UserProfile] in
            var returnUsers: [UserProfile] = []
            for id in uIds {
                taskGroup.addTask {
                    let user = await FetchManager.shared.fetchUser(uId: id)
                    if user.nickname == "탈퇴계정" {return nil}
                    return user
                }
            }
            for await value in taskGroup {
                guard let user = value else {continue}
                returnUsers.append(user)
            }
            return returnUsers
        }
    }
    
    public func fetchUser(uId: String) async -> UserProfile{
        let db = FirebaseManager.shared.db
        
        let query = db.collection("User").whereField("uid", isEqualTo: uId)
        do {
            let snapshot = try await query.getDocuments()
            if snapshot.isEmpty {
                return UserProfile(uId: "",
                                   nickname: "탈퇴계정",
                                   id: "",
                                   defaultProfileImage: SharedAsset.profileWithdrawed.swiftUIImage,
                                   signUpDate: Date())
            }

            guard let data = snapshot.documents.first?.data() else {return UserProfile()}
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
            return UserProfile()
        }
    }
    
    public func fetchSongs(songIds: [String]) async -> [Song]{
        var returnValue: [Song] = []
        var songIds: [String] = songIds
        return await withTaskGroup(of: Song?.self) { taskGroup -> [Song] in
            for id in songIds {
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

    public func isNewUser(email: String, method: SignInMethod) async -> Bool {
        let db = FirebaseManager.shared.db
        var methodName: String = ""
        
        switch method {
        case .none:
            methodName =  ""
        case .kakao:
            methodName =  "Kakao"
        case .email:
            methodName = "Email"
        case .google:
            methodName = "Google"
        case .apple:
            methodName = "Apple"
        }
        
        let query = db.collection("User")
            .whereField("email", isEqualTo: email)
            .whereField("signInMethod", isEqualTo: methodName)
        
        guard let snapshot = try? await query.getDocuments() else {return false}
        return snapshot.documents.isEmpty
    }
    
}


