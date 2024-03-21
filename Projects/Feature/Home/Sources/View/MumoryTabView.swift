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

    @Binding var selectedTab: Tab
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var playerViewModel: PlayerViewModel
    public init(selectedTab: Binding<Tab>) {
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 0) {
                
                Button(action: {
                    selectedTab = .home
                    playerViewModel.isShownMiniPlayer = false
                }) {
                    Image(uiImage: selectedTab == .home ? SharedAsset.homeOnTabbar.image : SharedAsset.homeOffTabbar.image )
                        .resizable()
                        .frame(width: 31, height: 43)
                }
                .frame(width: geometry.size.width / 5)
                
                Button(action: {
                    selectedTab = .social
                    playerViewModel.isShownMiniPlayer = false
                }) {
                    Image(uiImage: selectedTab == .social ? SharedAsset.socialOnTabbar.image : SharedAsset.socialOffTabbar.image)
                        .resizable()
                        .frame(width: 35, height: 45)

                }
                .frame(width: geometry.size.width / 5)
                
                Button(action: {
                    withAnimation(Animation.easeInOut(duration: 0.1)) {
                        appCoordinator.isCreateMumorySheetShown = true
                        appCoordinator.offsetY = CGFloat.zero
                    }
                }) {
                    Image(asset: SharedAsset.createMumoryTabbar)
                        .resizable()
                        .frame(width: 51, height: 51)

                }
                .frame(width: geometry.size.width / 5)
                
                Button(action: {
                    selectedTab = .library
                    playerViewModel.isShownMiniPlayer = true
                }) {
                    Image(asset: selectedTab == .library ? SharedAsset.libraryOnTabbar : SharedAsset.libraryOffTabbar)
                        .resizable()
                        .frame(width: 43, height: 45)
                }
                .frame(width: geometry.size.width / 5)
                
                Button(action: {
                    selectedTab = .notification
                    playerViewModel.isShownMiniPlayer = false
                }) {
                    Image(asset: selectedTab == .notification ? SharedAsset.notificationOnTabbar : SharedAsset.notificationOffTabbar)
                        .resizable()
                        .frame(width: 31, height: 44)

                }
                .frame(width: geometry.size.width / 5)
            }
            .padding(.top, 2)
        }
        .frame(height: appCoordinator.isHiddenTabBar ? 0 : 89)
        .background(Color.black)
    }
}
