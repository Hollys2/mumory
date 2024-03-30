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
    @State private var isSocialSearchViewShown: Bool = false
    @State private var isCreateMumoryPopUpViewShown: Bool = true
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject private var currentUserData: CurrentUserData
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var keyboardResponder: KeyboardResponder
    @EnvironmentObject var settingViewModel: SettingViewModel
    @EnvironmentObject var withdrawViewModel: WithdrawViewModel
    
    public init(){}
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            
            VStack(spacing: 0) {
                switch appCoordinator.selectedTab {
                case .home:
                    HomeMapView()
                case .social:
                    SocialView(isShown: self.$isSocialSearchViewShown)
                case .library:
                    LibraryView()
                case .notification:
                    NotifyView()
                }
                
                ZStack(alignment: .top) {
                    MumoryTabView(selectedTab: $appCoordinator.selectedTab)
                    
                    CreateMumoryPopUpView()
                        .offset(y: -41)
                        .opacity(self.isCreateMumoryPopUpViewShown ? 1: 0)
                        .animation(.easeInOut(duration: 1), value: self.isCreateMumoryPopUpViewShown)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
                                self.isCreateMumoryPopUpViewShown = false
                            }
                        }
                }
            }
            .rewardBottomSheet(isShown: self.$mumoryDataViewModel.isRewardPopUpShown)
            
            CreateMumoryBottomSheetView(isSheetShown: $appCoordinator.isCreateMumorySheetShown, offsetY: $appCoordinator.offsetY)
            
            MumoryCommentSheetView(isSheetShown: $appCoordinator.isSocialCommentSheetViewShown, offsetY: $appCoordinator.offsetY)
                .bottomSheet(isShown: $appCoordinator.isCommentBottomSheetShown, mumoryBottomSheet: MumoryBottomSheet(appCoordinator: appCoordinator, mumoryDataViewModel: mumoryDataViewModel, type: .mumoryCommentMyView(isMe: mumoryDataViewModel.selectedComment.uId == currentUserData.user.uId ? true : false), mumoryAnnotation: .constant(Mumory())))
            
            if self.appCoordinator.isMumoryPopUpShown {
                ZStack {
                    
                    Color.black.opacity(0.6)
                        .onTapGesture {
                            self.appCoordinator.isMumoryPopUpShown = false
                        }
                    
                    VStack(spacing: 16) {
                        
                        MumoryCarouselUIViewRepresentable(mumoryAnnotations: $mumoryDataViewModel.mumoryCarouselAnnotations)
                            .frame(height: 418)
                            .padding(.horizontal, (UIScreen.main.bounds.width - (getUIScreenBounds().width == 375 ? 296 : 310)) / 2 - 10)
                        
                        Button(action: {
                            self.appCoordinator.isMumoryPopUpShown = false
                        }, label: {
                            SharedAsset.closeButtonMumoryPopup.swiftUIImage
                                .resizable()
                                .frame(width: 26, height: 26)
                        })
                    }
                    .offset(y: 10)
                }
            }
            
            if self.appCoordinator.isAddFriendViewShown {
                SocialFriendTestView()
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
            
            MyPageBottomAnimationView()
            
            if self.isSocialSearchViewShown {
                SocialSearchView(isShown: self.$isSocialSearchViewShown)
            }
            
            if mumoryDataViewModel.isUpdating {
                ZStack {
                    Color.black
                        .opacity(0.1)
                        .ignoresSafeArea()
                    
                    LoadingAnimationView(isLoading: $mumoryDataViewModel.isUpdating)
                }
            }
        } // ZStack
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .onAppear {
            if UserDefaults.standard.object(forKey: "firstRun") == nil {
                UserDefaults.standard.set(true, forKey: "firstRun")
                UserDefaults.standard.set(Date(), forKey: "firstLogined")
            }
            
            playerViewModel.miniPlayerMoveToBottom = false
            
            Task {
                let authorizationStatus = await MusicAuthorization.request()
                if authorizationStatus == .authorized {
                    print("음악 권한 받음")
                    
                    if !appCoordinator.isFirst {
                        print("한번")
                        self.mumoryDataViewModel.fetchFriendsMumorys(uId: currentUserData.user.uId) { mumorys in
                            DispatchQueue.main.async {
                                self.mumoryDataViewModel.myMumorys = mumorys
                                self.listener = self.mumoryDataViewModel.fetchMyMumoryListener(uId: self.currentUserData.uId)
                                self.mumoryDataViewModel.isUpdating = false
                            }
                        }
                        
                        appCoordinator.isFirst = true
                    }
                } else {
                    print("음악 권한 거절")
                    DispatchQueue.main.async {
                        self.showAlertToRedirectToSettings()
                    }
                }
            }
        }
        .onDisappear {
            playerViewModel.miniPlayerMoveToBottom = true
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
    
    
    @ViewBuilder
    private func MyPageBottomAnimationView() -> some View {
        VStack {
            if appCoordinator.bottomAnimationViewStatus == .myPage {
                MyPageView()
                    .environmentObject(withdrawViewModel)
                    .environmentObject(settingViewModel)
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
                
            }
        }
        
    }
    
    @ViewBuilder
    private func PlayBottomAnimationView() -> some View {
        VStack {
            if appCoordinator.bottomAnimationViewStatus == .play {
                NowPlayingView()
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
            }
        }
    }
}
