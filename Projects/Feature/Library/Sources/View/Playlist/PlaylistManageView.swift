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
    @EnvironmentObject var userManager: UserViewModel
    @EnvironmentObject var manager: LibraryManageModel
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
                                manager.pop()
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
                                withAnimation {
                                    isEditing = false
                                    editButtonHeight = nil
                                }
                            }
                    }else{
                        
                        SharedAsset.add.swiftUIImage
                            .resizable()
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                UIView.setAnimationsEnabled(true)
                                isShowCreatePopup = true
                            }
                    }
                    
                }
                .padding(.horizontal, 20)
                .frame(height: 40)
                .fullScreenCover(isPresented: $isShowCreatePopup, content: {
                    CreatePlaylistPopupView(isCreatePlaylistCompleted: $isCreatePlaylistCompleted)
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
                    }
                
                
                //플레이리스트 스크롤뷰
                ScrollView(.vertical) {
                    LazyVGrid(columns: cols, spacing: 30, content: {
                        ForEach(userManager.playlistArray, id: \.title) { playlist in
                            PlaylistItem_Big(playlist: .constant(playlist), isAddSongItem: playlist.isAddItme, isEditing: $isEditing)
                                .frame(minWidth: 170, minHeight: 215)
                                .environmentObject(manager)
                        }
                    })
                }
                .padding(.top, isEditing ? 0 : 10)
                .scrollIndicators(.hidden)
                
                Spacer()
            }

        }
  
    }
    
    
    private func fetchSongInfo(songIDs: [String]) async throws -> [Song] {
        var songs: [Song] = []
        
        for id in songIDs{
            let musicItemID = MusicItemID(rawValue: id)
            let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
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
        .padding(.vertical, 8)
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .circular)
                .stroke(ColorSet.subGray, lineWidth: 1)
        }
    }
}

struct CompleteButton: View {
    var body: some View {
        Text("완료")
            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
            .foregroundStyle(Color.white)
    }
}

// 투명 fullScreenCover
//extension View {
//    func transparentFullScreenCover<Content: View>(isPresented: Binding<Bool>, content: @escaping () -> Content) -> some View {
//        fullScreenCover(isPresented: isPresented) {
//            ZStack {
//                content()
//            }
//            .background(TransparentBackground())
//        }
//    }
//}
