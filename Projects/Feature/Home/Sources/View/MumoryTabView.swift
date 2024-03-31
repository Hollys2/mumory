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
    @EnvironmentObject var currentUserData: CurrentUserData
    public init(selectedTab: Binding<Tab>) {
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        GeometryReader { geometry in
            
            HStack(alignment: .bottom, spacing: 0) {
                
                Image(uiImage: selectedTab == .home ? SharedAsset.homeOnTabbar.image : SharedAsset.homeOffTabbar.image )
                    .resizable()
                    .frame(width: 25, height: 41)
                    .frame(width: geometry.size.width / 5)
                    .onTapGesture {
                        selectedTab = .home
                    }
                
                Image(uiImage: selectedTab == .social ? SharedAsset.socialOnTabbar.image : SharedAsset.socialOffTabbar.image)
                    .resizable()
                    .frame(width: 35, height: 45)
                
                    .frame(width: geometry.size.width / 5)
                    .onTapGesture {
                        appCoordinator.scrollToTop = true
                        selectedTab = .social
                    }
                
                Image(asset: SharedAsset.createMumoryTabbar)
                    .resizable()
                    .frame(width: 51, height: 51)
                    .frame(width: geometry.size.width / 5)
                    .onTapGesture {
                        withAnimation(Animation.easeInOut(duration: 0.1)) {
                            appCoordinator.isCreateMumorySheetShown = true
                            appCoordinator.offsetY = CGFloat.zero
                        }
                    }
                
                Image(asset: selectedTab == .library ? SharedAsset.libraryOnTabbar : SharedAsset.libraryOffTabbar)
                    .resizable()
                    .frame(width: 43, height: 45)
                    .frame(width: geometry.size.width / 5)
                    .onTapGesture {
                        selectedTab = .library
                    }
                
                Image(asset: selectedTab == .notification ? currentUserData.existUnreadNotification ? SharedAsset.notificationOnDotTabbar : SharedAsset.notificationOnTabbar : currentUserData.existUnreadNotification ? SharedAsset.notificationOffDotTabbar : SharedAsset.notificationOffTabbar )                    
                    .resizable()
                    .frame(width: 31, height: 44)
                    .frame(width: geometry.size.width / 5)
                    .onTapGesture {
                        selectedTab = .notification
                    }

            }
            .padding(.top, 2)
        }
        .ignoresSafeArea()
        .frame(height: 89)
        .background(Color.black)
    }
}
