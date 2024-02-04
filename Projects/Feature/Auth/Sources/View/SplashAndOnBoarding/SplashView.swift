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

public struct SplashView: View {
    public init(){}
    @State var hasUid: Bool?
    @State var isSignInCompleted: Bool?
    @State var hasLoginHistory: Bool?
    @State var isNextViewPresenting: Bool = false
    @State var isCustomizationDone: Bool?
    @State var isTermsOfServiceDone: Bool?
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
                if isNextViewPresenting{
                    if !(isSignInCompleted ?? false) {
                        //로그인 실패
                        if hasLoginHistory ?? false{
                            //로그인 기록O
                            LoginView()
                        }else {
                            //로그인 기록X
                            OnBoardingManageView()
                        }
                    }else if !(isTermsOfServiceDone ?? false){
                        //이용약관 동의X
                        LoginView()
                    }else if !(isCustomizationDone ?? false) {
                        //프로필 커스텀 X
                        LoginView()
                    }else {
                        //이용약관O, 커스텀O
                        HomeView()
                    }
                }
            }
            .onAppear(perform: {
                //타이머와 초기셋팅 동시에 진행
                DispatchQueue.global().async {
                    let userDefault = UserDefaults.standard

                    //로그인한 기록이 있는지 확인
                    hasLoginHistory = (userDefault.value(forKey: "loginHistory") != nil)
                    
                    //현재 로그인 되어있는 상태인지 확인
//                    hasCurrentUser = (Auth.auth().currentUser != nil)
                    
                    let Firebase = FirebaseManager.shared
                    let db = Firebase.db
                    let auth = Firebase.auth
                    
                    if let user = auth.currentUser {
                        print("로그인된 계정 존재함")
                        print("email: \(user.email ?? "no mail")")
                        db.collection("User").document(user.uid).getDocument { snapshot, error in
                            if let error = error {
                                print("get document error: \(error)")
                                isSignInCompleted = false
                            }else if let snapshot = snapshot {
                                if snapshot.exists {
                                    print("document 존재")
                                    if let data = snapshot.data(){
                                        isSignInCompleted = true
                                        if let checkedThing = data["is_checked_service_news_notification"] {
                                            print("이용약관 존재")
                                            isTermsOfServiceDone = true
                                            if let id = data["id"]{
                                                print("id 존재")
                                                isCustomizationDone = true
                                                isInitialSettingDone = true
                                            }else{
                                                print("id 존재X")
                                                isCustomizationDone = false
                                                isInitialSettingDone = true
                                            }
                                        }else {
                                            print("이용약관 존재 X")
                                            isTermsOfServiceDone = false
                                            isInitialSettingDone = true
                                        }
                                    }else {
                                        print("data 존재X")
                                        isSignInCompleted = false
                                        isInitialSettingDone = true
                                    }
                                }else {
                                    print("document 존재X")
                                    isSignInCompleted = false
                                    isInitialSettingDone = true
                                }
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
