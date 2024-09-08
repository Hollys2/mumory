//
//  ClearBackground.swift
//  Feature
//
//  Created by 제이콥 on 2/12/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import SwiftUI

struct TransparentBackground: UIViewRepresentable {
    private class BackgroundRemovalView: UIView {
           override func didMoveToWindow() {
               super.didMoveToWindow()
               superview?.superview?.backgroundColor = .clear
           }
       }
       
       func makeUIView(context: Context) -> UIView {
           return BackgroundRemovalView()
       }

    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
