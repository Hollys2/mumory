//
//  LibraryView.swift
//  Feature
//
//  Created by 제이콥 on 11/19/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit
import Core

public struct LibraryManageView: View {
    @State private var path = NavigationPath()
    @EnvironmentObject var playerManager: PlayerViewModel
    @EnvironmentObject var recentSearchObject: RecentSearchObject
    @EnvironmentObject var userManager: UserViewModel
    @StateObject var manager: LibraryManageModel = LibraryManageModel()
    @StateObject var snackbarManager: SnackBarViewModel = SnackBarViewModel()
    
    @State var isPlaying: Bool = true
    @State var hasToRemoveSafeArea: Bool = false
    public init() {}
    public var body: some View {
        ZStack(alignment:.top){
            LibraryColorSet.background.ignoresSafeArea()
            VStack(spacing: 0, content: {
                
                
                
                switch(manager.page){
                case .entry(.myMusic):
                    LibraryView(isTapMyMusic: true)
                        .environmentObject(manager)
                case .entry(.recomendation):
                    LibraryView(isTapMyMusic: false)
                        .environmentObject(manager)
                case .search(term: let term):
                    SearchView(term: term)
                        .environmentObject(manager)
                case .artist(.fromArtist(data: let artist)):
                    ArtistView(artist: artist)
                        .environmentObject(manager)
                        .onAppear(perform: {
                            hasToRemoveSafeArea = true
                        })
                        .onDisappear(perform: {
                            hasToRemoveSafeArea = false
                        })
                case .artist(.fromSong(data: let song)):
                    ArtistOfSongView(song: song)
                        .environmentObject(manager)
                        .onAppear(perform: {
                            hasToRemoveSafeArea = true
                        })
                        .onDisappear(perform: {
                            hasToRemoveSafeArea = false
                        })
                case .playlistManage:
                    PlaylistManageView()
                        .environmentObject(manager)
                case .chart:
                    ChartListView()
                        .environmentObject(manager)
                        .environmentObject(playerManager)
                case .playlist(playlist: let playlist):
                    PlaylistView(playlist: playlist)
                        .environmentObject(manager)
                        .onAppear(perform: {
                            hasToRemoveSafeArea = true
                        })
                        .onDisappear(perform: {
                            hasToRemoveSafeArea = false
                        })
                case .shazam:
                    ShazamView()
                        .environmentObject(manager)
                        .environmentObject(playerManager)
                case .addSong(originPlaylist: let originPlaylist):
                    AddPlaylistSongView(originPlaylist: originPlaylist)
                        .environmentObject(manager)
                        .environmentObject(snackbarManager)
                case .play:
                    NowPlayingView()
                        .environmentObject(manager)
                case .saveToPlaylist(song: let song):
                    SaveToPlaylistView(song: song)
                        .environmentObject(manager)
                        .environmentObject(snackbarManager)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
                case .recommendation(genreID: let genreID):
                    RecommendationListView(genreID: genreID)
                        .environmentObject(manager) 
                        .onAppear(perform: {
                            hasToRemoveSafeArea = true
                        })
                        .onDisappear(perform: {
                            hasToRemoveSafeArea = false
                        })
                }
            })
            .padding(.top, hasToRemoveSafeArea ? 0 : userManager.topInset)
            
            ColorSet.background
                .frame(maxWidth: .infinity)
                .frame(height: userManager.topInset)
                .opacity(hasToRemoveSafeArea ? 0 : 1)
            
            VStack {
                Spacer()
                HStack {
                    if snackbarManager.status == .success {
                        HStack(spacing: 0) {
                            Text("플레이리스트")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))

                            Text("\"\(snackbarManager.title)\"")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                                .truncationMode(.tail)

                            Text("에 추가되었습니다.")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                        }
                        .lineLimit(1)
                    }else if snackbarManager.status == .failure{
                        HStack(spacing: 0) {
                            Text("이미 플레이리스트")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))

                            Text("\"\(snackbarManager.title)\"")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                                .lineLimit(1)
                                .truncationMode(.tail)

                            Text("에 존재합니다.")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                        }
                        .lineLimit(1)
                        
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 41)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
                .padding(.horizontal, 20)
                .padding(.bottom, userManager.bottomInset + 2)
            }
            .offset(y: snackbarManager.isPresent ? 0 : 100)

        }
        .onAppear(perform: {
            Task{
                await MusicAuthorization.request() //음악 사용 동의 창-앱 시작할 때
            }
        })
        
        
    }
    
    
    
    
}



//#Preview {
//    LibraryView()
//}


