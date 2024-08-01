//
//  LoadingAnimationView.swift
//  Shared
//
//  Created by 제이콥 on 2/27/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Lottie

public struct LoadingAnimationView: View {
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .center){
            Color.black.opacity(0.01)
            
            LottieView(animation: .named("loading", bundle: .module))
                .looping()
                .frame(width: getUIScreenBounds().width * 0.16, height: getUIScreenBounds().width * 0.16)
        }
    }
}
