//
//  HomeTabView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/17.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Shared


public struct MumoryTabView: View {
    
    @ObservedObject private var tabViewModel: TabViewModel = TabViewModel.shared
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var currentUserData: CurrentUserViewModel

    public init() {}
    
    public var body: some View {
        GeometryReader { geometry in
            
            HStack(alignment: .bottom, spacing: 0) {
                
                Image(uiImage: self.appCoordinator.selectedTab == .home ? SharedAsset.homeOnTabbar.image : SharedAsset.homeOffTabbar.image )
                    .resizable()
                    .frame(width: 25, height: 41)
                    .frame(width: geometry.size.width / 5)
                    .onTapGesture {
                        playerViewModel.isPresentNowPlayingView = false
//                        self.tabViewModel.tab = .home
//                        print("FUCK self.tabViewModel.tab: \(self.tabViewModel.tab)")
                        
                        self.appCoordinator.selectedTab = .home
                    }
                
                Image(uiImage: self.appCoordinator.selectedTab == .social ? SharedAsset.socialOnTabbar.image : SharedAsset.socialOffTabbar.image)
                    .resizable()
                    .frame(width: 35, height: 45)
                    .frame(width: geometry.size.width / 5)
                    .onTapGesture {
//                        self.appCoordinator.scrollToTop = true
                        self.appCoordinator.selectedTab = .social
//                        self.tabViewModel.tab = .social
//                        print("FUCK self.tabViewModel.tab: \(self.tabViewModel.tab)")
                    }
                
                Image(asset: SharedAsset.createMumoryTabbar)
                    .resizable()
                    .frame(width: 51, height: 51)
                    .frame(width: geometry.size.width / 5)
                    .onTapGesture {
                        playerViewModel.setLibraryPlayerVisibilityWithoutAnimation(isShown: false)
                        withAnimation(Animation.easeInOut(duration: 0.1)) {
                            self.appCoordinator.sheet = .createMumory
                        }
                    }
                
                Image(asset: self.tabViewModel.tab == .library ? SharedAsset.libraryOnTabbar : SharedAsset.libraryOffTabbar)
                    .resizable()
                    .frame(width: 43, height: 45)
                    .frame(width: geometry.size.width / 5)
                    .onTapGesture {
                        self.tabViewModel.tab = .library
                    }
                
                Image(asset: self.tabViewModel.tab == .notification ? currentUserData.existUnreadNotification ? SharedAsset.notificationOnDotTabbar : SharedAsset.notificationOnTabbar : currentUserData.existUnreadNotification ? SharedAsset.notificationOffDotTabbar : SharedAsset.notificationOffTabbar)
                    .resizable()
                    .frame(width: 31, height: 44)
                    .frame(width: geometry.size.width / 5)
                    .onTapGesture {
                        self.tabViewModel.tab = .notification
                    }

            }
            .padding(.top, 2)
        }
        .ignoresSafeArea()
        .frame(height: 89)
        .background(Color.black)
    }
}
