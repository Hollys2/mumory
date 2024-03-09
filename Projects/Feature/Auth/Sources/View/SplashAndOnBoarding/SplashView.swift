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
    @EnvironmentObject var currentUserData: CurrentUserData
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
                        .padding(.top, getUIScreenBounds().height * 0.37) //0.37은 디자인의 상단 여백 비율
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
        let Firebase = FBManager.shared
        let db = Firebase.db
        let auth = Firebase.auth
                
//        if let result = try? await db.collection("User").document("tester").getDocument(){
////            result.exists
//            print("okok")
//        }else {
//            print("no internet")
//        }
        
        
        //최근에 로그인했는지, 유저 데이터는 모두 존재하는지 확인. 하나라도 만족하지 않을시 로그인 페이지로 이동
        guard let user = auth.currentUser,
              let snapshot = try? await db.collection("User").document(user.uid).getDocument(),
              let data = snapshot.data(),
              let id = data["id"] as? String,
              let isCheckedServiceNewsNotification = data["isSubscribedToService"] as? Bool,
              let favoriteGenres = data["favoriteGenres"] as? [Int] else {
            isInitialSettingDone = true
            goToLoginView = true
            print("no user")
            return
        }
        
        currentUserData.uid = user.uid
        currentUserData.favoriteGenres = favoriteGenres
        print("done111")
        
        isInitialSettingDone = true
    }
}

//#Preview {
//    SplashView()
//}
