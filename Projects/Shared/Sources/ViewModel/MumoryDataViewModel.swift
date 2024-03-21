//
//  AnnotationViewModel.swift
//  Feature
//
//  Created by 다솔 on 2023/12/19.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
//import Core
import MapKit
import MusicKit
import FirebaseFirestore
import Firebase

final public class MumoryDataViewModel: ObservableObject {
    
    @Published public var choosedMusicModel: MusicModel?
    @Published public var choosedLocationModel: LocationModel?
    
    @Published public var selectedMumoryId: String = ""
    @Published public var selectedMumoryAnnotation: Mumory = Mumory()
    @Published public var selectedComment: Comment = Comment()
    
    @Published public var musicModels: [MusicModel] = []
    
    @Published public var myMumorys: [Mumory] = []
    @Published public var mumorys: [Mumory] = []
    @Published public var everyMumorys: [Mumory] = []
    @Published public var filterdMumorys: [Mumory] = []
    
    @Published public var mumoryComments: [Comment] = []
    @Published public var mumoryCarouselAnnotations: [Mumory] = []
    @Published public var searchedMumoryAnnotations: [Mumory] = []
    
    @Published public var isLoading: Bool = false
    @Published public var isCreating: Bool = false
    @Published public var isUpdating: Bool = false
    
    
    public init() {}
    
    func fetchMusic(songId: String) async throws -> MusicModel {
        let musicItemID = MusicItemID(rawValue: songId)
        let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
        let response = try await request.response()
        guard let song = response.items.first else {
            throw NSError(domain: "GoogleMapSample", code: 1, userInfo: [NSLocalizedDescriptionKey: "Song not found"])
        }
        
        return MusicModel(songID: musicItemID, title: song.title, artist: song.artistName, artworkUrl: song.artwork?.url(width: 500, height: 500))
    }
    
    func fetchSong(songId: String) async throws -> Song {
        let musicItemID = MusicItemID(rawValue: songId)
        let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
        
        let response = try await request.response()
        guard let song = response.items.first else {
            throw NSError(domain: "MUMORY", code: 1, userInfo: [NSLocalizedDescriptionKey: "Song not found"])
        }
        
        return song
    }
    
    // 위치 > 주소
    public func getChoosedeMumoryModelLocation(location: CLLocation, completion: @escaping (LocationModel) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                print("Error: ", error?.localizedDescription ?? "Unknown error")
                return }
            
            let locationTitle = placemark.name ?? ""
            let locationSubtitle = (placemark.locality ?? "") + " " + (placemark.thoroughfare ?? "") + " " + (placemark.subThoroughfare ?? "")
            let coordinate = location.coordinate
            
            let locationModel = LocationModel(locationTitle: locationTitle, locationSubtitle: locationSubtitle, coordinate: coordinate)
            
            completion(locationModel)
        }
    }
    
    public func fetchMyMumoryListener(userDocumentID: String) -> ListenerRegistration {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Mumory")
        let query = collectionReference.whereField("uId", isEqualTo: userDocumentID)
        
        let listener = query.addSnapshotListener { snapshot, error in
            Task {
                guard let snapshot = snapshot, error == nil else {
                    print("Error fetchMumoryListener: \(error!)")
                    return
                }
                
                for documentChange in snapshot.documentChanges {
                    switch documentChange.type {
                    case .added:
                        let documentData = documentChange.document.data()
                        guard let newMumory = await Mumory.fromDocumentDataToMumory(documentData, mumoryDocumentID: documentChange.document.documentID) else { return }
                        
//                        if !self.myMumorys.contains(where: { $0.id == documentChange.document.documentID }) {
//                            DispatchQueue.main.async {
//                                self.myMumorys.append(newMumory)
//                                self.myMumorys.sort { $0.date > $1.date }
//                            }
//                            print("Document added: \(documentChange.document.documentID)")
//                        }
                        DispatchQueue.main.async {
                            var uniqueIds = Set<String>(self.myMumorys.map { $0.id })
                            
                            if uniqueIds.contains(documentChange.document.documentID) {
                                // 이미 배열에 같은 id를 가진 Mumory가 있는 경우
                                uniqueIds.remove(documentChange.document.documentID)
                                uniqueIds.insert(newMumory.id)
                                self.myMumorys = self.myMumorys.filter { $0.id != documentChange.document.documentID }
                                self.myMumorys.append(newMumory)
                                self.myMumorys.sort { $0.date > $1.date }
                                print("1Document updated: \(documentChange.document.documentID)")
                            } else {
                                // 배열에 같은 id를 가진 Mumory가 없는 경우
                                self.myMumorys.append(newMumory)
                                self.myMumorys.sort { $0.date > $1.date }
                                print("1Document added: \(documentChange.document.documentID)")
                            }
                        }

                        
                        if !self.filterdMumorys.contains(where: { $0.id == documentChange.document.documentID }) {
                            DispatchQueue.main.async {
                                self.filterdMumorys.append(newMumory)
                                self.filterdMumorys.sort { $0.date > $1.date }
                            }
                        }
                        
                    case .modified:
                        let documentData = documentChange.document.data()
                        
                        let modifiedDocumentID = documentChange.document.documentID
                        if let index = self.myMumorys.firstIndex(where: { $0.id == modifiedDocumentID }),
                           let updatedMumory = await Mumory.fromDocumentDataToMumory(documentData, mumoryDocumentID: self.myMumorys[index].id) {
                            DispatchQueue.main.async {
                                self.myMumorys[index] = updatedMumory
                            }
                        }
                        print("Document modified: \(modifiedDocumentID)")
                        
                    case .removed:
                        let documentData = documentChange.document.data()
                        print("Document removed: \(documentChange.document.documentID)")
                        
                        let removedDocumentID = documentChange.document.documentID
                        DispatchQueue.main.async {
                            self.myMumorys.removeAll { $0.id == removedDocumentID }
                        }
                    }
                }
            }
        }
        return listener
    }
    
    public func fetchMumory(documentID: String) async -> Mumory {
        let db = FirebaseManager.shared.db
        let docRef = db.collection("Mumory").document(documentID)
        
        do {
            let documentSnapshot = try await docRef.getDocument()
            
            if documentSnapshot.exists {
                
                guard let documentData = documentSnapshot.data(),
                      let newMumory = await Mumory.fromDocumentDataToMumory(documentData, mumoryDocumentID: documentSnapshot.documentID) else { return Mumory() }
                
                return newMumory
      
            } else {
                print("Document does not exist")
            }
        } catch {
            print("Error fetching document: \(error.localizedDescription)")
        }
        
        return Mumory()
    }
    
    public func fetchMyMumory(uId: String, completion: @escaping () -> Void) {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Mumory").whereField("uId", isEqualTo: uId)
        
        Task {
            do {
                let snapshot = try await collectionReference.getDocuments()
                
//                DispatchQueue.main.async {
//                    self.myMumorys = []
//                }
                
                for document in snapshot.documents {
                    let documentData = document.data()
                    guard let newMumory = await Mumory.fromDocumentDataToMumory(documentData, mumoryDocumentID: document.documentID) else {return}
                    
                    if !self.myMumorys.contains(where: { $0.id == newMumory.id }) {
                        DispatchQueue.main.async {
                            self.myMumorys.append(newMumory)
                            self.myMumorys.sort { $0.date > $1.date }
                        }
                    }
                }
                print("fetchMyMumory successfully!")
                completion()
            } catch {
                print("Error fetchMyMumory: \(error.localizedDescription)")
            }
        }
    }
    
    public func fetchEveryMumory() {
        let db = FirebaseManager.shared.db
        
        let mumoryCollectionRef = db.collection("Mumory")
            .limit(to: 10)
        //            .order(by: "date", descending: true)
        
        Task {
            
            DispatchQueue.main.async {
                self.everyMumorys = []
            }
            
            do {
                let snapshot = try await mumoryCollectionRef.getDocuments()
                
                for document in snapshot.documents {
                    
                    let documentData = document.data()
                    
                    guard let newMumory: Mumory = await Mumory.fromDocumentDataToMumory(documentData, mumoryDocumentID: document.documentID) else {return}
                    
                    if !self.everyMumorys.contains(where: { $0.id == newMumory.id }) {
                        DispatchQueue.main.async {
                            print("newMumory.date: \(newMumory.date)")
                            self.everyMumorys.append(newMumory)
                            self.everyMumorys.sort { $0.date > $1.date }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.isUpdating = false
                }
                print("fetchSocialMumory successfully!")
            } catch {
                print("Error fetchSocialMumory: \(error.localizedDescription)")
            }
        }
    }
    
//    public static func fetchCommentCount(mumoryId: String, completion: @escaping (Int?) -> Void) {
//        let db = FirebaseManager.shared.db
//        let collectionReference = db.collection("Mumory").document(mumoryId).collection("Comment")
//
//        collectionReference.getDocuments { (querySnapshot, error) in
//            if let error = error {
//                print("Error fetching documents: \(error)")
//                completion(nil)
//            } else {
//                let count = querySnapshot?.documents.count ?? 0
//                completion(count)
//            }
//        }
//    }
    
    public static func fetchCommentCount(mumoryId: String) async -> Int {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Mumory").document(mumoryId).collection("Comment").whereField("parentId", isEqualTo: "")
        
        do {
            let querySnapshot = try await collectionReference.getDocuments()
            return querySnapshot.documents.count
        } catch {
            print("Error fetching documents: \(error)")
            return -1
        }
    }
    
    public func createMumory(_ mumory : Mumory, completionHandler: @escaping (Result<Void, Error>) -> Void)  {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Mumory")

        let newData: [String: Any] = [
            "uId": mumory.uId,
            "date": FirebaseManager.Timestamp(date: mumory.date),
            "songId": String(describing: mumory.musicModel.songID),
            "locationTitle": mumory.locationModel.locationTitle,
            "latitude": mumory.locationModel.coordinate.latitude,
            "longitude": mumory.locationModel.coordinate.longitude,
            "tags": mumory.tags ?? [],
            "content": mumory.content ?? "",
            "imageURLs": mumory.imageURLs ?? [],
            "isPublic": mumory.isPublic,
            "likes": mumory.likes,
            "commentCount": mumory.commentCount
        ]
        
        collectionReference.addDocument(data: newData) { error in
            if let error = error {
                print("Error createMumory: \(error)")
                completionHandler(.failure(error))
            } else {
                print("createMumory successfully!")
                completionHandler(.success(()))
            }
        }
        
    }

    public func updateMumory(_ mumory: Mumory, completion: @escaping () -> Void) {
        
        let db = FirebaseManager.shared.db
        let documentReference = db.collection("Mumory").document(mumory.id)

        let updatedData: [String: Any] = [
            "uId": mumory.uId,
            "date": FirebaseManager.Timestamp(date: mumory.date),
            "songId": String(describing: mumory.musicModel.songID),
            "latitude": mumory.locationModel.coordinate.latitude,
            "longitude": mumory.locationModel.coordinate.longitude,
            "tags": mumory.tags ?? [],
            "content": mumory.content ?? "",
            "imageURLs": mumory.imageURLs ?? [],
            "isPublic": mumory.isPublic,
            "likes": mumory.likes
        ]
        
        documentReference.updateData(updatedData) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
                
                if let originalMumory = self.myMumorys.first(where: { $0.id == mumory.id }) {
                    mumory.copy(from: originalMumory)
                }
            } else {
                print("updateMumory successfully! : \(documentReference.documentID)")
                self.selectedMumoryAnnotation = mumory
                completion()
            }
        }
    }
    
    public func deleteMumory(_ mumory: Mumory, completion: @escaping () -> Void) {
        
        let db = FirebaseManager.shared.db
        
        let documentReference = db.collection("Mumory").document(mumory.id)
        
        // 문서 삭제
        documentReference.delete { error in
            if let error = error {
                print("Error deleting document: \(error.localizedDescription)")
            } else {
                // Mumory 문서가 성공적으로 삭제된 경우 Comment 컬렉션 레퍼런스 가져오기
                let commentsRef = db.collection("Mumory").document(mumory.id).collection("Comment")
                
                // Comment 컬렉션의 모든 문서 가져오기 및 삭제
                commentsRef.getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Error getting documents from Comment collection: \(error.localizedDescription)")
                        completion()
                        return
                    }
                    
                    // 가져온 문서들을 순회하면서 삭제
                    for document in snapshot!.documents {
                        let commentRef = commentsRef.document(document.documentID)
                        commentRef.delete()
                    }
                    
                    completion()
                }
            }
        }
    }
    
    public func likeMumory(mumoryAnnotation: Mumory, uId: String) async {
        let db = FirebaseManager.shared.db
        let docRef = db.collection("Mumory").document(mumoryAnnotation.id)
        
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                guard let documentData = document.data(),
                      var oldLikes = documentData["likes"] as? [String] else {return}
                
                print("oldLikes1: \(oldLikes)")
                if oldLikes.contains(uId) {
                    if let index = oldLikes.firstIndex(of: uId) {
                        oldLikes.remove(at: index)
                    }
                } else {
                    oldLikes.append(uId)
                }
                
                print("oldLikes2: \(oldLikes)")
                
                self.selectedMumoryAnnotation.likes = oldLikes
                
//                if let index = self.everyMumoryAnnotations.firstIndex(where: { $0.id == mumoryAnnotation.id }) {
//                    DispatchQueue.main.async {
//                        self.everyMumoryAnnotations[index] = mumoryAnnotation
//                    }
//                }
            } else {
                print("Document does not exist")
            }
        } catch {
            print("Error getting document: \(error)")
        }
        
    }
    
    public func fetchCommentReply(mumoryDocumentID: String) {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Mumory").document(mumoryDocumentID).collection("Comment")
        
        collectionReference.getDocuments { (querySnapshot, error)  in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let commentID = document.documentID
                    let commentData: [String: Any] = document.data()
                    
                    guard let newComment: Comment = Comment.fromDocumentData(commentData, commentDocumentID: commentID, comments: []) else {return}
                    
                    if !self.mumoryComments.contains(where: { $0.id == commentID }) {
                        DispatchQueue.main.async {
                            self.mumoryComments.append(newComment)
                            self.mumoryComments.sort { $0.date > $1.date }
                        }
                    }
                }
            }
        }
    }
    
    public static func fetchComment(mumoryId: String) async -> [Comment]? {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Mumory").document(mumoryId).collection("Comment")
            .order(by: "date", descending: true)
        
        var comments: [Comment] = []
        
        do {
            let querySnapshot = try await collectionReference.getDocuments()
            for document in querySnapshot.documents {
                let commentID = document.documentID
                let commentData: [String: Any] = document.data()
                
                guard let newComment: Comment = Comment.fromDocumentData(commentData, commentDocumentID: commentID, comments: []) else {return nil}
                
                comments.append(newComment)
            }
            print("fetchComment 성공: \(comments)")
            return comments
        } catch {
            print("Error fetching documents: \(error)")
            return nil
        }
    }

    //                    let replyRef = db.collection("Comment").document(commentID).collection("Reply")
    //
    //                    replyRef.getDocuments { (replyQuerySnapshot, replyError) in
    //                        if let replyError = replyError {
    //                            print("Error getting replies: \(replyError)")
    //                        } else {
    //                            for replyDocument in replyQuerySnapshot!.documents {
    //                                let replyData = replyDocument.data()
    //                                print("Reply data: \(replyData)")
    //                            }
    //                        }
    //                    }
    
    public func createComment(mumoryDocumentID: String, comment: Comment, competion: @escaping ([Comment]) -> Void) {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Mumory").document(mumoryDocumentID).collection("Comment")
        let mumoryDocReference = db.collection("Mumory").document(mumoryDocumentID)
        
        let newData: [String: Any] = comment.toDictionary()
        
        collectionReference.addDocument(data: newData) { error in
            if let error = error {
                print("Error adding document: \(error)")
                competion([])
            } else {
                Task {
                    let commentCount = await MumoryDataViewModel.fetchCommentCount(mumoryId: mumoryDocumentID)
                    try await mumoryDocReference.updateData(["commentCount": commentCount])
                    let comments = await MumoryDataViewModel.fetchComment(mumoryId: comment.mumoryId) ?? []
                    var result: [Comment] = []
                    for i in comments {
                        if i.parentId == "" {
                            result.append(i)
                        }
                    }
                    print("createComment 성공")
                    competion(result)
                }
            }
        }
    }
    
    public func createReply(mumoryId: String, reply: Comment, competion: @escaping (Result<[Comment], Error>) -> Void) {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Mumory").document(mumoryId).collection("Comment")
        
        var newData: [String: Any] = reply.toDictionary()
        newData["parentId"] = reply.parentId
        
        collectionReference.addDocument(data: newData) { error in
            if let error = error {
                print("Error adding document: \(error)")
                competion(.failure(error))
            } else {
                Task {
                    let comments = await MumoryDataViewModel.fetchComment(mumoryId: reply.mumoryId) ?? []
                    var result: [Comment] = []
                    for i in comments {
                        if i.parentId != "" {
                            result.append(i)
                        }
                    }
                    print("createReply 성공")
                    competion(.success(result))
                }
            }
        }
    }
    
    public func deleteComment(comment: Comment, competion: @escaping ([Comment]) -> Void) {
        let db = FirebaseManager.shared.db
        let docReference = db.collection("Mumory").document(comment.mumoryId).collection("Comment").document(comment.id)
        
        docReference.delete { error in
            if let error = error {
                print("Error deleteComment: \(error)")
            } else {
                let collectionRef = db.collection("Mumory").document(comment.mumoryId).collection("Comment").whereField("parentId", isEqualTo: comment.id)
                
                Task {
                    let querySnapshot = try await collectionRef.getDocuments()

                    for document in querySnapshot.documents {
                        let docId = document.documentID
                        db.collection("Mumory").document(comment.mumoryId).collection("Comment").document(docId).delete { error in
                            if let error = error {
                                print("Error deleteComment: \(error)")
                            }
                        }
                    }
                    
                    let comments = await MumoryDataViewModel.fetchComment(mumoryId: comment.mumoryId) ?? []
                    print("deleteComment successfully")
                    competion(comments)
                }
                
            }
        }
        
    }
    
    public func acceptFriendReqeust(ID : String) {
        
        let db = FirebaseManager.shared.db
        
        let newData: [String: Any] = [
            "friends": FieldValue.arrayUnion([ID])
        ]
        
        let documentReference = db.collection("User").document("tester")
        
        documentReference.setData(newData, merge: true) { error in
            if let error = error {
                print("Error acceptFriendReqeust: \(error.localizedDescription)")
            } else {
                let new = FriendSearch(nickname: "FUCKK", id: ID)
                FirebaseManager.shared.friends.append(new)
                print("acceptFriendReqeust successfully! : \(documentReference.documentID)")
            }
        }
    }
    
    public func searchMumoryByContent(_ searchString: String) {
        
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
                        guard let newMumory = await Mumory.fromDocumentDataToMumory(documentData, mumoryDocumentID: document.documentID) else { return }
                        DispatchQueue.main.async {
                            self.searchedMumoryAnnotations.append(newMumory)
                        }
                    }
                }
                
                self.searchedMumoryAnnotations.sort { (doc1, doc2) -> Bool in
                    guard let content1 = doc1.content, let content2 = doc2.content  else { return false }
                    return content1.count < content2.count
                }
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

extension MumoryDataViewModel {
    
    public func createReply2(mumoryAnnotation: Mumory, loginUserID: String, parentCommentIndex: Int, reply: Comment) {
        
//        let db = FirebaseManager.shared.db
//
//        let commentsRef = db.collection("User").document(mumoryAnnotation.userDocumentID).collection("mumory").document(mumoryAnnotation.id)
//
//        db.runTransaction({ (transaction, errorPointer) -> Any? in
//
//            let postDocument: DocumentSnapshot
//
//            do {
//                try postDocument = transaction.getDocument(commentsRef)
//            } catch let fetchError as NSError {
//                errorPointer?.pointee = fetchError
//                return nil
//            }
//
//            guard var commentsData = postDocument.data()?["comments"] as? [[String: Any]] else {
//                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
//                    NSLocalizedDescriptionKey: "Unable to retrieve likes from snapshot \(postDocument)"
//                ])
//                errorPointer?.pointee = error
//                return nil
//            }
//
//            guard parentCommentIndex >= 0 && parentCommentIndex < commentsData.count else {
//                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
//                    NSLocalizedDescriptionKey: "Invalid parentCommentIndex"
//                ])
//                errorPointer?.pointee = error
//                return nil
//            }
//
//            let replyData = reply.toDictionary()
//            print("replyData: \(replyData)")
//
//            if var replies = commentsData[parentCommentIndex]["replies"] as? [[String: Any]] {
//                replies.append(replyData)
//                commentsData[parentCommentIndex]["replies"] = replies
//            } else {
//                let replies = [replyData]
//                commentsData[parentCommentIndex]["replies"] = replies
//            }
//
//            mumoryAnnotation.comments[parentCommentIndex].replies.append(reply)
//
//            if let index = self.everyMumoryAnnotations.firstIndex(where: { $0.id == mumoryAnnotation.id }) {
//                DispatchQueue.main.async {
//                    self.everyMumoryAnnotations[index] = mumoryAnnotation
//                }
//            }
//
//            transaction.updateData(["comments": commentsData], forDocument: commentsRef)
//
//            return nil
//        }) { (object, error) in
//            if let error = error {
//                print("Transaction failed: \(error)")
//            } else {
//                self.fetchEveryMumory()
//                print("Transaction successfully committed!")
//            }
//        }
    }

    public func likeMumory2(mumoryAnnotation: Mumory, uId: String) {
        
        let db = FirebaseManager.shared.db
        let postRef = db.collection("Mumory").document(mumoryAnnotation.id)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            
            let postDocument: DocumentSnapshot
            
            do {
                try postDocument = transaction.getDocument(postRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var oldLikes = postDocument.data()?["likes"] as? [String] else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Unable to retrieve likes from snapshot \(postDocument)"
                ])
                errorPointer?.pointee = error
                return nil
            }
            
            if oldLikes.contains(uId) {
                if let index = oldLikes.firstIndex(of: uId) {
                    oldLikes.remove(at: index)
                    mumoryAnnotation.likes.remove(at: index)
                }
            } else {
                oldLikes.append(uId)
                mumoryAnnotation.likes.append(uId)
            }
            
            if let index = self.everyMumorys.firstIndex(where: { $0.id == mumoryAnnotation.id }) {
                DispatchQueue.main.async {
                    self.everyMumorys[index] = mumoryAnnotation
                }
            }
            
            transaction.updateData(["likes": oldLikes], forDocument: postRef)
            
//            let newData: [String: Any] = [
//                "uId": uId,
//                "data": FirebaseManager.Timestamp(date: Date()),
//                "mumoryId": mumoryAnnotation.id
//            ]
//            likeCollectionRef.addDocument(data: newData)
            
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }
}
