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
    @EnvironmentObject var manager: LibraryCoordinator
    @EnvironmentObject var currentUserData: CurrentUserData
    
    
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
                    
                    Text("\(currentUserData.playlistArray.count-1)") //플레이리스트 추가 아이템 제외
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
                    manager.push(destination: .playlistManage)
                }
                
                ScrollView(.horizontal) {
                    LazyHGrid(rows: rows,spacing: 12, content: {
                        ForEach(currentUserData.playlistArray, id: \.title) { playlist in
                            PlaylistItem(playlist: playlist, itemSize: 81, isAddSongItem: playlist.isAddItme)
                                .onTapGesture {
                                    manager.push(destination: .playlist(playlist: playlist))
                                }
                        }
                    })
                    .padding(.horizontal, 20)
                }
                .padding(.top, 16)
                .scrollIndicators(.hidden)
            })
            
            Spacer()
            
            
        }
        .onAppear(perform: {
            getPlayList()
        })
        
    }
    
    func getPlayList(){
        let Firebase = FBManager.shared
        let db = Firebase.db
                
        DispatchQueue.main.async {
            currentUserData.playlistArray = [MusicPlaylist(id: "addItem", title: "", songIDs: [], isPublic: false, isAddItme: true)]
        }
        
        let query = db.collection("User").document(currentUserData.uid).collection("Playlist")
        query.getDocuments { snapshot, error in
            if let error = error {
                print(error)
            }else if let snapshot = snapshot {
                snapshot.documents.forEach { snapshot in
                    guard let title = snapshot.data()["title"] as? String else {
                        print("no title")
                        return
                    }
                    guard let isPublic = snapshot.data()["isPublic"] as? Bool else {
                        print("no private thing")
                        return
                    }
                    guard let songIDs = snapshot.data()["songIdentifiers"] as? [String] else {
                        print("no id list")
                        return
                    }
                    let id = snapshot.reference.documentID
                    
                    DispatchQueue.main.async {
                        if id == "favorite" {
                            withAnimation {
                                currentUserData.playlistArray.insert(MusicPlaylist(id: id, title: title, songIDs: songIDs, isPublic: isPublic, isAddItme: false), at: 0)
                            }
                        }else {
                            let index = currentUserData.playlistArray.count - 1
                            withAnimation {
                                currentUserData.playlistArray.insert(MusicPlaylist(id: id, title: title, songIDs: songIDs, isPublic: isPublic, isAddItme: false), at: index)
                            }
                        }
                    }
          

                    
                }
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
}






//#Preview {
//    MyPlaylistView()
//}
