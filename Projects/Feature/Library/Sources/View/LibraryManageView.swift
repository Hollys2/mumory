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
    
    @State var isPlaying: Bool = true
    @State var isNeedtoRemoveSafearea: Bool = false
    public init() {
        
    }
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
                case .artist(artist: let artist):
                    ArtistView(artist: artist)
                        .environmentObject(manager)
                        .onAppear(perform: {
                            isNeedtoRemoveSafearea = true
                        })
                        .onDisappear(perform: {
                            isNeedtoRemoveSafearea = false
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
                            isNeedtoRemoveSafearea = true
                        })
                        .onDisappear(perform: {
                            isNeedtoRemoveSafearea = false
                        })
                case .shazam:
                    ShazamView()
                        .environmentObject(manager)
                        .environmentObject(playerManager)
                case .addSong(originPlaylist: let originPlaylist):
                    AddPlaylistSongView(originPlaylist: originPlaylist)
                        .environmentObject(manager)
              
                }
            })
            .padding(.top, isNeedtoRemoveSafearea ? 0 : userManager.topInset)
            
            ColorSet.background
                .frame(maxWidth: .infinity)
                .frame(height: userManager.topInset)
                .opacity(isNeedtoRemoveSafearea ? 0 : 1)

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


