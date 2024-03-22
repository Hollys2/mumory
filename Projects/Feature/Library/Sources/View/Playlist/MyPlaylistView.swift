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
<<<<<<< HEAD
                    LazyHGrid(rows: rows,spacing: spacing, content: {
=======
                    LazyHGrid(rows: rows,spacing: 12, content: {
<<<<<<< HEAD
>>>>>>> 5e1e803 (edit playlist view)
=======
>>>>>>> f24e9fe (edit playlist view)
>>>>>>> dd89775 (edit playlist view)
                        ForEach( 0 ..< currentUserData.playlistArray.count, id: \.self) { index in
                            PlaylistItem(playlist: $currentUserData.playlistArray[index], itemSize: 81)
                                .onTapGesture {
                                    if currentUserData.playlistArray[index].id == "favorite" {
                                        appCoordinator.rootPath.append(LibraryPage.favorite)
                                    }else {
                                        appCoordinator.rootPath.append(LibraryPage.playlist(playlist: $currentUserData.playlistArray[index]))
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
<<<<<<< HEAD
            spacing = getUIScreenBounds().width <= 375 ? 8 : 12
=======
<<<<<<< HEAD
>>>>>>> 5e1e803 (edit playlist view)
=======
>>>>>>> f24e9fe (edit playlist view)
>>>>>>> dd89775 (edit playlist view)
            currentUserData.playlistArray.removeAll()
            Task {
                await getPlayList()
            }
        })
        
    }
    
    func getPlayList() async {
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
<<<<<<< HEAD
<<<<<<< HEAD
//                fetchSongWithPlaylistIndex(index: currentUserData.playlistArray.count-1)
=======
                fetchSongWithPlaylistIndex(index: currentUserData.playlistArray.count-1)
>>>>>>> 5e1e803 (edit playlist view)
=======
//                fetchSongWithPlaylistIndex(index: currentUserData.playlistArray.count-1)
>>>>>>> 805e3e0 (edit UI things and working on now playing view text animation)
            }
            

        }
    }
    
    private func fetchSongInfo(songIDs: [String]) async -> [Song] {
        var songs: [Song] = []
        
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
                
                songs.append(song)
            } catch {
                print("Error: \(error)")
            }
        }
        
        return songs
    }
    
    private func fetchSongWithPlaylistIndex(index: Int) {
        print("playlist \(index)")
        let songIDs = currentUserData.playlistArray[index].songIDs
        for id in songIDs {
            Task {
                let musicItemID = MusicItemID(rawValue: id)
                var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
                request.properties = [.genres, .artists]
                guard let response = try? await request.response() else {return}
                guard let song = response.items.first else {return}
                DispatchQueue.main.async {
                    currentUserData.playlistArray[index].songs.append(song)
                }
                
            }
        }
    }
    
    private func fetchPlaylistSong(playlist: Binding<MusicPlaylist>) {
        for id in playlist.songIDs.wrappedValue {
            Task {
                let musicItemID = MusicItemID(rawValue: id)
                var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
                request.properties = [.genres, .artists]
                guard let response = try? await request.response() else {return}
                guard let song = response.items.first else {return}
                DispatchQueue.main.async {
                    playlist.songs.wrappedValue.append(song)
                }
                
            }
        }
    }
}






//#Preview {
//    MyPlaylistView()
//}
