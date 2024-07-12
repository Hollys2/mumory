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


public class AppCoordinator: ObservableObject {
    
    @Published public var rootPath: NavigationPath = NavigationPath()
//    @Published public var rootPath: [MumoryPage] = []
    
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
    @Published public var isRewardPopUpShown: Bool = false
    
    @Published public var isLoading: Bool = false
    
    @Published public var choosedMumoryAnnotation: Mumory = Mumory()
    
    
    @Published public var page: Int = 1
    
    @Published public var safeAreaInsetsTop: CGFloat = 0.0
    @Published public var safeAreaInsetsBottom: CGFloat = 0.0
    
    @Published public var contentHeight: CGFloat = 111
    
    @Published public var bottomAnimationViewStatus: BottomAnimationPage = .remove
    
    //아래에서 나오는 뷰 관리 용도
    public enum BottomAnimationPage {
        case myPage
        case play
        case remove
    }
    
    public func setBottomAnimationPage(page: BottomAnimationPage) {
        withAnimation {
            self.bottomAnimationViewStatus = page
        }
    }
    
    public init () {}
}

