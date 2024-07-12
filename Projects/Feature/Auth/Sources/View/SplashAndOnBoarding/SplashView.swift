//
//  SplashView.swift
//  Feature
//
//  Created by 제이콥 on 1/29/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import MapKit
import Shared
import Lottie
import Core
import Firebase
import FirebaseAuth


enum testpath {
    case a
    case b
}

public struct SplashView: View {
    
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var mumoryViewModel: MumoryViewModel
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    @StateObject var customizationManageViewModel: CustomizationManageViewModel = CustomizationManageViewModel()
    @StateObject var withdrawViewModel: WithdrawViewModel = WithdrawViewModel()
    @StateObject var settingViewModel: SettingViewModel = SettingViewModel()
    @StateObject var friendDataViewModel: FriendDataViewModel = FriendDataViewModel()
    
    @State var time = 0.0
    @State var isSignInCompleted: Bool = false
    @State var isPresent: Bool = false
    @State var isInitialSettingDone = false
    @State var goToLoginView: Bool = false
    @State var isEndSplash: Bool = false
    
    @State private var popUp: PopUp = .none
    
    @State var testP: [String] = []
    
    public init() {}
    
    public var body: some View {
        ZStack {
            NavigationStack(path: $testP) {
                
            }
            NavigationStack(path: $appCoordinator.rootPath) {
                VStack(spacing: 0) {
                    switch(appCoordinator.initPage){
                    case .login:
                        LoginView()
                    case .onBoarding:
                        OnBoardingManageView()
                            .onAppear(perform: {
                                print("splash on boarding")
                            })
                    case .home:
                        HomeView()
                            .environmentObject(settingViewModel)
                            .environmentObject(withdrawViewModel)
                            .navigationBarBackButtonHidden()
                            .onAppear(perform: {
                                print("splash home")
                            })
                    }
                }
                .ignoresSafeArea()
                .onAppear(perform: {
                    playerViewModel.setLibraryPlayerVisibilityWithoutAnimation(isShown: false)
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
//                        FriendMenuView(type: .cancelRequestFriend)
                        Color.pink
                    case .unblockFriend:
//                        FriendMenuView(type: .unblockFriend)
                        Color.pink
                    default:
                        Color.pink
                    }
                })
                .navigationDestination(for: MumoryView.self) { view in
                    switch view.type {
                    case .mumoryDetailView:
                        MumoryDetailView(mumory: view.mumoryAnnotation)
                    case .editMumoryView:
                        MumoryEditView(mumory: view.mumoryAnnotation)
                    case .myMumoryView(let user):
                        MyMumoryView(user: user)
                    case .regionMyMumoryView(let user):
                        RegionMyMumoryView(user: user, region: view.region ?? "", mumorys: view.mumorys ?? [])
                    }
                }
                .navigationDestination(for: MumoryPage.self) { page in
                    switch(page) {
                    case .customization:
                        TermsOfServiceForSocialView() //커스텀 안 했을 시 커스텀 화면으로 이동
                            .environmentObject(customizationManageViewModel)
                        
                    case .home:
                        HomeView()
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
                        
                    case .requestFriend:
                        MyFriendRequestListView()
                            .navigationBarBackButtonHidden()
                        
                    case .blockFriend:
                        BlockFriendListView()
                            .navigationBarBackButtonHidden()
                        
                    case .friend(friend: let friend):
                        FriendPageView(friend: friend)
                            .navigationBarBackButtonHidden()
                            .environmentObject(friendDataViewModel)
                        
                    case .friendPlaylist(playlistIndex: let playlistIndex):
                        UneditablePlaylistView(playlist: $friendDataViewModel.playlistArray[playlistIndex])
                            .environmentObject(friendDataViewModel)
                        
                    case .friendPlaylistManage:
                        UneditablePlaylistManageView()
                            .environmentObject(friendDataViewModel)
                        
                    case .searchFriend:
                        SocialFriendTestView()
                        
                    case .mostPostedSongList(songs: let songs):
                        MostPostedSongListView(songs: songs)
                        
                    case .similarTasteList(songs: let songs):
                        SimilarTasteListView(songs: songs)
                        
                    case .myRecentMumorySongList:
                        MyRecentMumoryListView()
                        
                    case .report:
                        ReportView()
                            .environmentObject(settingViewModel)
                    case .mumoryReport(mumoryId: let mumoryId):
                        ReportView(mumoryId: mumoryId)
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
                        
                    case .shazam(type: let type):
                        ShazamView(type: type)
                            .navigationBarBackButtonHidden()
                        
                    case .addSong(originPlaylist: let originPlaylist):
                        AddSongView(originPlaylist: originPlaylist)
                            .navigationBarBackButtonHidden()
                        
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
                        
                    case .myPage:
                        MyPageView()
                            .navigationBarBackButtonHidden()
                            .environmentObject(withdrawViewModel)
                            .environmentObject(settingViewModel)
                        
                    case .setting:
                        SettingView()
                            .navigationBarBackButtonHidden()
                            .environmentObject(settingViewModel)
                            .environmentObject(withdrawViewModel)
                        
                    case .account:
                        AccountManageView()
                            .navigationBarBackButtonHidden()
                            .environmentObject(settingViewModel)
                        
                    case .notification(iconHidden: let hidden):
                        NotificationView(homeIconHidden: hidden)
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
                            .environmentObject(friendDataViewModel)
                        
                    case .reward:
                        RewardView()
                            .navigationBarBackButtonHidden()
                        
                    case .monthlyStat:
                        MonthlyStatView()
                            .navigationBarBackButtonHidden()
                        
                    case .activityList:
                        ActivityListView()
                            .navigationBarBackButtonHidden()
                    }
                }
            }
            
            //스플래시 뷰
            if !(isEndSplash && isInitialSettingDone) {
                ColorSet.mainPurpleColor
                    .overlay {
                        LottieView(animation: .named("splash", bundle: .module))
                            .looping()
                    }
                //                                .opacity(isEndSplash && isInitialSettingDone ? 0 : 1)
                    .transition(.opacity)
                    .onAppear(perform: {
                        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                            withAnimation {
                                isEndSplash = true
                            }
                        }
                        checkCurrentUserAndGetUserData()
                    })
            }
            
//            switch self.appCoordinator.sheet {
//            case .createMumory:
//                Color.black.opacity(0.6)
//                
//                CreateMumoryBottomSheetView()
//                
//            case .comment:
//                Color.black.opacity(0.6)
//                    .onTapGesture {
//                        withAnimation(.spring(response: 0.1)) {
//                            self.appCoordinator.sheet = .none
//                        }
//                    }
//                
//                MumoryCommentSheetView()
//                
//            default:
//                EmptyView()
//            }
            
            switch self.appCoordinator.bottomSheet {
            case .commentMenu:
                BottomSheetUIViewRepresentable(mumoryBottomSheet: MumoryBottomSheet(appCoordinator: appCoordinator, mumoryDataViewModel: mumoryDataViewModel, type: .mumoryCommentMyView(isMe: mumoryDataViewModel.selectedComment.uId == currentUserData.user.uId ? true : false), mumoryAnnotation: .constant(Mumory())))
                    .zIndex(.infinity)
            case .socialMenu:
                BottomSheetUIViewRepresentable(mumoryBottomSheet: MumoryBottomSheet(appCoordinator: appCoordinator, mumoryDataViewModel: mumoryDataViewModel, type: .mumorySocialView, mumoryAnnotation: $appCoordinator.choosedMumoryAnnotation))
            case .mumoryDetail:
                BottomSheetUIViewRepresentable(mumoryBottomSheet: MumoryBottomSheet(appCoordinator: appCoordinator, mumoryDataViewModel: mumoryDataViewModel, type: .mumoryDetailView, mumoryAnnotation: $appCoordinator.choosedMumoryAnnotation))
            case .none:
                EmptyView()
            }
            
            if self.mumoryDataViewModel.isUpdating {
                LoadingAnimationView(isLoading: $mumoryDataViewModel.isUpdating)
            }
        }
        
    }
    
    private func checkCurrentUserAndGetUserData() {
        print("splash checkcheck")
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        let auth = Firebase.auth
        let messaging = Firebase.messaging
        
        Task {
            print("splash checkcheck1")
            
            //최근에 로그인했는지, 유저 데이터는 모두 존재하는지 확인. 하나라도 만족하지 않을시 로그인 페이지로 이동
            guard let user = auth.currentUser,
                  let snapshot = try? await db.collection("User").document(user.uid).getDocument(),
                  let data = snapshot.data(),
                  let id = data["id"] as? String,
                  let isCheckedServiceNewsNotification = data["isSubscribedToService"] as? Bool,
                  let favoriteGenres = data["favoriteGenres"] as? [Int] else {
                appCoordinator.initPage = .onBoarding
                withAnimation {
                    isInitialSettingDone = true
                }
                return
            }
            
            currentUserData.uId = user.uid
            currentUserData.user = await MumoriUser(uId: user.uid)
            currentUserData.favoriteGenres = favoriteGenres
            UserDefaults.standard.setValue(Date(), forKey: "loginHistory")
            
            self.currentUserData.fetchRewards(uId: currentUserData.user.uId)
            self.mumoryDataViewModel.fetchActivitys(uId: currentUserData.user.uId)
            self.mumoryDataViewModel.fetchMumorys(uId: currentUserData.user.uId) { result in
                switch result {
                case .success(let mumorys):
                    print("fetchMumorys successfully: \(mumorys)")
                    DispatchQueue.main.async {
                        self.mumoryDataViewModel.myMumorys = mumorys
                        self.mumoryDataViewModel.listener = self.mumoryViewModel.fetchMyMumoryListener(uId: self.currentUserData.uId)
                        self.mumoryDataViewModel.rewardListener = self.currentUserData.fetchRewardListener(user: self.currentUserData.user)
                        self.mumoryDataViewModel.activityListener = self.mumoryDataViewModel.fetchActivityListener(uId: self.currentUserData.uId)
                    }
                case .failure(let error):
                    print("ERROR: \(error)")
                }
                
                DispatchQueue.main.async {
                    self.mumoryDataViewModel.isUpdating = false
                }
            }
            
            withAnimation {
                isInitialSettingDone = true
            }
            
            appCoordinator.initPage = .home
            try await db.collection("User").document(user.uid).updateData(["fcmToken": messaging.fcmToken ?? ""])
            guard let favoriteData = try? await db.collection("User").document(user.uid).collection("Playlist").document("favorite").getDocument().data() else {
                return
            }
            playerViewModel.favoriteSongIds = favoriteData["songIds"] as? [String] ?? []
        }
    }
}
