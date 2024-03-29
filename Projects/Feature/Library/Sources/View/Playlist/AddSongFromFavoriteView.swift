//
//  AddSongOfFavoriteView.swift
//  Feature
//
//  Created by 제이콥 on 2/14/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core

struct AddSongFromFavoriteView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @State var favoritePlaylist: MusicPlaylist?
    @State var favoriteSong = []
    @Binding var originPlaylist: MusicPlaylist
    private let lineGray = Color(white: 0.31)
    
    init(originPlaylist: Binding<MusicPlaylist>) {
        self._originPlaylist = originPlaylist
    }

    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            ScrollView(.vertical) {
                LazyVStack(spacing: 0, content: {
                    ForEach(currentUserData.playlistArray[0].songs, id: \.self) { song in
                        AddMusicItem(song: song, originPlaylist: $originPlaylist)
                    }

                })
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 90)
            }
            .ignoresSafeArea()
        }
        .onAppear(perform: {
            Task{
                await currentUserData.refreshPlaylist(playlistId: "favorite")
            }
        })
    }
    
}

//#Preview {
//    AddSongFromFavoriteView()
//}
