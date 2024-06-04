//
//  TabModel.swift
//  Shared
//
//  Created by 다솔 on 2024/05/20.
//  Copyright © 2024 hollys. All rights reserved.
//


import Foundation

public class TabViewModel: ObservableObject {
    public static let shared: TabViewModel = .init()
    
    public var tab: Tab = .home
    
    public init() {}
}
