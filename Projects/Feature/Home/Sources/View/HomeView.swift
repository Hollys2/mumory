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
    @EnvironmentObject private var currentUserData: CurrentUserData
    @EnvironmentObject private var playerViewModel: PlayerViewModel
    @EnvironmentObject private var keyboardResponder: KeyboardResponder
    @EnvironmentObject private var settingViewModel: SettingViewModel
    @EnvironmentObject private var withdrawViewModel: WithdrawViewModel
    
    public init() {}
    
    public var body: some View {
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
                SocialFriendTestView()
            }
            
            if self.appCoordinator.bottomAnimationViewStatus == .myPage {
                MyPageView()
            }
            
            if self.isSocialSearchViewShown {
                SocialSearchView(isShown: self.$isSocialSearchViewShown)
            }
        } // ZStack
        .navigationBarBackButtonHidden()
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
                currentUserData.playlistArray = await currentUserData.savePlaylist()
            }
            print("HomeView onAppear")
        }
        .onDisappear {
            print("HomeView onDisappear")
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
