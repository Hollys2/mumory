//
//  currentUserViewModel.swift
//  Feature
//
//  Created by 제이콥 on 2/10/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import Core
import Firebase
import Combine

//@MainActor
public class CurrentUserViewModel: ObservableObject {
    
    // MARK: - Propoerties
    @Published public var user: UserProfile = .init()
    @Published public var mumoryViewModel: MumoryViewModel = .init()
    @Published public var rewardViewModel: RewardViewModel = .init()
    @Published public var friendViewModel: FriendViewModel = .init()
    @Published public var playlistViewModel: PlaylistViewModel = .init()
    @Published public var locationManagerViewModel: LocationManagerViewModel = .init()
    
    @Published public var existUnreadNotification: Bool = false
//    @Published public var reward: RewardConstant = .none
    @Published public var myActivity: [(String, String)] = []
    
    @Published public var isLoading: Bool = false
    
    var mumoryListener: ListenerRegistration?
    var rewardListener: ListenerRegistration?
    var activityListener: ListenerRegistration?
    var notificationListener: ListenerRegistration?
    
    var anyCancellable: AnyCancellable? = nil
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Object lifecycle
    public init() {
        //        anyCancellable = appCoordinator.objectWillChange
        //            .sink { [weak self] (_) in
        //                self?.objectWillChange.send()
        //            }
        
        mumoryViewModel.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        rewardViewModel.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        friendViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        playlistViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        //        locationManagerViewModel.objectWillChange
        //            .receive(on: DispatchQueue.main)
        //            .sink { [weak self] _ in
        //                self?.objectWillChange.send()
        //            }
        //            .store(in: &cancellables)
    }
    
    // MARK: - Methods
    @MainActor
    public func initializeUserData() async -> Bool {
        guard let currentUser = FirebaseManager.shared.auth.currentUser else {
            return false
        }
        
        self.isLoading = true
        
        let uId = currentUser.uid
        
        self.friendViewModel = .init(uId: uId)
        self.playlistViewModel = .init(uId: uId)
        
        self.friendViewModel.FriendUpdateListener()
        self.friendViewModel.FriendRequestListener()
        self.playlistViewModel.savePlaylist()
        
        self.activityListener = self.fetchActivityListener(uId: uId)
        self.NotificationListener(uId: uId)
        
        await withTaskGroup(of: Void.self) { taskGroup in
            taskGroup.addTask { @MainActor in
                let user = await FetchManager.shared.fetchUser(uId: uId)
                self.user = user

        
                await self.rewardViewModel.fetchRewards(uId: uId) { result in
                    switch result {
                    case .success(let rewards):
                        print("SUCCESS fetchRewards: \(rewards)")
                        self.mumoryListener = self.mumoryViewModel.fetchMyMumoryListener(uId: uId, rewards: self.rewardViewModel.myRewards)
                        self.rewardListener = self.rewardViewModel.fetchRewardListener(user: user)
                    case .failure(let error):
                        print("ERROR fetchRewards: \(error)")
                    }
                }
            }
            
            taskGroup.addTask { @MainActor in
//                self.mumoryListener = self.mumoryViewModel.fetchMyMumoryListener(uId: uId)

//                await self.mumoryViewModel.fetchMumorys(uId: uId) { result in
//                    switch result {
//                    case .success(_):
//                        print("SUCCESS fetchMumorys")
//                        self.mumoryListener = self.mumoryViewModel.fetchMyMumoryListener(uId: uId)
//                    case .failure(let error):
//                        print("ERROR fetchMumorys: \(error)")
//                    }
//                }
            }
            
            taskGroup.addTask {
                await self.fetchActivitys(uId: uId)
            }
            
            await taskGroup.waitForAll()
            
            self.isLoading = false
        }
        
        return true
    }
    
    private func NotificationListener(uId: String) {
        let db = FirebaseManager.shared.db
        let query = db.collection("User").document(uId).collection("Notification")
            .whereField("isRead", isEqualTo: false)
        
        DispatchQueue.main.async {
            self.notificationListener = query.addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {return}
                self.existUnreadNotification = (snapshot.count > 0)
            }
        }
    }
    
    public func removeAllData(){
        user = UserProfile()
        existUnreadNotification = false
        notificationListener?.remove()
    }
    
    public func fetchActivityListener(uId: String) -> ListenerRegistration {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("User").document(uId).collection("Activity")
        
        let listener = collectionReference.addSnapshotListener { snapshot, error in
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
        
        return listener
    }
    
    public func fetchActivitys(uId: String) async {
        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("User").document(uId).collection("Activity")
        
        do {
            let snapshot = try await collectionReference.getDocuments()
            
            for document in snapshot.documents {
                let documentData = document.data()
                guard let type = documentData["type"] as? String else { continue }
                
                let newResult = (document.documentID, type)
                DispatchQueue.main.async {
                    self.myActivity.append(newResult)
                }
            }
            
            print("fetchActivitys successfully: \(myActivity)")
        } catch {
            print("Error fetchActivitys: \(error.localizedDescription)")
        }
        
    }
}
