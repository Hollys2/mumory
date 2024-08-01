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
    
    @State private var mumorylistener: ListenerRegistration?
    @State private var rewardListener: ListenerRegistration?
    @State private var activityListener: ListenerRegistration?
    @State private var isSocialSearchViewShown: Bool = false
    @State private var isAnnotationTapped: Bool = false
    
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject private var playerViewModel: PlayerViewModel
    @EnvironmentObject private var keyboardResponder: KeyboardResponder
    
    @StateObject private var settingViewModel: SettingViewModel = .init()
    @StateObject private var friendDataViewModel: FriendDataViewModel = .init()
    @StateObject private var withdrawViewModel: WithdrawViewModel = .init()

    @State private var selectedTab: Tab = .home
    
    public init() {}
    
    public var body: some View {
        
        NavigationStack(path: $appCoordinator.rootPath) {
            
            ZStack(alignment: .bottom) {

                MumoryTabViewControllerRepresentable(
                    viewControllers: [
                        makeViewController(title: "Home",
                                           image: SharedAsset.homeOffTabbar.image.resized(to: CGSize(width: 25, height: 41)),
                                           selectedImage: SharedAsset.homeOnTabbar.image.resized(to: CGSize(width: 25, height: 41)),
                                           content: HomeMapView(isAnnotationTapped: self.$isAnnotationTapped).ignoresSafeArea()),
                        makeViewController(title: "Social",
                                           image: SharedAsset.socialOffTabbar.image.resized(to: CGSize(width: 35, height: 45)),
                                           selectedImage: SharedAsset.socialOnTabbar.image.resized(to: CGSize(width: 35, height: 45)),
                                           content: SocialView(isSocialSearchViewShown: self.$isSocialSearchViewShown).ignoresSafeArea()),
                        makeViewController(title: "CreateMumory",
                                           image: SharedAsset.createMumoryTabbar.image.resized(to: CGSize(width: 51, height: 51)),
                                           selectedImage: SharedAsset.createMumoryTabbar.image.resized(to: CGSize(width: 51, height: 51)),
                                           content: EmptyView()),
                        makeViewController(title: "Library",
                                           image: SharedAsset.libraryOffTabbar.image.resized(to: CGSize(width: 43, height: 45)),
                                           selectedImage: SharedAsset.libraryOnTabbar.image.resized(to: CGSize(width: 43, height: 45)),
                                           content: LibraryView().ignoresSafeArea()),
                        makeViewController(title: "Notification",
                                           image: SharedAsset.notificationOffTabbar.image.resized(to: CGSize(width: 31, height: 44)),
                                           selectedImage: SharedAsset.notificationOnTabbar.image.resized(to: CGSize(width: 31, height: 44)),
                                           content: NotifyView().ignoresSafeArea())
                    ],
//                    selectedIndex: self.$appCoordinator.selectedIndex
                    selectedTab: self.$appCoordinator.selectedTab
                )
                
                MiniPlayerView()
                
                switch self.appCoordinator.sheet {
                case .createMumory:
                    CreateMumorySheetUIViewRepresentable()
                    
                    if self.appCoordinator.isDatePickerShown {
                        
                        ZStack {
                            Color.black
                                .opacity(0.1)
                                .onTapGesture {
                                    self.appCoordinator.isDatePickerShown.toggle()
                                }
                            
                            DatePicker("", selection: self.$appCoordinator.selectedDate, in: ...Date(), displayedComponents: [.date])
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                                .accentColor(SharedAsset.mainColor.swiftUIColor)
                                .frame(width: 280)
                                .padding(10)
                                .background(SharedAsset.backgroundColor.swiftUIColor)
                                .cornerRadius(15)
                                .environment(\.locale, Locale.init(identifier: "ko_KR"))
                        }
                    }
                    
                case .comment:
                    Color.black.opacity(0.6)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.1)) {
                                self.appCoordinator.sheet = .none
                            }
                        }
                    
                    MumoryCommentSheetView()
                    
                case .reward:
                    EmptyView()
                case .none:
                    //                default:
                    //                    EmptyView()
                    
                    EmptyView()
                case .socialMenu:
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
            .bottomSheet(
                sheet: self.$appCoordinator.sheet,
                mumoryBottomSheet: MumoryBottomSheet(appCoordinator: appCoordinator, type: .mumorySocialView, mumoryAnnotation: self.appCoordinator.selectedMumory)
            )
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
                    MumoryDetailView()
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
                    
                default:
                    EmptyView()
                }
            }
        }
    }
    
    func makeViewController<Content: View>(title: String, image: UIImage, selectedImage: UIImage, content: Content) -> UIViewController {
        let viewController = UIHostingController(rootView: content)
        let tabBarItem = UITabBarItem(title: nil, image: image.withRenderingMode(.alwaysOriginal), selectedImage: selectedImage.withRenderingMode(.alwaysOriginal))
        if title == "CreateMumory" {
            tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        } else {
            tabBarItem.imageInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
        }
        
        viewController.tabBarItem = tabBarItem
        
        return viewController
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
