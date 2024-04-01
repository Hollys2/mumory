//
//  OnBoarding2_small.swift
//  Feature
//
//  Created by 제이콥 on 1/29/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Lottie
import Shared

struct OnBoarding2View_small: View {
    var body: some View {
        VStack(spacing: 0, content: {
            LottieView(animation: .named("onBoarding2", bundle: .module))
                .looping()
            
            Text("친구들과 음악과 나의 순간을 함께 공유")
                .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 20))
                .foregroundStyle(.white)
                .padding(.top, 15)
            
            
            Text("뮤모리로 친구들과 음악과 나의 순간을\n함께 공유하며 소통해보세요")
                .multilineTextAlignment(.center)
                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(Color(red: 0.7, green: 0.7, blue: 0.7))
                .padding(.top, 21)
            Spacer()
        })
    }
}

//#Preview {
//    OnBoarding2View_small()
//}
