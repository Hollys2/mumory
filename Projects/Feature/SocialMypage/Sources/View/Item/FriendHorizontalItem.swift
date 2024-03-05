//
//  FriendHorizontalItem.swift
//  Feature
//
//  Created by 제이콥 on 2/24/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct FriendHorizontalItem: View {
    var defaultProfiles: [Image] = [SharedAsset.profileRed.swiftUIImage, SharedAsset.profilePurple.swiftUIImage, SharedAsset.profileOrange.swiftUIImage, SharedAsset.profileYellow.swiftUIImage]
    
    let nickname: String = "어쩔닉네임"
    let user: MumoriUser
    
    init(user: MumoriUser) {
        self.user = user
    }
    
    var body: some View {
        VStack(spacing: 15, content: {
            AsyncImage(url: user.profileImageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
            } placeholder: {
                defaultProfiles[Int.random(in: 0 ... 3)]
                    .resizable()
                    .frame(width: 55, height: 55)
                    .scaledToFill()
            }
            
            Text(user.nickname)
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                .foregroundStyle(Color.white)
                .frame(width: 60)
                .lineLimit(1)
                .truncationMode(.tail)

        })
    }
}

//#Preview {
//    FriendHorizontalItem()
//}
