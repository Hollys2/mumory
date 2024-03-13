//
//  InitialPopUpView.swift
//  Shared
//
//  Created by 다솔 on 2024/03/07.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI


struct CreateMumoryPopUpView: View {
    
    var body: some View {
        Image(uiImage: SharedAsset.createMumoryInitialPopup.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 146, height: 35)
    }
}

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
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                            .foregroundColor(.black)
                        
                        Text("지금 바로 구독하고 뮤모리를 이용해보세요.")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                            .foregroundColor(.black)
                    }
                    .padding(.leading, 20)
                    .padding(.vertical, 18)
                    
                    Spacer()
                    
                    Image(uiImage: SharedAsset.closeButtonPopup.image)
                        .resizable()
                        .frame(width: 17, height: 17)
                        .padding(.trailing, 11)
                }
            )
    }
}
