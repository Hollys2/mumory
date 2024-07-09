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
    var deleteAction: () -> Void
    init(title: String, deleteAction: @escaping () -> Void) {
        self.title = title
        self.deleteAction = deleteAction
    }
    var body: some View {
        HStack(spacing: 13){
            SharedAsset.graySearch.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 23, height: 23)
            
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                .foregroundColor(.white)
            
            SharedAsset.xGray.swiftUIImage
                .resizable()
                .frame(width: 19, height: 19)
                .onTapGesture {
                    deleteAction()
                }

        }
        .frame(height: 50)
        .padding(.horizontal, 20)

        
    }
}
