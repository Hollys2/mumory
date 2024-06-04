//
//  SignUpData.swift
//  Feature
//
//  Created by 제이콥 on 6/4/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import FirebaseAuth

/// 회원가입, 커스터마이징 관리를 위한 뷰모델

class SignUpData: ObservableObject {
    // MARK: - Object lifecycle
    
    init() {
        self.email = ""
        self.signInMethod = .none
        self.favoriteGenres = []
        self.notificationTime = 0
        self.isSubscribedToService = false
        self.isSubscribedToSocial = false
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
    @Published var isSubscribedToService: Bool
    @Published var isSubscribedToSocial: Bool
    @Published var favoriteGenres:[Int]
    @Published var notificationTime: Int
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
        step += 1
        //
    }
    
    public func goPrevious() {
        step -= 1
    }
}

public enum SignInMethod {
    case none
    case kakao
    case email
    case google
    case apple
}
