//
//  SplashView.swift
//  Feature
//
//  Created by 제이콥 on 6/3/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Lottie

public struct SplashView: View {
    // MARK: - Object lifecycle
    public init(){}
    
    // MARK: - View
    public var body: some View {
        ZStack(alignment: .center) {
            ColorSet.mainPurpleColor.ignoresSafeArea()
                .overlay {
                    LottieView(animation: .named("splash", bundle: .module))
                        .looping()
                }
                .transition(.opacity)
        }
    }
}

#Preview {
    SplashView()
}
