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
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator

    @State var favoritePlaylist: SongPlaylist?
    @State var favoriteSong = []
    @Binding var originPlaylist: SongPlaylist
    private let lineGray = Color(white: 0.31)

    
    init(originPlaylist: Binding<SongPlaylist>) {
        self._originPlaylist = originPlaylist
    }

    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            ScrollView(.vertical) {
                LazyVStack(spacing: 0, content: {
                    if currentUserViewModel.playlistViewModel.playlistArray[0].songs.isEmpty {
                        InitialSettingView(title: "즐겨찾기한 곡이 없습니다\n좋아하는 음악을 즐겨찾기 목록에 추가해보세요", buttonTitle: "추천 음악 보러가기") {
                            let myRandomGenre = currentUserViewModel.playlistViewModel.favoriteGenres[Int.random(in: currentUserViewModel.playlistViewModel.favoriteGenres.indices)]
                            appCoordinator.rootPath.append(MumoryPage.recommendation(genreID: myRandomGenre))
                        }
                        .padding(.top, getUIScreenBounds().height * 0.25)
                    }else {
                        ForEach(currentUserViewModel.playlistViewModel.playlistArray[0].songs, id: \.self) { song in
                            AddMusicItem(song: song, originPlaylist: $originPlaylist)
                        }
                    }

                })
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 90)
            }
            .ignoresSafeArea()
            .scrollIndicators(.hidden)
        }
        .onAppear(perform: {
            Task{
                await currentUserViewModel.playlistViewModel.refreshPlaylist(playlistId: "favorite")
            }
        })
    }
    
}
