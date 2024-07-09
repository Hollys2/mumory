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
import PhotosUI
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
        self.nickname = ""
        self.id = ""
        self.isValidNickname = false
        self.isValidId = false
    }
    
    // MARK: - Propoerties
    
    //common
    @Published var signInMethod: SignInMethod
    @Published var email: String
    @Published var isCheckedRequireItems: Bool
    @Published var isSubscribedToService: Bool
    @Published var isSubscribedToSocial: Bool
    @Published var favoriteGenres:[MusicGenre]
    @Published var notificationTime: TimeZone
    @Published var nickname: String
    @Published var id: String
    @Published var profileImage: UIImage?
    
    /// 유저별 인덱스 - 처음 설정된 해당 인덱스로 이후 기본 프로필 이미지의 컬러를 정한다(빨강, 노랑, 주황, 보라)
    @Published var profileIndex: Int

    
    //for email, kakao
    @Published var password: String?
    
    //for google
    @Published var googleCredential: AuthCredential?
    
    //for apple
    @Published var appleCredential: OAuthCredential?
    
    @Published var step: Int
    @Published var isValidEmail: Bool
    @Published var isValidPassword: Bool
    @Published var isValidNickname: Bool
    @Published var isValidId: Bool
    @Published var isLoading: Bool = false
    
    // MARK: - Methods
    public func setSignUpData(method: SignInMethod, email: String = "", appleCredential: OAuthCredential? = nil, googleCredential: AuthCredential? = nil, password: String = "") {
        self.email = email
        self.appleCredential = appleCredential
        self.googleCredential = googleCredential
        self.password = password
        
        self.signInMethod = method
        switch method {
        case .kakao, .google, .apple:
            step = 2 //terms of service view
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
        case 3: return "시작하기"
        case 6: return "회원가입"
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
        case 6: return isValidNickname && isValidId
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
    
    @MainActor
    public func setProfileImage(data: Data?) {
        guard let imageData = data else {
            self.profileImage = nil
            return
        }
        let uiImage = UIImage(data: imageData)
        self.profileImage = uiImage
    }
    
    public func uploadUserData(uId: String, profileImageURL: String) async {
        let data: [String: Any] = [
            "email": email,
            "signInMethod": getSignInMethodName(),
            "isSubscribedToService": isSubscribedToService,
            "isSubscribedToSocial": isSubscribedToSocial,
            "fcmToken": FirebaseManager.shared.messaging.fcmToken ?? "",
            "signUpDate": Date(),
            "id": id,
            "nickname": nickname,
            "notificationTime": getNotificationTimeNum(),
            "profileIndex": profileIndex,
            "profileImageURL": profileImageURL,
            "uid": uId
        ]
        try? await FirebaseManager.shared.db.collection("User").document(uId).setData(data)
    }
    
    public func signUp() async -> String{
        var uId: String = String()
        switch signInMethod {
        case .kakao:
            guard let password = self.password else {return uId}
            guard let result = try? await FirebaseManager.shared.auth.createUser(withEmail: "kakao/\(email)", password: "kakao/\(password)") else {return uId}
            uId = result.user.uid
        case .email:
            guard let password = self.password else {return uId}
            guard let result = try? await FirebaseManager.shared.auth.createUser(withEmail: email, password: password) else {return uId}
            uId = result.user.uid
        case .google:
            guard let credential = self.googleCredential else {return uId}
            guard let result = try? await FirebaseManager.shared.auth.signIn(with: credential) else {return uId}
            uId = result.user.uid
            
        case .apple:
            guard let credential = self.appleCredential else {return uId}
            guard let result = try? await FirebaseManager.shared.auth.signIn(with: credential) else {return uId}
            uId = result.user.uid
            self.email = result.user.email ?? "" //test
        default: break
        }
        return uId
    }
    
    public func getUploadedImageURL(uId: String) async -> String {
        guard let data = profileImage?.jpegData(compressionQuality: 0.1) else {
            print("DEBUG: NO IMAGE - RETURN EMPTY STRING")
            return ""
        }

        let storage = FirebaseManager.shared.storage
        let path: String = "ProfileImage/\(uId).jpg"
        let ref = storage.reference().child(path)
        let metaData = FirebaseManager.shared.storageMetadata()
        metaData.contentType = "image/jpeg"
        
        guard let result = try? await ref.putDataAsync(data, metadata: metaData) else {
            print("DEBUG: UPLOAD ERROR(PUT DATA ASYNC) - RETURN EMPTY STRING")
            return ""
        }
        guard let url = try? await ref.downloadURL() else {
            print("DEBUG: UPLOAD ERROR(PUT DATA ASYNC) - RETURN EMPTY STRING")
            return ""
        }
        return url.absoluteString
    }
    
    public func uploadFavoritePlaylist(uId: String) async {
        let db = FirebaseManager.shared.db
        let playlist: [String: Any] = [
            "title": "즐겨찾기 목록",
            "songIds": [],
            "isPublic": false,
            "date": Date()
        ]
        try? await db.collection("User").document(uId).collection("Playlist").document("favorite").setData(playlist)
        
    }
    
    private func getSignInMethodName() -> String {
        switch signInMethod {
        case .none: 
            return ""
        case .kakao:
            return "Kakao"
        case .email:
            return "Email"
        case .google:
            return "Google"
        case .apple:
            return "Apple"
        }
    }
    
    private func getNotificationTimeNum() -> Int{
        switch notificationTime {
        case .none:
            return 0
        case .moring:
            return 1
        case .afternoon:
            return 2
        case .evening:
            return 3
        case .night:
            return 4
        case .auto:
            return 5
        }
    }
    
    public func getDefaultProfileImage() -> Image {
        switch(self.profileIndex) {
        case 0: return SharedAsset.profileRedForSelection.swiftUIImage
        case 1: return SharedAsset.profilePurpleForSelection.swiftUIImage
        case 2: return SharedAsset.profileYellowForSelection.swiftUIImage
        case 3: return SharedAsset.profileOrangeForSelection.swiftUIImage
        default: return SharedAsset.profileRedForSelection.swiftUIImage
        }
    }
}


