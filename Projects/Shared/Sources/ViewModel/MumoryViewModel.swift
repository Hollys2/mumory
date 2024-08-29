//
//  MumoryViewModel.swift
//  Shared
//
//  Created by 다솔 on 2024/06/11.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import Combine
import MapKit
import MusicKit
import Firebase
import FirebaseFirestore


@MainActor
final public class MumoryViewModel: FirebaseManager, ObservableObject {
    
    @Published public var myMumorys: [Mumory] = []
    @Published public var friendMumorys: [Mumory] = []
    @Published public var locationMumorys: [String: [Mumory]] = [:]
    @Published public var sameSongFriendMumorys: [Mumory] = []
    @Published public var socialMumorys: [Mumory] = []
    @Published public var monthlyMumorys: [Mumory] = []
    @Published public var surroundingMumorys: [Mumory] = []
    
    @Published public var mumoryComments: [Comment] = []
    @Published public var mumoryCarouselAnnotations: [Mumory] = []
    @Published public var searchedMumoryAnnotations: [Mumory] = []
    
    @Published public var favoriteDate: [Date] = []
    
    //    @Published public var myActivity: [(String, String)] = []
    //    @Published public var myRewards: [String] = []
    
    private var tempMumory: [Mumory] = []
    private var lastDocument: DocumentSnapshot?
    
    public override init() {
        super.init()
    }
    
    public func fetchMyMumoryListener(uId: String, rewards: [Reward]) -> ListenerRegistration {
        let collectionReference = self.db.collection("Mumory")
        
        let query = collectionReference
            .whereField("uId", isEqualTo: uId)
            .order(by: "date", descending: true)
        
        let listener = query.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("Error fetchMumoryListener: \(error!)")
                return
            }
            
            for documentChange in snapshot.documentChanges {
                switch documentChange.type {
                case .added:
                    do {
                        let newMumory = try documentChange.document.data(as: Mumory.self)
                        
                        self.myMumorys.append(newMumory)
                        self.myMumorys.sort { $0.date > $1.date }
                        
                        let collectionReference = self.db.collection("User").document(uId).collection("Reward")
                        
                        if self.myMumorys.count == 1, !rewards.contains(where: { $0 == Reward(type: .record(0))}) {
                            do {
                                try collectionReference.addDocument(from: Reward(type: .record(0)))
                            } catch {
                                print("ERROR fetchMyMumoryListener: \(error)")
                            }
                        } else if self.myMumorys.count == 5, !rewards.contains(where: { $0 == Reward(type: .record(1))}) {
                            do {
                                try collectionReference.addDocument(from: Reward(type: .record(1)))
                            } catch {
                                print("ERROR fetchMyMumoryListener: \(error)")
                            }
                        } else if self.myMumorys.count == 10, !rewards.contains(where: { $0 == Reward(type: .record(2))}) {
                            do {
                                try collectionReference.addDocument(from: Reward(type: .record(2)))
                            } catch {
                                print("ERROR fetchMyMumoryListener: \(error)")
                            }
                        } else if self.myMumorys.count == 20, !rewards.contains(where: { $0 == Reward(type: .record(3))}) {
                            do {
                                try collectionReference.addDocument(from: Reward(type: .record(3)))
                            } catch {
                                print("ERROR fetchMyMumoryListener: \(error)")
                            }
                        } else if self.myMumorys.count == 50, !rewards.contains(where: { $0 == Reward(type: .record(4))}) {
                            do {
                                try collectionReference.addDocument(from: Reward(type: .record(4)))
                            } catch {
                                print("ERROR fetchMyMumoryListener: \(error)")
                            }
                        }
                        
                        var country = newMumory.location.country
                        let administrativeArea = newMumory.location.administrativeArea
                        if country != "대한민국" {
                            if country == "영국" {
                                country += " 🇬🇧"
                            } else if country == "미 합중국" {
                                country = "미국 🇺🇸"
                            } else if country == "이탈리아" {
                                country += " 🇮🇹"
                            } else if country == "프랑스" {
                                country += " 🇫🇷"
                            } else if country == "독일" {
                                country += " 🇩🇪"
                            } else if country == "일본" {
                                country += " 🇯🇵"
                            } else if country == "중국" {
                                country += " 🇨🇳"
                            } else if country == "캐나다" {
                                country += " 🇨🇦"
                            } else if country == "오스트레일리아" {
                                country += " 🇦🇹"
                            } else if country == "브라질" {
                                country += " 🇧🇷"
                            } else if country == "인도" {
                                country += " 🇮🇳"
                            } else if country == "러시아" {
                                country += " 🇷🇺"
                            } else if country == "우크라이나" {
                                country += " 🇺🇦"
                            } else if country == "호주" {
                                country += " 🇦🇺"
                            } else if country == "멕시코" {
                                country += " 🇲🇽"
                            } else if country == "인도네시아" {
                                country += " 🇮🇩"
                            } else if country == "터키" {
                                country += " 🇹🇷"
                            } else if country == "사우디아라비아" {
                                country += " 🇸🇦"
                            } else if country == "스페인" {
                                country += " 🇪🇸"
                            } else if country == "네덜란드" {
                                country += " 🇳🇱"
                            } else if country == "스위스" {
                                country += " 🇨🇭"
                            } else if country == "아르헨티나" {
                                country += " 🇦🇷"
                            } else if country == "스웨덴" {
                                country += " 🇸🇪"
                            } else if country == "폴란드" {
                                country += " 🇵🇱"
                            } else if country == "벨기에" {
                                country += " 🇧🇪"
                            } else if country == "태국" {
                                country += " 🇹🇭"
                            } else if country == "이란" {
                                country += " 🇮🇷"
                            } else if country == "오스트리아" {
                                country += " 🇦🇹"
                            } else if country == "노르웨이" {
                                country += " 🇳🇴"
                            } else if country == "아랍에미리트" {
                                country += " 🇦🇪"
                            } else if country == "나이지리아" {
                                country += " 🇳🇬"
                            } else if country == "남아프리카공화국" {
                                country += " 🇿🇦"
                            } else {
                                country = "기타 🏁"
                            }
                            
                            if var countryMumories = self.locationMumorys[country] {
                                countryMumories.append(newMumory)
                                self.locationMumorys[country] = countryMumories
                            } else {
                                self.locationMumorys[country] = [newMumory]
                                
                                if self.locationMumorys.count == 2, !rewards.contains(where: { $0 == Reward(type: .location(0))}) {
                                    do {
                                        try collectionReference.addDocument(from: Reward(type: .location(0)))
                                    } catch {
                                        print("ERROR fetchMyMumoryListener: \(error)")
                                    }
                                } else if self.locationMumorys.count == 3, !rewards.contains(where: { $0 == Reward(type: .location(1))}) {
                                    do {
                                        try collectionReference.addDocument(from: Reward(type: .location(1)))
                                    } catch {
                                        print("ERROR fetchMyMumoryListener: \(error)")
                                    }
                                } else if self.locationMumorys.count == 5, !rewards.contains(where: { $0 == Reward(type: .location(2))}) {
                                    do {
                                        try collectionReference.addDocument(from: Reward(type: .location(2)))
                                    } catch {
                                        print("ERROR fetchMyMumoryListener: \(error)")
                                    }
                                } else if self.locationMumorys.count == 10, !rewards.contains(where: { $0 == Reward(type: .location(3))}) {
                                    do {
                                        try collectionReference.addDocument(from: Reward(type: .location(3)))
                                    } catch {
                                        print("ERROR fetchMyMumoryListener: \(error)")
                                    }
                                } else if self.locationMumorys.count == 15, !rewards.contains(where: { $0 == Reward(type: .location(4))}) {
                                    do {
                                        try collectionReference.addDocument(from: Reward(type: .location(4)))
                                    } catch {
                                        print("ERROR fetchMyMumoryListener: \(error)")
                                    }
                                }
                            }
                        } else {
                            if var countryMumories = self.locationMumorys[administrativeArea] {
                                countryMumories.append(newMumory)
                                self.locationMumorys[administrativeArea] = countryMumories
                            } else {
                                self.locationMumorys[administrativeArea] = [newMumory]
                                
                                if self.locationMumorys.count == 2, !rewards.contains(where: { $0 == Reward(type: .location(0))}) {
                                    do {
                                        try collectionReference.addDocument(from: Reward(type: .location(0)))
                                    } catch {
                                        print("ERROR fetchMyMumoryListener: \(error)")
                                    }
                                } else if self.locationMumorys.count == 3, !rewards.contains(where: { $0 == Reward(type: .location(1))}) {
                                    do {
                                        try collectionReference.addDocument(from: Reward(type: .location(1)))
                                    } catch {
                                        print("ERROR fetchMyMumoryListener: \(error)")
                                    }
                                } else if self.locationMumorys.count == 5, !rewards.contains(where: { $0 == Reward(type: .location(2))}) {
                                    do {
                                        try collectionReference.addDocument(from: Reward(type: .location(2)))
                                    } catch {
                                        print("ERROR fetchMyMumoryListener: \(error)")
                                    }
                                } else if self.locationMumorys.count == 10, !rewards.contains(where: { $0 == Reward(type: .location(3))}) {
                                    do {
                                        try collectionReference.addDocument(from: Reward(type: .location(3)))
                                    } catch {
                                        print("ERROR fetchMyMumoryListener: \(error)")
                                    }
                                } else if self.locationMumorys.count == 15, !rewards.contains(where: { $0 == Reward(type: .location(4))}) {
                                    do {
                                        try collectionReference.addDocument(from: Reward(type: .location(4)))
                                    } catch {
                                        print("ERROR fetchMyMumoryListener: \(error)")
                                    }
                                }
                            }
                        }
                    } catch {
                        print("ERROR")
                    }
                    
                case .modified:
                    let modifiedDocumentID = documentChange.document.documentID
                    if let index = self.myMumorys.firstIndex(where: { $0.id == modifiedDocumentID }) {
                        do {
                            let updatedMumory = try documentChange.document.data(as: Mumory.self)
                            
                            //                            DispatchQueue.main.async {
                            self.myMumorys[index] = updatedMumory
                            //                            }
                        } catch {
                            print("ERROR")
                        }
                    }
                    //                        if let index = self.socialMumorys.firstIndex(where: { $0.id == modifiedDocumentID }),
                    //                           let updatedMumory = await Mumory.fromDocumentDataToMumory(documentData, mumoryDocumentID: self.socialMumorys[index].id) {
                    //                            DispatchQueue.main.async {
                    //                                self.socialMumorys[index] = updatedMumory
                    //                            }
                    //                        }
                    print("Document modified: \(modifiedDocumentID)")
                    
                case .removed:
                    let documentData = documentChange.document.data()
                    print("Document removed: \(documentChange.document.documentID)")
                    
                    let removedDocumentID = documentChange.document.documentID
                    //                    DispatchQueue.main.async {
                    self.myMumorys.removeAll { $0.id == removedDocumentID }
                    //                    }
                }
            }
            
            print("self.myMumorys.count: \(self.myMumorys.count)")
        }
        return listener
    }
    
    public func fetchMumorys(uId: String, completion: @escaping (Result<[Mumory], Error>) -> Void) async {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Mumory")
            .whereField("uId", isEqualTo: uId)
            .order(by: "date", descending: true)
        
        do {
            let snapshot = try await collectionReference.getDocuments()
            
            var mumorys: [Mumory] = []
            for document in snapshot.documents {
                let newMumory = try document.data(as: Mumory.self)
                
                DispatchQueue.main.async {
                    var country = newMumory.location.country
                    let administrativeArea = newMumory.location.administrativeArea
                    
                    if country != "대한민국" {
                        if country == "영국" {
                            country += " 🇬🇧"
                        } else if country == "미 합중국" {
                            country = "미국 🇺🇸"
                        } else if country == "이탈리아" {
                            country += " 🇮🇹"
                        } else if country == "프랑스" {
                            country += " 🇫🇷"
                        } else if country == "독일" {
                            country += " 🇩🇪"
                        } else if country == "일본" {
                            country += " 🇯🇵"
                        } else if country == "중국" {
                            country += " 🇨🇳"
                        } else if country == "캐나다" {
                            country += " 🇨🇦"
                        } else if country == "오스트레일리아" {
                            country += " 🇦🇹"
                        } else if country == "브라질" {
                            country += " 🇧🇷"
                        } else if country == "인도" {
                            country += " 🇮🇳"
                        } else if country == "러시아" {
                            country += " 🇷🇺"
                        } else if country == "우크라이나" {
                            country += " 🇺🇦"
                        } else if country == "호주" {
                            country += " 🇦🇺"
                        } else if country == "멕시코" {
                            country += " 🇲🇽"
                        } else if country == "인도네시아" {
                            country += " 🇮🇩"
                        } else if country == "터키" {
                            country += " 🇹🇷"
                        } else if country == "사우디아라비아" {
                            country += " 🇸🇦"
                        } else if country == "스페인" {
                            country += " 🇪🇸"
                        } else if country == "네덜란드" {
                            country += " 🇳🇱"
                        } else if country == "스위스" {
                            country += " 🇨🇭"
                        } else if country == "아르헨티나" {
                            country += " 🇦🇷"
                        } else if country == "스웨덴" {
                            country += " 🇸🇪"
                        } else if country == "폴란드" {
                            country += " 🇵🇱"
                        } else if country == "벨기에" {
                            country += " 🇧🇪"
                        } else if country == "태국" {
                            country += " 🇹🇭"
                        } else if country == "이란" {
                            country += " 🇮🇷"
                        } else if country == "오스트리아" {
                            country += " 🇦🇹"
                        } else if country == "노르웨이" {
                            country += " 🇳🇴"
                        } else if country == "아랍에미리트" {
                            country += " 🇦🇪"
                        } else if country == "나이지리아" {
                            country += " 🇳🇬"
                        } else if country == "남아프리카공화국" {
                            country += " 🇿🇦"
                        } else {
                            country = "기타 🏁"
                        }
                        
                        // 해당 국가를 키로 가지는 배열이 이미 딕셔너리에 존재하는지 확인
                        if var countryMumories = self.locationMumorys[country] {
                            // 존재하는 경우 해당 배열에 뮤모리 추가
                            countryMumories.append(newMumory)
                            // 딕셔너리에 업데이트
                            self.locationMumorys[country] = countryMumories
                        } else {
                            // 존재하지 않는 경우 새로운 배열 생성 후 뮤모리 추가
                            self.locationMumorys[country] = [newMumory]
                        }
                    } else {
                        if var countryMumories = self.locationMumorys[administrativeArea] {
                            // 존재하는 경우 해당 배열에 뮤모리 추가
                            countryMumories.append(newMumory)
                            // 딕셔너리에 업데이트
                            self.locationMumorys[administrativeArea] = countryMumories
                        } else {
                            // 존재하지 않는 경우 새로운 배열 생성 후 뮤모리 추가
                            self.locationMumorys[administrativeArea] = [newMumory]
                        }
                    }
                }
                
                mumorys.append(newMumory)
            }
            
            self.myMumorys = mumorys
            
            completion(.success(mumorys))
        } catch {
            completion(.failure(error))
        }
    }
    
    public func fetchSocialMumory(currentUserViewModel: CurrentUserViewModel, isRefreshControl: Bool = false, completion: @escaping (Result<Int, Error>) -> Void) {
        if isRefreshControl {
            self.lastDocument = nil
        }
        
        var friendsUids: [String] = currentUserViewModel.friendViewModel.friends.map { $0.uId }
        friendsUids.append(currentUserViewModel.user.uId)
        
        var mumoryCollectionRef = db.collection("Mumory")
//            .whereField("uId", in: friendsUids.isEmpty ? ["X"] : friendsUids)
            .whereField("uId", in: friendsUids)
            .whereField("isPublic", isEqualTo: true)
            .order(by: "date", descending: true)
            .limit(to: 7)
        
        if let lastDoc = self.lastDocument {
            mumoryCollectionRef = mumoryCollectionRef.start(afterDocument: lastDoc)
        }
        
        let copiedMumoryCollectionRef = mumoryCollectionRef
        
        Task {
            do {
                let snapshot = try await copiedMumoryCollectionRef.getDocuments()
                
                if snapshot.documents.isEmpty {
                    completion(.success(snapshot.documents.count))
                    return
                }
                
                var tempSocialMumory: [Mumory] = []
                for document in snapshot.documents {
                    let newMumory = try document.data(as: Mumory.self)
                    if !tempSocialMumory.contains(where: { $0.id == newMumory.id }) {
                        tempSocialMumory.append(newMumory)
                    }
                }
                
                tempSocialMumory.sort { $0.date > $1.date }
                
                self.socialMumorys.append(contentsOf: tempSocialMumory)
                
                self.lastDocument = snapshot.documents.last
                
                completion(.success(snapshot.documents.count))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func createMumory(_ mumory : Mumory, completion: @escaping (Result<Void, Error>) -> Void) {
        let collectionReference = db.collection("Mumory")
        
        do {
            let data: [String: Any] = try Firestore.Encoder().encode(mumory)
            
            collectionReference.addDocument(data: data) { error in
                if let error = error {
                    print("Error createMumory: \(error)")
                    completion(.failure(error))
                } else {
                    print("createMumory successfully!")
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    public func updateMumory(mumoryId: String, mumory: Mumory, completion: @escaping (Result<Void, Error>) -> Void) {
        let documentReference = db.collection("Mumory").document(mumoryId)
        
        do {
            let updatedData: [String: Any] = try Firestore.Encoder().encode(mumory)
            
            documentReference.updateData(updatedData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    public func deleteMumory(_ mumory: Mumory, completion: @escaping (Result<Void, Error>) -> Void) {
        let documentReference = db.collection("Mumory").document(mumory.id ?? "")
        
        documentReference.delete { error in
            if let error = error {
                print("Error deleting document: \(error.localizedDescription)")
            } else {
                if let index = self.myMumorys.firstIndex(where: { $0.id == mumory.id }) {
                    self.myMumorys.remove(at: index)
                }
                
                if let index = self.socialMumorys.firstIndex(where: { $0.id == mumory.id }) {
                    self.socialMumorys.remove(at: index)
                }
                
                let commentsRef = documentReference.collection("Comment")
                commentsRef.getDocuments { (snapshot, error) in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        for document in snapshot!.documents {
                            let commentRef = commentsRef.document(document.documentID)
                            commentRef.delete()
                        }
                        completion(.success(()))
                    }
                }
            }
        }
    }
}

extension MumoryViewModel {
    
    public func likeMumory(mumoryAnnotation: Mumory, uId: String, completion: @escaping (Result<[String], Error>) -> Void) async {
        let docRef = db.collection("Mumory").document(mumoryAnnotation.id ?? "")
        
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                guard let documentData = document.data(),
                      var oldLikes = documentData["likes"] as? [String] else {return}
                
                if oldLikes.contains(uId) {
                    if let index = oldLikes.firstIndex(of: uId) {
                        oldLikes.remove(at: index)
                    }
                } else {
                    oldLikes.append(uId)
                }
                
                print("oldLikes: \(oldLikes)")
                completion(.success(oldLikes))
            } else {
                completion(.failure(FetchError.documentNotFound))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    public func checkIsMyComment(mumoryId: String, reply: Comment, currentUser: UserProfile) async -> Bool {
        let db = FirebaseManager.shared.db
        let docReference = db.collection("Mumory").document(mumoryId).collection("Comment").document(reply.parentId)
        
        do {
            let documentSnapshot = try await docReference.getDocument()
            
            if documentSnapshot.exists {
                guard let documentData = documentSnapshot.data() else { return false }
                guard let uId = documentData["uId"] as? String else { return false }
                
                if currentUser.uId == uId {
                    return true
                }
                
            } else {
                return false
            }
        } catch {
            print("Error checkIsMyComment: \(error.localizedDescription)")
            return false
        }
        return false
    }
    
    public func createComment(documentId: String?, comment: Comment, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let documentId = documentId else {
            completion(.failure(FetchError.documentIdError))
            return
        }
        
        let db = FirebaseManager.shared.db
        let commentCollectionReference = db.collection("Mumory").document(documentId).collection("Comment")
        let mumoryDocReference = db.collection("Mumory").document(documentId)
        
        do {
            let data: [String: Any] = try Firestore.Encoder().encode(comment)
            commentCollectionReference.addDocument(data: data) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    Task {
                        let latestMumory = try await FetchManager.shared.fetchMumory(documentID: documentId)
                        latestMumory.commentCount += 1
                        let updatedData: [String: Any] = try Firestore.Encoder().encode(latestMumory)
                        try await mumoryDocReference.updateData(updatedData)
                        completion(.success(()))
                    }
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    public func deleteComment(comment: Comment, competion: @escaping (Result<[Comment], Error>) -> Void) {
        let db = FirebaseManager.shared.db
        guard let documentId = comment.id else {
            return
        }
        
        let docReference = db.collection("Mumory").document(comment.mumoryId).collection("Comment").document(documentId)
        
        docReference.delete { error in
            if let error = error {
                print("Error deleteComment: \(error)")
            } else {
                let collectionRef = db.collection("Mumory").document(comment.mumoryId).collection("Comment").whereField("parentId", isEqualTo: documentId)
                
                Task {
                    let querySnapshot = try await collectionRef.getDocuments()
                    
                    for document in querySnapshot.documents {
                        let docId = document.documentID
                        db.collection("Mumory").document(comment.mumoryId).collection("Comment").document(docId).delete { error in
                            if let error = error {
                                print("Error deleteComment: \(error)")
                                competion(.failure(error))
                            }
                        }
                    }
                    
                    if let comments = try? await FetchManager.shared.fetchCommentAndReply(DocumentID: comment.mumoryId) {
                        print("deleteComment successfully")
                        competion(.success(comments))
                    }
                }
            }
        }
    }
    
    public func searchMumoryByContent(_ searchString: String, completion: @escaping ()-> Void) {
        
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Mumory")
            .whereField("content", isGreaterThanOrEqualTo: searchString)
            .whereField("content", isLessThan: searchString + "\u{f8ff}")
        
        collectionReference.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                
                for document in querySnapshot!.documents {
                    
                    //                    if let content = document.data()["content"] as? String, content.contains(where: { $0.lowercased() == searchString.lowercased() }) {
                    print("searchMumoryByContent successfully! : \(document.documentID)")
                    
                    let documentData = document.data()
                    Task {
//                        guard let newMumory = await Mumory.fromDocumentDataToMumory(documentData, mumoryDocumentID: document.documentID) else { return }
                        let newMumory = try document.data(as: Mumory.self)
                        DispatchQueue.main.async {
                            self.searchedMumoryAnnotations.append(newMumory)
                        }
                    }
                }
                
                self.searchedMumoryAnnotations.sort { (doc1, doc2) -> Bool in
                    guard let content1 = doc1.content, let content2 = doc2.content  else { return false }
                    return content1.count < content2.count
                }
                completion()
            }
        }
    }
    
    private func uploadImageToStorage(completion: @escaping (URL?) -> Void) {
        let storageRef = FirebaseManager.shared.storage.reference()
        let imageRef = storageRef.child("mumoryImages/\(UUID().uuidString).jpg")
        
        
        // 예시: 이미지 데이터를 업로드
        guard let imageData = UIImage(named: "exampleImage")?.jpegData(compressionQuality: 0.8) else {
            print("Could not convert image to Data.")
            completion(nil)
            return
        }
        
        imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
                print("Image upload error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            print("Image uploaded successfully.")
            
            // 다운로드 URL을 가져오기
            imageRef.downloadURL { (url, error) in
                guard let url = url, error == nil else {
                    print("Error getting download URL: \(error?.localizedDescription ?? "")")
                    completion(nil)
                    return
                }
                
                print("Download URL: \(url)")
                
                // 이미지 다운로드 URL을 completionHandler에 전달
                completion(url)
            }
        }
    }
}

extension MumoryViewModel {
    
    public static func fetchRewardCount(user: UserProfile, reward: String) async -> Int {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("User").document(user.uId).collection("Reward")
            .whereField("type", isEqualTo: reward)
        
        do {
            let querySnapshot = try await collectionReference.getDocuments()
            return querySnapshot.documents.count
        } catch {
            print("Error fetching documents: \(error)")
            return -1
        }
    }
    
    public static func fetchRewardCount(user: UserProfile) async -> Int {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("User").document(user.uId).collection("Reward")
        
        do {
            let querySnapshot = try await collectionReference.getDocuments()
            return querySnapshot.documents.count
        } catch {
            print("Error fetching documents: \(error)")
            return -1
        }
    }
    
    public static func fetchCommentCount(mumoryId: String) async -> Int {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Mumory").document(mumoryId).collection("Comment")
            .whereField("parentId", isEqualTo: "")
        
        do {
            let querySnapshot = try await collectionReference.getDocuments()
            return querySnapshot.documents.count
        } catch {
            print("Error fetching documents: \(error)")
            return -1
        }
    }
    
    public static func fetchMyCommentCount(mumoryId: String, uId: String) async -> Int {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Mumory").document(mumoryId).collection("Comment").whereField("uId", isEqualTo: uId)
        
        do {
            let querySnapshot = try await collectionReference.getDocuments()
            return querySnapshot.documents.count
        } catch {
            print("Error fetching documents: \(error)")
            return -1
        }
    }
    
    public func sameSongFriendMumory(friend: UserProfile, songId: String, mumory: Mumory) async {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Mumory")
            .whereField("uId", isEqualTo: friend.uId)
            .whereField("songId", isEqualTo: songId)
            .order(by: "date", descending: true)
            
        do {
            let querySnapshot = try await collectionReference.getDocuments()
            DispatchQueue.main.async {
                self.sameSongFriendMumorys = []
            }
            
            for document in querySnapshot.documents {
                let newMumory = try document.data(as: Mumory.self)
                
                if mumory.id != document.documentID {
                    DispatchQueue.main.async {
                        if !self.sameSongFriendMumorys.contains(where: { $0.id == document.documentID }), newMumory.isPublic {
                            self.sameSongFriendMumorys.append(newMumory)
                        }
                    }
                }
            }
        } catch {
            print("Error sameSongFriendMumory: \(error)")
        }
    }
    
    public func surroundingFriendMumory(friend: UserProfile, mumory: Mumory) async {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Mumory")
            .whereField("uId", isEqualTo: friend.uId)
            .whereField("longitude", isGreaterThan: mumory.location.coordinate.longitude - 0.01)
            .whereField("longitude", isLessThan: mumory.location.coordinate.longitude + 0.01)
        
        do {
            let querySnapshot = try await collectionReference.getDocuments()
            DispatchQueue.main.async {
                self.surroundingMumorys = []
                self.tempMumory = []
            }
            
            let filteredQuerySnapshot = querySnapshot.documents.filter {
                let documentData = $0.data()
                let latitude = documentData["latitude"] as? Double ?? 0.0
                return latitude > mumory.location.coordinate.latitude - 0.01 &&
                       latitude < mumory.location.coordinate.latitude + 0.01
            }
            
            for document in filteredQuerySnapshot {
                let newMumory = try document.data(as: Mumory.self)
                
                DispatchQueue.main.async {
                    if !self.tempMumory.contains(where: { $0.id == document.documentID}) {
                        if !self.tempMumory.contains(where: { $0.song.id == newMumory.song.id}) {
                            if mumory.song.id != newMumory.song.id {
                                self.tempMumory.append(newMumory)
                            }
                        }
                    }
                }
            }

            DispatchQueue.main.async {
                self.surroundingMumorys = self.tempMumory
            }
        } catch {
            print("Error sameSongFriendMumory: \(error)")
        }
    }
    
    public func fetchFavoriteDate(user: UserProfile) async {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("User").document(user.uId).collection("MonthlyStat")
            .whereField("type", isEqualTo: "favorite")
        
        do {
            DispatchQueue.main.async {
                self.favoriteDate = []
            }
            
            let querySnapshot = try await collectionReference.getDocuments()
            for document in querySnapshot.documents {
                let documentData = document.data()
                guard let date: FirebaseManager.Timestamp = documentData["date"] as? FirebaseManager.Timestamp else { return }
                
//                if !self.favoriteDate.contains(where: { $0.id == document.documentID }) {
                    DispatchQueue.main.async {
                        self.favoriteDate.append(date.dateValue())
                    }
//                }
            }
        } catch {
            print("Error sameSongFriendMumory: \(error)")
        }
    }
}

