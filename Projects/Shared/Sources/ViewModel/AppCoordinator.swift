//
//  AppCoordinator.swift
//  Shared
//
//  Created by 다솔 on 2023/12/01.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import MapKit
import MusicKit
import Firebase

public enum AppNavigationType {
    case auth
    case mumory
}

public class AppCoordinator: ObservableObject {
    public init(){}
    
    @Published public var rootPath: NavigationPath = NavigationPath()
    @Published public var authPath: [AuthPage] = []
    
    @Published public var initPage: InitPage = .login
    @Published public var selectedTab: Tab = .home
    
    @Published public var scrollToTop: Bool = false
    @Published public var createdMumoryRegion: MKCoordinateRegion?
    
    @Published public var offsetY: CGFloat = .zero
    
    @Published public var sheet: Sheet = .none
    @Published public var bottomSheet: BottomSheet = .none
    
    @Published public var isCreateMumorySheetShown: Bool = false
    @Published public var isMumoryDetailShown = false
    @Published public var isNavigationBarColored = false
    @Published public var isReactionBarShown = true
    @Published public var isMumoryDetailMenuSheetShown = false
//    @Published public var isSocialMenuSheetViewShown = false
    @Published public var isMumoryDetailCommentSheetViewShown = false
    @Published public var isSocialCommentSheetViewShown: Bool = false
    @Published public var isCommentBottomSheetShown = false
    @Published public var isMyMumoryBottomSheetShown = false
    @Published public var isDeleteCommentPopUpViewShown = false
    @Published public var isAddFriendViewShown = false
    @Published public var isDeleteMumoryPopUpViewShown = false
    @Published public var isFirstTabSelected: Bool = false
    
    @Published public var choosedMumoryAnnotation: Mumory = Mumory()
    
    @Published public var page: Int = 1
    
    @Published public var safeAreaInsetsTop: CGFloat = 0.0
    @Published public var safeAreaInsetsBottom: CGFloat = 0.0
    
    @Published public var isMyPageViewShown = false
    @Published public var isSplashViewShown: Bool = true
    @Published public var isHomeViewShown: Bool = false
    @Published public var isOnboardingShown: Bool = false
    
    

    
    public func push<T>(destination: T) {
        if let dst = destination as? AuthPage {
            authPath.append(dst)
        } else if let dst = destination as? MumoryPage {
            rootPath.append(dst)
        }
    }
    
    public func pop(target: AppNavigationType) {
        if target == .auth {
            _ = authPath.popLast()
        } else if target == .mumory {
            rootPath.removeLast()
        }
    }
    

}

