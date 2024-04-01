//
//  SelectPlaylistItem.swift
//  Feature
//
//  Created by 제이콥 on 2/20/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct SaveToPlaylistItem: View {
    var playlist: MusicPlaylist
    
    init(playlist: MusicPlaylist) {
        self.playlist = playlist
    }
    
    var body: some View {
        VStack(spacing: 0, content: {
            HStack(spacing: 0, content: {
                Text(playlist.title)
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                SharedAsset.lock.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .opacity(playlist.isPublic ? 0 : 1)
                    .padding(.leading, 15)
                
                Text("\(playlist.songIDs.count)")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                    .foregroundStyle(ColorSet.charSubGray)
                    .frame(width: 40, alignment: .trailing)
                    
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .frame(height: 70)
            .background(ColorSet.background)
            
            Divider05()
        })
   
    }
}

//#Preview {
//    SelectPlaylistItem()
//}
