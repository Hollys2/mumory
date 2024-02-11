//
//  PlayAllButton.swift
//  Feature
//
//  Created by 제이콥 on 2/8/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct PlayAllButton: View {
    var body: some View {
        HStack(spacing: 6, content: {
            SharedAsset.playPurple.swiftUIImage
                .frame(width: 9, height: 9)
            Text("전체재생")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundStyle(ColorSet.mainPurpleColor)
        })
        .padding(.leading, 15)
        .padding(.trailing, 14)
        .padding(.top, 9)
        .padding(.bottom, 9)
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .circular).stroke(ColorSet.mainPurpleColor, lineWidth: 1.0)
        }
    }
}

#Preview {
    PlayAllButton()
}
