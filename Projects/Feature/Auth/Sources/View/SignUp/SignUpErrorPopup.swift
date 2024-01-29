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
    var body: some View {
       
            
            VStack{
                Text("알 수 없는 오류가 생겼습니다.")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                    .foregroundStyle(.white)
                    .padding(.top, 40)
                
                Text("회원가입을 다시 시도해주세요.")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 13))
                    .foregroundStyle(.white)
                    .padding(.top, 22)
                
            }
            .background(ColorSet.darkGray)
        
    }
}

#Preview {
    SignUpErrorPopup()
}
