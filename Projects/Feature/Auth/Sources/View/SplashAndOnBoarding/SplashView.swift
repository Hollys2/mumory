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
    enum initPage {
        case login
        case onBoarding
        case home
    }
    
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @StateObject var customizationManageViewModel: CustomizationManageViewModel = CustomizationManageViewModel()
    @StateObject var withdrawViewModel: WithdrawViewModel = WithdrawViewModel()
    @StateObject var settingViewModel: SettingViewModel = SettingViewModel()

    @State var time = 0.0
    @State var isSignInCompleted: Bool = false
    @State var isPresent: Bool = false
    @State var isInitialSettingDone = false
    @State var goToLoginView: Bool = false
    @State var isEndSplash: Bool = false
    @State var page: initPage = .login
    
    public init() {}
    
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
                                .environmentObject(settingViewModel)
                                .environmentObject(withdrawViewModel)
                                .navigationBarBackButtonHidden()
                        }
                    }
                }
                .onAppear(perform: {
                    checkCurrentUserAndGetUserData()
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                        withAnimation {
                            isEndSplash = true
                        }
                    }
                })
                .navigationDestination(for: String.self, destination: { i in
                    if i == "music" {
                        SearchMusicViewInCreateMumory()
                    } else if i == "location" {
                        SearchLocationView()
                    } else if i == "map" {
                        SearchLocationMapView()
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
                        MumoryDetailView(mumory: view.mumoryAnnotation)
                    case .editMumoryView:
                        MumoryEditView(mumoryAnnotation: view.mumoryAnnotation)
                    case .myMumoryView:
                        MyMumoryView()
                    }
                }
                .navigationDestination(for: MumoryPage.self) { page in
                    switch(page){
                    case .customization:
                        TermsOfServiceForSocialView() //커스텀 안 했을 시 커스텀 화면으로 이동
                            .environmentObject(customizationManageViewModel)
                    case .home(selectedTab: let tab):
                        HomeView(tab: tab)
                            .environmentObject(settingViewModel)
                            .environmentObject(withdrawViewModel)
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
                    case .requestFriend:
                        MyFriendRequestListView()
                            .navigationBarBackButtonHidden()
                    case .blockFriend:
                        BlockFriendListView()
                            .navigationBarBackButtonHidden()
                    case .friend(friend: let friend):
                        FriendPageView(friend: friend)
                            .navigationBarBackButtonHidden()
                    case .friendPlaylist(playlist: let playlist):
                        UneditablePlaylistView(playlist: playlist)
                    case .friendPlaylistManage(friend: let friend, playlist: let playlist):
                        UneditablePlaylistManageView(friend: friend, playlistArray: playlist)
                    }
                }
                .navigationDestination(for: LibraryPage.self) { page in
                    switch(page){
                    case .search(term: let term):
                        SearchMusicView(term: term)
                        
                    case .artist(artist: let artist):
                        ArtistView(artist: artist)
                            .navigationBarBackButtonHidden()

                    case .playlistManage:
                        PlaylistManageView()
                            .navigationBarBackButtonHidden()
                    case .chart:
                        ChartListView()
                        
                    case .playlist(playlist: let playlist):
                        PlaylistView(playlist: playlist)
                            .navigationBarBackButtonHidden()

                    case .shazam:
                        ShazamView()
                            .navigationBarBackButtonHidden()

                    case .addSong(originPlaylist: let originPlaylist):
                        AddSongView(originPlaylist: originPlaylist)
                            .navigationBarBackButtonHidden()
                    case .play:
                        NowPlayingView()
                        
                    case .saveToPlaylist(songs: let songs):
                        SaveToPlaylistView(songs: songs)
                            .navigationBarBackButtonHidden()
                        
                    case .recommendation(genreID: let genreID):
                        RecommendationListView(genreID: genreID)
                            .navigationBarBackButtonHidden()
                        
                    case .selectableArtist(artist: let artist):
                        SelectableArtistView(artist: artist)
                            .navigationBarBackButtonHidden()
                        
                    case .favorite:
                        FavoriteListView()
                            .navigationBarBackButtonHidden()
                        
                    case .playlistWithIndex(index: let index):
                        PlaylistView(playlist: $currentUserData.playlistArray[index])
                    }
                }
                .navigationDestination(for: MyPage.self) { page in
                    switch(page){
                    case .myPage:
                        MyPageView()
                            .environmentObject(settingViewModel)
                            .environmentObject(withdrawViewModel)
                        
                    case .setting:
                        SettingView()
                            .navigationBarBackButtonHidden()
                            .environmentObject(settingViewModel)
                            .environmentObject(withdrawViewModel)
              
                    case .account:
                        AccountManageView()
                            .navigationBarBackButtonHidden()
                            .environmentObject(settingViewModel)
                     
                    case .notification:
                        NotificationView()
                            .navigationBarBackButtonHidden()
                            .environmentObject(settingViewModel)
                         
                    case .setPW:
                        SetPWView()
                            .navigationBarBackButtonHidden()
                            .environmentObject(settingViewModel)

                    case .question:
                        QuestionView()
                            .navigationBarBackButtonHidden()
                            .environmentObject(settingViewModel)

                    case .emailVerification:
                        EmailLoginForWithdrawView()
                            .navigationBarBackButtonHidden()
                            .environmentObject(settingViewModel)
                            .environmentObject(withdrawViewModel)

                    case .selectNotificationTime:
                        SelectNotificationTimeView()
                            .navigationBarBackButtonHidden()
                            .environmentObject(settingViewModel)
                        
                    case .login:
                        LoginView()
                            .navigationBarBackButtonHidden()
                            .environmentObject(settingViewModel)
                        
                    case .friendList:
                        FriendListView()
                            .navigationBarBackButtonHidden()
                        
                    case .friendPage(friend: let friend):
                        FriendPageView(friend: friend)
                            .navigationBarBackButtonHidden()
                    
                    case .activityList:
                        ActivityListView()
                            .navigationBarBackButtonHidden()
                    }

                }
            }
            
            //스플래시 뷰
            ColorSet.mainPurpleColor.ignoresSafeArea()
                .overlay {
                    LottieView(animation: .named("splash", bundle: .module))
                        .looping()
                }
                .opacity(isEndSplash && isInitialSettingDone ? 0 : 1)
                .transition(.opacity)
        }
        
    }
    
    private func checkCurrentUserAndGetUserData() {
        let Firebase = FBManager.shared
        let db = Firebase.db
        let auth = Firebase.auth
        let messaging = Firebase.messaging
        
//        if (UserDefaults.standard.value(forKey: "loginHistory") == nil) {
//            page = .onBoarding
//            withAnimation {
//                isInitialSettingDone = true
//            }
//            return
//        }
        
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
                return
            }
            
    
            
            currentUserData.uId = user.uid
//            appCoordinator.currentUser = await MumoriUser(uId: user.uid).fetchFriend(uId: user.uid)
//            await MumoriUser().fetchFriend(uId: user.uid)
            currentUserData.favoriteGenres = favoriteGenres
            page = .home
            withAnimation {
                isInitialSettingDone = true
            }
            
            guard let favoriteData = try? await db.collection("User").document(user.uid).collection("Playlist").document("favorite").getDocument().data() else {
                return
            }
            
            guard let fcmToken = messaging.fcmToken else {
                return
            }
            try await db.collection("User").document(user.uid).updateData(["fcmToken": fcmToken])
            
            playerViewModel.favoriteSongIds = favoriteData["songIds"] as? [String] ?? []
        }
    }
}
