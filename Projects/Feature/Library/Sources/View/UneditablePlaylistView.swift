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
    @EnvironmentObject var friendDataViewModel: FriendDataViewModel
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @State var offset: CGPoint = .zero
    @State var isBottomSheetPresent: Bool = false
    @State var isCompletedGetSongs: Bool = false
    @State var searchIndex: Int = 0
    @Binding var playlist: SongPlaylist
    init(playlist: Binding<SongPlaylist>){
        self._playlist = playlist
    }
    let itemHeight: CGFloat = 70
    
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()

            //이미지
            PlaylistImageTest(playlist: $playlist)
                .offset(y: offset.y < -getSafeAreaInsets().top ? -(offset.y+getSafeAreaInsets().top) : 0)
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
                        .padding(.top, getUIScreenBounds().width - getSafeAreaInsets().top - 30) //사진 세로 길이 - 세이프공간 높이 - 그라데이션과 사진이 겹치는 부분
                    
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
                                        playerViewModel.playAll(title: "\(friendDataViewModel.friend.nickname)님의 \(playlist.title)" , songs: playlist.songs)
                                        AnalyticsManager.shared.setSelectContentLog(title: "FriendPlaylistViewPlayAllButton")
                                    }
                            })
                            .padding(.bottom, 15)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 74)
                        .padding(.horizontal, 20)
                        
                        //플레이리스트 곡 목록
                        ForEach(playlist.songs.indices, id: \.self) { index in
                            MusicListItemInUneditablePage(song: playlist.songs[index], type: .normal)
                                .id("\(playlist.songs[index].artistName) \(playlist.songs[index].id.rawValue) \(index)")
                                .onTapGesture {
                                    let tappedSong = playlist.songs[index]
                                    playerViewModel.playAll(title: "\(friendDataViewModel.friend.nickname)님의 \(playlist.title)" , songs: playlist.songs, startingItem: playlist.songs[index])
                                    
                                    searchIndex = playlist.songIDs.count / 20 + 1 //스크롤 이동 시 새로 로드되는 걸 막기 위해서
                                    let startIndex = playlist.songs.count
                                    let endIndex = playlist.songIDs.endIndex
                                    let requestSongIds = Array(playlist.songIDs[startIndex..<endIndex])
                                    Task {
                                        let songs = await fetchSongs(songIDs: requestSongIds)
                                        guard let index = friendDataViewModel.playlistArray.firstIndex(where: {$0.id == playlist.id}) else {return}
                                        friendDataViewModel.playlistArray[index].songs.append(contentsOf: songs)
                                        playerViewModel.setQueue(songs: playlist.songs, startSong: tappedSong)
                                    }
                                }
                            
                            Divider05()
                        }
                        
                        if friendDataViewModel.isPlaylistLoading {
                            SongListSkeletonView(isLineShown: false)
                        }
                        //플레이어에 가려지는 높이만큼 채워주기
                        //노래가 채워지면서 뷰의 크기가 바뀌면 에러발생함. 따라서 맨 처음에는 1000만큼 공간을 채워줘서 안정적으로 데이터를 받아올 수 있도록 함
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(height: friendDataViewModel.isPlaylistLoading ? 1000 : playlist.songs.count < 10 ? 400 : 90)
                    })
                    .offset(y: -30) //그라데이션과 겹치도록 위로 30만큼 땡김
                    .frame(width: getUIScreenBounds().width, alignment: .center)
                    .background(ColorSet.background)
                    
                    
                    
                })
                .frame(width: getUIScreenBounds().width + 1)
                .frame(minHeight: getUIScreenBounds().height)
                
            }
            .refreshAction {
                Task {
                    friendDataViewModel.isPlaylistLoading = true
                    playlist.songs = await requestPlaylistSong(uId: friendDataViewModel.friend.uId, playlistID: playlist.id)
                    friendDataViewModel.isPlaylistLoading = false
                }
            }
            .scrollIndicators(.hidden)
            .onChange(of: offset, perform: { value in
                if offset.y > CGFloat(searchIndex) * itemHeight * 20 {
                    searchIndex += 1
                    DispatchQueue.main.async {
                        Task {
                            let startIndex = searchIndex * 20
                            guard startIndex < playlist.songIDs.endIndex else {return}
                            var endIndex = startIndex + 20
                            endIndex = playlist.songIDs.endIndex < endIndex ? playlist.songIDs.endIndex : endIndex
                            print(endIndex)
                            let requestSongIds = Array(playlist.songIDs[startIndex..<endIndex])
                            self.playlist.songs.append(contentsOf: await fetchSongs(songIDs: requestSongIds))
                        }
                    }
                }
            })
            
            
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
                        isBottomSheetPresent.toggle()
                    }
            })
            .frame(height: 65)
            .padding(.top, getSafeAreaInsets().top)

        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .fullScreenCover(isPresented: $isBottomSheetPresent, content: {
            BottomSheetDarkGrayWrapper(isPresent: $isBottomSheetPresent)  {
                BottomSheetItem(image: SharedAsset.report.swiftUIImage, title: "신고")
                    .onTapGesture {
                        isBottomSheetPresent.toggle()
                        appCoordinator.rootPath.append(MumoryPage.report)
                    }
            }
            .background(TransparentBackground())
        })
        .onAppear {
            playerViewModel.setLibraryPlayerVisibility(isShown: true, moveToBottom: true)
            if playlist.songs.count < playlist.songIDs.count {
                Task {
                    friendDataViewModel.isPlaylistLoading = true
                    let startIndex = 0
                    var endIndex = playlist.songIDs.endIndex < 20 ? playlist.songIDs.endIndex : 20
                    let requestSongIds = Array(playlist.songIDs[startIndex..<endIndex])
                    self.playlist.songs = await fetchSongs(songIDs: requestSongIds)
                    friendDataViewModel.isPlaylistLoading = false
                }
            }
        }
        
        
        
    }
}


public struct PlaylistImageTest: View {
    @State var imageWidth: CGFloat = 0
    @Binding var playlist: SongPlaylist
    
    let emptyGray = Color(red: 0.18, green: 0.18, blue: 0.18)
    
    init(playlist: Binding<SongPlaylist>) {
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

public func requestPlaylistSong(uId: String, playlistID: String) async -> [Song]{
    let db = FirebaseManager.shared.db
    return await withTaskGroup(of: Song?.self) { taskGroup -> [Song] in
        var returnValue:[Song] = []
        let query = db.collection("User").document(uId).collection("Playlist").document(playlistID)
        guard let document = try? await query.getDocument() else {return returnValue}
        guard let data = document.data() else {return returnValue}
        
        var songIds = data["songIds"] as? [String] ?? []
        for id in songIds {
            taskGroup.addTask {
                let musicItemID = MusicItemID(rawValue: id)
                var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
                guard let response = try? await request.response() else {return nil}
                guard let song = response.items.first else {return nil}
                return song
            }
        }
        
        for await value in taskGroup {
            guard let song = value else {continue}
            returnValue.append(song)
        }
        songIds.removeAll { songId in
            return !returnValue.contains(where: {$0.id.rawValue == songId})
        }
        var songs = songIds.map { songId in
            return returnValue.first(where: {$0.id.rawValue == songId})!
        }
        
        return songs
    }
}
