//
//  QueueItem.swift
//  Feature
//
//  Created by 제이콥 on 2/20/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct QueueItem: View {
    @EnvironmentObject var playerManager: PlayerViewModel
    @State var isPresentBottomSheet: Bool = false
    var song: Song
    var scrollProxy: ScrollViewProxy
    
    init(song: Song, scrollProxy: ScrollViewProxy) {
        self.song = song
        self.scrollProxy = scrollProxy
    }
    var body: some View {
        HStack(spacing: 0, content: {
            AsyncImage(url: song.artwork?.url(width: 300, height: 300)) { image in
                image
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 5,style: .circular))
            } placeholder: {
                RoundedRectangle(cornerRadius: 5, style: .circular)
                    .foregroundStyle(.gray)
                    .frame(width: 40, height: 40)
            }
            .padding(.leading, 15)
            .padding(.trailing, 15)
            
            VStack(content: {
                Text(song.title)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(playerManager.playingSong() == self.song ? ColorSet.mainPurpleColor : .white)
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
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .padding(.trailing, 13)
                .onTapGesture {
                    isPresentBottomSheet = true
                }
                .fullScreenCover(isPresented: $isPresentBottomSheet, content: {
                    BottomSheetWrapper(isPresent: $isPresentBottomSheet) {
                        SongBottomSheetView(song: song)
                    }
                    .background(TransparentBackground())
                })

            
        })
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 70)
        .background(playerManager.playingSong() == self.song ? Color.black : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
        .padding(.horizontal, 15)
    }

}

//#Preview {
//    QueueItem()
//}
