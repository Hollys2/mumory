//
//  imageTestview.swift
//  Feature
//
//  Created by 제이콥 on 2/29/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Lottie

struct imageTestview: View {
    var body: some View {
        ZStack{
            Color.black
            VStack{
                LottieView(animation: .named("survey", bundle: .module))
                    .looping()
                    .scaledToFill()
            }
            .ignoresSafeArea()

        }
        .ignoresSafeArea()

    }
}
//
//#Preview {
//    imageTestview()
//}
