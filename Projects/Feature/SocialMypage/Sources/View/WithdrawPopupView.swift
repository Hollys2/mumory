//
//  WithdrawPopupView.swift
//  Feature
//
//  Created by 제이콥 on 2/5/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct WithdrawPopupView: View {
    private let gray = Color(red: 0.65, green: 0.65, blue: 0.65)
    var negativeAction: () -> Void
    var positiveAction: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text("계정을 탈퇴하시겠습니까?")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                .foregroundStyle(.white)
                .padding(.top, 28)
            
            Text("탈퇴하신 계정은 복구가 불가능합니다.")
                .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 13))
                .foregroundStyle(.white)
                .padding(.top, 18)
            
            Rectangle()
                .foregroundStyle(gray)
                .frame(maxWidth: .infinity, maxHeight: 0.5)
                .padding(.top, 30)


            
            HStack(spacing: 0, content: {
                Spacer()
                Text("취소")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                    .foregroundStyle(.white)
                    .padding(10)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    .onTapGesture {
                        negativeAction()
                    }
                Spacer()
                Rectangle()
                    .foregroundStyle(gray)
                    .frame(maxWidth: 0.5, maxHeight: 45)
                Spacer()
                Text("탈퇴")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(ColorSet.mainPurpleColor)
                    .padding(10)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    .onTapGesture {
                        positiveAction()
                    }

                Spacer()

            })
        }
        .background(ColorSet.darkGray)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
        .padding(.leading, 50)
        .padding(.trailing, 50)
    }
}

