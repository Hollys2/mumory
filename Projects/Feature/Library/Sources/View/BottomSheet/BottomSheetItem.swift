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
}

struct BottomSheetItem: View {
    var image: Image
    var title: String
    var type: ItemType
    
    init(image: Image, title: String, type: ItemType) {
        self.image = image
        self.title = title
        self.type = type
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 13, content: {
            image
                .resizable()
                .frame(width: 30, height: 30)
            
            Text(title)
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .foregroundStyle(type == .normal ? Color.white : ColorSet.accentRed)
        })
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .background(ColorSet.background)
        .padding(.horizontal, 20)
    }
    
}

#Preview {
    BottomSheetItem(image: SharedAsset.bookmarkFilled.swiftUIImage, title: "즐겨찾기하기", type: .normal)
}
