//
//  TestTestView.swift
//  Feature
//
//  Created by 제이콥 on 2/1/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Lottie

struct LottieTestView: View {
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
            LottieView(animation: .named("loading", bundle: .module))
                .looping()
            
        }
    }
}

//#Preview {
//    LottieTestView()
//}
