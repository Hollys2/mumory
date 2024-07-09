//
//  MyRecentMumoryListView.swift
//  Feature
//
//  Created by 제이콥 on 3/21/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct MyRecentMumoryListView: View {
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @State var isPresentBottomSheet: Bool = false
    @State var isLoading: Bool = true
    @State var songs: [Song] = []
    @State var songIds: [String] = []
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            VStack(spacing: 0, content: {
                //상단바
                HStack(content: {
                    SharedAsset.back.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            appCoordinator.rootPath.removeLast()
                        }
                    Spacer()
                    Text("나의 최근 뮤모리 뮤직")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundStyle(.white)
                    Spacer()
                    SharedAsset.menuWhite.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            UIView.setAnimationsEnabled(false)
                            isPresentBottomSheet = true
                        }
                })
                .frame(height: 65)
                .padding(.horizontal, 20)
                
                HStack(alignment: .bottom){
                    Text("\(songIds.count)곡")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                        .foregroundStyle(ColorSet.subGray)
                    
                    Spacer()
                    
                    PlayAllButton()
                        .onTapGesture {
                            guard isLoading == false else {return}
                            playerViewModel.playAll(title: "나의 최근 뮤모리 뮤직", songs: songs)
                            AnalyticsManager.shared.setSelectContentLog(title: "FavoriteListViewPlayAllButton")
                        }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Divider05()
                    .padding(.top, 15)
                
                if songs.isEmpty && !isLoading {
                    InitialSettingView(title: "나의 뮤모리를 기록하고\n음악 리스트를 채워보세요!", buttonTitle: "뮤모리 기록하러 가기") {
                        playerViewModel.setLibraryPlayerVisibility(isShown: false, moveToBottom: true)
                        withAnimation(Animation.easeInOut(duration: 3)) {
                            appCoordinator.isCreateMumorySheetShown = true
                            appCoordinator.offsetY = CGFloat.zero
                        }
                    }
                    .padding(.top, getUIScreenBounds().height * 0.25)
                }
                
                ScrollView {
                    LazyVStack(spacing: 0, content: {
                        if isLoading {
                            ForEach(0...7, id: \.self) { count in
                                FavoriteSongSkeletonView().id(UUID())
                            }
                        }else {
                            ForEach(songs, id: \.id) { song in
                                SongListBigItem(song: song, type: .recentMumory)
                                    .onTapGesture {
                                        let tappedSong = song
                                        playerViewModel.playAll(title: "나의 최근 뮤모리 뮤직", songs: songs, startingItem: tappedSong)
                                    }
                            }
                        }
                        
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 90)
                    })
                }
                .refreshable {
                    Task {
                        self.isLoading = true
                        
                        var testSongIds: [String] = []
                        for mumory in mumoryDataViewModel.myMumorys {
                            let songId = mumory.song.songId
                            if !testSongIds.contains(songId) {
                                testSongIds.append(mumory.song.songId)
                            }
                        }
                        self.songIds = testSongIds
                        self.songs = await fetchSongs(songIDs: testSongIds)
                        
                        self.isLoading = false
                    }
                }
                .scrollIndicators(.hidden)
            })
            
//            CreateMumoryBottomSheetView(isSheetShown: $appCoordinator.isCreateMumorySheetShown)
//                .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            UIRefreshControl.appearance().tintColor = UIColor(white: 0.47, alpha: 1)
            playerViewModel.setLibraryPlayerVisibility(isShown: !appCoordinator.isCreateMumorySheetShown, moveToBottom: true)
            Task {
                self.isLoading = true
                
                var testSongIds: [String] = []
                for mumory in mumoryDataViewModel.myMumorys {
                    let songId = mumory.song.songId
                    if !testSongIds.contains(songId) {
                        testSongIds.append(mumory.song.songId)
                    }
                }
                self.songIds = testSongIds
                self.songs = await fetchSongs(songIDs: testSongIds)
                
                self.isLoading = false
            }
        }
        .fullScreenCover(isPresented: $isPresentBottomSheet) {
            BottomSheetDarkGrayWrapper(isPresent: $isPresentBottomSheet) {
                BottomSheetItem(image: SharedAsset.report.swiftUIImage, title: "신고")
                    .onTapGesture {
                        isPresentBottomSheet = false
                        appCoordinator.rootPath.append(MumoryPage.report)
                    }
            }
            .background(TransparentBackground())
        }
    }
}
