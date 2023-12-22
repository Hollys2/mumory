//
//  RecentSearchItem.swift
//  Feature
//
//  Created by 제이콥 on 12/4/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct RecentSearchItem: View {
    var title: String = "검색어"
    var body: some View {
        HStack(spacing: 13){
            SharedAsset.graySearch.swiftUIImage
                .frame(width: 23, height: 23)
            
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                .foregroundColor(.white)
                .padding(.top, 10)
                .padding(.bottom, 10)
            
            SharedAsset.xGray.swiftUIImage
                .frame(width: 19, height: 19)
            
        }
        
    }
}

//#Preview {
//    RecentSearchItem()
//}