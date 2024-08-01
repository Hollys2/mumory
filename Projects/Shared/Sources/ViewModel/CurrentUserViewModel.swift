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

@MainActor
public class RewardViewModel: FirebaseManager, ObservableObject {
    @Published public var reward: Reward = .none
    @Published public var myRewards: [String] = []
    
    public func fetchRewards(uId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        //        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("User").document(uId).collection("Reward")
        
        Task {
            do {
                let snapshot = try await collectionReference.getDocuments()
                
                for document in snapshot.documents {
                    let documentData = document.data()
                    guard let type = documentData["type"] as? String else { continue }
                    
                    DispatchQueue.main.async {
                        self.myRewards.append(type)
                    }
                }
                
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    public func fetchRewardListener(user: UserProfile) -> ListenerRegistration {
        let pastDate: Date = user.signUpDate
        let currentDate = Date()
        let components = Calendar.current.dateComponents([.day], from: pastDate, to: currentDate)
        
        if let dayDifference = components.day {
            print("FUCK dayDifference: \(dayDifference)")
        }
//        let db = FirebaseManager.shared.db
        let collectionReference = db.collection("User").document(user.uId).collection("Reward")
        
        let listener = collectionReference.addSnapshotListener { snapshot, error in
            Task {
                guard let snapshot = snapshot, error == nil else {
                    print("Error fetchRewardListener: \(error!)")
                    return
                }

                if !self.myRewards.contains(where: { $0 == "attendance0" }) {
                    self.myRewards.append("attendance0")
                    
                    let db = FirebaseManager.shared.db
                    let collectionReference = db.collection("User").document(user.uId).collection("Reward")
                    let data = ["type": "attendance0"]
                    collectionReference.addDocument(data: data)
                    
                    self.reward = .attendance(0)
                    //                        withAnimation(.spring(response: 0.2)) {
                    //                            self.isRewardPopUpShown = true
                    //                        }
                }
                
                for documentChange in snapshot.documentChanges {
                    guard documentChange.type == .added else { continue }
                    let documentData = documentChange.document.data()
                    guard let type = documentData["type"] as? String else { continue }
                    let newReward: String = type
                    
                    let newReward2 = try documentChange.document.data(as: Reward.self)
                    
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
                        let components = Calendar.current.dateComponents([.day], from: pastDate, to: currentDate)
                        
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
                        
                        //                            withAnimation(.spring(response: 0.2)) {
                        //                                self.isRewardPopUpShown = true
                        //                            }
                        print("fetchRewardListener added: \(self.reward)")
                    }
                    
                }
            }
        }
        return listener
    }
    
}

@MainActor
public class CurrentUserViewModel: ObservableObject {
    
    // MARK: - Propoerties
    @Published public var user: UserProfile = .init() 
    @Published public var mumoryViewModel: MumoryViewModel = .init()
    @Published public var rewardViewModel: RewardViewModel = .init()
    @Published public var friendViewModel: FriendViewModel = .init()
    @Published public var playlistViewModel: PlaylistViewModel = .init()
    @Published public var locationManagerViewModel: LocationManagerViewModel = .init()
    
    @Published public var existUnreadNotification: Bool = false
    @Published public var reward: Reward = .none

    @Published public var isLoading: Bool = false
    
    var mumoryListener: ListenerRegistration?
    var rewardListener: ListenerRegistration?
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
    public func initializeUserData() async -> Bool {
        guard let currentUser = FirebaseManager.shared.auth.currentUser else {
            return false
        }

        self.isLoading = true

        let uId = currentUser.uid
        self.user = await FetchManager.shared.fetchUser(uId: uId)
        
        friendViewModel = .init(uId: uId)
        playlistViewModel = .init(uId: uId)
        
        NotificationListener(uId: uId)
        
        self.mumoryListener = self.mumoryViewModel.fetchMyMumoryListener(uId: uId)
        self.mumoryViewModel.fetchMumorys(uId: uId) { result in
            switch result {
            case .success(let mumorys):
                print("SUCCESS fetchMumorys: \(mumorys)")
            case .failure(let error):
                print("ERROR fetchMumorys: \(error)")
            }
        }
        
        self.rewardViewModel.fetchRewards(uId: uId) { result in
            switch result {
            case .success(let mumorys):
                self.rewardListener = self.rewardViewModel.fetchRewardListener(user: self.user)
                print("SUCCESS fetchRewards: \(mumorys)")
            case .failure(let error):
                print("ERROR fetchRewards: \(error)")
            }
        }
        
        friendViewModel.FriendUpdateListener()
        friendViewModel.FriendRequestListener()
        playlistViewModel.savePlaylist()
        
        self.isLoading = false
        
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
}
