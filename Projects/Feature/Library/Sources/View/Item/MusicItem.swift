//
//  MusicItem.swift
//  Feature
//
//  Created by 제이콥 on 1/25/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import MusicKit
import Shared

struct MusicItem: View {
    let title = "타이틀"
    let artist = "아티스트"
    var song: Song
    var body: some View {
            HStack(spacing: 0){
                AsyncImage(url: song.artwork?.url(width: 300, height: 300), content: { image in
                    image
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)))
                }, placeholder: {
                    //
                })
                .padding(.trailing, 13)

                VStack(content: {
                    Text(song.title)
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Text(song.artistName)
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundStyle(LibraryColorSet.lightGrayTitle)
                        .lineLimit(1)
                        .truncationMode(.tail)
                })
                .padding(.trailing, 10)
                
                Spacer()
                SharedAsset.bookmark.swiftUIImage
                    .padding(.trailing, 23)
                SharedAsset.menu.swiftUIImage
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 7)
            .padding(.bottom, 7)
        }
}

//#Preview {
//    MusicItem()
//}
