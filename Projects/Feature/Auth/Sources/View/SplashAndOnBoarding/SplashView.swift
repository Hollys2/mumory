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
    @EnvironmentObject var userManager: UserViewModel
    @State var time = 0.0
    @State var isSignInCompleted: Bool = false
    @State var isPresent: Bool = false
    @State var isInitialSettingDone = false
    @State var goToLoginView: Bool = false

    var hasLoginHistory: Bool
    
    public init() {
        self.hasLoginHistory = (UserDefaults.standard.value(forKey: "loginHistory") != nil)
    }
    
    public var body: some View {
        NavigationStack{
            ZStack(alignment: .top){
                    ColorSet.mainPurpleColor.ignoresSafeArea()
                    LottieView(animation: .named("splash", bundle: .module))
                        .looping()
                        .padding(.top, userManager.height * 0.37) //0.37은 디자인의 상단 여백 비율
            }
            .navigationDestination(isPresented: $isPresent) {
                if !hasLoginHistory {
                    OnBoardingManageView()
                }else if goToLoginView {
                    LoginView()
                }else {
                    HomeView()
                }
            }
            .onAppear(perform: {
                time = 0.0
                Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { timer in
                    time = 4.0
                    isPresent = isInitialSettingDone
                }
                Task{
                    await checkCurrentUserAndGetUserData()
                }
                isPresent = time == 4.0 ? true : false
            })
            
        }
    }
    
    private func checkCurrentUserAndGetUserData() async{
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        let auth = Firebase.auth
                
        //최근에 로그인했는지, 유저 데이터는 모두 존재하는지 확인. 하나라도 만족하지 않을시 로그인 페이지로 이동
        guard let user = auth.currentUser,
              let snapshot = try? await db.collection("User").document(user.uid).getDocument(),
              let data = snapshot.data(),
              let id = data["id"] as? String,
              let nickname = data["nickname"] as? String,
              let email = data["email"] as? String,
              let signInMethod = data["sign_in_method"] as? String,
              let selectedNotificationTime = data["selected_notification_time"] as? Int,
              let isCheckedSocialNotification = data["is_checked_social_notification"] as? Bool,
              let isCheckedServiceNewsNotification = data["is_checked_service_news_notification"] as? Bool,
              let favoriteGenres = data["favorite_genres"] as? [Int],
              let profileImageURLString = data["profile_image_url"] as? String else {
            isInitialSettingDone = true
            goToLoginView = true
            return
        }
        
        userManager.uid = user.uid
        userManager.id = id
        userManager.nickname = nickname
        userManager.email = email
        userManager.signInMethod = signInMethod
        userManager.selectedNotificationTime = selectedNotificationTime
        userManager.isCheckedSocialNotification = isCheckedSocialNotification
        userManager.isCheckedServiceNewsNotification = isCheckedServiceNewsNotification
        userManager.favoriteGenres = favoriteGenres
        userManager.profileImageURL = URL(string: profileImageURLString)
        userManager.backgroundImageURL = URL(string: data["background_image_url"] as? String ?? "")
        userManager.bio = data["bio"] as? String ?? ""
        
        isInitialSettingDone = true
    }
}

//#Preview {
//    SplashView()
//}
