//
//  AppleMusicPopUpView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/24.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Shared

struct AppleMusicPopUpView: View {
    var body: some View {
        Rectangle()
        .foregroundColor(.clear)
        .frame(width: 350, height: 67)
        .background(Color(red: 0.64, green: 0.51, blue: 0.99))
        .cornerRadius(10)
        .overlay(
            HStack {
                VStack(alignment: .leading, spacing: 13) {
                    Text("Apple Music 이용권이 없습니다.")
                      .font(
                        Font.custom("Pretendard", size: 14)
                          .weight(.semibold)
                      )
                      .foregroundColor(.black)
                    Text("지금 바로 구독하고 뮤모리를 이용해보세요.")
                      .font(
                        Font.custom("Pretendard", size: 12)
                          .weight(.medium)
                      )
                      .foregroundColor(.black)
                }
                .padding(.leading, 20)
                .padding(.vertical, 18)
                Spacer()
                
                Image(uiImage: SharedAsset.closeButtonPopup.image)
                .frame(width: 17, height: 17)
                .padding(.trailing, 11)
            }
        )
    }
}

struct AppleMusicPopUpView_Previews: PreviewProvider {
    static var previews: some View {
        AppleMusicPopUpView()
    }
}
