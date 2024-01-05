//
//  AppCoordinator.swift
//  Shared
//
//  Created by 다솔 on 2023/12/01.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Foundation

public enum StackViewType {
    case firstView
    case secondView
}

public struct StackView: Hashable {
    public let type: StackViewType
//    let content: String
    
//    public init() {
//        self.type = .firstView
//    }
}


@available(iOS 16.0, *)
public class AppCoordinator: ObservableObject {
    
    public init () {}

    @Published public var path: NavigationPath = NavigationPath()
    @Published public var rootPath: NavigationPath = NavigationPath()

    @Published public var createMumoryPath: NavigationPath = NavigationPath()
    
    @Published public var isCreateMumorySheetShown = false
    @Published public var isSearchLocationViewShown = false
    @Published public var isSearchLocationMapViewShown = false
    @Published public var isMumoryDetailShown = false
    @Published public var isNavigationBarShown = true
    @Published public var isNavigationBarColored = false
    @Published public var isReactionBarShown = true
    @Published public var isMumoryDetailMenuSheetShown = false
    @Published public var isMumoryDetailShownInSocial = false
    @Published public var isMumoryPopUpShown = false
    @Published public var isSocialMenuSheetViewShown = false
    @Published public var isMumoryDetailCommentSheetViewShown = false
    
    @Published public var isTestViewShown = false
    
    @Published public var mumoryPopUpZIndex: Double = 2.0
    
    @Published public var isNavigationStackShown = false
    
    @Published public var page: Int = -1
    
    @Published public var translation: CGSize = CGSize(width: 0, height: 0)
    
    @Published public var safeAreaInsetsTop: CGFloat = 0.0
    @Published public var safeAreaInsetsBottom: CGFloat = 0.0
    
//    @Published public var choosedMumory: MumoryAnnotation = MumoryAnnotation()
}
