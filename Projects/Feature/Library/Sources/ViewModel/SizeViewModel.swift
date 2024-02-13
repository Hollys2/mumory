//
//  SizeViewModel.swift
//  Feature
//
//  Created by 제이콥 on 2/8/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation

public class SizeViewModel: ObservableObject {
    public init(){}

    @Published public var width: CGFloat = 0
    @Published public var height: CGFloat = 0
    @Published public var topInset: CGFloat = 0
    @Published public var bottomInset: CGFloat = 0
    @Published public var customTopbarHeight: CGFloat = 68
    
}
