//
//  AnnotationViewModel.swift
//  Feature
//
//  Created by 다솔 on 2023/12/19.
//  Copyright © 2023 hollys. All rights reserved.
//


import Foundation
import Shared
import Core
import MapKit
import MusicKit


final public class MumoryDataViewModel: ObservableObject {
    
    @Published var choosedMusicModel: MusicModel?
    @Published var choosedLocationModel: LocationModel?
    @Published var createdMumoryAnnotation: MumoryAnnotation?
    
    @Published public var musicModels: [MusicModel] = []
    @Published public var mumoryAnnotations: [MumoryAnnotation] = []
    
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
    
    @MainActor
    func loadMusics() async {
        let musicIDs: [String] = ["1487778081", "1712044358", "1590067123"]
        
        guard let userLocation = CLLocationManager().location else {
            print("User location is not available")
            return
        }
        
        for id in musicIDs {
            do {
                let songItem = try await fetchMusic(musicID: id)
                let newAnnotation = MumoryAnnotation(date: Date(), musicModel: songItem, locationModel: LocationModel(locationTitle: "ㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋ", locationSubtitle: "ㅎㅎ", coordinate: userLocation.coordinate))
                self.mumoryAnnotations.append(newAnnotation)
            } catch {
                print("Error fetching song info for ID \(id): \(error)")
            }
        }
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
    
    func fetchData() {
        
        let db = FirebaseManager.shared.db
        
        let playlistCollectionRef = db.collection("User").document("tester").collection("mumory")
        
        playlistCollectionRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching playlist documents: \(error.localizedDescription)")
            } else {
                for document in snapshot!.documents {
                    let documentData = document.data()
                    print("documentData: \(documentData)")
                    
                    if let musicItemIDString = documentData["MusicItemID"] as? String,
                       let locationTitle = documentData["locationTitle"] as? String,
                       let locationSubtitle = documentData["locationSubtitle"] as? String,
                       let latitude = documentData["latitude"] as? Double,
                       let longitude = documentData["longitude"] as? Double {
                        
                        Task {
                            do {
                                let musicModel = try await self.fetchMusic(musicID: musicItemIDString)
                                let locationModel = LocationModel(locationTitle: locationTitle, locationSubtitle: locationSubtitle, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                                
                                let newMumoryAnnotation = MumoryAnnotation(date: Date(), musicModel: musicModel, locationModel: locationModel)
                                
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
        
        let newData: [String: Any] = [
            "MusicItemID": String(describing: mumoryAnnotation.musicModel.songID),
            "locationTitle": mumoryAnnotation.locationModel.locationTitle,
            "locationSubtitle": mumoryAnnotation.locationModel.locationSubtitle,
            "latitude": mumoryAnnotation.locationModel.coordinate.latitude,
            "longitude": mumoryAnnotation.locationModel.coordinate.longitude
        ]
        
        db.collection("User").document("tester").collection("mumory").document().setData(newData, merge: true) { error in
            if let error = error {
                print("Error adding tester document: \(error.localizedDescription)")
            } else {
                print("Tester document added successfully!")
                
                let newMumoryAnnotation = MumoryAnnotation(date: Date(), musicModel: mumoryAnnotation.musicModel, locationModel: mumoryAnnotation.locationModel)
                
                self.mumoryAnnotations.append(newMumoryAnnotation)
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
