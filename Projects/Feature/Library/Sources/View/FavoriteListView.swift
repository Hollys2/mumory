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
    @EnvironmentObject var currentUserData: CurrentUserData
    @State var isLoading: Bool = false
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
                        .onTapGesture {
                            playerViewModel.playAll(title: "즐겨찾기 목록", songs: currentUserData.playlistArray[0].songs)
                            AnalyticsManager.shared.setSelectContentLog(title: "FavoriteListViewPlayAllButton")
                        }
                }
                .padding(.horizontal, 20)
                .padding(.top, 19)
                
                Divider05()
                    .padding(.top, 15)
                
                ScrollView {
                    LazyVStack(spacing: 0, content: {
                        ForEach(currentUserData.playlistArray[0].songs, id: \.id) { song in
                            FavoriteSongItem(song: song)
                        }
                        if isLoading {
                            ForEach(0...7, id: \.self) { count in
                                FavoriteSongSkeletonView().id(UUID())
                            }
                        }
                    })
                }
                .refreshable {
                    Task {
                        self.isLoading = true
                        currentUserData.playlistArray[0].songs = await currentUserData.requestMorePlaylistSong(playlistID: "favorite")
                        self.isLoading = false
                    }
                }
        
            })
        }
        .onAppear {
            playerViewModel.miniPlayerMoveToBottom = true
            UIRefreshControl.appearance().tintColor = UIColor(white: 0.47, alpha: 1)
            Task {
                self.isLoading = true
                currentUserData.playlistArray[0].songs = await currentUserData.requestMorePlaylistSong(playlistID: "favorite")
                self.isLoading = false
            }
        }
    }

}

struct FavoriteSongItem: View {
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    let song: Song
    init(song: Song) {
        self.song = song
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
                        .fill(ColorSet.skeleton)
                }
                .frame(width: 57, height: 57)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
                .padding(.trailing, 16)
                
                VStack(spacing: 4, content: {
                    Text(song.title)
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Text(song.artistName)
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundStyle(Color(white: 0.72))
                        .frame(maxWidth: .infinity, alignment: .leading)
                })
                .padding(.trailing, 27)
                
                if playerViewModel.favoriteSongIds.contains(song.id.rawValue) {
                    SharedAsset.bookmarkFilled.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding(.trailing, 20)
                        .onTapGesture {
                            playerViewModel.removeFromFavorite(uid: currentUserData.uId, songId: self.song.id.rawValue)
                            snackBarViewModel.setSnackBar(type: .favorite, status: .delete)
                        }
                }else {
                    SharedAsset.bookmark.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding(.trailing, 20)
                        .onTapGesture {
                            playerViewModel.addToFavorite(uid: currentUserData.uId, songId: self.song.id.rawValue)
                            snackBarViewModel.setSnackBar(type: .favorite, status: .success)
                        }
                }
                
                SharedAsset.menu.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            })
            .padding(.horizontal, 20)
            .background(ColorSet.background)
            .frame(height: 95)
            
        })
    }
}

struct FavoriteSongSkeletonView: View {
    @State var startAnimation: Bool = false
    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 5, style: .circular)
                .fill(startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                .frame(width: 57, height: 57)
                .padding(.trailing, 16)

            VStack(alignment: .leading, spacing: 7) {
                RoundedRectangle(cornerRadius: 5, style: .circular)
                    .fill(startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                    .frame(width: 91, height: 15)
                
                RoundedRectangle(cornerRadius: 5, style: .circular)
                    .fill(startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                    .frame(width: 71, height: 11)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(height: 95)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: startAnimation)
        .onAppear {
            startAnimation.toggle()
        }
    }
}
