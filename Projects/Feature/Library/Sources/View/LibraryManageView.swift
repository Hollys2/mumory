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
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var manager: LibraryManageModel
    @StateObject var snackbarManager: SnackBarViewModel = SnackBarViewModel()
    
    @State var isPlaying: Bool = true
    @State var hasToRemoveSafeArea: Bool = false
    @State var isDragging: Bool = false
    @GestureState var dragState = CGSize.zero
    public init() {}
    public var body: some View {
        ZStack(alignment:.top){
            LibraryColorSet.background.ignoresSafeArea()
            
            ForEach(0 ..< manager.stack.count, id: \.self) { index in
                
                VStack(spacing: 0, content: {
                    switch(manager.stack[index]){
                    case .entry:
                        LibraryView(isTapMyMusic: true)
                        
                    case .search(term: let term):
                        SearchView(term: term)
                        
                    case .artist(artist: let artist):
                        ArtistView(artist: artist)
                            .onAppear(perform: {
                                hasToRemoveSafeArea = true
                            })
                            .onDisappear(perform: {
                                hasToRemoveSafeArea = false
                            })
                        
                    case .playlistManage:
                        PlaylistManageView()
                        
                    case .chart:
                        ChartListView()
                        
                    case .playlist(playlist: let playlist):
                        PlaylistView(playlist: playlist)
                            .onAppear(perform: {
                                hasToRemoveSafeArea = true
                            })
                            .onDisappear(perform: {
                                hasToRemoveSafeArea = false
                            })
                        
                    case .shazam:
                        ShazamView()
                        
                    case .addSong(originPlaylist: let originPlaylist):
                        AddPlaylistSongView(originPlaylist: originPlaylist)
                            .environmentObject(snackbarManager)
                        
                    case .play:
                        NowPlayingView()
                        
                    case .saveToPlaylist(songs: let songs):
                        SaveToPlaylistView(songs: songs)
                            .environmentObject(snackbarManager)
                        
                    case .recommendation(genreID: let genreID):
                        RecommendationListView(genreID: genreID)
                            .onAppear(perform: {
                                hasToRemoveSafeArea = true
                            })
                            .onDisappear(perform: {
                                hasToRemoveSafeArea = false
                            })
                    }
                })
                .padding(.top,  currentUserData.topInset)
                .offset(x: isCurrentPage(index: index) ? manager.xOffset : isPreviousPage(index: index) ? ((70/getUIScreenBounds().width) * manager.xOffset) - 70 : 0)
//                .simultaneousGesture(drag)
                .transition(.move(edge: .trailing))
            }
            
            
            
            ColorSet.background
                .frame(maxWidth: .infinity)
                .frame(height: currentUserData.topInset)
                .opacity(hasToRemoveSafeArea ? 0 : 1)
            
            //스낵바 - 추후 수정 예정
            HStack {
                if snackbarManager.status == .success {
                    HStack(spacing: 0) {
                        HStack(spacing: 0, content: {
                            Text("플레이리스트")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                            
                            Text("\"\(snackbarManager.title)")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            Text("\"")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                            
                            Text("에 추가되었습니다.")
                                .fixedSize()
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                        })
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        
                        Text("실행취소")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                            .padding(.leading, 18)
                            .foregroundStyle(ColorSet.mainPurpleColor)
                    }
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                }else if snackbarManager.status == .failure{
                    HStack(spacing: 0) {
                        Text("이미 플레이리스트")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                        
                        Text("\"\(snackbarManager.title)")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Text("\"")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                        
                        Text("에 존재합니다.")
                            .fixedSize()
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                    }
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
            }
            .ignoresSafeArea()
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .padding(.horizontal, 20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
            .padding(.horizontal, 15)
            .offset(y: snackbarManager.isPresent ? 53 : -50)
            .opacity(snackbarManager.isPresent ? 1 : 0)
            
        }
        .onAppear(perform: {
            Task{
                await MusicAuthorization.request() //음악 사용 동의 창-앱 시작할 때
            }
        })
        
    }
    
    private func isCurrentPage(index: Int) -> Bool {
        if index == 0 {
            return false
        }else if index == manager.stack.count - 1 {
            return true
        }else {
            return false
        }
    }
    
    private func isPreviousPage(index: Int) -> Bool {
        let length = manager.stack.count
        if length > 1 && index == length - 2 {
            return true
        }else {
            return false
        }
    }
    
//    var drag: some Gesture {
//        DragGesture()
//            .onChanged({ drag in
//                if drag.startLocation.x > 20{
//                    return
//                }
//                isDragging = true
//                DispatchQueue.main.async {
//                    manager.xOffset = drag.location.x
//                }
//            })
//            .onEnded({ drag in
//                isDragging = false
//                if manager.stack.count < 1 || drag.startLocation.x > 20{
//                    return
//                }
//
//                if drag.velocity.width > 1000.0{
//                    DispatchQueue.main.async {
//                        withAnimation(.spring(duration: 0.2)) {
//                            manager.xOffset = getUIScreenBounds().width
//                        }
//                    }
//                    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in
//                        _ = manager.stack.popLast()
//                        manager.xOffset = 0
//                    }
//
//                }else if drag.location.x > getUIScreenBounds().width/2 {
//                    DispatchQueue.main.async {
//                        withAnimation(.spring(duration: 0.1)) {
//                            manager.xOffset = getUIScreenBounds().width
//                        }
//                    }
//                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
//                        _ = manager.stack.popLast()
//                        manager.xOffset = 0
//                    }
//                }else{
//                    DispatchQueue.main.async {
//                        withAnimation(.spring(duration: 0.2)) {
//                            manager.xOffset = 0
//                        }
//                    }
//                }
//            })
//    }
    
    
}
