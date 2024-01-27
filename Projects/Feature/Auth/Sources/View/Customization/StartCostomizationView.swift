//
//  StartCostomizationView.swift
//  Feature
//
//  Created by 제이콥 on 12/11/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct StartCostomizationView: View {

    var body: some View {
        ZStack{
            LibraryColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0, content: {
                Text("음악과 일상을\n나누는 새로운 방법\n뮤모리를 통해 친구들과\n특별한 순간을 기록하세요")
                    .foregroundColor(.white)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 24))
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.top, 80)
                
                Text("다음 설문지를 통해\n나의 음악 취향 설정과 프로필이 생성됩니다.")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.top, 69)
                
                Spacer()
                Text("뮤모리는 Apple Music과 연계된 어플입니다.")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 14))
                    .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                
                NavigationLink {
                    CustomizationView()
                } label: {
                    //enable을 true로 설정하면 배경이 보라색으로 바뀜
                    WhiteButton(title: "시작하기", isEnabled: true)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .padding(.bottom, 10)
                        .padding(.top, 28)
                }

                
            })
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    StartCostomizationView()
}
