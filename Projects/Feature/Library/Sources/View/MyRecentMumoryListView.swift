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
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @State var isLoading: Bool = false
    @State var songs: [Song] = []
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
                })
                .frame(height: 65)
                .padding(.horizontal, 20)
                
                HStack(alignment: .bottom){
                    Text("\(mumoryDataViewModel.myMumorys.count)곡")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                        .foregroundStyle(ColorSet.subGray)
                    
                    Spacer()
                    
                    PlayAllButton()
                        .onTapGesture {
                            playerViewModel.playAll(title: "나의 최근 뮤모리 뮤직", songs: songs)
                            AnalyticsManager.shared.setSelectContentLog(title: "FavoriteListViewPlayAllButton")
                        }
                }
                .padding(.horizontal, 20)
                .padding(.top, 19)
                
                Divider05()
                    .padding(.top, 15)
                
                ScrollView {
                    LazyVStack(spacing: 0, content: {
                        ForEach(songs, id: \.id) { song in
                            FavoriteSongItem(song: song)
                                .onTapGesture {
                                    playerViewModel.playAll(title: "나의 최근 뮤모리 뮤직", songs: songs, startingItem: song)
                                }
//                                .highPriorityGesture(
//                                    TapGesture()
//                                        .onEnded({ _ in
//                                            playerViewModel.playAll(title: "즐겨찾기 목록", songs: currentUserData.playlistArray[0].songs, startingItem: song)
//                                        })
//                                )
                            
                        }
                        if isLoading {
                            ForEach(0...7, id: \.self) { count in
                                FavoriteSongSkeletonView().id(UUID())
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
                        let songIds = mumoryDataViewModel.myMumorys.map({$0.musicModel.songID.rawValue})
                        let songIdSet: Set = Set(songIds)
                        self.songs = await fetchSongs(songIDs: Array(songIdSet))
                        self.isLoading = false
                    }
                }
        
            })
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            UIRefreshControl.appearance().tintColor = UIColor(white: 0.47, alpha: 1)
            Task {
                self.isLoading = true
                let songIds = mumoryDataViewModel.myMumorys.map({$0.musicModel.songID.rawValue})
                let songIdSet: Set = Set(songIds) //순서가 섞임 음 ,
                self.songs = await fetchSongs(songIDs: Array(songIdSet))
                self.isLoading = false
            }
        }
    }
}
