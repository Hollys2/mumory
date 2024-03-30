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
    @EnvironmentObject var appCoordinator: AppCoordinator

    @State var favoritePlaylist: MusicPlaylist?
    @State var favoriteSong = []
    @Binding var originPlaylist: MusicPlaylist
    private let lineGray = Color(white: 0.31)
    
    private let initText = """
                        즐겨찾기한 곡이 없습니다
                        좋아하는 음악을 즐겨찾기 목록에 추가해보세요
                        """
    
    init(originPlaylist: Binding<MusicPlaylist>) {
        self._originPlaylist = originPlaylist
    }

    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            ScrollView(.vertical) {
                LazyVStack(spacing: 0, content: {
                    if currentUserData.playlistArray[0].songs.isEmpty {
                        VStack (spacing: 25){
                            Text(initText)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(ColorSet.subGray)
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                            
                            Text("추천 음악 보러가기")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                                .foregroundStyle(ColorSet.mainPurpleColor)
                                .frame(height: 30)
                                .padding(.horizontal, 10)
                                .background(ColorSet.darkGray)
                                .clipShape(RoundedRectangle(cornerRadius: 30, style: .circular))
                                .onTapGesture {
                                    let myRandomGenre = currentUserData.favoriteGenres[Int.random(in: currentUserData.favoriteGenres.indices)]
                                    appCoordinator.rootPath.append(LibraryPage.recommendation(genreID: myRandomGenre))
                                }
                        }
                        .padding(.top, getUIScreenBounds().height * 0.25)
                    }else {
                        ForEach(currentUserData.playlistArray[0].songs, id: \.self) { song in
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
                await currentUserData.refreshPlaylist(playlistId: "favorite")
            }
        })
    }
    
}

//#Preview {
//    AddSongFromFavoriteView()
//}
