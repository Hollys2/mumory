//
//  StartCostomizationView.swift
//  Feature
//
//  Created by 제이콥 on 12/11/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Lottie

struct StartCostomizationView: View {
    @EnvironmentObject var manager: CustomizationManageViewModel

    var body: some View {
        
        ZStack{
            LibraryColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0, content: {
                Text("음악과 일상을  나누는 새로운 방법,\n뮤모리를 통해 친구들과\n특별한 순간을 기록하세요")
                    .foregroundColor(.white)
                    .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 22))
                    .lineSpacing(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 30)
                    .padding(.top, 48.5)
                
                Text("다음 질문지를 통해 나의 음악 취향\n설정과 프로필이 생성됩니다.")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .lineSpacing(5)
                    .tracking(0.3)
                    .foregroundStyle(Color(red: 0.54, green: 0.54, blue: 0.54))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 30)
                    .padding(.top, 40)
                
                Spacer()

                LottieView(animation: .named("survey", bundle: .module))
                    .looping()
                    .ignoresSafeArea()
                
                Spacer()
                
                Text("뮤모리는 Apple Music과 연계된 어플입니다.")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                    .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                
            
                NavigationLink {
                    CustomizationView()
                        .environmentObject(manager)
                } label: {
                    //enable을 true로 설정하면 배경이 보라색으로 바뀜
                    WhiteButton(title: "시작하기", isEnabled: true)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                        .padding(.top, 25)
                }

                
            })
        }
        .navigationBarBackButtonHidden()
    }
}

//#Preview {
//    StartCostomizationView()
//}
