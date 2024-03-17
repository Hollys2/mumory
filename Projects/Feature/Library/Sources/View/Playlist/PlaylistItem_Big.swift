//
//  PlaylistItem.swift
//  Feature
//
//  Created by 제이콥 on 11/28/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core
import MusicKit

//플레이리스트 아이템(플레이리스트 뷰)
struct PlaylistItem_Big: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserData: CurrentUserData
    
    @Binding var playlist: MusicPlaylist
    @Binding var isEditing: Bool
    
    @State var isDeletePupupPresent: Bool = false

    
    var isAddSongItem: Bool
    var emptyGray = Color(red: 0.18, green: 0.18, blue: 0.18)
    var favoriteEditingTitleTextColor = Color(red: 0.6, green: 0.6, blue: 0.6)
    var favoriteEditingSubTextColor = Color(red: 0.45, green: 0.45, blue: 0.45)
    var radius: CGFloat = 10

    init(playlist: Binding<MusicPlaylist>, isAddSongItem: Bool, isEditing: Binding<Bool>) {
        self._playlist = playlist
        self.isAddSongItem = isAddSongItem
        self._isEditing = isEditing
    }

    @State var songs: [Song] = []
    var body: some View {
        ZStack{
            if isAddSongItem {
                if !isEditing {
                    AddSongItem()
                }
            }else{
                VStack(spacing: 0){
                    ZStack(alignment: .bottom){
                        VStack(spacing: 0, content: {
                            HStack(spacing: 0, content: {
                                //1번째 이미지
                                if songs.count < 1 {
                                    Rectangle()
                                        .frame(width: 84, height: 84)
                                        .foregroundStyle(emptyGray)
                                }else{
                                    AsyncImage(url: songs[0].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                                        image
                                            .resizable()
                                            .frame(width: 84, height: 84)
                                    } placeholder: {
                                        Rectangle()
                                            .frame(width: 84, height: 84)
                                            .foregroundStyle(emptyGray)
                                    }
                                }
                                
                                //세로줄(구분선)
                                Rectangle()
                                    .frame(width: 1, height: 84)
                                    .foregroundStyle(ColorSet.background)
                                
                                //2번째 이미지
                                if songs.count < 2{
                                    Rectangle()
                                        .frame(width: 84, height: 84)
                                        .foregroundStyle(emptyGray)
                                }else{
                                    AsyncImage(url: songs[1].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                                        image
                                            .resizable()
                                            .frame(width: 84, height: 84)
                                    } placeholder: {
                                        Rectangle()
                                            .frame(width: 84, height: 84)
                                            .foregroundStyle(emptyGray)
                                    }
                                }
                                
                                
                            })
                            
                            //가로줄(구분선)
                            Rectangle()
                                .frame(width: 169, height: 1)
                                .foregroundStyle(ColorSet.background)
                            
                            HStack(spacing: 0,content: {
                                //3번째 이미지
                                if songs.count < 3 {
                                    Rectangle()
                                        .frame(width: 84, height: 84)
                                        .foregroundStyle(emptyGray)
                                }else{
                                    AsyncImage(url: songs[2].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                                        image
                                            .resizable()
                                            .frame(width: 84, height: 84)
                                    } placeholder: {
                                        Rectangle()
                                            .frame(width: 84, height: 84)
                                            .foregroundStyle(emptyGray)
                                    }
                                }
                                
                                //세로줄 구분선
                                Rectangle()
                                    .frame(width: 1, height: 84)
                                    .foregroundStyle(ColorSet.background)
                                
                                //4번째 이미지
                                if songs.count <  4 {
                                    Rectangle()
                                        .frame(width: 84, height: 84)
                                        .foregroundStyle(emptyGray)
                                }else{
                                    AsyncImage(url: songs[3].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                                        image
                                            .resizable()
                                            .frame(width: 84, height: 84)
                                    } placeholder: {
                                        Rectangle()
                                            .frame(width: 84, height: 84)
                                            .foregroundStyle(emptyGray)
                                    }
                                }
                                
                            })
                        })
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
                        .overlay {
                            SharedAsset.bookmarkWhite.swiftUIImage
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                                .opacity(playlist.id == "favorite" ? 1 : 0)
                            
                            SharedAsset.lockPurple.swiftUIImage
                                .resizable()
                                .frame(width: 23, height: 23)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .opacity(playlist.id == "favorite" ? 0 : playlist.isPublic ? 0 : 1)
                            
                            SharedAsset.deletePlaylist.swiftUIImage
                                .resizable()
                                .frame(width: 23, height: 23)
                                .padding(.horizontal, 9)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                .offset(y: 11)
                                .opacity(playlist.id == "favorite" ? 0 : isEditing ? 1 : 0) //기본 즐겨찾기 목록은 삭제 불가
                                .transition(.opacity)
                                .onTapGesture {
                                    UIView.setAnimationsEnabled(false)
                                    isDeletePupupPresent = true
                                }
                            
                            //즐겨찾기 항목 삭제 불가 나타냄
                            Color.black.opacity(0.4)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
                                .opacity(playlist.id == "favorite" && isEditing ? 1 : 0)
                        }
                        
                        
                    }
                    //삭제하시겠습니까 팝업
                    .fullScreenCover(isPresented: $isDeletePupupPresent, content: {
                        TwoButtonPopupView(title: "해당 플레이리스트를 삭제하시겠습니까?", positiveButtonTitle: "플레이리스트 삭제", positiveAction: {
                            deletePlaylist()
                        })
                        .background(TransparentBackground())
                    })
                    
                    
                    
                    //노래 제목 및 아티스트 이름
                    Text(playlist.title)
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                        .frame(maxWidth: 169, alignment: .leading)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.top, 10)
                        .foregroundStyle(playlist.id == "favorite" && isEditing ? favoriteEditingTitleTextColor : .white)
                    
                    Text("\(playlist.songIDs.count)곡")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundStyle(playlist.id == "favorite" && isEditing ? favoriteEditingSubTextColor : .white)
                        .frame(maxWidth: 169, alignment: .leading)
                        .padding(.top, 5)
                    
                }
                .onTapGesture {
                    appCoordinator.rootPath.append(LibraryPage.playlist(playlist: playlist))
                }
            }
        }
        .onAppear(perform: {
            Task{
                await fetchSongInfo(songIDs: playlist.songIDs)
            }
        })
    }
    
    private func deletePlaylist() {
        let Firebase = FBManager.shared
        let db = Firebase.db
        
        let ref = db.collection("User").document(currentUserData.uid).collection("Playlist").document(playlist.id)
        ref.delete()
        
        withAnimation {
            currentUserData.playlistArray.removeAll(where: {$0.id == playlist.id})
        }
    }
    
    private func fetchSongInfo(songIDs: [String]) async {
        for id in songIDs {
            let musicItemID = MusicItemID(rawValue: id)
            var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
            request.properties = [.genres, .artists]
            
            do {
                let response = try await request.response()
                
                guard let song = response.items.first else {
                    print("no song")
                    continue
                }
                
                self.songs.append(song)
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
}

//새 플레이리스트 아이템
private struct AddSongItem: View {
    var emptyGray = Color(red: 0.18, green: 0.18, blue: 0.18)
    @State var isPresent: Bool = false
    var body: some View {
        VStack(spacing: 0, content: {
            RoundedRectangle(cornerRadius: 10, style: .circular)
                .frame(width: 169, height: 169)
                .foregroundStyle(emptyGray)
                .overlay {
                    SharedAsset.addPurple.swiftUIImage
                        .resizable()
                        .frame(width: 53, height: 53)
                }
            
            Text("새 플레이리스트")
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .foregroundStyle(ColorSet.mainPurpleColor)
                .frame(width: 169, alignment: .leading)
                .padding(.top, 10)
            
            Spacer()
            
        })
        .frame(height: 220)
        .onTapGesture {
            isPresent = true
        }
        .fullScreenCover(isPresented: $isPresent, content: {
            CreatePlaylistPopupView()
                .background(TransparentBackground())
        })
    }
}
