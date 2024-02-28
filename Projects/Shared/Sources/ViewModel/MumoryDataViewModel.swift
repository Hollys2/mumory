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

final public class MumoryDataViewModel: ObservableObject {
    
    @Published public var choosedMusicModel: MusicModel?
    @Published public var choosedLocationModel: LocationModel?
    
    @Published public var selectedMumoryAnnotation: MumoryAnnotation?
    
    @Published public var musicModels: [MusicModel] = []
    @Published public var homeMumoryAnnotations: [MumoryAnnotation] = []
    @Published public var socialMumoryAnnotations: [MumoryAnnotation] = []
    @Published public var mumoryCarouselAnnotations: [MumoryAnnotation] = []
    
    @Published public var isFetchFinished: Bool = false
    @Published public var isSocialFetchFinished: Bool = false
    
    @Published public var isLoading: Bool = false
    @Published public var isUpdating: Bool = false
    
    //    private var db = Firestore.firestore()
    
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
    
    //    @MainActor
    //    func loadMusics() async {
    //        let musicIDs: [String] = ["1487778081", "1712044358", "1590067123"]
    //
    //        guard let userLocation = CLLocationManager().location else {
    //            print("User location is not available")
    //            return
    //        }
    //
    //        for id in musicIDs {
    //            do {
    //                let songItem = try await fetchMusic(musicID: id)
    //                let newAnnotation = MumoryAnnotation(date: Date(), musicModel: songItem, locationModel: LocationModel(locationTitle: "ㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋ", locationSubtitle: "ㅎㅎ", coordinate: userLocation.coordinate))
    //                self.mumoryAnnotations.append(newAnnotation)
    //            } catch {
    //                print("Error fetching song info for ID \(id): \(error)")
    //            }
    //        }
    //    }
    
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
    
    public func fetchHomeMumory() {
        
        self.isFetchFinished = false
        let db = FirebaseManager.shared.db
        
        let mumoryCollectionRef = db.collection("User").document("tester").collection("mumory")
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
                       let comments = documentData["comments"] as? [Comment]
                    {
                        do {
                            let musicModel = try await self.fetchMusic(musicID: musicItemIDString)
                            let locationModel = LocationModel(locationTitle: locationTitle, locationSubtitle: locationSubtitle, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                            
                            let newMumoryAnnotation = MumoryAnnotation(author: author, id: document.documentID, date: date.dateValue(), musicModel: musicModel, locationModel: locationModel, tags: tags, content: content, imageURLs: imageURLs, isPublic: isPublic, likes: likes, comments: comments)
                            
                            DispatchQueue.main.async {
                                if !self.homeMumoryAnnotations.contains(where: { $0.id == newMumoryAnnotation.id }) {
                                    self.homeMumoryAnnotations.append(newMumoryAnnotation)
                                    self.homeMumoryAnnotations.sort { $0.date > $1.date }
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
                    // 여기서 모든 데이터가 완료되었을 때의 작업을 수행할 수 있습니다.
                    self.isFetchFinished = true
                    print("fetchHomeMumory successfully!")
                }
            } catch {
                print("Error fetching playlist documents: \(error.localizedDescription)")
            }
        }
        
        //        mumoryCollectionRef.getDocuments { (snapshot, error) in
        //            if let error = error {
        //                print("Error fetching playlist documents: \(error.localizedDescription)")
        //            } else {
        //                for document in snapshot!.documents {
        //
        //                    print("document.documentID: \(document.documentID)")
        //
        //                    let documentData = document.data()
        //
        //                    if let musicItemIDString = documentData["MusicItemID"] as? String,
        //                       let locationTitle = documentData["locationTitle"] as? String,
        //                       let locationSubtitle = documentData["locationSubtitle"] as? String,
        //                       let latitude = documentData["latitude"] as? Double,
        //                       let longitude = documentData["longitude"] as? Double,
        //                       let date = documentData["date"] as? FirebaseManager.Timestamp,
        //                       let tags = documentData["tags"] as? [String],
        //                       let content = documentData["content"] as? String,
        //                       let imageURLs = documentData["imageURLs"] as? [String],
        //                       let isPublic = documentData["isPublic"] as? Bool
        //                    {
        //                        Task {
        //                            do {
        //                                let musicModel = try await self.fetchMusic(musicID: musicItemIDString)
        //                                let locationModel = LocationModel(locationTitle: locationTitle, locationSubtitle: locationSubtitle, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        //
        //                                let newMumoryAnnotation = MumoryAnnotation(id: document.documentID, date: date.dateValue(), musicModel: musicModel, locationModel: locationModel, tags: tags, content: content, imageURLs: imageURLs, isPublic: isPublic)
        //
        //                                DispatchQueue.main.async {
        //                                    self.mumoryAnnotations.append(newMumoryAnnotation)
        //                                    self.mumoryAnnotations.sort { $0.date > $1.date }
        //                                }
        //
        //                                self.isFetchFinished = true
        //                            } catch {
        //                                print("Error fetching music: \(error.localizedDescription)")
        //                            }
        //                        }
        //                    }
        //
        //                }
        //            }
        //        }
    }
    
    public func fetchMumoryAnnotation(mumoryID id: String) async throws -> MumoryAnnotation? {
        
        let db = FirebaseManager.shared.db
        
        let mumoryDocumentRef = db.collection("User").document("tester").collection("mumory").document(id)
        
        do {
            let documentSnapshot = try await mumoryDocumentRef.getDocument()
            if let documentData = documentSnapshot.data(),
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
               let comments = documentData["comments"] as? [Comment]
            {
                do {
                    let musicModel = try await self.fetchMusic(musicID: musicItemIDString)
                    let locationModel = LocationModel(locationTitle: locationTitle, locationSubtitle: locationSubtitle, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                    
                    let mumoryAnnotation = MumoryAnnotation(author: author, id: documentSnapshot.documentID, date: date.dateValue(), musicModel: musicModel, locationModel: locationModel, tags: tags, content: content, imageURLs: imageURLs, isPublic: isPublic, likes: likes, comments: comments)
                    
                    print("fetch MumoryAnnotation successfully")
                    
                    return mumoryAnnotation
                } catch {
                    print("Error fetching music: \(error.localizedDescription)")
                    return nil
                }
            } else {
                return nil
            }
        } catch {
            print("Error fetching mumory document: \(error.localizedDescription)")
            return nil
        }
    }
    
    public func fetchSocialMumory() {
        
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
                            print("comments: \(comments)")
                            print("commentsData: \(commentsData)")
                            
                            let newMumoryAnnotation = MumoryAnnotation(author: author, id: document.documentID, date: date.dateValue(), musicModel: musicModel, locationModel: locationModel, tags: tags, content: content, imageURLs: imageURLs, isPublic: isPublic, likes: likes, comments: commentsData)
                            
                            DispatchQueue.main.async {
                                if !self.socialMumoryAnnotations.contains(where: { $0.id == newMumoryAnnotation.id }) {
                                    self.socialMumoryAnnotations.append(newMumoryAnnotation)
                                    self.socialMumoryAnnotations.sort { $0.date > $1.date }
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
                    
                    self.isSocialFetchFinished = true
                    print("fetchSocialMumory successfully!")
                }
            } catch {
                print("Error fetching playlist documents: \(error.localizedDescription)")
            }
        }
        
        
        //        do {
        //            let documentSnapshot = try await mumoryDocumentRef.getDocument()
        //            if let documentData = documentSnapshot.data(),
        //               let musicItemIDString = documentData["MusicItemID"] as? String,
        //               let locationTitle = documentData["locationTitle"] as? String,
        //               let locationSubtitle = documentData["locationSubtitle"] as? String,
        //               let latitude = documentData["latitude"] as? Double,
        //               let longitude = documentData["longitude"] as? Double,
        //               let date = documentData["date"] as? FirebaseManager.Timestamp,
        //               let tags = documentData["tags"] as? [String],
        //               let content = documentData["content"] as? String,
        //               let imageURLs = documentData["imageURLs"] as? [String],
        //               let isPublic = documentData["isPublic"] as? Bool,
        //               let likes = documentData["likes"] as? [String],
        //               let comments = documentData["comments"] as? [Comment]
        //            {
        //                do {
        //                    let musicModel = try await self.fetchMusic(musicID: musicItemIDString)
        //                    let locationModel = LocationModel(locationTitle: locationTitle, locationSubtitle: locationSubtitle, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        //
        //                    let mumoryAnnotation = MumoryAnnotation(id: documentSnapshot.documentID, date: date.dateValue(), musicModel: musicModel, locationModel: locationModel, tags: tags, content: content, imageURLs: imageURLs, isPublic: isPublic, likes: likes, comments: comments)
        //
        //                    print("fetch MumoryAnnotation successfully")
        //
        //                    return mumoryAnnotation
        //                } catch {
        //                    print("Error fetching music: \(error.localizedDescription)")
        //                    return nil
        //                }
        //            } else {
        //                return nil
        //            }
        //        } catch {
        //            print("Error fetching mumory document: \(error.localizedDescription)")
        //            return nil
        //        }
    }
    
    
    public func createMumory(_ mumoryAnnotation : MumoryAnnotation) {
        let db = FirebaseManager.shared.db
        
        var newData: [String: Any] = [
            "author": "tester3",
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
            "comments":mumoryAnnotation.comments
        ]
        
        //        let documentReference = db.collection("User").document("tester").collection("mumory").document()
        let documentReference = db.collection("User").document("tester3").collection("mumory")
        
        documentReference.addDocument(data: newData) { error in
            if let error = error {
                print("Error adding tester document: \(error.localizedDescription)")
            } else {
                let newMumoryAnnotation = MumoryAnnotation(author: "tester3", id: documentReference.document().documentID, date: mumoryAnnotation.date, musicModel: mumoryAnnotation.musicModel, locationModel: mumoryAnnotation.locationModel, tags: mumoryAnnotation.tags, content: mumoryAnnotation.content, imageURLs: mumoryAnnotation.imageURLs, isPublic: mumoryAnnotation.isPublic, likes: mumoryAnnotation.likes, comments: mumoryAnnotation.comments)
                
                self.homeMumoryAnnotations.append(newMumoryAnnotation)
            }
        }
        
        //        documentReference.setData(newData, merge: true) { error in
        //            if let error = error {
        //                print("Error adding tester document: \(error.localizedDescription)")
        //            } else {
        //                print("Tester document added successfully! : \(documentReference.documentID)")
        //
        //                let newMumoryAnnotation = MumoryAnnotation(id: documentReference.documentID, date: mumoryAnnotation.date, musicModel: mumoryAnnotation.musicModel, locationModel: mumoryAnnotation.locationModel, tags: mumoryAnnotation.tags, content: mumoryAnnotation.content, imageURLs: mumoryAnnotation.imageURLs, isPublic: mumoryAnnotation.isPublic, likes: mumoryAnnotation.likes, comments: mumoryAnnotation.comments)
        //
        //                self.mumoryAnnotations.append(newMumoryAnnotation)
        //            }
        //        }
    }
    
    public func updateMumory(_ mumoryAnnotation: MumoryAnnotation, completion: @escaping () -> Void) {
        
        let db = FirebaseManager.shared.db
        
        var updatedData: [String: Any] = [
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
        
        let documentReference = db.collection("User").document("tester").collection("mumory").document(mumoryAnnotation.id)
        
        documentReference.updateData(updatedData) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
                
                if let originalMumoryAnnotation = self.homeMumoryAnnotations.first(where: { $0.id == mumoryAnnotation.id }) {
                    mumoryAnnotation.copy(from: originalMumoryAnnotation)
                }
            } else {
                print("Document updated successfully! : \(documentReference.documentID)")
                
                self.isUpdating = false
                // If you need to update the local array of annotations, you can find the index of the annotation and replace it
                if let index = self.homeMumoryAnnotations.firstIndex(where: { $0.id == mumoryAnnotation.id }) {
                    self.homeMumoryAnnotations[index] = mumoryAnnotation
                }
                
                completion()
            }
        }
    }
    
    public func deleteMumory(_ mumoryAnnotation: MumoryAnnotation) {
        let db = FirebaseManager.shared.db
        
        let documentReference = db.collection("User").document("tester").collection("mumory").document(mumoryAnnotation.id)
        
        // 문서 삭제
        documentReference.delete { error in
            if let error = error {
                print("Error deleting document: \(error.localizedDescription)")
            } else {
                print("Document deleted successfully!")
            }
        }
        
        // 배열에서도 해당 객체 삭제
        if let index = self.homeMumoryAnnotations.firstIndex(where: { $0.id == mumoryAnnotation.id }) {
            self.homeMumoryAnnotations.remove(at: index)
        }
    }
    
    public func likeMumory(mumoryAnnotation: MumoryAnnotation, loginUserID: String) {
        
        let db = FirebaseManager.shared.db

        let postRef = db.collection("User").document(mumoryAnnotation.author).collection("mumory").document(mumoryAnnotation.id)
        
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
            
            if let index = self.socialMumoryAnnotations.firstIndex(where: { $0.id == mumoryAnnotation.id }) {
                DispatchQueue.main.async {
                    self.socialMumoryAnnotations[index] = mumoryAnnotation
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
    
    public func createComment(mumoryAnnotation: MumoryAnnotation, loginUserID: String, comment: Comment) {
        
        let db = FirebaseManager.shared.db
        
        let commentsRef = db.collection("User").document(mumoryAnnotation.author).collection("mumory").document(mumoryAnnotation.id)
        
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
            
            oldComments.append(commentData)
            mumoryAnnotation.comments.append(comment)
            
            if let index = self.socialMumoryAnnotations.firstIndex(where: { $0.id == mumoryAnnotation.id }) {
                DispatchQueue.main.async {
                    self.socialMumoryAnnotations[index] = mumoryAnnotation
                }
            }
            
            transaction.updateData(["comments": oldComments], forDocument: commentsRef)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }
    
    
    private func uploadImageToStorage(completion: @escaping (URL?) -> Void) {
        
        //        guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
        //            print("Could not convert image to Data.")
        //            continue
        //        }
        
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

//    func fetchSongInfo(songId: String) async throws -> AnnotationModel {
//        let musicItemID = MusicItemID(rawValue: songId)
//        let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
//        let response = try await request.response()
//        guard let song = response.items.first else {
//            throw NSError(domain: "GoogleMapSample", code: 1, userInfo: [NSLocalizedDescriptionKey: "Song not found"])
//        }
////        print("response.items.first: \(song)")
//
//        if let artworkUrl = song.artwork?.url(width: 400, height: 400) {
//                  return AnnotationModel(date: Date(), location: "Nowhere", songID: musicItemID, title: song.title, artist: song.artistName, artworkUrl: artworkUrl)
//        } else {
//            // nil인 경우, 기본값으로 URL을 설정하거나 에러를 처리하는 등의 작업을 수행할 수 있습니다.
//            // 여기서는 기본값으로 빈 URL을 설정했습니다.
//            return AnnotationModel(date: Date(), location: "Nowhere", songID: musicItemID, title: song.title, artist: song.artistName, artworkUrl: URL(string: "https://previews.123rf.com/images/martialred/martialred1507/martialred150700740/42614010-%EC%95%B1%EA%B3%BC-%EC%9B%B9-%EC%82%AC%EC%9D%B4%ED%8A%B8%EC%97%90-%EB%8C%80%ED%95%9C-%EC%9D%B8%ED%84%B0%EB%84%B7-url-%EB%A7%81%ED%81%AC-%EB%9D%BC%EC%9D%B8-%EC%95%84%ED%8A%B8-%EC%95%84%EC%9D%B4%EC%BD%98.jpg")!)
//        }
//    }
