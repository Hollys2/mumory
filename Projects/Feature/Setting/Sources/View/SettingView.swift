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
import Lottie

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var manager: SettingViewModel = SettingViewModel()
    @StateObject var withdrawManager: WithdrawViewModel = WithdrawViewModel()
    @State var isLogout: Bool = false
    @State var isShowingWithdrawPopup = false
    @State var isDeleteUserDone: Bool = false
    @State var isDeleteDocumentsDone: Bool = false //유저 관전 정보가 삭제 되었는지
    @State var isUserDeleted: Bool = false //로그인 페이지로 넘어가는 조건
    @State var isLoading: Bool = false
    @State var isNeededEmailLogin = false
    
    var body: some View {
        //테스트때문에 navigationStack 추가함. 이후 삭제하기
        
        
        
        
        GeometryReader { geometry in
            
            ZStack{
                ColorSet.background.ignoresSafeArea()
                NavigationStack{
                    VStack(spacing: 0){
                        //설정 버튼들
                        NavigationLink{
                            AccountManageView()
                                .environmentObject(manager)
                        }label: {
                            SettingItem(title: "계정 정보 / 보안")
                                .padding(.top, 12)
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
                                .padding(.trailing, 62)
                                .padding(.leading, 62)
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
                            .onChange(of: withdrawManager.isAppleUserAuthenticated, perform: { value in
                                if value{
                                    //계정 탈퇴를 위한 애플 로그인 성공시
                                    deleteAppleUser()
                                }
                            })
                            .onTapGesture {
                                isShowingWithdrawPopup = true
                            }
                        
                    }
                    .background(ColorSet.background)
                    .navigationBarBackButtonHidden()
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationDestination(isPresented: $isNeededEmailLogin, destination: {
                        EmailLoginForWithdrawView()
                            .environmentObject(withdrawManager)
                            .environmentObject(manager)
                    })
                    .navigationDestination(isPresented: $isLogout, destination: {
                        LoginView()
                    })
                    .navigationDestination(isPresented: $isUserDeleted, destination: {
                        LoginView()
                    })
                    .onDisappear(perform: {
                        isLoading = false
                    })
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
                }
                if isShowingWithdrawPopup{
                    Color.black.opacity(0.5).ignoresSafeArea()
                }
                
                if isShowingWithdrawPopup{
                    WithdrawPopupView {
                        //취소버튼 클릭 action - 팝업 창 삭제
                        isShowingWithdrawPopup = false
                        
                    } positiveAction: {
                        //탈퇴(확인)버튼 클릭 action - 회원가입 방식에 따라 재 로그인 진행
                        withdraw(method: manager.signinMethod)
                        
                    }
                }
                
                LottieView(animation: .named("loading", bundle: .module))
                    .looping()
                    .opacity(isLoading ? 1 : 0)
                    .frame(width: geometry.size.width * 0.2, height: geometry.size.width * 0.2)
                
            }
            .onAppear(perform: {
                    getUserInfo()
            })
            
            
            
            
            
            
            
        }
        
        
        
    }
    private func deleteAppleUser(){
        print("in delete apple user")
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        let auth = Firebase.auth
        
        guard let currentUser = auth.currentUser else {
            print("no current user")
            return
        }
        
        currentUser.delete { error in
            if let error = error{
                print("delete user error: \(error)")
                //에러처리
            }else {
                print("delete user successful")
                isDeleteUserDone = true
                
                db.collection("User").document(currentUser.uid).delete { error in
                    if let error = error {
                        print("delete document error: \(error)")
                        //에러처리
                    }else {
                        print("delete docs successful")
                        isUserDeleted = true
                    }
                }
            }
            
        }
    }
    private func withdraw(method: String){
        isLoading = true
        isShowingWithdrawPopup = false
        if manager.signinMethod == "Apple" {
            withdrawManager.AppleLogin()
        }else if manager.signinMethod == "Google" {
            withdrawManager.GoogleLogin(originalEmail: manager.email) { isSuccessful in
                deleteUser(isSuccessful: isSuccessful)
            }
        }else if manager.signinMethod == "Kakao" {
            withdrawManager.KakaoLogin(originalEmail: manager.email) { isSuccessful in
                deleteUser(isSuccessful: isSuccessful)
            }
        }else if manager.signinMethod == "Email" {
            isLoading = false
            isShowingWithdrawPopup = false
            isNeededEmailLogin = true
        }
        
        
        
    }
    
    private func deleteUser(isSuccessful: Bool){
        if isSuccessful {
            let Firebase = FirebaseManager.shared
            let db = Firebase.db
            let auth = Firebase.auth
            
            guard let currentUser = auth.currentUser else {
                print("no current user")
                return
            }
            
            currentUser.delete { error in
                if let error = error{
                    print("delete user error: \(error)")
                }else {
                    db.collection("User").document(currentUser.uid).delete { error in
                        if let error = error {
                            print("delete document error: \(error)")
                        }else {
                            isLoading = false
                            isUserDeleted = true
                        }
                    }
                }
            }
            
        }
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
