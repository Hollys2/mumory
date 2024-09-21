//
//  ClearBackground.swift
//  Feature
//
//  Created by 제이콥 on 2/12/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import SwiftUI

public struct TransparentBackground: UIViewRepresentable {
    public init(){}
    
    public class BackgroundRemovalView: UIView {
        public override func didMoveToWindow() {
            super.didMoveToWindow()
            superview?.superview?.backgroundColor = .clear
        }
    }
    
    public func makeUIView(context: Context) -> UIView {
        return BackgroundRemovalView()
    }
    
    
    public func updateUIView(_ uiView: UIView, context: Context) {}
}
