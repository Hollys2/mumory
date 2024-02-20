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
    @State var playlist: MusicPlaylist
    @Binding var selectedPlaylists: [MusicPlaylist]
    
    init(playlist: MusicPlaylist, selectedPlaylists: Binding<[MusicPlaylist]>) {
        self.playlist = playlist
        self._selectedPlaylists = selectedPlaylists
    }
    
    var body: some View {
        VStack(spacing: 0, content: {
            HStack(spacing: 0, content: {
                if selectedPlaylists.contains(playlist) {
                    SharedAsset.checkCircleFill.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .padding(.trailing, 13)
                }else {
                    SharedAsset.checkCircle.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .padding(.trailing, 13)
                }
                
                Text(playlist.title)
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.trailing, 20)
                
                if playlist.isPrivate {
                    SharedAsset.lock.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                    
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .frame(height: 70)
            
            Divider()
                .frame(maxWidth: .infinity)
                .frame(height: 0.5)
                .background(ColorSet.lineGray)
        })
   
    }
}

//#Preview {
//    SelectPlaylistItem()
//}
