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
    let songId: String
    @State var song: Song?
    @EnvironmentObject var playerViewModel: PlayerViewModel
    init(songId: String) {
        self.songId = songId
    }
    public var body: some View {
        
        VStack(alignment: .leading){
            
            AsyncImage(url: song?.artwork?.url(width: 500, height: 500), content: { image in
                image
                    .resizable()
                    .scaledToFill()
                
            }, placeholder: {
                RoundedRectangle(cornerRadius: 15,style: .circular)
                    .foregroundStyle(.gray)
            })
            .overlay {
                LinearGradient(colors: [ColorSet.mainPurpleColor, Color.clear], startPoint: .bottom, endPoint: .init(x: 0.5, y: 0.6 ))
            }
            .frame(width: 105, height: 105)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))

            
            Text(song?.title ?? "")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                .frame(width: 105, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(.white)
            
            Text(song?.artistName ?? "")
                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(ColorSet.charSubGray)
                .frame(width: 105, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)
            
        }
        .onAppear {
            Task {
                self.song = await fetchSong(songID: self.songId)
            }
        }
        .onTapGesture {
            if let song = song {
                playerViewModel.playNewSong(song: song)
            }
        }
        
    }
}
