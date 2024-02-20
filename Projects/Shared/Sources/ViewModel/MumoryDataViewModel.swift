//
//  AnnotationViewModel.swift
//  Feature
//
//  Created by 다솔 on 2023/12/19.
//  Copyright © 2023 hollys. All rights reserved.
//


import Foundation
//import Core
import MapKit
import MusicKit


final public class MumoryDataViewModel: ObservableObject {
    
    @Published public var choosedMusicModel: MusicModel?
    @Published public var choosedLocationModel: LocationModel?
    
    @Published public var musicModels: [MusicModel] = []
    @Published public var mumoryAnnotations: [MumoryAnnotation] = []
    @Published public var mumoryCarouselAnnotations: [MumoryAnnotation] = []
    
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
    
    public func fetchData() {
        
        let db = FirebaseManager.shared.db
        
        let mumoryCollectionRef = db.collection("User").document("tester").collection("mumory")

        mumoryCollectionRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching playlist documents: \(error.localizedDescription)")
            } else {
                for document in snapshot!.documents {
                    print("document.documentID: \(document.documentID)")
                    let documentData = document.data()
                    
                    if let musicItemIDString = documentData["MusicItemID"] as? String,
                       let locationTitle = documentData["locationTitle"] as? String,
                       let locationSubtitle = documentData["locationSubtitle"] as? String,
                       let latitude = documentData["latitude"] as? Double,
                       let longitude = documentData["longitude"] as? Double,
                       let date = documentData["date"] as? FirebaseManager.Timestamp,
                       let tags = documentData["tags"] as? [String],
                       let content = documentData["content"] as? String,
                       let imageURLs = documentData["imageURLs"] as? [String],
                       let isPublic = documentData["isPublic"] as? Bool
                    {
                        Task {
                            do {
                                let musicModel = try await self.fetchMusic(musicID: musicItemIDString)
                                let locationModel = LocationModel(locationTitle: locationTitle, locationSubtitle: locationSubtitle, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                                
//                                let tags = tags.components(separatedBy: ",")
//                                let imageURLs = imageURLs.components(separatedBy: ",")
                                
                                let newMumoryAnnotation = MumoryAnnotation(id: document.documentID, date: date.dateValue(), musicModel: musicModel, locationModel: locationModel, tags: tags, content: content, imageURLs: imageURLs, isPublic: isPublic)
                                
                                DispatchQueue.main.async {
                                    self.mumoryAnnotations.append(newMumoryAnnotation)
                                }
                            } catch {
                                print("Error fetching music: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func loadData() {
        let db = FirebaseManager.shared.db
        
        let testerData: [String: Any] = [:]
        
        db.collection("User").document("tester").setData(testerData) { error in
            if let error = error {
                print("Error adding tester document: \(error.localizedDescription)")
            } else {
                print("Tester document added successfully!")
                
                // Add playlist data to the "playlist" collection inside the "tester" document
                let playlistData: [String: Any] = [
                    "playlist": ["1487778081", "1712044358", "1590067123"]
                ]
                
                db.collection("User").document("tester").collection("playlist").document("").setData(playlistData) { error in
                    if let error = error {
                        print("Error adding playlist document: \(error.localizedDescription)")
                    } else {
                        print("Playlist document added successfully!")
                    }
                }
            }
        }
    }
    
    public func createMumory(_ mumoryAnnotation : MumoryAnnotation) {
        let db = FirebaseManager.shared.db
                
        var newData: [String: Any] = [
            "MusicItemID": String(describing: mumoryAnnotation.musicModel.songID),
            "locationTitle": mumoryAnnotation.locationModel.locationTitle,
            "locationSubtitle": mumoryAnnotation.locationModel.locationSubtitle,
            "latitude": mumoryAnnotation.locationModel.coordinate.latitude,
            "longitude": mumoryAnnotation.locationModel.coordinate.longitude,
            "date": FirebaseManager.Timestamp(date: mumoryAnnotation.date),
            "tags": mumoryAnnotation.tags ?? [],
            "content": mumoryAnnotation.content ?? "",
            "imageURLs": mumoryAnnotation.imageURLs ?? [],
            "isPublic": mumoryAnnotation.isPublic
        ]
        
        let documentReference = db.collection("User").document("tester").collection("mumory").document()
        
        documentReference.setData(newData, merge: true) { error in
            if let error = error {
                print("Error adding tester document: \(error.localizedDescription)")
            } else {
                print("Tester document added successfully! : \(documentReference.documentID)")
                
                let newMumoryAnnotation = MumoryAnnotation(id: documentReference.documentID, date: mumoryAnnotation.date, musicModel: mumoryAnnotation.musicModel, locationModel: mumoryAnnotation.locationModel, tags: mumoryAnnotation.tags, content: mumoryAnnotation.content, imageURLs: mumoryAnnotation.imageURLs, isPublic: mumoryAnnotation.isPublic)
                
                self.mumoryAnnotations.append(newMumoryAnnotation)
            }
        }
    }
    
    public func updateMumory(_ mumoryAnnotation: MumoryAnnotation) {
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
            "isPublic": mumoryAnnotation.isPublic
        ]
        
        let documentReference = db.collection("User").document("tester").collection("mumory").document(mumoryAnnotation.id ?? "")
        
        documentReference.updateData(updatedData) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
            } else {
                print("Document updated successfully! : \(documentReference.documentID)")
                
                // If you need to update the local array of annotations, you can find the index of the annotation and replace it
                if let index = self.mumoryAnnotations.firstIndex(where: { $0.id == mumoryAnnotation.id }) {
                    self.mumoryAnnotations[index] = mumoryAnnotation
                }
                
                
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
