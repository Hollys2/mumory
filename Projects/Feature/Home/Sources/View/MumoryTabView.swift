//
//  HomeTabView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/17.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI

import Shared


final private class CustomTabBarController: UITabBarController {
    private class CustomHeightTabBar: UITabBar {
        override open func sizeThatFits(_ size: CGSize) -> CGSize {
            var sizeThatFits = super.sizeThatFits(size)
            sizeThatFits.height = 89
            return sizeThatFits
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        object_setClass(self.tabBar, CustomHeightTabBar.self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct MumoryTabViewControllerRepresentable: UIViewControllerRepresentable {
    
    var viewControllers: [UIViewController]
    @Binding var selectedTab: Tab    
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject private var playerViewModel: PlayerViewModel
    
    func makeUIViewController(context: Context) -> UITabBarController {
        let tabBarController = CustomTabBarController()
        tabBarController.viewControllers = viewControllers
        tabBarController.tabBar.backgroundColor = .black
        tabBarController.delegate = context.coordinator
        
        return tabBarController
    }
    
    func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
        uiViewController.selectedIndex = self.selectedTab.rawValue
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    class Coordinator: NSObject, UITabBarControllerDelegate {
        var parent: MumoryTabViewControllerRepresentable
        
        init(_ parent: MumoryTabViewControllerRepresentable) {
            self.parent = parent
        }
        
        func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
            if let index = tabBarController.viewControllers?.firstIndex(of: viewController) {
                if let tab = Tab(rawValue: index){
                    if tab == .createMumroy {
                        self.parent.appCoordinator.isCreateMumorySheetShown = true
                        self.parent.playerViewModel.setLibraryPlayerVisibilityWithoutAnimation(isShown: false)
                    } else {
                        if tab == .social {
                            if self.parent.selectedTab == .social {
                                self.parent.appCoordinator.isScrollToTop = true
                            }
                        }
                        
                        self.parent.selectedTab = tab
                    }
                }
            }
        }
    }
}



//public struct MumoryTabView: View {
//
//    @EnvironmentObject var appCoordinator: AppCoordinator
//    @EnvironmentObject var playerViewModel: PlayerViewModel
//    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
//
//    public init() {}
//
//    public var body: some View {
//        GeometryReader { geometry in
//
//            HStack(alignment: .bottom, spacing: 0) {
//
//                Image(uiImage: self.appCoordinator.selectedTab == .home ? SharedAsset.homeOnTabbar.image : SharedAsset.homeOffTabbar.image)
//                    .resizable()
//                    .frame(width: 25, height: 41)
//                    .frame(width: geometry.size.width / 5)
//                    .onTapGesture {
//                        playerViewModel.isPresentNowPlayingView = false
////                        self.tabViewModel.tab = .home
////                        print("FUCK self.tabViewModel.tab: \(self.tabViewModel.tab)")
//
//                        self.appCoordinator.selectedTab = .home
//                    }
//
//                Image(uiImage: self.appCoordinator.selectedTab == .social ? SharedAsset.socialOnTabbar.image : SharedAsset.socialOffTabbar.image)
//                    .resizable()
//                    .frame(width: 35, height: 45)
//                    .frame(width: geometry.size.width / 5)
//                    .onTapGesture {
////                        self.appCoordinator.scrollToTop = true
//                        self.appCoordinator.selectedTab = .social
////                        self.tabViewModel.tab = .social
////                        print("FUCK self.tabViewModel.tab: \(self.tabViewModel.tab)")
//                    }
//
//                Image(asset: SharedAsset.createMumoryTabbar)
//                    .resizable()
//                    .frame(width: 51, height: 51)
//                    .frame(width: geometry.size.width / 5)
//                    .onTapGesture {
//                        playerViewModel.setLibraryPlayerVisibilityWithoutAnimation(isShown: false)
//
//                        self.appCoordinator.sheet = .createMumory
//                    }
//
//                Image(asset: self.appCoordinator.selectedTab == .library ? SharedAsset.libraryOnTabbar : SharedAsset.libraryOffTabbar)
//                    .resizable()
//                    .frame(width: 43, height: 45)
//                    .frame(width: geometry.size.width / 5)
//                    .onTapGesture {
//                        self.appCoordinator.selectedTab = .library
//                    }
//
//                Image(asset: self.appCoordinator.selectedTab == .notification ? currentUserViewModel.existUnreadNotification ? SharedAsset.notificationOnDotTabbar : SharedAsset.notificationOnTabbar : currentUserViewModel.existUnreadNotification ? SharedAsset.notificationOffDotTabbar : SharedAsset.notificationOffTabbar)
//                    .resizable()
//                    .frame(width: 31, height: 44)
//                    .frame(width: geometry.size.width / 5)
//                    .onTapGesture {
//                        self.appCoordinator.selectedTab = .notification
//                    }
//
//            }
//            .padding(.top, 2)
//        }
//        .ignoresSafeArea()
//        .frame(height: 89)
//        .background(Color.black)
//    }
//}
