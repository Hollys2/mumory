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
import FirebaseAuth

public struct SplashView: View {
    public init(){}
    @State var hasUid: Bool?
    @State var hasCurrentUser: Bool?
    @State var currentUser: User?
    @State var hasLoginHistory: Bool?
    @State var isNextViewPresenting: Bool = false
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
                    
                    if hasCurrentUser ?? false {
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
                    let userDefault = UserDefaults.standard
                    
                    //저장된 유저 정보가 있는지 확인
                    hasUid = (userDefault.string(forKey: "uid") != nil )
                    //로그인한 기록이 있는지 확인
                    hasLoginHistory = (userDefault.value(forKey: "loginHistory") != nil)
                    
                    if let user = Auth.auth().currentUser {
                        print("로그인된 계정 존재함")
                        print("email: \(user.email ?? "no mail")")
                        hasCurrentUser = true
                    }else{
                        print("로그인된 계정 존재 안 함")
                        hasCurrentUser = false
                    }
                    
                }
                
                var time = 0.0
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                    time += 0.5
                    if time > 4 {
                        //스플래쉬 화면 기본 설정 시간이 4초이지만 초기 셋팅이 더 걸릴 경우에는 초기 셋팅이 완료된 후에 다음 화면으로 넘어가도록 함
                        withAnimation {
                            isNextViewPresenting = hasUid != nil && hasLoginHistory != nil
                        }
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
