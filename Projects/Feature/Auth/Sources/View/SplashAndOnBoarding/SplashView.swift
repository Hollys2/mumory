//
//  SplashView.swift
//  Feature
//
//  Created by 제이콥 on 1/29/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Lottie
import Core
import FirebaseAuth

public struct SplashView: View {
    public init(){}
    @EnvironmentObject var userManager: UserViewModel
    @State var time = 0.0
    @State var isSignInCompleted: Bool = false
    @State var hasLoginHistory: Bool?
    @State var isPresent: Bool = false
    @State var isInitialSettingDone = false
    public var body: some View {
        NavigationStack{
            ZStack{
                GeometryReader(content: { geometry in
                    ColorSet.mainPurpleColor.ignoresSafeArea()
                    LottieView(animation: .named("splash", bundle: .module))
                        .looping()
                        .padding(.top, geometry.size.height * 0.37) //0.37은 디자인의 상단 여백 비율
                })
            }
            .transition(.opacity)
            .navigationDestination(isPresented: $isPresent) {
                if isPresent {
                    if isSignInCompleted {
                        if userManager.id == "" {
                            LoginView()
                        }else {
                            HomeView()
                        }
                    }else if hasLoginHistory ?? false {
                        LoginView()
                    }else {
                        OnBoardingManageView()
                    }
                }
            }
            .onAppear(perform: {
                checkCurrentUserAndGetUserData()
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                    time += 0.5
                    if time > 4 {
                        isPresent = isInitialSettingDone
                        if isPresent{
                            //다음 화면으로 넘어갈 때 타이머 멈추기
                            timer.invalidate()
                        }
                    }
                }
                
            })
            
        }
    }
    
    private func checkCurrentUserAndGetUserData(){
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        let auth = Firebase.auth
        
        //로그인한 기록이 있는지 확인
        hasLoginHistory = (UserDefaults.standard.value(forKey: "loginHistory") != nil)
        
        //파이어베이스 이용해서 로그인 한 계정 있는지 확인
        if let user = auth.currentUser {
            //로그인 한 계정이 있다면 유저 데이터 저장
            print("로그인 계정 존재. email: \(user.email ?? "no mail")")
            db.collection("User").document(user.uid).getDocument { snapshot, error in
                if let error = error {
                    print("error 발생: \(error)")
                    isSignInCompleted = false
                    isInitialSettingDone = true
                }else if let snapshot = snapshot{
                    guard let data = snapshot.data() else {
                        print("no data")
                        isSignInCompleted = false
                        isInitialSettingDone = true
                        return
                    }
                    userManager.uid = user.uid
                    userManager.id = data["id"] as? String ?? ""
                    userManager.nickname = data["nickname"] as? String ?? ""
                    userManager.email = data["email"] as? String ?? ""
                    userManager.signInMethod = data["signin_method"] as? String ?? ""
                    userManager.selectedNotificationTime = data["selected_notification_time"] as? Int ?? 0
                    userManager.isCheckedSocialNotification = data["is_checked_social_notification"] as? Bool ?? nil
                    userManager.isCheckedServiceNewsNotification = data["is_checked_service_news_notification"] as? Bool ?? nil
                    userManager.favoriteGenres = data["favorite_genres"] as? [Int] ?? []
                    
                    isSignInCompleted = true
                    isInitialSettingDone = true
                }
            }
        }else{
            print("로그인된 계정 존재 안 함")
            isSignInCompleted = false
            isInitialSettingDone = true
        }
    }
}

//#Preview {
//    SplashView()
//}
