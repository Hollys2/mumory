//
//  RewardViewModel.swift
//  Shared
//
//  Created by 다솔 on 2024/08/24.
//  Copyright © 2024 hollys. All rights reserved.
//


import Foundation
import Combine
import Firebase

@MainActor
public class RewardViewModel: FirebaseManager, ObservableObject {
    @Published public var myRewards: [Reward] = [] {
        didSet {
            print("myRewards didSet: \(myRewards)")
        }
    }
    @Published public var isRewardViewShown: (Bool, Reward) = (false, .init(type: .none))
    
    public override init() {
        super.init()
    }
    
    public func fetchRewards(uId: String, completion: @escaping (Result<[Reward], Error>) -> Void) async {
        let collectionReference = self.db.collection("User").document(uId).collection("Reward")
        do {
            let snapshot = try await collectionReference.getDocuments()
            for document in snapshot.documents {
                let newReward = try document.data(as: Reward.self)
                if !self.myRewards.contains(where: { $0 == newReward}) {
                    self.myRewards.append(newReward)
                }
            }
            completion(.success(self.myRewards))
        } catch {
            completion(.failure(error))
        }
    }
    
    public func fetchRewardListener(user: UserProfile) -> ListenerRegistration {
        let collectionReference = self.db.collection("User").document(user.uId).collection("Reward")
        
        let listener = collectionReference.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("Error fetchRewardListener: \(error!)")
                return
            }
            
            for documentChange in snapshot.documentChanges {
                guard documentChange.type == .added else { continue }
                
                do {
                    let newReward = try documentChange.document.data(as: Reward.self)
                    if !self.myRewards.contains(where: { $0 == newReward }) {
                        self.myRewards.append(newReward)
                        
                        self.isRewardViewShown = (true, newReward)
                    }
                } catch {
                    print("Error fetchRewardListener: \(error)")
                }
            }
            
            if !self.myRewards.contains(where: { $0.type == .attendance(num: 0) }) {
                self.myRewards.append(Reward(type: .attendance(num: 0)))
                do {
                    try collectionReference.addDocument(from: Reward(type: .attendance(num: 0)))
                } catch {
                    print("Error fetchRewardListener addDocument: \(error)")
                }
            } else {
                let signUpDate: Date = user.signUpDate
//                guard let pastDate = Calendar.current.date(byAdding: .day, value: -15, to: signUpDate) else {return}
                
                let components = Calendar.current.dateComponents([.day], from: signUpDate, to: Date())
                if let dayDifference = components.day {
                    if dayDifference >= 3 && dayDifference < 7, !self.myRewards.contains(where: { $0.type == .attendance(num: 1) }) {
                        self.myRewards.append(Reward(type: .attendance(num: 1)))
                        do {
                            try collectionReference.addDocument(from: Reward(type: .attendance(num: 1)))
                        } catch {
                            print("Error fetchRewardListener addDocument: \(error)")
                        }
                    } else if dayDifference >= 7 && dayDifference < 14, !self.myRewards.contains(where: { $0.type == .attendance(num: 2) }) {
                        self.myRewards.append(Reward(type: .attendance(num: 2)))
                        do {
                            try collectionReference.addDocument(from: Reward(type: .attendance(num: 2)))
                        } catch {
                            print("Error fetchRewardListener addDocument: \(error)")
                        }
                    } else if dayDifference >= 14 && dayDifference < 30, !self.myRewards.contains(where: { $0.type == .attendance(num: 3) }) {
                        self.myRewards.append(Reward(type: .attendance(num: 3)))
                        do {
                            try collectionReference.addDocument(from: Reward(type: .attendance(num: 3)))
                        } catch {
                            print("Error fetchRewardListener addDocument: \(error)")
                        }
                    } else if dayDifference >= 30, !self.myRewards.contains(where: { $0.type == .attendance(num: 4) }) {
                        self.myRewards.append(Reward(type: .attendance(num: 4)))
                        do {
                            try collectionReference.addDocument(from: Reward(type: .attendance(num: 4)))
                        } catch {
                            print("Error fetchRewardListener addDocument: \(error)")
                        }
                    }
                }
            }
        }
        
        return listener
    }
    
}
