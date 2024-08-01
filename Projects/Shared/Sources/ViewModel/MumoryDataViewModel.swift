//
//  AnnotationViewModel.swift
//  Feature
//
//  Created by 다솔 on 2023/12/19.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import CoreLocation
import MusicKit
import FirebaseFirestore
import Firebase


//final public class MumoryDataViewModel: FirebaseManager, ObservableObject {
//    
////    @Published public var choosedMusicModel: SongModel?
////    @Published public var choosedLocationModel: LocationModel?
////    
////    @Published public var selectedMumoryId: String = ""
////    @Published public var selectedMumoryAnnotation: Mumory = Mumory()
////    @Published public var selectedComment: Comment = Comment()
//    
//    @Published public var musicModels: [SongModel] = []
//    
//    @Published public var myMumorys: [Mumory] = []
//    @Published public var friendMumorys: [Mumory] = []
//    @Published public var sameSongFriendMumorys: [Mumory] = []
//    @Published public var monthlyMumorys: [Mumory] = []
//    @Published public var surroundingMumorys: [Mumory] = []
//    @Published public var locationMumorys: [String: [Mumory]] = [:]
//    
//    @Published public var myActivity: [(String, String)] = []
//    @Published public var myRewards: [String] = []
//    
//    @Published public var favoriteDate: [Date] = []
//    
//    @Published public var mumoryComments: [Comment] = []
////    @Published public var mumoryCarouselAnnotations: [Mumory] = []
////    @Published public var searchedMumoryAnnotations: [Mumory] = []
//    
////    @Published public var isLoading: Bool = false
////    @Published public var isUpdating: Bool = false
//    @Published public var isFirstSocialLoad: Bool = false
//    
//    @Published public var isRewardPopUpShown: Bool = false
//    @Published public var reward: Reward = .none
//    
//    @Published public var listener: ListenerRegistration?
//    @Published public var rewardListener: ListenerRegistration?
//    @Published public var activityListener: ListenerRegistration?
//    
//    @Published var appState: AppCoordinator = .init()
//
//    private var tempMumory: [Mumory] = []
//    private var lastDocument: DocumentSnapshot?
//    private var initialSnapshot: Bool = true
//    private var initialMumorySnapshot: Bool = true
//    
//    public override init() {}
//    
//   
//}

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
    
    @Published public var choosedLocationModel: LocationModel?
    
    @Published public var selectedMumoryId: String = ""
    @Published public var selectedMumoryAnnotation: Mumory = Mumory()
    @Published public var selectedComment: Comment = Comment()
    
    
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
    
}
