//
//  FriendListItem.swift
//  Feature
//
//  Created by 제이콥 on 3/6/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct FriendListItem: View {
    let user: MumoriUser
    
    init(user: MumoriUser) {
        self.user = user
    }
    
    var body: some View {
        HStack(spacing: 13, content: {
            AsyncImage(url: user.profileImageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .fill(ColorSet.darkGray)
                    .frame(width: 55)
            }
            
            VStack(alignment: .leading, spacing: 1, content: {
                Text(user.nickname)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(Color.white)
                
                Text("@\(user.id)")
                    .font(SharedFontFamily.Pretendard.thin.swiftUIFont(size: 12))
                    .foregroundStyle(ColorSet.charSubGray)
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            
            SharedAsset.menu.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
        })
        .padding(.horizontal, 20)
        .background(ColorSet.background)
        .frame(height: 79)
    }
}

//#Preview {
//    FriendListItem()
//}
