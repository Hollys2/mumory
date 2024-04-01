//
//  WhiteButton.swift
//  Feature
//
//  Created by 제이콥 on 12/10/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared


struct MumorySimpleButton: View {
    var title: String = ""
    var isEnabled: Bool = false
    var showShadow: Bool = true
    var body: some View {
        VStack{
            Text(title)
                .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 18))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 58)
        .foregroundColor(.black)
        .background(isEnabled ? ColorSet.mainPurpleColor : ColorSet.subGray)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .circular))
        .shadow(color: showShadow ? Color.black.opacity(0.25) : Color.clear, radius: 10, y: 6)

    }
}

struct MumoryLoadingButton: View {
    var title: String
    var isEnabled: Bool = false
    var showShadow: Bool = true
    @Binding var isLoading: Bool
    
    init(title: String, isEnabled: Bool, isLoading: Binding<Bool>) {
        self.title = title
        self.isEnabled = isEnabled
        self._isLoading = isLoading
    }
    
    var body: some View {
        VStack{
            if isLoading {
                WhiteLoadingAnimationView(isLoading: $isLoading)
            }else {
                Text(title)
                    .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 18))
                    .foregroundStyle(Color.black)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 58)
        .foregroundColor(.black)
        .background(isEnabled ? ColorSet.mainPurpleColor : ColorSet.subGray)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .circular))
        .shadow(color: showShadow ? Color.black.opacity(0.25) : Color.clear, radius: 10, y: 6)

    }
}