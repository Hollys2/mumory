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
    @EnvironmentObject var currentUserData: CurrentUserData
    @State var spacing: CGFloat = 0
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
                    
                    Text("\(currentUserData.playlistArray.count)") //플레이리스트 추가 아이템 제외
                        .foregroundStyle(LibraryColorSet.lightGrayTitle)
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .padding(.trailing, 4)
                        .opacity(currentUserData.playlistArray.count > 0 ? 1 : 0) //개수 없을 때는 안 보이게 하기
                    
                    SharedAsset.next.swiftUIImage
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.top, 10)
                .padding(.bottom, 10)
                .onTapGesture {
                    appCoordinator.rootPath.append(LibraryPage.playlistManage)
                    AnalyticsManager.shared.setSelectContentLog(title: "MoveToPlaylistManage")
                }
                
                ScrollView(.horizontal) {
                    LazyHGrid(rows: rows,spacing: spacing, content: {
                        ForEach( 0 ..< currentUserData.playlistArray.count, id: \.self) { index in
                            PlaylistItem(playlist: $currentUserData.playlistArray[index], itemSize: 81)
                                .onTapGesture {
                                    if currentUserData.playlistArray[index].id == "favorite" {
                                        appCoordinator.rootPath.append(LibraryPage.favorite)
                                    }else {
                                        appCoordinator.rootPath.append(LibraryPage.playlistWithIndex(index: index))
                                    }
                                    AnalyticsManager.shared.setSelectContentLog(title: "MyPlaylistViewItem")
                                }
                        }
                        AddSongItem()

                    })
                    .padding(.horizontal, 20)
                }
                .padding(.top, 16)
                .scrollIndicators(.hidden)
            })
            
            Spacer()
            
            
        }
        .onAppear(perform: {
            spacing = getUIScreenBounds().width <= 375 ? 8 : 12
        })
        
    }
    
    private func getPlayList() async {
        let Firebase = FBManager.shared
        let db = Firebase.db
        
        currentUserData.playlistArray.removeAll()
        
        let query = db.collection("User").document(currentUserData.uId).collection("Playlist")
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
            let id = document.reference.documentID
            
            withAnimation {
                currentUserData.playlistArray.append(MusicPlaylist(id: id, title: title, songIDs: songIDs, isPublic: isPublic))
                fetchSongWithPlaylistID(playlistId: id)
            }
        }
    }

    private func fetchSongWithPlaylistID(playlistId: String) {
        guard let index = currentUserData.playlistArray.firstIndex(where: {$0.id == playlistId}) else {print("no index");return}
        let songIDs = currentUserData.playlistArray[index].songIDs
        for id in songIDs {
            Task {
                let musicItemID = MusicItemID(rawValue: id)
                var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
                request.properties = [.genres, .artists]
                guard let response = try? await request.response() else {return}
                guard let song = response.items.first else {return}
                guard let reloadIndex = currentUserData.playlistArray.firstIndex(where: {$0.id == playlistId}) else {print("no index2");return}
                DispatchQueue.main.async {
                    currentUserData.playlistArray[reloadIndex].songs.append(song)
                }
            }
        }
    }
    
}







//#Preview {
//    MyPlaylistView()
//}
