//
//  MusicTestItem.swift
//  Feature
//
//  Created by 제이콥 on 2/20/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct MusicTestItem: View {
    var body: some View {
        HStack(spacing: 0, content: {
            
            RoundedRectangle(cornerRadius: 5, style: .circular)
                .foregroundStyle(.gray)
                .frame(width: 40, height: 40)
                .padding(.trailing, 13)
            
            
            VStack(content: {
                Text("타이틀")
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text("아티스트 이름")
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(LibraryColorSet.lightGrayTitle)
                    .lineLimit(1)
                    .truncationMode(.tail)
            })
            
            Spacer()
            SharedAsset.bookmark.swiftUIImage
                .frame(width: 20, height: 20)
                .padding(.trailing, 23)
            
            SharedAsset.menu.swiftUIImage
                .frame(width: 22, height: 22)
            
        })
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
    }
}
