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
        VStack(spacing: 0) {
            HStack(spacing: 16){
                AsyncImage(url: song.artwork?.url(width: 300, height: 300), content: { image in
                    image
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5), style: .circular))
                }, placeholder: {
                    RoundedRectangle(cornerRadius: 5, style: .circular)
                        .foregroundStyle(.gray)
                        .frame(width: 40, height: 40)

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
                    .frame(width: 22, height: 22)
                    .padding(.trailing, 15)
            }
            .padding(.top, 15)
            .padding(.bottom, 15)
            
            Divider()
                .frame(maxWidth: .infinity)
                .frame(height: 0.5)
                .background(ColorSet.subGray)
                .opacity(rank%4 == 0 ? 0 : 1)
        }
        .padding(.leading, 20)
       
        }

}

//#Preview {
//    MusicChartItem()
//}
