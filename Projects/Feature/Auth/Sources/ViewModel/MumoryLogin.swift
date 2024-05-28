//
//  LoginViewModel.swift
//  Feature
//
//  Created by 제이콥 on 5/25/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import KakaoSDKUser
import Firebase
import Shared

class MumoryLogin: ObservableObject {
    @Published var isLoading: Bool = false
//    var Firebase = FirebaseManager.shared
//    public func kakaoLogin(){
//        isLoading = true
//        if UserApi.isKakaoTalkLoginAvailable() {
//            UserApi.shared.loginWithKakaoTalk { authToken, error in
//                self.handleKakaoLogin(error: error)
//                return
//            }
//        }
//        
//        UserApi.shared.loginWithKakaoAccount { authToken, error in
//            self.handleKakaoLogin(error: error)
//        }
//    }
//    
//    private func handleKakaoLogin(error: Error?) {
//        self.isLoading = false
//        guard error == nil else {return}
//        Task {
//            await firebaseSignUpWithKakao()
//        }
//    }
//    
//    private func firebaseSignUpWithKakao() async {
//        UserApi.shared.me { user, error in
//            if let error = error { return }
//            guard let user = user else {return}
//            guard let email = user.kakaoAccount?.email else {return}
//            guard let uid = user.id else {return}
//            
//            Task {
//                if await self.isNewKakaoUser(email: email) {
//                    let firebaseEmail = "kakao/\(email)"
//                    let firebasePassword = "kakao/\(uid)"
//                    guard let result = try? await FirebaseManager.shared.auth.createUser(withEmail: firebaseEmail, password: firebasePassword) else {return}
//                    await self.checkInitialSetting(uid: result.user.uid, email: email, method: "Kakao")
//
//                }else {
//                    self.signIn(email:"kakao/\(email)", password:"kakao/\(uid)")
//                }
//            }
//        }
//    }
//    
//    private func isNewKakaoUser(email: String) async -> Bool{
//        let db = FirebaseManager.shared.db
//        let checkOldUserQuery = db.collection("User")
//            .whereField("email", isEqualTo: email)
//            .whereField("signInMethod", isEqualTo: "Kakao")
//        
//        guard let documents = try? await checkOldUserQuery.getDocuments() else {return false}
//        return documents.isEmpty
//    }
//    
//    private func createUser(email: String, password: String) async {
//       
//    }
//    
//    private func signIn(email: String, password: String) {
//        Firebase.auth.signIn(withEmail: email, password: password) { result, error in
//            if let error = error {return}
//            guard let user = result?.user else {return}
//            Task {
//                await self.checkInitialSetting(uid: user.uid, email: email, method: "Kakao")
//            }
//        }
//    }
//    
//    private func isOldUser(uid: String) async -> Bool {
// 
//    }
//    
//    private func getUserDocument(uid: String) -> FBManager.Document{
//        
//    }
//    
//    private func setLoginHistory() {
//        let userDefualt = UserDefaults.standard
//        userDefualt.setValue(Date(), forKey: "loginHistory")
//    }
//    
//        
//    private func checkInitialSetting(uid: String, email: String?, method: String) async {
//        let query = Firebase.db.collection("User").document(uid)
//        guard let snapshot = try? await query.getDocument() else {
//            self.isLoading = false
//            return
//        }
//        let isOldUser = snapshot.exists
//        if isOldUser {
//            guard let data = snapshot.data() else {return}
//            if !isCompletedCustomization(data: data) {
//                appCoordinator.rootPath.append(MumoryPage.customization)
//            }
//            
//            currentUserData.uId = uid
//            currentUserData.user = await MumoriUser(uId: uid)
//            currentUserData.favoriteGenres = data["favoriteGenres"] as? [Int] ?? []
//            try? await query.updateData(["fcmToken": fcmToken])
//            appCoordinator.selectedTab = .home
//            appCoordinator.initPage = .home
//            
//            self.mumoryDataViewModel.fetchRewards(uId: currentUserData.user.uId)
//            self.mumoryDataViewModel.fetchActivitys(uId: currentUserData.user.uId)
//            self.mumoryDataViewModel.fetchMumorys(uId: currentUserData.user.uId) { result in
//                switch result {
//                case .success(let mumorys):
//                    print("fetchMumorys successfully: \(mumorys)")
//                    DispatchQueue.main.async {
//                        self.mumoryDataViewModel.myMumorys = mumorys
//                        self.mumoryDataViewModel.listener = self.mumoryDataViewModel.fetchMyMumoryListener(uId: self.currentUserData.uId)
//                        self.mumoryDataViewModel.rewardListener = self.mumoryDataViewModel.fetchRewardListener(user: self.currentUserData.user)
//                        self.mumoryDataViewModel.activityListener = self.mumoryDataViewModel.fetchActivityListener(uId: self.currentUserData.uId)
//                    }
//                case .failure(let error):
//                    print("ERROR: \(error)")
//                }
//                
//                DispatchQueue.main.async {
//                    self.mumoryDataViewModel.isUpdating = false
//                }
//            }
//            
//            var transaction = Transaction()
//            transaction.disablesAnimations = true
//            appCoordinator.isCreateMumorySheetShown = false
//            withTransaction(transaction) {
//                appCoordinator.rootPath = NavigationPath()
//            }
//        }else {
//           handleNewUser()
//        }
//
//
//
//     }
//    
//    private func handleOldUser() {
//        
//    }
//    
//    private func handleNewUser() {
//        let fcmToken = Messaging.messaging().fcmToken ?? ""
//        var userData: [String: Any] = [
//            "uid": uid,
//            "email": email ?? "NOEMAIL\(uid)", //이메일 없을 경우 - NOEMAIL유저아이디
//            "signInMethod": method,
//            "fcmToken": fcmToken,
//            "signUpDate": Date()
//        ]
//        try? await snapshot.reference.setData(userData)
//        self.isLoading = false
//        appCoordinator.rootPath.append(MumoryPage.customization)
//    }
//    
//    private func isCompletedCustomization(data: [String: Any]) -> Bool {
//        guard let id = data["id"] as? String,
//              let nickname = data["nickname"] as? String else {
//            return false
//        }
//        return true
//    }
}
