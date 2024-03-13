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
    
    @Published public var selectedMumoryAnnotation: Mumory?
    
    @Published public var musicModels: [MusicModel] = []
    @Published public var myMumoryAnnotations: [Mumory] = []
    @Published public var everyMumoryAnnotations: [Mumory] = []
    @Published public var mumoryCarouselAnnotations: [Mumory] = []
    @Published public var searchedMumoryAnnotations: [Mumory] = []
    
    @Published public var isSocialFetchFinished: Bool = false
    
    @Published public var isLoading: Bool = false
    @Published public var isCreating: Bool = false
    @Published public var isUpdating: Bool = false
    
    
    public init() {}
    
    func fetchMusic(musicID: String) async throws -> MusicModel {
        let musicItemID = MusicItemID(rawValue: musicID)
        let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
        let response = try await request.response()
        guard let song = response.items.first else {
            throw NSError(domain: "GoogleMapSample", code: 1, userInfo: [NSLocalizedDescriptionKey: "Song not found"])
        }
        
        return MusicModel(songID: musicItemID, title: song.title, artist: song.artistName, artworkUrl: song.artwork?.url(width: 500, height: 500))
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
    
    public func locationToLocationModel(location: CLLocation, completion: @escaping (LocationModel?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                print("Error: ", error?.localizedDescription ?? "Unknown error")
                completion(nil) // 에러가 발생하면 nil을 반환
                return
            }
            
            let locationTitle = placemark.name ?? ""
            let locationSubtitle = (placemark.locality ?? "") + " " + (placemark.thoroughfare ?? "") + " " + (placemark.subThoroughfare ?? "")
            
            let locationModel = LocationModel(locationTitle: locationTitle, locationSubtitle: locationSubtitle, coordinate: location.coordinate)
            
            completion(locationModel) // 성공적으로 LocationModel을 생성하여 콜백을 통해 반환
        }
    }
    
    
    public func fetchMyMumoryListener(userDocumentID: String) -> ListenerRegistration {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Mumory")
        let query = collectionReference.whereField("userDocumentID", isEqualTo: userDocumentID)
        
        
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
                        
                        guard let newMumory = await Mumory.fromDocumentData(documentData, documentID: documentChange.document.documentID) else { return }
                        
                        if !self.myMumoryAnnotations.contains(where: { $0.id == newMumory.id }) {
                            DispatchQueue.main.async {
                                self.myMumoryAnnotations.append(newMumory)
                                self.myMumoryAnnotations.sort { $0.date > $1.date }
                            }
                            print("Document added: \(documentChange.document.documentID)")
                        }

                    case .modified:
                        let documentData = documentChange.document.data()
                        
                        let modifiedDocumentID = documentChange.document.documentID
                        if let index = self.myMumoryAnnotations.firstIndex(where: { $0.id == modifiedDocumentID }),
                           let updatedMumory = await self.myMumoryAnnotations[index].convertDataToMumory(with: documentData) {
                            DispatchQueue.main.async {
                                self.myMumoryAnnotations[index] = updatedMumory
                            }
                            print("Document modified: \(modifiedDocumentID)")
                        }
                        
                        
                    case .removed:
                        let documentData = documentChange.document.data()
                        print("Document removed: \(documentData)")
                        
                        let removedDocumentID = documentChange.document.documentID
                        DispatchQueue.main.async {
                            self.myMumoryAnnotations.removeAll { $0.id == removedDocumentID }
                        }
                        
                        //                        if let index = self.everyMumoryAnnotations.firstIndex(where: { $0.id == documentChange.document.documentID }) {
//                            self.everyMumoryAnnotations.remove(at: index)
//                        }
                    }
                }
            }
        }
        
        return listener
    }
    
    public func fetchMumory(documentID: String) async {
        let db = FirebaseManager.shared.db
        let docRef = db.collection("Mumory").document(documentID)
        
        do {
            let documentSnapshot = try await docRef.getDocument()
            
            if documentSnapshot.exists {
                do {
                    
                    guard let documentData = documentSnapshot.data(), let newMumory = await Mumory.fromDocumentData(documentData, documentID: documentSnapshot.documentID) else { return }
                } catch {
                    print(error)
                }
            } else {
                print("Document does not exist")
            }
        } catch {
            print("Error fetching document: \(error.localizedDescription)")
        }
    }
    
    public func fetchMumorys(userDocumentID: String, completionHandler: @escaping (Result<[Mumory?], Error>) -> Void) {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Mumory")
        
        let dispatchGroup = DispatchGroup()
        
        Task {
            do {
                let snapshot = try await collectionReference.whereField("userDocumentID", isEqualTo: userDocumentID).getDocuments()
                
                var documentIDs: [String] = []
                
                for document in snapshot.documents {
                    
                    dispatchGroup.enter()
                    
                    let documentData = document.data()
                    
                    if let userDocumentID = documentData["userDocumentID"] as? String,
                       let songID = documentData["songID"] as? String,
                       let latitude = documentData["latitude"] as? CLLocationDegrees,
                       let longitude = documentData["longitude"] as? CLLocationDegrees,
                       let date = documentData["timeStamp"] as? FirebaseManager.Timestamp,
                       let tags = documentData["tags"] as? [String],
                       let content = documentData["content"] as? String,
                       let imageURLs = documentData["imageURLs"] as? [String],
                        let isPublic = documentData["isPublic"] as? Bool,
                       let likes = documentData["likes"] as? [String],
                       let comments = documentData["comments"] as? [[String: Any]]
                    {
                        do {
                            let musicModel = try await self.fetchMusic(musicID: songID)
                            let location = CLLocation(latitude: latitude, longitude: longitude)
                            self.locationToLocationModel(location: location) { locationModel in
                                if let locationModel  = locationModel {
                                    
                                    let commentsData = comments.compactMap { Comment(data: $0) } // : [Comment]
                                    
                                    let newMumory = Mumory(id: document.documentID, userDocumentID: userDocumentID, date: date.dateValue(), musicModel: musicModel, locationModel: locationModel, tags: [], content: "", imageURLs: [], isPublic: isPublic, likes: likes, comments: commentsData)
                                    
                                    DispatchQueue.main.async {
                                        if !self.myMumoryAnnotations.contains(where: { $0.id == newMumory.id }) {
                                            self.myMumoryAnnotations.append(newMumory)
                                            self.myMumoryAnnotations.sort { $0.date > $1.date }
                                        }
                                        dispatchGroup.leave()
                                    }
                                } else {
                                    print("위치 정보를 가져오는데 실패했습니다.")
                                    dispatchGroup.leave()
                                }
                            }
                        } catch {
                            print("Error fetchMyMumory: \(error.localizedDescription)")
                            dispatchGroup.leave()
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    print("fetchMumorys successfully!")
                }
            } catch {
                print("Error fetching playlist documents: \(error.localizedDescription)")
            }
        }
        
    }

    public func fetchMyMumory2(userDocumentID: String) {
 
        let db = FirebaseManager.shared.db
        
        let mumoryCollectionRef = db.collection("User").document(userDocumentID).collection("mumory")
            .order(by: "date", descending: true)
        
        let dispatchGroup = DispatchGroup()
        
        Task {
            do {
                let snapshot = try await mumoryCollectionRef.getDocuments()
                
                for document in snapshot.documents {
                    
                    dispatchGroup.enter()
                    
                    let documentData = document.data()
                    
                    if let author = documentData["author"] as? String,
                       let musicItemIDString = documentData["MusicItemID"] as? String,
                       let locationTitle = documentData["locationTitle"] as? String,
                       let locationSubtitle = documentData["locationSubtitle"] as? String,
                       let latitude = documentData["latitude"] as? Double,
                       let longitude = documentData["longitude"] as? Double,
                       let date = documentData["date"] as? FirebaseManager.Timestamp,
                       let tags = documentData["tags"] as? [String],
                       let content = documentData["content"] as? String,
                       let imageURLs = documentData["imageURLs"] as? [String],
                       let isPublic = documentData["isPublic"] as? Bool,
                       let likes = documentData["likes"] as? [String],
                       let comments = documentData["comments"] as? [[String: Any]]
                    {
                        do {
                            let musicModel = try await self.fetchMusic(musicID: musicItemIDString)
                            let locationModel = LocationModel(locationTitle: locationTitle, locationSubtitle: locationSubtitle, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                            
                            let commentsData = comments.compactMap { Comment(data: $0) } // : [Comment]
                            
                            let newMumoryAnnotation = Mumory(id: document.documentID, userDocumentID: author, date: date.dateValue(), musicModel: musicModel, locationModel: locationModel, tags: tags, content: content, imageURLs: imageURLs, isPublic: isPublic, likes: likes, comments: commentsData)
                            
                            DispatchQueue.main.async {
                                if !self.myMumoryAnnotations.contains(where: { $0.id == newMumoryAnnotation.id }) {
                                    self.myMumoryAnnotations.append(newMumoryAnnotation)
                                    self.myMumoryAnnotations.sort { $0.date > $1.date }
                                }
                                dispatchGroup.leave()
                            }
                        } catch {
                            print("Error fetchMyMumory: \(error.localizedDescription)")
                            dispatchGroup.leave()
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    print("fetchMyMumory successfully!")
                }
            } catch {
                print("Error fetching playlist documents: \(error.localizedDescription)")
            }
        }
    }
    
    public func fetchMumoryAnnotation(mumoryID id: String) async throws -> Mumory? {
        
        let db = FirebaseManager.shared.db
        
        let mumoryDocumentRef = db.collectionGroup("mumory")
        
        do {
            let snapshot = try await mumoryDocumentRef.getDocuments()
            
            for document in snapshot.documents {
                
                let documentData = document.data()
                
                if let author = documentData["author"] as? String,
                   let musicItemIDString = documentData["MusicItemID"] as? String,
                   let locationTitle = documentData["locationTitle"] as? String,
                   let locationSubtitle = documentData["locationSubtitle"] as? String,
                   let latitude = documentData["latitude"] as? Double,
                   let longitude = documentData["longitude"] as? Double,
                   let date = documentData["date"] as? FirebaseManager.Timestamp,
                   let tags = documentData["tags"] as? [String],
                   let content = documentData["content"] as? String,
                   let imageURLs = documentData["imageURLs"] as? [String],
                   let isPublic = documentData["isPublic"] as? Bool,
                   let likes = documentData["likes"] as? [String],
                   let comments = documentData["comments"] as? [[String: Any]]
                {
                    do {
                        let musicModel = try await self.fetchMusic(musicID: musicItemIDString)
                        let locationModel = LocationModel(locationTitle: locationTitle, locationSubtitle: locationSubtitle, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                        
                        let commentsData = comments.compactMap { Comment(data: $0) } // : [Comment]
                        
                        let newMumoryAnnotation = Mumory(id: document.documentID, userDocumentID: author, date: date.dateValue(), musicModel: musicModel, locationModel: locationModel, tags: tags, content: content, imageURLs: imageURLs, isPublic: isPublic, likes: likes, comments: commentsData)
                        
                        //                        DispatchQueue.main.async {
                        //                            if !self.socialMumoryAnnotations.contains(where: { $0.id == newMumoryAnnotation.id }) {
                        //                                self.socialMumoryAnnotations.append(newMumoryAnnotation)
                        //                                self.socialMumoryAnnotations.sort { $0.date > $1.date }
                        //                            }
                        //                        }
                        print("fetchMumoryAnnotation successfully")
                        
                        return newMumoryAnnotation
                    } catch {
                        print("Error fetching music: \(error.localizedDescription)")
                    }
                }
            }
            
        } catch {
            print("Error fetching mumory document: \(error.localizedDescription)")
            return nil
        }
        
        return nil
    }
    
    public func fetchEveryMumory() {
        self.isSocialFetchFinished = false
        let db = FirebaseManager.shared.db
        
        let mumoryCollectionRef = db.collectionGroup("mumory")
        //            .order(by: "date", descending: true)
        
        let dispatchGroup = DispatchGroup()
        
        Task {
            do {
                let snapshot = try await mumoryCollectionRef.getDocuments()
                
                for document in snapshot.documents {
                    
                    dispatchGroup.enter()
                    
                    let documentData = document.data()
                    
                    if let author = documentData["author"] as? String,
                       let musicItemIDString = documentData["MusicItemID"] as? String,
                       let locationTitle = documentData["locationTitle"] as? String,
                       let locationSubtitle = documentData["locationSubtitle"] as? String,
                       let latitude = documentData["latitude"] as? Double,
                       let longitude = documentData["longitude"] as? Double,
                       let date = documentData["date"] as? FirebaseManager.Timestamp,
                       let tags = documentData["tags"] as? [String],
                       let content = documentData["content"] as? String,
                       let imageURLs = documentData["imageURLs"] as? [String],
                       let isPublic = documentData["isPublic"] as? Bool,
                       let likes = documentData["likes"] as? [String],
                       let comments = documentData["comments"] as? [[String: Any]]
                    {
                        do {
                            let musicModel = try await self.fetchMusic(musicID: musicItemIDString)
                            let locationModel = LocationModel(locationTitle: locationTitle, locationSubtitle: locationSubtitle, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                            
                            let commentsData = comments.compactMap { Comment(data: $0) } // : [Comment]
                            
                            let newMumoryAnnotation = Mumory(id: document.documentID, userDocumentID: author, date: date.dateValue(), musicModel: musicModel, locationModel: locationModel, tags: tags, content: content, imageURLs: imageURLs, isPublic: isPublic, likes: likes, comments: commentsData)
                            
                            DispatchQueue.main.async {
                                if !self.everyMumoryAnnotations.contains(where: { $0.id == newMumoryAnnotation.id }) {
                                    self.everyMumoryAnnotations.append(newMumoryAnnotation)
                                    self.everyMumoryAnnotations.sort { $0.date > $1.date }
                                }
                                dispatchGroup.leave()
                            }
                        } catch {
                            print("Error fetchSocialMumory: \(error.localizedDescription)")
                            dispatchGroup.leave()
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    
                    self.isSocialFetchFinished = true
                    print("fetchSocialMumory successfully!")
                }
            } catch {
                print("Error fetchSocialMumory: \(error.localizedDescription)")
            }
        }
    }
    
    public func fetchMumoryAnnotation(mumoryAnnotation: Mumory) {
        
        let db = FirebaseManager.shared.db
        
        let mumoryCollectionRef = db.collectionGroup("mumory")
        //            .order(by: "date", descending: true)
        
        let dispatchGroup = DispatchGroup()
        
        Task {
            do {
                let snapshot = try await mumoryCollectionRef.getDocuments()
                
                for document in snapshot.documents {
                    
                    dispatchGroup.enter()
                    
                    let documentData = document.data()
                    
                    print("FUCK1")
                    
                    if document.documentID == mumoryAnnotation.id,
                       let author = documentData["author"] as? String,
                       let musicItemIDString = documentData["MusicItemID"] as? String,
                       let locationTitle = documentData["locationTitle"] as? String,
                       let locationSubtitle = documentData["locationSubtitle"] as? String,
                       let latitude = documentData["latitude"] as? Double,
                       let longitude = documentData["longitude"] as? Double,
                       let date = documentData["date"] as? FirebaseManager.Timestamp,
                       let tags = documentData["tags"] as? [String],
                       let content = documentData["content"] as? String,
                       let imageURLs = documentData["imageURLs"] as? [String],
                       let isPublic = documentData["isPublic"] as? Bool,
                       let likes = documentData["likes"] as? [String],
                       let comments = documentData["comments"] as? [[String: Any]]
                    {
                        print("FUCK2")
                        do {
                            let musicModel = try await self.fetchMusic(musicID: musicItemIDString)
                            let locationModel = LocationModel(locationTitle: locationTitle, locationSubtitle: locationSubtitle, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                            
                            let commentsData = comments.compactMap { Comment(data: $0) } // : [Comment]
                            
                            let newMumoryAnnotation = Mumory(id: document.documentID, userDocumentID: author, date: date.dateValue(), musicModel: musicModel, locationModel: locationModel, tags: tags, content: content, imageURLs: imageURLs, isPublic: isPublic, likes: likes, comments: commentsData)
                            
                            DispatchQueue.main.async {
                                if !self.everyMumoryAnnotations.contains(where: { $0.id == newMumoryAnnotation.id }) {
                                    self.everyMumoryAnnotations.append(newMumoryAnnotation)
                                    self.everyMumoryAnnotations.sort { $0.date > $1.date }
                                }
                                dispatchGroup.leave()
                            }
                        } catch {
                            print("Error fetching music: \(error.localizedDescription)")
                            dispatchGroup.leave()
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.selectedMumoryAnnotation = mumoryAnnotation
                    print("fetchMumoryAnnotation successfully!")
                }
            } catch {
                print("Error fetching playlist documents: \(error.localizedDescription)")
            }
        }
    }

    
    public func createMumory(_ mumory : Mumory, completionHandler: @escaping (Result<Void, Error>) -> Void)  {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Mumory")

        let newData: [String: Any] = [
            "userDocumentID": mumory.userDocumentID,
            "date": FirebaseManager.Timestamp(date: mumory.date),
            "songID": String(describing: mumory.musicModel.songID),
            "latitude": mumory.locationModel.coordinate.latitude,
            "longitude": mumory.locationModel.coordinate.longitude,
            "tags": mumory.tags ?? [],
            "content": mumory.content ?? "",
            "imageURLs": mumory.imageURLs ?? [],
            "isPublic": mumory.isPublic,
            "likes": mumory.likes,
            "comments": mumory.comments
        ]
        
        collectionReference.addDocument(data: newData) { error in
            if let error = error {
                print("Error createMumory: \(error)")
                completionHandler(.failure(error))
            } else {
                print("createMumory successfully!")

                self.isCreating = false
                completionHandler(.success(()))
            }
        }
        
    }

    public func updateMumory(_ mumory: Mumory, completion: @escaping () -> Void) {
        
        let db = FirebaseManager.shared.db
        let documentReference = db.collection("Mumory").document(mumory.id)

        let updatedData: [String: Any] = [
            "userDocumentID": mumory.userDocumentID,
            "date": FirebaseManager.Timestamp(date: mumory.date),
            "songID": String(describing: mumory.musicModel.songID),
            "latitude": mumory.locationModel.coordinate.latitude,
            "longitude": mumory.locationModel.coordinate.longitude,
            "tags": mumory.tags ?? [],
            "content": mumory.content ?? "",
            "imageURLs": mumory.imageURLs ?? [],
            "isPublic": mumory.isPublic,
            "likes": mumory.likes,
            "comments": mumory.comments.map { $0.toDictionary() }
        ]
        
        
        documentReference.updateData(updatedData) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
                
                if let originalMumory = self.myMumoryAnnotations.first(where: { $0.id == mumory.id }) {
                    mumory.copy(from: originalMumory)
                }
            } else {
                print("updateMumory successfully! : \(documentReference.documentID)")
                
//                if let index = self.myMumoryAnnotations.firstIndex(where: { $0.id == mumory.id }) {
//                    self.myMumoryAnnotations[index] = mumory
//                }
//
//                if let index = self.everyMumoryAnnotations.firstIndex(where: { $0.id == mumory.id }) {
//                    self.everyMumoryAnnotations[index] = mumory
//                }
                
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
//                if let index = self.myMumoryAnnotations.firstIndex(where: { $0.id == mumory.id }) {
//                    self.myMumoryAnnotations.remove(at: index)
//                }
//
//                if let index = self.everyMumoryAnnotations.firstIndex(where: { $0.id == mumory.id }) {
//                    self.everyMumoryAnnotations.remove(at: index)
//                }

                completion()
                print("Document deleted successfully!")
            }
        }
    }
    
    public func likeMumory(mumoryAnnotation: Mumory, loginUserID: String) {
        
        let db = FirebaseManager.shared.db

        let postRef = db.collection("User").document(mumoryAnnotation.userDocumentID).collection("mumory").document(mumoryAnnotation.id)
        
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
            
            if oldLikes.contains(loginUserID) {
                if let index = oldLikes.firstIndex(of: loginUserID) {
                    oldLikes.remove(at: index)
                    mumoryAnnotation.likes.remove(at: index)
                }
            } else {
                oldLikes.append(loginUserID)
                mumoryAnnotation.likes.append(loginUserID)
            }
            
            if let index = self.everyMumoryAnnotations.firstIndex(where: { $0.id == mumoryAnnotation.id }) {
                DispatchQueue.main.async {
                    self.everyMumoryAnnotations[index] = mumoryAnnotation
                }
            }
            
            transaction.updateData(["likes": oldLikes], forDocument: postRef)
            
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }
    
    public func createComment(comment: Comment) {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Comment")
        
        let newData: [String: Any] = comment.toDictionary()
        
        collectionReference.addDocument(data: newData) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("createComment Document added with ID: \(collectionReference.document().documentID)")
            }
        }
    }
    
    public func createReply(commentDocumentID: String, reply: Comment) {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Comment").document(commentDocumentID).collection("Reply")
        
        let newData: [String: Any] = reply.toDictionary()
        
        collectionReference.addDocument(data: newData) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("createReply Document added with ID: \(collectionReference.document().documentID)")
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
        let collectionReference = db.collection("User").document("tester3").collection("mumory")
        
//        let dispatchGroup = DispatchGroup()
        
        collectionReference.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                
                for document in querySnapshot!.documents {
                    
                    if let content = document.data()["content"] as? String, content.contains(where: { $0.lowercased() == searchString.lowercased() }) {
                        print("searchMumoryByContent successfully! : \(document.documentID)")
                        
                        let documentData = document.data()
                        
                        if let author = documentData["author"] as? String,
                           let musicItemIDString = documentData["MusicItemID"] as? String,
                           let locationTitle = documentData["locationTitle"] as? String,
                           let locationSubtitle = documentData["locationSubtitle"] as? String,
                           let latitude = documentData["latitude"] as? Double,
                           let longitude = documentData["longitude"] as? Double,
                           let date = documentData["date"] as? FirebaseManager.Timestamp,
                           let tags = documentData["tags"] as? [String],
                           let content = documentData["content"] as? String,
                           let imageURLs = documentData["imageURLs"] as? [String],
                           let isPublic = documentData["isPublic"] as? Bool,
                           let likes = documentData["likes"] as? [String],
                           let comments = documentData["comments"] as? [[String: Any]]
                        {
                            
                            Task {
                                let musicModel = try await self.fetchMusic(musicID: musicItemIDString)
                                let locationModel = LocationModel(locationTitle: locationTitle, locationSubtitle: locationSubtitle, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                                
                                let commentsData = comments.compactMap { Comment(data: $0) } // : [Comment]
                                
                                let newMumoryAnnotation = Mumory(id: document.documentID, userDocumentID: author, date: date.dateValue(), musicModel: musicModel, locationModel: locationModel, tags: tags, content: content, imageURLs: imageURLs, isPublic: isPublic, likes: likes, comments: commentsData)
                                
                                DispatchQueue.main.async {
                                    self.searchedMumoryAnnotations.append(newMumoryAnnotation)                                    
                                }
                            }
                        }
                    }
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
    
    public func createMumory2(_ mumoryAnnotation : Mumory, completionHandler: @escaping (Result<Void, Error>) -> Void)  {
        let db = FirebaseManager.shared.db
        
        let newData: [String: Any] = [
            "author": "tester",
            "MusicItemID": String(describing: mumoryAnnotation.musicModel.songID),
            "locationTitle": mumoryAnnotation.locationModel.locationTitle,
            "locationSubtitle": mumoryAnnotation.locationModel.locationSubtitle,
            "latitude": mumoryAnnotation.locationModel.coordinate.latitude,
            "longitude": mumoryAnnotation.locationModel.coordinate.longitude,
            "date": FirebaseManager.Timestamp(date: mumoryAnnotation.date),
            "tags": mumoryAnnotation.tags ?? [],
            "content": mumoryAnnotation.content ?? "",
            "imageURLs": mumoryAnnotation.imageURLs ?? [],
            "isPublic": mumoryAnnotation.isPublic,
            "likes": mumoryAnnotation.likes,
            "comments": mumoryAnnotation.comments
        ]
        
        
        let documentReference = db.collection("User").document("tester").collection("mumory")

        documentReference.addDocument(data: newData) { error in
            if let error = error {
                print("Error adding tester document: \(error.localizedDescription)")
                completionHandler(.failure(error))
            } else {
                let newMumoryAnnotation = Mumory(id: documentReference.document().documentID, userDocumentID: "tester", date: mumoryAnnotation.date, musicModel: mumoryAnnotation.musicModel, locationModel: mumoryAnnotation.locationModel, tags: mumoryAnnotation.tags, content: mumoryAnnotation.content, imageURLs: mumoryAnnotation.imageURLs, isPublic: mumoryAnnotation.isPublic, likes: mumoryAnnotation.likes, comments: mumoryAnnotation.comments)
                
                self.myMumoryAnnotations.append(newMumoryAnnotation)
                self.isCreating = false
                completionHandler(.success(()))
            }
        }
    }
    
    public func deleteMumory2(_ mumoryAnnotation: Mumory, completion: @escaping () -> Void) {
        
        let db = FirebaseManager.shared.db
        
        let documentReference = db.collection("User").document(mumoryAnnotation.userDocumentID).collection("mumory").document(mumoryAnnotation.id)
        
        // 문서 삭제
        documentReference.delete { error in
            if let error = error {
                print("Error deleting document: \(error.localizedDescription)")
            } else {
                if let index = self.myMumoryAnnotations.firstIndex(where: { $0.id == mumoryAnnotation.id }) {
                    self.myMumoryAnnotations.remove(at: index)
                }
                
                if let index = self.everyMumoryAnnotations.firstIndex(where: { $0.id == mumoryAnnotation.id }) {
                    self.everyMumoryAnnotations.remove(at: index)
                }

                completion()
                print("Document deleted successfully!")
            }
        }
    }
    
    public func createComment2(mumoryAnnotation: Mumory, loginUserID: String, comment: Comment) {
        
        let db = FirebaseManager.shared.db
        
        let commentsRef = db.collection("User").document(mumoryAnnotation.userDocumentID).collection("mumory").document(mumoryAnnotation.id)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            
            let postDocument: DocumentSnapshot
            
            do {
                try postDocument = transaction.getDocument(commentsRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var oldComments = postDocument.data()?["comments"] as? [[String: Any]] else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Unable to retrieve likes from snapshot \(postDocument)"
                ])
                errorPointer?.pointee = error
                return nil
            }
            
            let commentData = comment.toDictionary()
            print("commentData: \(commentData)")

            oldComments.append(commentData) // : [String: Any]
            mumoryAnnotation.comments.append(comment) // : Comment
            
            if let index = self.everyMumoryAnnotations.firstIndex(where: { $0.id == mumoryAnnotation.id }) {
                DispatchQueue.main.async {
                    self.everyMumoryAnnotations[index] = mumoryAnnotation
                }
            }
            
            transaction.updateData(["comments": oldComments], forDocument: commentsRef)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                self.fetchEveryMumory()
                print("Transaction successfully committed!")
            }
        }
    }
    
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

}
