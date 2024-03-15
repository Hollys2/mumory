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
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    @StateObject var customizationManageViewModel: CustomizationManageViewModel = CustomizationManageViewModel()

    
    @State var time = 0.0
    @State var isSignInCompleted: Bool = false
    @State var isPresent: Bool = false
    @State var isInitialSettingDone = false
    @State var goToLoginView: Bool = false
    @State var isEndSplash: Bool = false
    
    enum initPage {
        case login
        case onBoarding
        case home
    }
    
 
        
    @State var page: initPage = .login
    
    public init() {
    }
    
    public var body: some View {
        ZStack(alignment: .top){
            NavigationStack(path: $appCoordinator.rootPath) {
                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        switch(page){
                        case .login:
                            LoginView()
                        case .onBoarding:
                            OnBoardingManageView()
                        case .home:
                            HomeView()
                                .navigationBarBackButtonHidden()
                        }
                    }
                }
                .onAppear(perform: {
                    
                    Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { timer in
                        withAnimation {
                            isEndSplash = true
                        }                    }
                    checkCurrentUserAndGetUserData()
                })
                .navigationDestination(for: String.self, destination: { i in
                    if i == "music" {
                        SearchMusicView()
                    } else if i == "location" {
                        SearchLocationView()
                    } else if i == "map" {
                        SearchLocationMapView()
                    } else if i == "search-social" {
                        SocialSearchView()
                    } else {
                        Color.gray
                    }
                })
                .navigationDestination(for: SearchFriendType.self, destination: { type in
                    switch type {
                    case .cancelRequestFriend:
                        FriendMenuView(type: .cancelRequestFriend)
                    case .unblockFriend:
                        FriendMenuView(type: .unblockFriend)
                    default:
                        Color.pink
                    }
                })
                .navigationDestination(for: MumoryView.self) { view in
                    switch view.type {
                    case .mumoryDetailView:
                        MumoryDetailView(mumoryAnnotation: view.mumoryAnnotation)
                    case .editMumoryView:
                        MumoryEditView(mumoryAnnotation: view.mumoryAnnotation)
                    }
                }
                .navigationDestination(for: LoginPage.self) { page in
                    switch(page){
                    case .customization:
                        TermsOfServiceForSocialView() //커스텀 안 했을 시 커스텀 화면으로 이동
                            .environmentObject(customizationManageViewModel)
                    case .home:
                        HomeView()
                    case .signUp:
                        SignUpManageView()
                    case .startCustomization:
                        StartCostomizationView()
                            .environmentObject(customizationManageViewModel)
                    case .emailLogin:
                        EmailLoginView()
                    case .lastOfCustomization:
                        LastOfCustomizationView()
                            .environmentObject(customizationManageViewModel)
                    case .login:
                        LoginView()
                    }
                }
                
                
            }
            
            //스플래시 뷰
            ColorSet.mainPurpleColor.ignoresSafeArea()
                .overlay {
                    LottieView(animation: .named("splash", bundle: .module))
                        .looping()
                        //.padding(.top, getUIScreenBounds().height * 0.37) //0.37은 디자인의 상단 여백 비율
                }
                .opacity(isEndSplash && isInitialSettingDone ? 0 : 1)
                .transition(.opacity)
        }
        
    }
    
    private func checkCurrentUserAndGetUserData() {
        let Firebase = FBManager.shared
        let db = Firebase.db
        let auth = Firebase.auth
        
        print("111")
        if (UserDefaults.standard.value(forKey: "loginHistory") == nil) {
            page = .onBoarding
            withAnimation {
                isInitialSettingDone = true
            }
            return
        }
        print("2222")
        Task {
            //최근에 로그인했는지, 유저 데이터는 모두 존재하는지 확인. 하나라도 만족하지 않을시 로그인 페이지로 이동
            guard let user = auth.currentUser,
                  let snapshot = try? await db.collection("User").document(user.uid).getDocument(),
                  let data = snapshot.data(),
                  let id = data["id"] as? String,
                  let isCheckedServiceNewsNotification = data["isSubscribedToService"] as? Bool,
                  let favoriteGenres = data["favoriteGenres"] as? [Int] else {
                page = .login
                withAnimation {
                    isInitialSettingDone = true
                }
                print("333")
                return
            }
            
            currentUserData.uid = user.uid
            currentUserData.favoriteGenres = favoriteGenres
            print("444")
            page = .home
            withAnimation {
                isInitialSettingDone = true
            }
        }
    }
}

//#Preview {
//    SplashView()
//}
