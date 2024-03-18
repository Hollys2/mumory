//
//  FavoriteListView.swift
//  Feature
//
//  Created by 제이콥 on 3/18/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct FavoriteListView: View {
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State var songs: [Song] = []
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            VStack(spacing: 0, content: {
                HStack(content: {
                    SharedAsset.back.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            appCoordinator.rootPath.removeLast()
                        }
                    Spacer()
                    Text("즐겨찾기 목록")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundStyle(.white)
                    Spacer()
                    SharedAsset.menuWhite.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                })
                .frame(height: 40)
                .padding(.horizontal, 20)
                
                HStack(alignment: .bottom){
                    Text("\(playerViewModel.favoriteSongIds.count)곡")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                        .foregroundStyle(ColorSet.subGray)
                    Spacer()
                    PlayAllButton()
                }
                .padding(.horizontal, 20)
                .padding(.top, 19)
                
                Divider()
                    .frame(maxWidth: .infinity)
                    .frame(height: 0.5)
                    .background(ColorSet.subGray)
                    .padding(.top, 15)
                
                ScrollView {
                    LazyVStack(spacing: 0, content: {
                        ForEach(songs, id: \.id) { song in
                            FavoriteSongItem(song: song, list: $songs)
                        }
                    })
                }
        
            })
        }
        .onAppear {
            fetchSongInfo(songIDs: playerViewModel.favoriteSongIds)
        }
    }
    
    private func fetchSongInfo(songIDs: [String]){
        self.songs = []
        
        for id in songIDs {
            Task {
                let musicItemID = MusicItemID(rawValue: id)
                var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
                request.properties = [.genres, .artists]

                guard let response = try? await request.response() else {
                    return
                }
                guard let song = response.items.first else {
                    print("no song")
                    return
                }
                self.songs.append(song)
            }
        }
        
    }
}

struct FavoriteSongItem: View {
    let song: Song
    @Binding var list: [Song]
    init(song: Song, list: Binding<[Song]>) {
        self.song = song
        self._list = list
    }
    @State var bookmark: Image = SharedAsset.bookmarkFilled.swiftUIImage
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
    
    var body: some View {
        VStack(spacing: 0, content: {
            HStack(spacing: 0, content: {
                AsyncImage(url: song.artwork?.url(width: 200, height: 200)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(ColorSet.darkGray)
                }
                .frame(width: 57, height: 57)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
                .padding(.trailing, 16)
                
                VStack(spacing: 0, content: {
                    Text(song.title)
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(song.artistName)
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundStyle(Color(white: 0.72))
                        .frame(maxWidth: .infinity, alignment: .leading)
                })
                .padding(.trailing, 27)
                
                bookmark
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 20)
                    .onTapGesture {
                        bookmark = SharedAsset.bookmark.swiftUIImage
                        playerViewModel.removeFromFavorite(uid: currentUserData.uId, songId: song.id.rawValue)
                        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in
                            withAnimation {
                                list.removeAll(where: {$0 == song})
                            }
                        }
                    }
                
                SharedAsset.menu.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            })
            .padding(.horizontal, 20)
            .background(ColorSet.background)
            
            Divider()
                .frame(maxWidth: .infinity)
                .frame(height: 0.5)
                .background(ColorSet.subGray)
                .padding(.top, 15)
        })
        .frame(height: 95)
  
  
        
        

    }
    

}
