//
//  AddSongItem.swift
//  Feature
//
//  Created by 제이콥 on 2/14/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct AddPlaylistSongItem: View {
    @State var isCheck = true
    var body: some View {
        HStack(alignment: .center, spacing: 0){
            Button(action: {
                isCheck.toggle()
            }, label: {
                if isCheck {
                    SharedAsset.checkCircleFill.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }else {
                    SharedAsset.checkCircleDefault.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }
            })
            .padding(.trailing, 20)
            
            RoundedRectangle(cornerRadius: 5, style: .circular)
                .foregroundStyle(.gray)
                .frame(width: 40, height: 40)
                .padding(.trailing, 13)
            
            VStack(content: {
                Text("title")
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text("artist")
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(LibraryColorSet.lightGrayTitle)
                    .lineLimit(1)
                    .truncationMode(.tail)
            })
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(ColorSet.background)
    }
}

#Preview {
    AddPlaylistSongItem()
}
