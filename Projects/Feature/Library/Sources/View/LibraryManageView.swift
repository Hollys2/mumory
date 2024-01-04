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
    @EnvironmentObject var nowPlaySong: NowPlaySong
    @EnvironmentObject var recentSearchObject: RecentSearchObject
    
    //    @EnvironmentObject var setView: SetView
    @StateObject var setView: SetView = SetView()
    @StateObject var manager: LibraryManageModel = LibraryManageModel()
    @State var isPlaying: Bool = true
    
    public init() {
        
    }
    public var body: some View {
        NavigationStack{
            ZStack{
                LibraryColorSet.background.ignoresSafeArea()
                VStack(spacing: 0, content: {
                    if manager.nowPage == .entry{
                        LibraryView()
                            .environmentObject(manager)
                        
                    }else if manager.nowPage == .search {
                        SearchView()
                            .environmentObject(manager)
                    }
                })
                
                //미니 플레이어
                if isPlaying{
                    MiniPlayerView()
                        .environmentObject(nowPlaySong)
                }
                
            }
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $setView.isSearchViewShowing) {
                ArtistView()
            }
            .environmentObject(setView)
            .onAppear(perform: {
                Task{
                    let authRequest = await MusicAuthorization.request() //음악 사용 동의 창-앱 시작할 때
                }
            })
            
        }
        
        
    }
    
    
    
    
}



//#Preview {
//    LibraryView()
//}


