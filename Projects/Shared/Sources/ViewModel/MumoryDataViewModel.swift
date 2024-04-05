//
//  AnnotationViewModel.swift
//  Feature
//
//  Created by 다솔 on 2023/12/19.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
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
    @Published public var friendMumorys: [Mumory] = []
    @Published public var sameSongFriendMumorys: [Mumory] = []
    @Published public var everyMumorys: [Mumory] = []
    @Published public var monthlyMumorys: [Mumory] = []
    @Published public var surroundingMumorys: [Mumory] = []
    @Published public var locationMumorys: [String: [Mumory]] = [:]
    
    @Published public var myActivity: [(String, String)] = []
    @Published public var myRewards: [String] = []
    
    @Published public var favoriteDate: [Date] = []
    
    @Published public var mumoryComments: [Comment] = []
    @Published public var mumoryCarouselAnnotations: [Mumory] = []
    @Published public var searchedMumoryAnnotations: [Mumory] = []
    
    @Published public var isLoading: Bool = false
    @Published public var isUpdating: Bool = false
    @Published public var isFirstSocialLoad: Bool = false
    
    @Published public var isRewardPopUpShown: Bool = false
    @Published public var reward: Reward = .none
    
    @Published public var listener: ListenerRegistration?
    @Published public var rewardListener: ListenerRegistration?
    @Published public var activityListener: ListenerRegistration?
    
    private var tempMumory: [Mumory] = []
    private var tempSocialMumory: [Mumory] = []
    private var lastDocument: DocumentSnapshot?
    private var initialSnapshot: Bool = true
    private var initialMumorySnapshot: Bool = true
    
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
            
            let locationModel = LocationModel(locationTitle: locationTitle, locationSubtitle: locationSubtitle, coordinate: coordinate, country: placemark.country ?? "", administrativeArea: placemark.administrativeArea ?? "")
            
            completion(locationModel)
        }
    }
    
    public func fetchMyMumoryListener(uId: String) -> ListenerRegistration {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Mumory")
        
        let query = collectionReference
            .whereField("uId", isEqualTo: uId)
            .order(by: "date", descending: true)
        
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
                        
                        DispatchQueue.main.async {
                            if !self.myMumorys.contains(where: { $0.id == newMumory.id }) {
                                self.myMumorys.append(newMumory)
                                self.myMumorys.sort { $0.date > $1.date }
                                print("fetchMyMumoryListener: \(self.myMumorys)")
                                
                                if self.myMumorys.count == 1 {
                                    let collectionReference = db.collection("User").document(uId).collection("Reward")
                                    let data = ["type": "record0"]
                                    collectionReference.addDocument(data: data)
                                } else if self.myMumorys.count == 5 {
                                    let collectionReference = db.collection("User").document(uId).collection("Reward")
                                    let data = ["type": "record1"]
                                    collectionReference.addDocument(data: data)
                                } else if self.myMumorys.count == 10 {
                                    let collectionReference = db.collection("User").document(uId).collection("Reward")
                                    let data = ["type": "record2"]
                                    collectionReference.addDocument(data: data)
                                } else if self.myMumorys.count == 20 {
                                    let collectionReference = db.collection("User").document(uId).collection("Reward")
                                    let data = ["type": "record3"]
                                    collectionReference.addDocument(data: data)
                                } else if self.myMumorys.count == 50 {
                                    let collectionReference = db.collection("User").document(uId).collection("Reward")
                                    let data = ["type": "record4"]
                                    collectionReference.addDocument(data: data)
                                }
                                
                                var country = newMumory.locationModel.country
                                let administrativeArea = newMumory.locationModel.administrativeArea
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
                                        
                                        print("fetchMyMumoryListener locationMumorys1: \(self.locationMumorys)")
                                        
                                        if self.locationMumorys.count == 2 {
                                            let collectionReference = db.collection("User").document(uId).collection("Reward")
                                            let data = ["type": "location0"]
                                            collectionReference.addDocument(data: data)
                                        } else if self.locationMumorys.count == 3 {
                                            let collectionReference = db.collection("User").document(uId).collection("Reward")
                                            let data = ["type": "location1"]
                                            collectionReference.addDocument(data: data)
                                        } else if self.locationMumorys.count == 5 {
                                            let collectionReference = db.collection("User").document(uId).collection("Reward")
                                            let data = ["type": "location2"]
                                            collectionReference.addDocument(data: data)
                                        } else if self.locationMumorys.count == 10 {
                                            let collectionReference = db.collection("User").document(uId).collection("Reward")
                                            let data = ["type": "location3"]
                                            collectionReference.addDocument(data: data)
                                        } else if self.locationMumorys.count == 15 {
                                            let collectionReference = db.collection("User").document(uId).collection("Reward")
                                            let data = ["type": "location4"]
                                            collectionReference.addDocument(data: data)
                                        }
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
                                        
                                        print("fetchMyMumoryListener locationMumorys2: \(self.locationMumorys)")
                                        
                                        if self.locationMumorys.count == 2 {
                                            let collectionReference = db.collection("User").document(uId).collection("Reward")
                                            let data = ["type": "location0"]
                                            collectionReference.addDocument(data: data)
                                        } else if self.locationMumorys.count == 3 {
                                            let collectionReference = db.collection("User").document(uId).collection("Reward")
                                            let data = ["type": "location1"]
                                            collectionReference.addDocument(data: data)
                                        } else if self.locationMumorys.count == 5 {
                                            let collectionReference = db.collection("User").document(uId).collection("Reward")
                                            let data = ["type": "location2"]
                                            collectionReference.addDocument(data: data)
                                        } else if self.locationMumorys.count == 10 {
                                            let collectionReference = db.collection("User").document(uId).collection("Reward")
                                            let data = ["type": "location3"]
                                            collectionReference.addDocument(data: data)
                                        } else if self.locationMumorys.count == 15 {
                                            let collectionReference = db.collection("User").document(uId).collection("Reward")
                                            let data = ["type": "location4"]
                                            collectionReference.addDocument(data: data)
                                        }
                                    }
                                }
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
                        if let index = self.everyMumorys.firstIndex(where: { $0.id == modifiedDocumentID }),
                           let updatedMumory = await Mumory.fromDocumentDataToMumory(documentData, mumoryDocumentID: self.everyMumorys[index].id) {
                            DispatchQueue.main.async {
                                self.everyMumorys[index] = updatedMumory
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
    
    public func fetchRewardListener(user: MumoriUser) -> ListenerRegistration {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("User").document(user.uId).collection("Reward")
        
        let listener = collectionReference.addSnapshotListener { snapshot, error in
            Task {
                guard let snapshot = snapshot, error == nil else {
                    print("Error fetchRewardListener: \(error!)")
                    return
                }

                
                DispatchQueue.main.async {
                    if !self.myRewards.contains(where: { $0 == "attendance0" }) {
                        self.myRewards.append("attendance0")
                        
                        let db = FirebaseManager.shared.db
                        let collectionReference = db.collection("User").document(user.uId).collection("Reward")
                        let data = ["type": "attendance0"]
                        collectionReference.addDocument(data: data)
                        
                        self.reward = .attendance(0)
                        withAnimation(.spring(response: 0.2)) {
                            self.isRewardPopUpShown = true
                        }
                    }
                }
                
                for documentChange in snapshot.documentChanges {
                    guard documentChange.type == .added else { continue }
                    let documentData = documentChange.document.data()
                    guard let type = documentData["type"] as? String else { continue }
                    let newReward: String = type
                    
                    DispatchQueue.main.async {
                        
                        if !self.myRewards.contains(where: { $0 == type }) {
                            self.myRewards.append(newReward)
                            switch type {
                            case "attendance0":
                                self.reward = .attendance(0)
                            case "attendance1":
                                self.reward = .attendance(1)
                            case "attendance2":
                                self.reward = .attendance(2)
                            case "attendance3":
                                self.reward = .attendance(3)
                            case "attendance4":
                                self.reward = .attendance(4)
                            case "record0":
                                self.reward = .record(0)
                            case "record1":
                                self.reward = .record(1)
                            case "record2":
                                self.reward = .record(2)
                            case "record3":
                                self.reward = .record(3)
                            case "record4":
                                self.reward = .record(4)
                            case "location0":
                                self.reward = .location(0)
                            case "location1":
                                self.reward = .location(1)
                            case "location2":
                                self.reward = .location(2)
                            case "location3":
                                self.reward = .location(3)
                            case "location4":
                                self.reward = .location(4)
                            case "like0":
                                self.reward = .like(0)
                            case "like1":
                                self.reward = .like(1)
                            case "like2":
                                self.reward = .like(2)
                            case "like3":
                                self.reward = .like(3)
                            case "like4":
                                self.reward = .like(4)
                            case "comment0":
                                self.reward = .comment(0)
                            case "comment1":
                                self.reward = .comment(1)
                            case "comment2":
                                self.reward = .comment(2)
                            case "comment3":
                                self.reward = .comment(3)
                            case "comment4":
                                self.reward = .comment(4)
                            default:
                                self.reward = .none
                                break
                            }
                            
                            let pastDate: Date = user.signUpDate
                            let currentDate = Date()
                            
                            let calendar = Calendar.current
                            let components = calendar.dateComponents([.day], from: pastDate, to: currentDate)
                            if let dayDifference = components.day {
                                if dayDifference >= 3 {
                                    let db = FirebaseManager.shared.db
                                    let collectionReference = db.collection("User").document(user.uId).collection("Reward")
                                    let data = ["type": "attendance1"]
                                    collectionReference.addDocument(data: data)
                                }
                                
                                if dayDifference >= 7 {
                                    let db = FirebaseManager.shared.db
                                    let collectionReference = db.collection("User").document(user.uId).collection("Reward")
                                    let data = ["type": "attendance2"]
                                    collectionReference.addDocument(data: data)
                                }
                                
                                if dayDifference >= 14 {
                                    let db = FirebaseManager.shared.db
                                    let collectionReference = db.collection("User").document(user.uId).collection("Reward")
                                    let data = ["type": "attendance3"]
                                    collectionReference.addDocument(data: data)
                                }
                                
                                if dayDifference >= 30 {
                                    let db = FirebaseManager.shared.db
                                    let collectionReference = db.collection("User").document(user.uId).collection("Reward")
                                    let data = ["type": "attendance4"]
                                    collectionReference.addDocument(data: data)
                                }
                            }
                            
                            withAnimation(.spring(response: 0.2)) {
                                self.isRewardPopUpShown = true
                            }
                            print("fetchRewardListener added: \(self.reward)")
                            
                        }
                    }
                }
            }
        }
        return listener
    }
    
            
    public func fetchActivityListener(uId: String) -> ListenerRegistration {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("User").document(uId).collection("Activity")
        
        let listener = collectionReference.addSnapshotListener { snapshot, error in
            Task {
                guard let snapshot = snapshot, error == nil else {
                    print("Error fetchRewardListener: \(error!)")
                    return
                }
                
                for documentChange in snapshot.documentChanges {
                    guard documentChange.type == .added else { continue }
                    let documentData = documentChange.document.data()
                    guard let friendUid = documentData["friendUId"] as? String,
                          let type = documentData["type"] as? String else { continue }
                    
                    DispatchQueue.main.async {
                        if !self.myActivity.contains(where: { $0.0 == documentChange.document.documentID }) {
                            if uId != friendUid {
                                let newActivity: (String, String) = (documentChange.document.documentID, type)
                                self.myActivity.append(newActivity)
                                
                                if newActivity.1 == "like" {
                                    if self.myActivity.filter({$0.1 == "like"}).count == 1 {
                                        let collectionReference = db.collection("User").document(uId).collection("Reward")
                                        let data = ["type": "like0"]
                                        collectionReference.addDocument(data: data)
                                    } else if self.myActivity.filter({$0.1 == "like"}).count == 5 {
                                        let collectionReference = db.collection("User").document(uId).collection("Reward")
                                        let data = ["type": "like1"]
                                        collectionReference.addDocument(data: data)
                                    } else if self.myActivity.filter({$0.1 == "like"}).count == 15 {
                                        let collectionReference = db.collection("User").document(uId).collection("Reward")
                                        let data = ["type": "like2"]
                                        collectionReference.addDocument(data: data)
                                    } else if self.myActivity.filter({$0.1 == "like"}).count == 30 {
                                        let collectionReference = db.collection("User").document(uId).collection("Reward")
                                        let data = ["type": "like3"]
                                        collectionReference.addDocument(data: data)
                                    } else if self.myActivity.filter({$0.1 == "like"}).count == 50 {
                                        let collectionReference = db.collection("User").document(uId).collection("Reward")
                                        let data = ["type": "like4"]
                                        collectionReference.addDocument(data: data)
                                    }
                                } else if newActivity.1 == "comment" {
                                    if self.myActivity.filter({$0.1 == "comment"}).count == 1 {
                                        let collectionReference = db.collection("User").document(uId).collection("Reward")
                                        let data = ["type": "comment0"]
                                        collectionReference.addDocument(data: data)
                                    } else if self.myActivity.filter({$0.1 == "comment"}).count == 5 {
                                        let collectionReference = db.collection("User").document(uId).collection("Reward")
                                        let data = ["type": "comment1"]
                                        collectionReference.addDocument(data: data)
                                    } else if self.myActivity.filter({$0.1 == "comment"}).count == 10 {
                                        let collectionReference = db.collection("User").document(uId).collection("Reward")
                                        let data = ["type": "comment2"]
                                        collectionReference.addDocument(data: data)
                                    } else if self.myActivity.filter({$0.1 == "comment"}).count == 20 {
                                        let collectionReference = db.collection("User").document(uId).collection("Reward")
                                        let data = ["type": "comment3"]
                                        collectionReference.addDocument(data: data)
                                    } else if self.myActivity.filter({$0.1 == "comment"}).count == 40 {
                                        let collectionReference = db.collection("User").document(uId).collection("Reward")
                                        let data = ["type": "comment4"]
                                        collectionReference.addDocument(data: data)
                                    }
                                }
                            }
                        }
                        
                        print("fetchActivityListener added")
                    }
                }
                
            }
        }
        return listener
    }
    
    public func fetchActivitys(uId: String) {
        DispatchQueue.main.async {
            self.isUpdating = true
        }
        
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("User").document(uId).collection("Activity")
        
        Task {
            do {
                let snapshot = try await collectionReference.getDocuments()
                
                for document in snapshot.documents {
                    let documentData = document.data()
                    guard let type = documentData["type"] as? String else {
                        DispatchQueue.main.async {
                            self.isUpdating = false
                        }
                        continue }
                    
                    let newResult = (document.documentID, type)
                    DispatchQueue.main.async {
                        self.myActivity.append(newResult)
                    }
                }
                
                print("fetchActivitys successfully: \(myActivity)")
            } catch {
                print("Error fetchActivitys: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isUpdating = false
                }
            }
        }
    }
    
    public func fetchRewards(uId: String) {
        DispatchQueue.main.async {
            self.isUpdating = true
        }
        
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("User").document(uId).collection("Reward")
        
        Task {
            do {
                let snapshot = try await collectionReference.getDocuments()
                
                for document in snapshot.documents {
                    let documentData = document.data()
                    guard let type = documentData["type"] as? String else {
                        DispatchQueue.main.async {
                            self.isUpdating = false
                        }
                        continue }
                    
                    DispatchQueue.main.async {
                        self.myRewards.append(type)
                    }
                }
                
                print("fetchRewards successfully: \(myRewards)")
            } catch {
                print("Error fetchRewards: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isUpdating = false
                }
            }
        }
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
    
    public func fetchMumorys(uId: String, completion: @escaping (Result<[Mumory], Error>) -> Void) {
        DispatchQueue.main.async {
            self.isUpdating = true
        }
        
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Mumory")
            .whereField("uId", isEqualTo: uId)
            .order(by: "date", descending: true)
        
        Task {
            do {
                let snapshot = try await collectionReference.getDocuments()
                
                DispatchQueue.main.async {
                    self.sameSongFriendMumorys = []
                }
                
                var result: [Mumory] = []
                
                for document in snapshot.documents {
                    let documentData = document.data()
                    guard let newMumory = await Mumory.fromDocumentDataToMumory(documentData, mumoryDocumentID: document.documentID) else {
                        DispatchQueue.main.async {
                            self.isUpdating = false
                        }
                        continue
                    }
                    
                    DispatchQueue.main.async {
                        var country = newMumory.locationModel.country
                        let administrativeArea = newMumory.locationModel.administrativeArea
                        
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
                    
                    result.append(newMumory)
                }
                completion(.success(result))
            } catch {
                print("Error fetchMumorys: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isUpdating = false
                }
                completion(.failure(error))
            }
        }
    }
    
    public func fetchEveryMumory(friends: [MumoriUser], me: MumoriUser) {
        DispatchQueue.main.async {
            self.isUpdating = true
        }
        
        let db = FirebaseManager.shared.db
        var friendsUids: [String] = friends.map {$0.uId}
    
        var mumoryCollectionRef = db.collection("Mumory")
            .whereField("uId", in: friendsUids.isEmpty ? ["X"] : friendsUids)
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
                for document in snapshot.documents {
                    let documentData = document.data()
                    guard let newMumory: Mumory = await Mumory.fromDocumentDataToMumory(documentData, mumoryDocumentID: document.documentID) else {
                        DispatchQueue.main.async {
                            self.isUpdating = false
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        if !self.tempSocialMumory.contains(where: { $0.id == document.documentID }) {
                            self.tempSocialMumory.append(newMumory)
                            self.tempSocialMumory.sort { $0.date > $1.date }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.tempSocialMumory.sort { $0.date > $1.date }
                    self.everyMumorys = self.tempSocialMumory
                    self.lastDocument = snapshot.documents.last
                    self.isUpdating = false
                    self.isFirstSocialLoad = true
                }
                
                print("fetchSocialMumory successfully!")
                
                
                if snapshot.documents.count < 7 {
                    print("No more documents to fetch")
                }
            } catch {
                print("Error fetchSocialMumory: \(error.localizedDescription)")
            }
        }
    }
    
    public func fetchEveryMumory2(friends: [MumoriUser], completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let db = FirebaseManager.shared.db
        let friendsUids: [String] = friends.map {$0.uId}
           
        Task {
            var mumoryCollectionRef = db.collection("Mumory")
                .whereField("uId", in: friendsUids.isEmpty ? ["X"] : friendsUids)
                .whereField("isPublic", isEqualTo: true)
                .order(by: "date", descending: true)
                .limit(to: 7)
//            let mumoryCollectionRef = db.collection("Mumory")
//                .order(by: "date", descending: true)
//                .limit(to: 7)

            do {
                let snapshot = try await mumoryCollectionRef.getDocuments()
                self.tempMumory = []
                for document in snapshot.documents {
                    let documentData = document.data()
                    guard let newMumory: Mumory = await Mumory.fromDocumentDataToMumory(documentData, mumoryDocumentID: document.documentID) else {return}
                    
                    DispatchQueue.main.async {
                        if !self.tempMumory.contains(where: { $0.id == document.documentID }) {
                            self.tempMumory.append(newMumory)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.tempMumory.sort { $0.date > $1.date }
                    print("self.tempMumory: \(self.tempMumory)")
                    self.everyMumorys = self.tempMumory
                    self.isUpdating = false
                    completionHandler(.success(()))
                }
                
                print("fetchSocialMumory2 successfully!")

            } catch {
                print("Error fetchSocialMumory: \(error.localizedDescription)")
            }
        }
    }
    
    public static func fetchReward(user: MumoriUser) async -> [String] {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("User").document(user.uId).collection("Reward")
        
        var rewards: [String] = [] // 배열을 초기화
        
        do {
            let querySnapshot = try await collectionReference.getDocuments()
            
            for document in querySnapshot.documents {
                let documentData = document.data()
                guard let reward: String = documentData["type"] as? String else {
                    continue
                }
                rewards.append(reward)
            }
        } catch {
            print("Error fetching documents: \(error)")
        }
        
        return rewards
    }
    
    public static func fetchRewardCount(user: MumoriUser, reward: String) async -> Int {
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
    
    public static func fetchRewardCount(user: MumoriUser) async -> Int {
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
        let collectionReference = db.collection("Mumory").document(mumoryId).collection("Comment").whereField("parentId", isEqualTo: "")
        
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
    
    public func sameSongFriendMumory(friend: MumoriUser, songId: String, mumory: Mumory) async {
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
                let documentData = document.data()
                guard let newMumory: Mumory = await Mumory.fromDocumentDataToMumory(documentData, mumoryDocumentID: document.documentID) else {return}
                
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
    
    public func surroundingFriendMumory(friend: MumoriUser, mumory: Mumory) async {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Mumory")
            .whereField("uId", isEqualTo: friend.uId)
            .whereField("longitude", isGreaterThan: mumory.locationModel.coordinate.longitude - 0.01)
            .whereField("longitude", isLessThan: mumory.locationModel.coordinate.longitude + 0.01)
        
        do {
            let querySnapshot = try await collectionReference.getDocuments()
            DispatchQueue.main.async {
                self.surroundingMumorys = []
                self.tempMumory = []
            }
            
            let filteredQuerySnapshot = querySnapshot.documents.filter {
                let documentData = $0.data()
                let latitude = documentData["latitude"] as? Double ?? 0.0
                return latitude > mumory.locationModel.coordinate.latitude - 0.01 &&
                       latitude < mumory.locationModel.coordinate.latitude + 0.01
            }
            
            for document in filteredQuerySnapshot {
                let documentData = document.data()
                guard let newMumory: Mumory = await Mumory.fromDocumentDataToMumory(documentData, mumoryDocumentID: document.documentID) else { return }
                
                DispatchQueue.main.async {
                    if !self.tempMumory.contains(where: { $0.id == document.documentID}) {
                        if !self.tempMumory.contains(where: { $0.musicModel.songID.rawValue == newMumory.musicModel.songID.rawValue}) {
                            if mumory.musicModel.songID.rawValue != newMumory.musicModel.songID.rawValue {
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
    
    public func fetchFavoriteDate(user: MumoriUser) async {
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
            "coutry": mumory.locationModel.country,
            "administrativeArea": mumory.locationModel.administrativeArea,
            "tags": mumory.tags ?? [],
            "content": mumory.content ?? "",
            "imageURLs": mumory.imageURLs ?? [],
            "isPublic": mumory.isPublic,
            "likes": mumory.likes,
            "commentCount": mumory.commentCount,
            "myCommentCount": mumory.myCommentCount
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
            "locationTitle": mumory.locationModel.locationTitle,
            "latitude": mumory.locationModel.coordinate.latitude,
            "longitude": mumory.locationModel.coordinate.longitude,
            "coutry": mumory.locationModel.country,
            "administrativeArea": mumory.locationModel.administrativeArea,
            "tags": mumory.tags ?? [],
            "content": mumory.content ?? "",
            "imageURLs": mumory.imageURLs ?? [],
            "isPublic": mumory.isPublic,
            "likes": mumory.likes,
            "commentCount": mumory.commentCount,
            "myCommentCount": mumory.myCommentCount
        ]
        
        documentReference.updateData(updatedData) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
                
                if let originalMumory = self.myMumorys.first(where: { $0.id == mumory.id }) {
                    mumory.copy(from: originalMumory)
                }
            } else {
                print("updateMumory successfully! : \(documentReference.documentID)")
                completion()
            }
        }
    }
    
    public func deleteMumory(_ mumory: Mumory, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.isUpdating = true
        }

        let db = FirebaseManager.shared.db
        
        let documentReference = db.collection("Mumory").document(mumory.id)
        
        // 문서 삭제
        documentReference.delete { error in
            if let error = error {
                print("Error deleting document: \(error.localizedDescription)")
            } else {
                if let index = self.myMumorys.firstIndex(where: { $0.id == mumory.id }) {
                    self.myMumorys.remove(at: index)
                }
                
                if let index = self.everyMumorys.firstIndex(where: { $0.id == mumory.id }) {
                    self.everyMumorys.remove(at: index)
                }

                let commentsRef = db.collection("Mumory").document(mumory.id).collection("Comment")
                
                // Comment 컬렉션의 모든 문서 가져오기 및 삭제
                commentsRef.getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Error getting documents from Comment collection: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.isUpdating = false
                        }
                        completion()
                        return
                    }
                    
                    // 가져온 문서들을 순회하면서 삭제
                    for document in snapshot!.documents {
                        let commentRef = commentsRef.document(document.documentID)
                        commentRef.delete()
                    }
                    
                    DispatchQueue.main.async {
                        self.isUpdating = false
                    }
                    completion()
                }
            }
        }
    }
    
    public func likeMumory(mumoryAnnotation: Mumory, uId: String, completion: @escaping ([String]) -> Void) async {
        let db = FirebaseManager.shared.db
        let docRef = db.collection("Mumory").document(mumoryAnnotation.id)
        
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
                completion(oldLikes)
                
//                self.selectedMumoryAnnotation.likes = oldLikes
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
            .order(by: "date", descending: true)
        
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
//                            self.mumoryComments.sort { $0.date > $1.date }
                        }
                    }
                }
            }
        }
    }
    
    public func checkIsMyComment(mumoryId: String, reply: Comment, currentUser: MumoriUser) async -> Bool {
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

    public static func fetchComment(mumoryId: String) async -> [Comment]? {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Mumory").document(mumoryId).collection("Comment")
            .order(by: "date", descending: false)
        
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
    
    public func createComment(mumory: Mumory, comment: Comment, competion: @escaping ([Comment]) -> Void) {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("Mumory").document(mumory.id).collection("Comment")
        let mumoryDocReference = db.collection("Mumory").document(mumory.id)
        
        let newData: [String: Any] = comment.toDictionary()
        
        collectionReference.addDocument(data: newData) { error in
            if let error = error {
                print("Error adding document: \(error)")
                competion([])
            } else {
                Task {
                    let commentCount = await MumoryDataViewModel.fetchCommentCount(mumoryId: mumory.id)
                    var myCommentCount = 0
                    if mumory.uId == comment.uId {
                        myCommentCount = await MumoryDataViewModel.fetchMyCommentCount(mumoryId: mumory.id, uId: comment.uId)
                        print("나다: \(myCommentCount)")
                        try await mumoryDocReference.updateData(["commentCount": commentCount, "myCommentCount": myCommentCount])
                    } else {
                        try await mumoryDocReference.updateData(["commentCount": commentCount, "myCommentCount": commentCount])
                    }
                    
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
