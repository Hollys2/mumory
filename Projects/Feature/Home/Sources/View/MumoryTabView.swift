//
//  HomeTabView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/17.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Shared


public enum Tab {
    case home
    case social
    case library
    case notification
}


public struct MumoryTabView: View {

    @Binding var selectedTab: Tab
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    public init(selectedTab: Binding<Tab>) {
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 0) {
                
                Button(action: {
                    selectedTab = .home
                }) {
                    Image(uiImage: selectedTab == .home ? SharedAsset.homeOnTabbar.image : SharedAsset.homeOffTabbar.image )
                }
                .frame(width: geometry.size.width / 5)
                
                Button(action: {
                    selectedTab = .social
                }) {
                    Image(uiImage: selectedTab == .social ? SharedAsset.socialOnTabbar.image : SharedAsset.socialOffTabbar.image)
                }
                .frame(width: geometry.size.width / 5)
                
                Button(action: {
                    withAnimation(Animation.easeInOut(duration: 0.1)) {
                        appCoordinator.isCreateMumorySheetShown = true
                        appCoordinator.offsetY = CGFloat.zero
                    }
                }) {
                    Image(asset: SharedAsset.createMumoryTabbar)
                }
                .frame(width: geometry.size.width / 5)
                
                Button(action: {
                    selectedTab = .library
                }) {
                    Image(asset: selectedTab == .library ? SharedAsset.libraryOnTabbar : SharedAsset.libraryOffTabbar)
                }
                .frame(width: geometry.size.width / 5)
                
                Button(action: {
                    selectedTab = .notification
                }) {
                    Image(asset: selectedTab == .notification ? SharedAsset.notificationOnTabbar : SharedAsset.notificationOffTabbar)
                }
                .frame(width: geometry.size.width / 5)
            }
            .padding(.top, 2)
        }
        .frame(height: 89)
        .background(Color.black)
    }
}