//
//  RecentMusicCell.swift
//  Feature
//
//  Created by 제이콥 on 11/20/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

public struct RecentMusicItem: View {
    @State var title: String = "All I Want For Christmas is you"
    @State var artist: String = "Mariah Carey"
    @State var song: Song
    public var body: some View {
    
        VStack{
            AsyncImage(url: song.artwork?.url(width: 1000, height: 1000), content: { image in
                image
                    .resizable()
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
            }, placeholder: {
                ProgressView()
            })
            .frame(width: 105, height: 105)

            
                
            Text(song.title)
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .frame(width: 105, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(.white)
            
            Text(song.artistName)
                .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 14))
                .foregroundStyle(LibraryColorSet.lightGrayTitle)
                .frame(width: 105, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)
            
        }

    }
}

//#Preview {
//    RecentMusicItem()
//}
