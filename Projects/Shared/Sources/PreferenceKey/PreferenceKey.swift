//
//  PreferenceKey.swift
//  Shared
//
//  Created by 다솔 on 2024/03/17.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI

public struct TabWidthPreferenceKey: PreferenceKey {
    
    public static var defaultValue: [Int: CGFloat] = [:]
    
    public static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        //        value.merge(nextValue()) { $1 }
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}
