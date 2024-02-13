//
//  MusicChartItem.swift
//  Feature
//
//  Created by 제이콥 on 11/22/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct MusicChartItem: View {
    var rank: Int
    let title = "타이틀"
    let artist = "아티스트"
    var song: Song
    var body: some View {
//        ZStack{
//            LibraryColorSet.background
            HStack(spacing: 16){
                AsyncImage(url: song.artwork?.url(width: 300, height: 300), content: { image in
                    image
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)))
                }, placeholder: {
                    //
                })
                
                Text(String(format: "%02d", rank))
                    .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                    .foregroundStyle(LibraryColorSet.purpleBackground)
                
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
                
                Spacer()
                
                SharedAsset.menu.swiftUIImage
            }
            .padding(.leading, 20)
            .padding(.trailing, 15)
        }

//    }
}

//#Preview {
//    MusicChartItem()
//}
