//
//  SettingView.swift
//  Feature
//
//  Created by 제이콥 on 2/3/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core
import FirebaseAuth
import Firebase
import GoogleSignIn
import KakaoSDKAuth
import KakaoSDKUser

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var manager: SettingViewModel = SettingViewModel()
    @State var isLogout: Bool = false
    @State var isShowingWithdrawPopup = false
    @State var isDeleteUserDone: Bool = false
    @State var isDeleteDocumentsDone: Bool = false
    @State var isPresent: Bool = false

    var body: some View {
        //테스트때문에 navigationStack 추가함. 이후 삭제하기
        ZStack{
            ColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0){
                //설정 버튼들
                NavigationLink{
                    AccountManageView()
                        .environmentObject(manager)
                }label: {
                    SettingItem(title: "계정 정보 / 보안")
                }
                
                NavigationLink {
                    NotificationView()
                        .environmentObject(manager)

                } label: {
                    SettingItem(title: "알림")
                }
                
                NavigationLink {
                    QuestionView()
                        .environmentObject(manager)
                } label: {
                    SettingItem(title: "1:1 문의")

                }

                SettingItem(title: "앱 리뷰 남기기")
                
                
                Spacer()
                Button {
                    //로그아웃
                    UserDefaults.standard.removeObject(forKey: "uid")
                    try? FirebaseManager.shared.auth.signOut()
                    print("로그아웃 완료")
                    isLogout = true
                    
                } label: {
                    Text("로그아웃")
                        .foregroundColor(.white)
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .padding(.top, 15)
                        .padding(.bottom, 15)
                        .padding(.trailing, 58)
                        .padding(.leading, 58)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color(red: 0.65, green: 0.65, blue: 0.65), lineWidth: 1)
                        )
                }
                
                Text("계정 탈퇴")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(ColorSet.subGray)
                    .underline()
                    .padding(.bottom, 70)
                    .padding(.top, 67)
                    .onTapGesture {
                        isShowingWithdrawPopup = true
                    }
                
            }
            
            if isShowingWithdrawPopup{
                Color.black.opacity(0.5).ignoresSafeArea()
            }
            
            if isShowingWithdrawPopup{
                WithdrawPopupView {
                    isShowingWithdrawPopup = false
                } positiveAction: {
                    let Firebase = FirebaseManager.shared
                    let db = Firebase.db
                    let auth = Firebase.auth
                    var credential: AuthCredential
                    guard let currentUser = auth.currentUser else {
                        print("no current user")
                        return
                    }
                    
                    getCredential(method: manager.signinMethod) { credential in
                        if let credential = credential {
                            
                        }
                    }
                    
//                    currentUser.reauthenticate(with: T##AuthCredential)
                    currentUser.delete { error in
                        if let error = error{
                            print("delete user error: \(error)")
                        }else {
                            isDeleteUserDone = true
                            
                            db.collection("User").document(currentUser.uid).delete { error in
                                if let error = error {
                                    print("delete document error: \(error)")
                                }else {
                                    isDeleteDocumentsDone = true
                                    isPresent = isDeleteUserDone && isDeleteDocumentsDone
                                }
                            }
                            
                            isPresent = isDeleteUserDone && isDeleteDocumentsDone
                        }
                    }
                    
                 
                   
                }
            }

        }
        .navigationDestination(isPresented: $isLogout, destination: {
            LoginView()
        })
        .navigationDestination(isPresented: $isPresent, destination: {
            LoginView()
        })
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    SharedAsset.back.swiftUIImage
                        .frame(width: 30, height: 30)
                }
                
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                
                NavigationLink {
                    HomeView()
                } label: {
                    SharedAsset.home.swiftUIImage
                        .frame(width: 30, height: 30)
                }
                
            }
            
            ToolbarItem(placement: .principal) {
                Text("설정")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                    .foregroundColor(.white)
            }
        }
        .onAppear(perform: {
            getUserInfo()
        })
        
    }
    
    private func getUserInfo(){
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        let auth = Firebase.auth
        
        if let currentUser = auth.currentUser {
            let query = db.collection("User").document(currentUser.uid)
            
            query.getDocument { snapshot, error in
                if let error = error {
                    print("firestore error: \(error)")
                }else if let snapshot = snapshot {
                    guard let documentData = snapshot.data() else {
                        print("no document")
                        return
                    }
                    
                    guard let email = documentData["email"] as? String else {
                        print("no email")
                        return
                    }
                    self.manager.email = email

                    guard let method = documentData["signin_method"] as? String else {
                        print("no method")
                        return
                    }
                    self.manager.signinMethod = method
                    
                    guard let selectedTime = documentData["selected_notification_time"] as? Int else {
                        print("no time")
                        return
                    }
                    self.manager.selectedNotificationTime = selectedTime

                    guard let isCheckdServiceNewsNotification = documentData["is_checked_service_news_notification"] as? Bool else {
                        print("no service notification")
                        return
                    }
                    self.manager.isCheckedServiceNewsNotification = isCheckdServiceNewsNotification
                    
                    guard let isCheckdSocialNotification = documentData["is_checked_social_notification"] as? Bool else {
                        print("no social notification")
                        return
                    }
                    self.manager.isCheckedSocialNotification = isCheckdSocialNotification
                    
                    guard let nickname = documentData["nickname"] as? String else {
                        print("no nickname")
                        return
                    }
                    self.manager.nickname = nickname

                    
                    
                }
            }

        }else {
            //재로그인
        }
    }
    
    private func getCredential(method: String, completion: @escaping (AuthCredential?) -> Void){
        if method == "Google"{
            if let id = FirebaseApp.app()?.options.clientID {
                let config = GIDConfiguration(clientID: id)
                GIDSignIn.sharedInstance.configuration = config
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let presentingVC = window.rootViewController {
                    
                    GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { result, error in
                        if let error = error{
                            print("google error: \(error)")
                        }else{
                            print("google login success")
                            guard let idToken = result?.user.idToken?.tokenString else {print("no idToken");return}
                            guard let accessToken = result?.user.accessToken.tokenString else {print("no accessToken");return}
                            
                            completion(GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken))
                            
                        }
                    }
                }
            }
        }else if method == "Apple"{
            
            
            
        }else if method == "Kakao"{
            if UserApi.isKakaoTalkLoginAvailable(){
                //카카오톡 어플 사용이 가능하다면
                UserApi.shared.loginWithKakaoTalk { authToken, error in
                    //앱로그인
                    if let error = error{
                        //카카오 로그인 실패
                        print("kakao login error: \(error)")
                    }else if let authToken = authToken {
                        //카카오 로그인 성공
                        print("login successful with app")
                        UserApi.shared.me { user, error in
                            if let user = user {
                                let email = user.kakaoAccount?.email ?? ""
                                let id = user.id ?? 0
                                
                                Auth.auth().signIn(withEmail: "kakao/\(email)", password: "kakao/\(id)") { result, error in
                                    if let error = error {
                                        print("sign in error: \(error)")
                                    }else if let result = result {
                                        completion(result.credential)
                                    }
                                }
                            }
                        }
                        
                    }
                }
            }else{
                //카카오톡 어플 사용이 불가하다면
                UserApi.shared.loginWithKakaoAccount { authToken, error in
                    //계정로그인
                    if let error = error{
                        print("kakao acount login error: \(error)")
                    }else if let authToken = authToken{
                        print("login successful with account")
                        UserApi.shared.me { user, error in
                            if let user = user {
                                let email = user.kakaoAccount?.email ?? ""
                                let id = user.id ?? 0
                                
                                Auth.auth().signIn(withEmail: "kakao/\(email)", password: "kakao/\(id)") { result, error in
                                    if let error = error {
                                        print("sign in error: \(error)")
                                    }else if let result = result {
                                        completion(result.credential)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }else {
            
        }
        
    }
    
}

#Preview {
    SettingView()
}

struct SettingItem: View {
    @State var title: String
    var body: some View {
        HStack{
            Text(title)
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                .foregroundStyle(.white)
            
            Spacer()
            
            SharedAsset.nextSetting.swiftUIImage
                .frame(width: 25, height: 25)
        }
        .padding(20)
    }
}
