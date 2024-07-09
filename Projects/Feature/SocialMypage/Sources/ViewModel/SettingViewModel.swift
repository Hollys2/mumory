//
//  SettingViewModel.swift
//  Feature
//
//  Created by 제이콥 on 2/3/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import Shared

class SettingViewModel: ObservableObject{
    @Published var email: String = ""
    @Published var signinMethod: String = ""
    @Published var nickname: String = ""
    @Published var isLoading: Bool = false
    @Published var notificationTime: Int = 0 {
        didSet {
            db.collection("User").document(uid).setData(["notificationTime": notificationTime], merge: true)
        }
    }
    @Published var isSubscribedToService = false {
        didSet {
            db.collection("User").document(uid).setData(["isSubscribedToService": isSubscribedToService], merge: true)
            if isSubscribedToService {
                messaging.subscribe(toTopic: "Service")
            }else {
                messaging.unsubscribe(fromTopic: "Service")
            }
        }
    }
    @Published var isSubscribedToSocial = false {
        didSet {
            db.collection("User").document(uid).setData(["isSubscribedToSocial": isSubscribedToSocial], merge: true)
            if isSubscribedToSocial {
                messaging.subscribe(toTopic: "Social")
            }else {
                messaging.unsubscribe(fromTopic: "Social")
            }
        }
    }
    var uid: String = "" {
        didSet {
            if uid != "" {
                isLoading = true
                Task {
                    guard let document = try? await db.collection("User").document(uid).getDocument() else {
                        return
                    }
                    guard let data = document.data() else {
                        return
                    }
                    guard let email = data["email"] as? String,
                          let nickname = data["nickname"] as? String,
                          let signInMethod = data["signInMethod"] as? String,
                          let isSubscribedToService = data["isSubscribedToService"] as? Bool,
                          let isSubscribedToSocial = data["isSubscribedToSocial"] as? Bool,
                          let notificationTime = data["notificationTime"] as? Int else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.signinMethod = signInMethod
                        self.isSubscribedToSocial = isSubscribedToSocial
                        self.isSubscribedToService = isSubscribedToService
                        self.email = email
                        self.nickname = nickname
                        self.notificationTime = notificationTime
                        self.isLoading = false
                    }
                }
            }
        }
    }
    let db = FirebaseManager.shared.db
    let messaging = FirebaseManager.shared.messaging
    
    public init() {}

    
    
    public func getSignInMethodText() -> String {
        switch(signinMethod){
        case "Kakao":
            return "카카오 계정 로그인"
        case "Google":
            return "Google 계정 로그인"
        case "Apple":
            return "Apple 계정 로그인"
        default: return "소셜 계정 없음"
        }
    }
    
    public func getNotificationTimeText() -> String {
        switch(notificationTime){
        case 1: return "아침  6:00AM ~ 11:00AM"
        case 2: return "점심  11:00AM ~ 4:00PM"
        case 3: return "저녁  4:00PM ~ 9:00PM"
        case 4: return "밤  9:00PM ~ 2:00AM"
        case 5: return "이용 시간대를 분석해 자동으로 설정"
        default : return "시간을 설정해주세요"
        }
    }
}
