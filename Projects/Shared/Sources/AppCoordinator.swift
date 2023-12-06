//
//  AppCoordinator.swift
//  Shared
//
//  Created by 다솔 on 2023/12/01.
//  Copyright © 2023 hollys. All rights reserved.
//


import Foundation

public class AppCoordinator: ObservableObject {
    
    public init () {}

    
    @Published public var isCreateMumorySheetShown = false
    @Published public var isSearchLocationViewShown = false
    @Published public var isSearchLocationMapViewShown = false
    
    @Published public var isNavigationStackShown = false
}
