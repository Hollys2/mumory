//
//  OnBoarding3_small.swift
//  Feature
//
//  Created by 제이콥 on 1/29/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Lottie
import Shared

struct OnBoarding3View_small: View {
    var body: some View {
        VStack(spacing: 0, content: {
            LottieView(animation: .named("onBoarding3", bundle: .module))
                .looping()
            
            Text("뮤모리만의 음악 추천")
                .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 20))
                .foregroundStyle(.white)
                .padding(.top, 15)
            
            
            Text("뮤모리는 당신의 음악 취향을 이해하고,\n비슷한 취향을 가진 사람들의 음악을 추천 해드립니다")
                .multilineTextAlignment(.center)
                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(Color(red: 0.7, green: 0.7, blue: 0.7))
                .padding(.top, 21)
            Spacer()
        })
    }
}

//#Preview {
//    OnBoarding3View_small()
//}
