//
//  OnBoarding1View.swift
//  Feature
//
//  Created by 제이콥 on 1/29/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Lottie

struct OnBoarding1View_small: View {
    var body: some View {
        VStack(spacing: 0, content: {
            LottieView(animation: .named("onBoarding1", bundle: .module))
                .looping()
            
            Text("음악과 특별한 순간을 기록")
                .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 20))
                .foregroundStyle(.white)
                .padding(.top, 15)
            
            
            Text("지도에 언제 어디에서 어떤 음악을 들었는지 기록하고,\n리워드를 받아보세요")
                .multilineTextAlignment(.center)
                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(Color(red: 0.7, green: 0.7, blue: 0.7))
                .padding(.top, 21)
            Spacer()
        })
    }
}

//#Preview {
//    OnBoarding1View_small()
//}
