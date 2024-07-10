//
//  HomeView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/08.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import MapKit
import MusicKit
import Firebase

import Core
import Shared


public struct HomeView: View {
    
    @State private var listener: ListenerRegistration?
    @State private var rewardListener: ListenerRegistration?
    @State private var activityListener: ListenerRegistration?
    @State private var isSocialSearchViewShown: Bool = false
    
    @State private var isAnnotationTapped: Bool = false
    
    @ObservedObject private var tabViewModel: TabViewModel = TabViewModel.shared
    
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject private var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject private var playerViewModel: PlayerViewModel
    @EnvironmentObject private var keyboardResponder: KeyboardResponder
    
    @StateObject private var settingViewModel: SettingViewModel = .init()
    @StateObject private var friendDataViewModel: FriendDataViewModel = .init()
    @StateObject private var withdrawViewModel: WithdrawViewModel = .init()
    public init() {}
    
    public var body: some View {
        NavigationStack(path: $appCoordinator.rootPath) {
            ZStack(alignment: .bottom) {
                
                VStack(spacing: 0) {
                    switch self.appCoordinator.selectedTab {
                    case .home:
                        HomeMapView(isAnnotationTapped: self.$isAnnotationTapped)
                    case .social:
                        SocialView(isShown: self.$isSocialSearchViewShown)
                    case .library:
                        LibraryView()
                    case .notification:
                        NotifyView()
                    }
                    
                    MumoryTabView()
                        .overlay(CreateMumoryPopUpView(), alignment: .top)
                }
                
                MiniPlayerView()
                
                switch self.appCoordinator.sheet {
                case .createMumory:
                    Color.black.opacity(0.6)
                    
                    CreateMumoryBottomSheetView()
                    
                case .comment:
                    Color.black.opacity(0.6)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.1)) {
                                self.appCoordinator.sheet = .none
                            }
                        }
                    
                    MumoryCommentSheetView()
                    
                default:
                    EmptyView()
                }
                
                
                
                if self.isAnnotationTapped {
                    MumoryCardView(isAnnotationTapped: self.$isAnnotationTapped)
                }
                
                if self.appCoordinator.isAddFriendViewShown {
                    SocialFriendView()
                }
                
                if self.appCoordinator.isMyPageViewShown {
                    MyPageView()
                        .animation(.default, value: appCoordinator.isMyPageViewShown)
                        .environmentObject(settingViewModel)
                }
                
                if self.isSocialSearchViewShown {
                    SocialSearchView(isShown: self.$isSocialSearchViewShown)
                }
            } // ZStack
            .navigationBarBackButtonHidden()
            .ignoresSafeArea()
            .onAppear {
                let userDefualt = UserDefaults.standard
                if !userDefualt.bool(forKey: "firstLogined") {
                    userDefualt.setValue(true, forKey: "firstLogined")
                    userDefualt.setValue(true, forKey: "appleMusicPopUpShown")
                    userDefualt.setValue(true, forKey: "starPopUp")
                    userDefualt.setValue(true, forKey: "commentPopUp")
                }
                
                playerViewModel.miniPlayerMoveToBottom = false
                
                Task {
                    let authorizationStatus = await MusicAuthorization.request()
                    if authorizationStatus == .authorized {
                        print("음악 권한 받음")
                        
                    } else {
                        print("음악 권한 거절")
                        DispatchQueue.main.async {
                            self.showAlertToRedirectToSettings()
                        }
                    }
                    currentUserViewModel.playlistViewModel.savePlaylist()
                }
                print("HomeView onAppear")
            }
            .onDisappear {
                print("HomeView onDisappear")
            }
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
                    MumoryEditView(mumory: view.mumoryAnnotation)
                case .myMumoryView(let user):
                    MyMumoryView(user: user)
                case .regionMyMumoryView(let user):
                    RegionMyMumoryView(user: user, region: view.region ?? "", mumorys: view.mumorys ?? [])
                }
            }
            .navigationDestination(for: MumoryPage.self) { page in
                switch(page) {
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
                    SocialFriendView()
                    
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
                    PlaylistView(playlist: $currentUserViewModel.playlistViewModel.playlistArray[index])
                    
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
                    
                default: EmptyView()
                }
            }
        }
        
    }
    
    func showAlertToRedirectToSettings() {
        let alertController = UIAlertController(title: "음악 권한 허용", message: "뮤모리를 이용하려면 음악 권한이 필요합니다. 설정으로 이동하여 권한을 허용해주세요.", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "설정으로 이동", style: .default) { (_) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
        //        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        //            if let window = windowScene.windows.first {
        //                window.rootViewController?.present(alertController, animated: true, completion: nil)
        //            }
        //        }
        
    }
    
}


