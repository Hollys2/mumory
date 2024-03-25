//
//  PlaylistView.swift
//  Feature
//
//  Created by 제이콥 on 1/4/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit
import FirebaseFirestore

struct PlaylistManageView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @State var isCreatePlaylistCompleted: Bool = false
    @State var playlistArray: [MusicPlaylist] = []
    @State var isShowCreatePopup: Bool = false
    @State var isEditing: Bool = false
    @State var editButtonHeight: CGFloat?
    var cols: [GridItem] = [
        GridItem(.flexible(minimum: 150, maximum: 170), spacing: 12),
        GridItem(.flexible(minimum: 150, maximum: 170), spacing: 12)
    ]
    var body: some View {
        ZStack(alignment: .top){
            LibraryColorSet.background.ignoresSafeArea()
            
            VStack(alignment: .center){
                //상단바
                HStack(){
                    if isEditing{
                        Rectangle()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.clear)
                    }else {
                        SharedAsset.back.swiftUIImage
                            .resizable()
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                appCoordinator.rootPath.removeLast()
                            }
                    }
                    
                    
                    Spacer()
                    
                    Text("내 플레이리스트")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    if isEditing {
                        CompleteButton()
                            .transition(.opacity)
                            .onTapGesture {
                                appCoordinator.isHiddenTabBarWithoutAnimation = false
                                withAnimation {
                                    isEditing = false
                                    appCoordinator.isHiddenTabBar = false
                                    editButtonHeight = nil
                                }
                            }
                    }else{
                        
                        SharedAsset.add.swiftUIImage
                            .resizable()
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                isShowCreatePopup = true
                            }
                    }
                    
                }
                .padding(.horizontal, 20)
                .frame(height: 63)
                .fullScreenCover(isPresented: $isShowCreatePopup, content: {
                    CreatePlaylistPopupView()
                        .background(TransparentBackground())
                })
            
          

                
                
                //편집버튼
                EditButton()
                    .padding(.trailing, 20)
                    .frame(height: editButtonHeight)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .opacity(isEditing ? 0 : 1)
                    .onTapGesture {
                        withAnimation {
                            isEditing = true
                            editButtonHeight = 0
                        }
                        AnalyticsManager.shared.setSelectContentLog(title: "PlaylistManageViewEditButton")
                    }
                
                
                //플레이리스트 스크롤뷰
                ScrollView(.vertical) {
                    LazyVGrid(columns: cols, spacing: 30, content: {
                        ForEach(0 ..< currentUserData.playlistArray.count, id: \.self) { index in
                            PlaylistItem_Big(playlist: $currentUserData.playlistArray[index], isEditing: $isEditing)
                                .frame(minWidth: 170, minHeight: 215)
                            
                        }
                        AddSongItemBig()
                            .opacity(isEditing ? 0 : 1)
                    })
                    
                    Rectangle()
                        .foregroundStyle(Color.clear)
                        .frame(height: 90)
                }
                .padding(.top, isEditing ? 0 : 10)
                .scrollIndicators(.hidden)
                
             
            }

        }
        .onAppear {
            playerViewModel.miniPlayerMoveToBottom = true
            AnalyticsManager.shared.setScreenLog(screenTitle: "PlaylistManageView")
        }
  
    }
    
    
    private func fetchSongInfo(songIDs: [String]) async throws -> [Song] {
        var songs: [Song] = []
        
        for id in songIDs{
            let musicItemID = MusicItemID(rawValue: id)
            var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
            request.properties = [.genres, .artists]
            let response = try await request.response()
            guard let song = response.items.first else {
                throw NSError(domain: "GoogleMapSample", code: 1, userInfo: [NSLocalizedDescriptionKey: "Song not found"])
            }
            songs.append(song)
        }
        
        return songs
    }
}



//#Preview {
//    PlaylistView()
//}

struct EditButton: View {
    var body: some View {
        HStack(spacing: 5, content: {
            SharedAsset.editMumoryDetailMenu.swiftUIImage
                .resizable()
                .frame(width: 12, height: 12)
            
            Text("편집")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundStyle(ColorSet.subGray)
        })
        .padding(.horizontal, 13)
        .frame(height: 33)
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .circular)
                .stroke(ColorSet.subGray, lineWidth: 1)
        }
    }
}

struct CompleteButton: View {
    var body: some View {
        Text("완료")
            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
            .foregroundStyle(Color.white)
    }
}

