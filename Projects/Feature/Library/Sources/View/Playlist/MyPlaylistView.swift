//
//  MyPlaylistView.swift
//  Feature
//
//  Created by 제이콥 on 11/28/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core
import MusicKit

//라이브러리 첫 화면 - 최근 뮤모리 뮤직 하단 뷰
struct MyPlaylistView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @State var isPresentCreatePlaylistPopup: Bool = false

    var rows: [GridItem] = [
        GridItem(.fixed(215), spacing: 23),
        GridItem(.fixed(215), spacing: 23)
    ]
    
    var body: some View {
        ZStack{
            VStack(spacing: 0, content: {
                
                HStack(spacing: 0){
                    Text("내 플레이리스트")
                        .foregroundStyle(.white)
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                    
                    Spacer()
                    
                    Text("\(currentUserViewModel.playlistViewModel.playlistArray.count < 1 ? 0 : currentUserViewModel.playlistViewModel.playlistArray.count - 1)") //플레이리스트 추가 아이템 제외
                        .foregroundStyle(LibraryColorSet.lightGrayTitle)
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .padding(.trailing, 4)
                        .opacity(currentUserViewModel.playlistViewModel.playlistArray.count > 0 ? 1 : 0) //개수 없을 때는 안 보이게 하기
                    
                    SharedAsset.next.swiftUIImage
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.top, 10)
                .padding(.bottom, 10)
                .onTapGesture {
                    appCoordinator.rootPath.append(MumoryPage.playlistManage)
                    AnalyticsManager.shared.setSelectContentLog(title: "MoveToPlaylistManage")
                }
                
                ScrollView(.horizontal) {
                    LazyHGrid(rows: rows, spacing: getUIScreenBounds().width <= 375 ? 8 : 12, content: {
                        ForEach( 0 ..< currentUserViewModel.playlistViewModel.playlistArray.count, id: \.self) { index in
                            PlaylistItem(playlist: $currentUserViewModel.playlistViewModel.playlistArray[index], itemSize: 81)
                                .onTapGesture {
                                    if currentUserViewModel.playlistViewModel.playlistArray[index].id == "favorite" {
                                        appCoordinator.rootPath.append(MumoryPage.favorite)
                                    }else {
                                        appCoordinator.rootPath.append(MumoryPage.playlistWithIndex(index: index))
                                    }
                                    AnalyticsManager.shared.setSelectContentLog(title: "MyPlaylistViewItem")
                                }
                        }
                        if currentUserViewModel.playlistViewModel.playlistArray.isEmpty {
                            PlaylistSkeletonView(itemSize: 81)
                            PlaylistSkeletonView(itemSize: 81)
                            PlaylistSkeletonView(itemSize: 81)
                            PlaylistSkeletonView(itemSize: 81)
                            PlaylistSkeletonView(itemSize: 81)
                            PlaylistSkeletonView(itemSize: 81)
                        }
                      
                        AddSongItem()
                            .onTapGesture {
                                isPresentCreatePlaylistPopup.toggle()
                            }
                     

                    })
                    .padding(.horizontal, 20)
                }
                .padding(.top, 16)
                .scrollIndicators(.hidden)
                .scrollDisabled(currentUserViewModel.playlistViewModel.playlistArray.isEmpty)
           
            })
            
            Spacer()
            
            
        }
        .fullScreenCover(isPresented: $isPresentCreatePlaylistPopup, content: {
            CreatePlaylistPopupView()
                .background(TransparentBackground())
        })
        
    }
    
    private func getPlayList() async {
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        
        currentUserViewModel.playlistViewModel.playlists.removeAll()
        
        let query = db.collection("User").document(currentUserViewModel.user.uId).collection("Playlist")
            .order(by: "date", descending: false)
        
        guard let snapshot = try? await query.getDocuments() else {
            return
        }
        
        snapshot.documents.forEach { document in
            let data = document.data()
            guard let title = data["title"] as? String else {
                print("no title")
                return
            }
            guard let isPublic = data["isPublic"] as? Bool else {
                print("no private thing")
                return
            }
            guard let songIDs = data["songIds"] as? [String] else {
                print("no id list")
                return
            }
            guard let date = (document.data()["date"] as? FirebaseManager.Timestamp)?.dateValue() else {
                return
            }
            
            let id = document.reference.documentID
            
            withAnimation {
                currentUserViewModel.playlistViewModel.playlistArray.append(SongPlaylist(id: id, title: title, songIDs: songIDs, isPublic: isPublic, createdDate: date))
                fetchSongWithPlaylistID(playlistId: id)
            }
        }
    }

    private func fetchSongWithPlaylistID(playlistId: String) {
        guard let index = currentUserViewModel.playlistViewModel.playlists.firstIndex(where: {$0.id == playlistId}) else {print("no index");return}
        let songIDs = currentUserViewModel.playlistViewModel.playlistArray[index].songIDs
        for id in songIDs {
            Task {
                let musicItemID = MusicItemID(rawValue: id)
                var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
                request.properties = [.genres, .artists]
                guard let response = try? await request.response() else {return}
                guard let song = response.items.first else {return}
                guard let reloadIndex = currentUserViewModel.playlistViewModel.playlistArray.firstIndex(where: {$0.id == playlistId}) else {print("no index2");return}
                DispatchQueue.main.async {
                    currentUserViewModel.playlistViewModel.playlistArray[reloadIndex].songs.append(song)
                }
            }
        }
    }
    
}

