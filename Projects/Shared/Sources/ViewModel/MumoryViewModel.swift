//
//  MumoryViewModel.swift
//  Shared
//
//  Created by 다솔 on 2024/06/11.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import MapKit
import MusicKit
import Firebase
import FirebaseFirestore


final public class MumoryViewModel: ObservableObject {
    
    @Published public var myMumorys: [Mumory] = []
    @Published public var locationMumorys: [String: [Mumory]] = [:]
    
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
                        //                        guard let newMumory = await Mumory.fromDocumentDataToMumory(documentData, mumoryDocumentID: documentChange.document.documentID) else { return }
                        
                        let newMumory = try documentChange.document.data(as: Mumory.self)
                        
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
                                
                                var country = newMumory.location.country
                                let administrativeArea = newMumory.location.administrativeArea
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
                        if let index = self.myMumorys.firstIndex(where: { $0.id == modifiedDocumentID })
                        //                           let updatedMumory =
                        //                            await Mumory.fromDocumentDataToMumory(documentData, mumoryDocumentID: self.myMumorys[index].id ?? "") {
                        {
                            let updatedMumory = try documentChange.document.data(as: Mumory.self)
                            
                            DispatchQueue.main.async {
                                self.myMumorys[index] = updatedMumory
                            }
                        }
//                        if let index = self.socialMumorys.firstIndex(where: { $0.id == modifiedDocumentID }),
//                           let updatedMumory = await Mumory.fromDocumentDataToMumory(documentData, mumoryDocumentID: self.socialMumorys[index].id) {
//                            DispatchQueue.main.async {
//                                self.socialMumorys[index] = updatedMumory
//                            }
//                        }
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
}

