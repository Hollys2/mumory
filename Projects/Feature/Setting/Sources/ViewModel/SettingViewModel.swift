//
//  SettingViewModel.swift
//  Feature
//
//  Created by 제이콥 on 2/3/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation

class SettingViewModel: ObservableObject{
    @Published var email: String = ""
    @Published var signinMethod: String = ""
    @Published var selectedNotificationTime = 0
    
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
        switch(selectedNotificationTime){
        case 1: return "아침  6:00AM ~ 11:00AM"
        case 2: return "점심  11:00AM ~ 4:00PM"
        case 3: return "저녁  4:00PM ~ 9:00PM"
        case 4: return "밤  9:00PM ~ 2:00AM"
        case 5: return "이용 시간대를 분석해 자동으로 설정"
        default : return "시간을 설정해주세요"
        }
    }
}
