//
//  DeviceDimension.swift
//  Shared
//
//  Created by 제이콥 on 7/9/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import UIKit

class DeviceDimension {
    static public func bounds() -> CGRect {
        UIScreen.main.bounds
    }
    
    static public func safeAreaInsets() -> UIEdgeInsets {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let safeAreaInsets = window.safeAreaInsets
            return safeAreaInsets
        }
        return UIEdgeInsets.zero
    }
    
    public func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.height < 800
    }
}
