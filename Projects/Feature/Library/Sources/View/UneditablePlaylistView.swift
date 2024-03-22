//
//  UneditablePlaylistView.swift
//  Feature
//
//  Created by 제이콥 on 3/19/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct UneditablePlaylistView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerManager: PlayerViewModel
    
    @State var offset: CGPoint = .zero
    @State var isBottomSheetPresent: Bool = false
//    @State var songs: [Song] = []
    @Binding var playlist: MusicPlaylist
    @State var isCompletedGetSongs: Bool = false
            
    init(playlist: Binding<MusicPlaylist>){
        self._playlist = playlist
    }
    
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()

            //이미지
            PlaylistImageTest(playlist: $playlist)
                .offset(y: offset.y < -currentUserData.topInset ? -(offset.y+currentUserData.topInset) : 0)
                .overlay {
                    LinearGradient(colors: [ColorSet.background.opacity(0.8), Color.clear], startPoint: .top, endPoint: .init(x: 0.5, y: 0.3))
                    ColorSet.background.opacity(offset.y/(getUIScreenBounds().width-50.0))
                }
        
            
            
            SimpleScrollView(contentOffset: $offset) {
                
                VStack(spacing: 0, content: {
                    SharedAsset.bottomGradient.swiftUIImage
                        .resizable()
                        .frame(width: getUIScreenBounds().width, height: 45)
                        .ignoresSafeArea()
                        .padding(.top, getUIScreenBounds().width - currentUserData.topInset - 30) //사진 세로 길이 - 세이프공간 높이 - 그라데이션과 사진이 겹치는 부분
                    
                    VStack(spacing: 0, content: {
                        Text(playlist.title)
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 24))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .foregroundStyle(.white)
                        
                        ZStack(alignment: .bottom){
                            HStack(alignment: .bottom,spacing: 8, content: {
                                Text("\(playlist.songIDs.count)곡")
                                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                                    .foregroundStyle(ColorSet.subGray)
                                
                                Spacer()
                                
                                PlayAllButton()
                                    .onTapGesture {
                                        playerManager.playAll(title: playlist.title , songs: playlist.songs)
                                        AnalyticsManager.shared.setSelectContentLog(title: "FriendPlaylistViewPlayAllButton")
                                    }
                            })
                            .padding(.bottom, 15)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 74)
                        .padding(.horizontal, 20)
                        
                        //플레이리스트 곡 목록
                        ForEach(playlist.songs, id: \.self) { song in
                            UneditablePlaylistMusicListItem(song: song)
                                .onTapGesture {
                                    playerManager.playNewSong(song: song)
                                }
                            
                            Divider05()
                        }
                        
                        
                        //플레이어에 가려지는 높이만큼 채워주기
                        //노래가 채워지면서 뷰의 크기가 바뀌면 에러발생함. 따라서 맨 처음에는 1000만큼 공간을 채워줘서 안정적으로 데이터를 받아올 수 있도록 함
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(height: playlist.songs.count == 0 ? 1000 : isCompletedGetSongs ? 500 : 1000)
                        
                        
                    })
                    .offset(y: -30) //그라데이션과 겹치도록 위로 30만큼 땡김
                    .frame(width: getUIScreenBounds().width, alignment: .center)
                    .background(ColorSet.background)
                    
                    
                    
                })
                .frame(width: getUIScreenBounds().width)
                .frame(minHeight: getUIScreenBounds().height)
                
            }
            
            
            //상단바 - z축 최상위
            HStack(spacing: 0, content: {
                SharedAsset.backGradient.swiftUIImage
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.leading, 20)
                    .onTapGesture {
                        appCoordinator.rootPath.removeLast()
                    }
                
                Spacer()
                
                SharedAsset.menuGradient.swiftUIImage
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 20)
                    .onTapGesture {
                        UIView.setAnimationsEnabled(false)
                        isBottomSheetPresent = true
                    }
            })
            .frame(height: 50)
            .padding(.top, currentUserData.topInset)

        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
//        .onAppear(perform: {
//            Task {
//                fetchSongInfo(songIDs: playlist.songIDs, songs: $songs)
//            }
//        })
        .fullScreenCover(isPresented: $isBottomSheetPresent, content: {
            BottomSheetDarkGrayWrapper(isPresent: $isBottomSheetPresent)  {
                BottomSheetItem(image: SharedAsset.report.swiftUIImage, title: "신고")
            }
            .background(TransparentBackground())
        })
        
        
        
    }
    
//    private func fetchSongInfo(songIDs: [String], songs: Binding<[Song]>) {
//        if self.songs.count >= 50 {
//            return
//        }
//        self.songs = []
//        for id in songIDs {
//            Task {
//                let musicItemID = MusicItemID(rawValue: id)
//                let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
//                guard let response = try? await request.response() else {
//                    return
//                }
//                guard let song = response.items.first else {
//                    print("no song")
//                    return
//                }
//                DispatchQueue.main.async {
//                    self.songs.append(song)
//                }
//            }
//        }
//        isCompletedGetSongs = true
//    }
}

struct UneditablePlaylistMusicListItem: View {
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
    var song: Song
        @State var isPresentBottomSheet: Bool = false

    init( song: Song) {
        self.song = song
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
            .padding(.trailing, 13)
            
            
            VStack(content: {
                Text(song.title)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(song.artistName)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(LibraryColorSet.lightGrayTitle)
                    .lineLimit(1)
                    .truncationMode(.tail)
            })
                        
            if playerViewModel.favoriteSongIds.contains(song.id.rawValue) {
                SharedAsset.bookmarkFilled.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 23)
                    .onTapGesture {
                        playerViewModel.removeFromFavorite(uid: currentUserData.uId, songId: self.song.id.rawValue)
                        snackBarViewModel.setSnackBar(type: .favorite, status: .delete)
                    }
            }else {
                SharedAsset.bookmark.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 23)
                    .onTapGesture {
                        playerViewModel.addToFavorite(uid: currentUserData.uId, songId: self.song.id.rawValue)
                        snackBarViewModel.setSnackBar(type: .favorite, status: .success)
                    }
            }
            
            SharedAsset.menu.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .onTapGesture {
                    UIView.setAnimationsEnabled(false)
                    isPresentBottomSheet = true
                }
        })
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .fullScreenCover(isPresented: $isPresentBottomSheet, content: {
            BottomSheetWrapper(isPresent: $isPresentBottomSheet) {
                SongBottomSheetView(song: song, types: [.withoutBookmark])
            }
            .background(TransparentBackground())
        })
        
    }
}

public struct PlaylistImageTest: View {
    @State var imageWidth: CGFloat = 0
    @Binding var playlist: MusicPlaylist
    
    let emptyGray = Color(red: 0.18, green: 0.18, blue: 0.18)
    
    init(playlist: Binding<MusicPlaylist>) {
        self._playlist = playlist
    }
    
    public var body: some View {
        VStack(spacing: 0, content: {
            HStack(spacing: 0, content: {
                //1번째 이미지
                if playlist.songs.count < 1 {
                    Rectangle()
                        .frame(width: imageWidth, height: imageWidth)
                        .foregroundStyle(emptyGray)
                }else{
                    AsyncImage(url: playlist.songs[0].artwork?.url(width: 600, height: 600) ?? URL(string: "")) { image in
                        image
                            .resizable()
                            .frame(width: imageWidth, height: imageWidth)
                    } placeholder: {
                        Rectangle()
                            .frame(width: imageWidth, height: imageWidth)
                            .foregroundStyle(emptyGray)
                    }
                }
                
                //세로줄(구분선)
                Rectangle()
                    .frame(width: 1, height: imageWidth)
                    .foregroundStyle(ColorSet.background)
                
                //2번째 이미지
                if playlist.songs.count < 2{
                    Rectangle()
                        .frame(width: imageWidth, height: imageWidth)
                        .foregroundStyle(emptyGray)
                }else{
                    AsyncImage(url: playlist.songs[1].artwork?.url(width: 600, height: 600) ?? URL(string: "")) { image in
                        image
                            .resizable()
                            .frame(width: imageWidth, height: imageWidth)
                    } placeholder: {
                        Rectangle()
                            .frame(width: imageWidth, height: imageWidth)
                            .foregroundStyle(emptyGray)
                    }
                }
                
                
            })
            
            //가로줄(구분선)
            Rectangle()
                .frame(width: getUIScreenBounds().width, height: 1)
                .foregroundStyle(ColorSet.background)
            
            HStack(spacing: 0,content: {
                //3번째 이미지
                if playlist.songs.count < 3 {
                    Rectangle()
                        .frame(width: imageWidth, height: imageWidth)
                        .foregroundStyle(emptyGray)
                }else{
                    AsyncImage(url: playlist.songs[2].artwork?.url(width: 600, height: 600) ?? URL(string: "")) { image in
                        image
                            .resizable()
                            .frame(width: imageWidth, height: imageWidth)
                    } placeholder: {
                        Rectangle()
                            .frame(width: imageWidth, height: imageWidth)
                            .foregroundStyle(emptyGray)
                    }
                }
                
                //세로줄 구분선
                Rectangle()
                    .frame(width: 1, height: imageWidth)
                    .foregroundStyle(ColorSet.background)
                
                //4번째 이미지
                if playlist.songs.count <  4 {
                    Rectangle()
                        .frame(width: imageWidth, height: imageWidth)
                        .foregroundStyle(emptyGray)
                }else{
                    AsyncImage(url: playlist.songs[3].artwork?.url(width: 600, height: 600) ?? URL(string: "")) { image in
                        image
                            .resizable()
                            .frame(width: imageWidth, height: imageWidth)
                    } placeholder: {
                        Rectangle()
                            .frame(width: imageWidth, height: imageWidth)
                            .foregroundStyle(emptyGray)
                    }
                }
                
            })
        })
        .onAppear {
            self.imageWidth = getUIScreenBounds().width/2
        }
        
    }
    
    
}
