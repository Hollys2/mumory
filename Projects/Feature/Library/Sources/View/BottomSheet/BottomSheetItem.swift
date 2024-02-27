//
//  BottomSheetItem.swift
//  Feature
//
//  Created by 제이콥 on 2/13/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

enum ItemType {
    case normal
    case warning
    case accent
}

struct BottomSheetItem: View {
    var image: Image
    var title: String
    var type: ItemType = .normal
    
    init(image: Image, title: String, type: ItemType) {
        self.image = image
        self.title = title
        self.type = type
    }
    
    init(image: Image, title: String) {
        self.image = image
        self.title = title
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 13, content: {
            image
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
            
            Text(title)
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .foregroundStyle(type == .normal ? Color.white : type == .accent ? ColorSet.mainPurpleColor : ColorSet.accentRed)
        })
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 54)
        .padding(.horizontal, 20)
        .background(ColorSet.background)
    }
    
}

#Preview {
    BottomSheetItem(image: SharedAsset.bookmarkFilled.swiftUIImage, title: "즐겨찾기하기", type: .normal)
}
