//
//  AppCoordinator.swift
//  Shared
//
//  Created by 다솔 on 2023/12/01.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Foundation

@available(iOS 16.0, *)
public class AppCoordinator: ObservableObject {
    
    public init () {
        self.path = NavigationPath()
    }

    @Published public var path: NavigationPath
    
    @Published public var isCreateMumorySheetShown = false
    @Published public var isSearchLocationViewShown = false
    @Published public var isSearchLocationMapViewShown = false
    @Published public var isMumoryDetailShown = false
    @Published public var isNavigationBarShown = true
    @Published public var isNavigationBarColored = false
    @Published public var isReactionBarShown = true
    @Published public var isMumoryDetailMenuSheetShown = false
    
    @Published public var isNavigationStackShown = false
    
    @Published public var page: Int = -1
    
    @Published public var translation: CGSize = CGSize(width: 0, height: 0)
    
    @Published public var safeAreaInsetsTop: CGFloat = 0.0
    @Published public var safeAreaInsetsBottom: CGFloat = 0.0
    
//    @Published public var choosedMumory: MumoryAnnotation = MumoryAnnotation()
}
