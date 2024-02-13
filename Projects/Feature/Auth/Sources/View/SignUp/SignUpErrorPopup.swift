//
//  SignUpErrorPopup.swift
//  Feature
//
//  Created by 제이콥 on 1/30/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct SignUpErrorPopup: View {
    @Binding var isShowing: Bool
    var body: some View {
            VStack{
                Text("알 수 없는 오류가 생겼습니다.")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                    .foregroundStyle(.white)
                    .padding(.top, 40)
                
                Text("회원가입을 다시 시도해주세요.")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 13))
                    .foregroundStyle(.white)
                    .padding(.top, 5)
                
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundStyle(Color(red: 0.65, green: 0.65, blue: 0.65))
                    .padding(.top, 20)
                
                Button(action: {
                    isShowing = false
                }, label: {
                    Text("확인")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                        .foregroundStyle(ColorSet.mainPurpleColor)
                        .padding(.top, 4)
                        .padding(.bottom, 12)
                })
                
            }
            .frame(maxWidth: .infinity)
            .background(ColorSet.darkGray)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
            .padding(39)
            .opacity(isShowing ? 1 : 0)
        
    }
}

//#Preview {
//    SignUpErrorPopup()
//}
