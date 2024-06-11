//
//  SignUpData.swift
//  Feature
//
//  Created by 제이콥 on 6/4/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import FirebaseAuth
import SwiftUI
import Shared

/// 회원가입, 커스터마이징 관리를 위한 뷰모델
public class SignUpViewModel: ObservableObject {
    // MARK: - Object lifecycle
    
    public init() {
        self.email = ""
        self.signInMethod = .none
        self.favoriteGenres = []
        self.notificationTime = .none
        isCheckedRequireItems = false
        self.isSubscribedToService = false
        self.isSubscribedToSocial = true
        self.nickname = ""
        self.id = ""
        self.profileIndex = Int.random(in: 0...3)
        self.step = 0
        self.isValidEmail = false
        self.isValidPassword = false
    }
    
    // MARK: - Propoerties
    
    //common
    @Published var signInMethod: SignInMethod
    @Published var profileIndex: Int
    @Published var email: String
    @Published var isCheckedRequireItems: Bool
    @Published var isSubscribedToService: Bool
    @Published var isSubscribedToSocial: Bool
    @Published var favoriteGenres:[MusicGenre]
    @Published var notificationTime: TimeZone
    @Published var nickname: String
    @Published var id: String
    //프로필 이미지?
    
    //email, kakao
    @Published var password: String?
    
    //google
    @Published var googleCredential: AuthCredential?
    
    //apple
    @Published var appleCredential: OAuthCredential?
    
    //관련 프로퍼티
    @Published var step: Int
    @Published var isValidEmail: Bool
    @Published var isValidPassword: Bool
    
    @Published var isLoading: Bool = false
    
    // MARK: - Methods
    
    public func startSignUp(method: SignInMethod) {
        self.signInMethod = method
        switch method {
        case .kakao, .google, .apple:
            step = 3
        case .email:
            step = 0
        case .none:
            break
        }
    }
    
    public func goNext() {
        withAnimation {
            step += 1
        }
    }
    
    public func goPrevious() {
        withAnimation {
            step -= 1
        }
    }
    
    public func getButtonTitle() -> String {
        switch step {
        case 2: return "회원가입"
        case 3: return "시작하기"
        case 6: return "완료"
        default: return "다음"
        }
    }
    
    public func getNavigationTitle() -> String {
        switch step {
        case 0: return "이메일 입력하기"
        case 1: return "비밀번호 입력하기"
        default: return ""
        }
    }
    
    public func isButtonEnabled() -> Bool {
        switch step {
        case 0: return isValidEmail
        case 1: return isValidPassword
        case 2: return isCheckedRequireItems
        case 4: return favoriteGenres.count > 0
        case 5: return notificationTime != .none
        default: return false
        }
    }
    
    public func appendGenre(genre: MusicGenre){
        if favoriteGenres.contains(where: {$0.id == genre.id}){
            favoriteGenres.removeAll(where: {$0.id == genre.id})
        }else {
            if favoriteGenres.count < 5 {
                favoriteGenres.append(genre)
            }
        }
    }
    
    public func contains(genre: MusicGenre) -> Bool{
        return favoriteGenres.contains(where: {$0.id == genre.id})
    }
}

public enum SignInMethod {
    case none
    case kakao
    case email
    case google
    case apple
}
