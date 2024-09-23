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
    
    public func fetchUser(uId: String) async -> UserProfile {
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
    
    public func fetchSong(songId: String) async -> Song? {
        let musicItemID = MusicItemID(rawValue: songId)
        var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
        request.properties = [.genres, .artists]
        guard let response = try? await request.response() else { return nil }
        guard let song = response.items.first else { return nil }
        
        return song
    }
    
    public func fetchSongs(songIds: [String]) async -> [Song] {
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
        print(email)
        let query = db.collection("User")
            .whereField("email", isEqualTo: email)
            .whereField("signInMethod", isEqualTo: methodName)
        
        guard let snapshot = try? await query.getDocuments() else {return false}
        return snapshot.documents.isEmpty
    }
    
    
    public func fetchMumory(documentID: String?) async throws -> Mumory {
        guard let documentID = documentID else {
            throw FetchError.documentIdError
        }
        
        let db = FirebaseManager.shared.db
        let docRef = db.collection("Mumory").document(documentID)
        
        guard let documentSnapshot = try? await docRef.getDocument() else {
            throw FetchError.getDocumentError
        }
        
        guard documentSnapshot.exists else {
            throw FetchError.documentNotFound
        }
        
        guard let mumory = try? documentSnapshot.data(as: Mumory.self) else {
            throw FetchError.decodingError
        }
        
        return mumory
    }
    
    public func fetchCommentAndReply(DocumentID: String?) async throws -> [Comment] {
        guard let DocumentID = DocumentID else {
            throw FetchError.documentIdError
        }
        
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Mumory").document(DocumentID).collection("Comment")
            .order(by: "date", descending: false)
        
        do {
            let querySnapshot = try await collectionReference.getDocuments()
            var comments: [Comment] = []
            for document in querySnapshot.documents {
                let newComment = try document.data(as: Comment.self)
                comments.append(newComment)
            }
            
            return comments
        } catch {
            throw error
        }
    }
    //    public func updateMumory(_ mumory: Mumory, completion: @escaping (Result<Void, Error>) -> Void) {
    public func fetchReward(user: UserProfile, completion: @escaping (Result<[String], Error>) -> Void) async {
        
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("User").document(user.uId).collection("Reward")
        
        var rewards: [String] = []
        
        do {
            let querySnapshot = try await collectionReference.getDocuments()
            
            for document in querySnapshot.documents {
                let documentData = document.data()
                guard let reward: String = documentData["type"] as? String else {
                    continue
                }
                rewards.append(reward)
            }
            
            completion(.success(rewards))
            
        } catch {
            completion(.failure(error))
        }
    }
    
    public func fetchActivitys(uId: String) {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("User").document(uId).collection("Activity")
        
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
                    
                    let newResult = (document.documentID, type)
                    DispatchQueue.main.async {
//                        self.myActivity.append(newResult)
                    }
                }
                
//                print("fetchActivitys successfully: \(myActivity)")
            } catch {
                print("Error fetchActivitys: \(error.localizedDescription)")
                DispatchQueue.main.async {
//                    self.isUpdating = false
                }
            }
        }
    }

}


