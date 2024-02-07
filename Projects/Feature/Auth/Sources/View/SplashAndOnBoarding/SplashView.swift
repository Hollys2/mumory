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
    @State var isSignInCompleted: Bool?
    @State var hasLoginHistory: Bool?
    @State var isNextViewPresenting: Bool = false
    @State var isInitialSettingDone = false
    public var body: some View {
        NavigationStack{
            ZStack{
                GeometryReader(content: { geometry in
                    ColorSet.mainPurpleColor.ignoresSafeArea()
                    LottieView(animation: .named("splash", bundle: .module))
                        .looping()
                        .padding(.top, geometry.size.height * 0.37)
                        //0.37은 디자인 상의 상단 여백 비율
                })
            }
            .transition(.opacity)
            .navigationDestination(isPresented: $isNextViewPresenting) {
                if isNextViewPresenting {
                    if isSignInCompleted ?? false {
                        HomeView()
                    }else if hasLoginHistory ?? false {
                        LoginView()
                    }else {
                        OnBoardingManageView()
                    }
                }
            }
            .onAppear(perform: {
                //타이머와 초기셋팅 동시에 진행
                DispatchQueue.global().async {
                    let Firebase = FirebaseManager.shared
                    let db = Firebase.db
                    let auth = Firebase.auth
                    
                    //로그인한 기록이 있는지 확인
                    hasLoginHistory = (UserDefaults.standard.value(forKey: "loginHistory") != nil)
                    
                    if let user = auth.currentUser {
                        print("로그인된 계정 존재함")
                        print("email: \(user.email ?? "no mail")")
                        db.collection("User").document(user.uid).getDocument { snapshot, error in
                            if let snapshot = snapshot {
                                if snapshot.exists {
                                    if let data = snapshot.data(){
                                        //이용약관 동의와 커스텀 완료 여부
                                        isSignInCompleted = (data["is_checked_service_news_notification"] != nil) && (data["id"] != nil)
                                        isInitialSettingDone = true
                                    }
                                }
                            }else {
                                isSignInCompleted = false
                                isInitialSettingDone = true
                            }
                        }
                    }else{
                        print("로그인된 계정 존재 안 함")
                        isSignInCompleted = false
                        isInitialSettingDone = true
                    }
                    
                }
                
                var time = 0.0
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                    time += 0.5
                    if time > 4 {
                        isNextViewPresenting = isInitialSettingDone
                        if isNextViewPresenting{
                            //다음 화면으로 넘어갈 때 타이머 멈추기
                            timer.invalidate()
                        }
                    }
                }
            })
            
        }
    }
}

//#Preview {
//    SplashView()
//}
