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

struct MyPlaylistView: View {
    @EnvironmentObject var manager: LibraryManageModel
    @EnvironmentObject var userManager: UserViewModel
    
    
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
                    
                    Text("\(userManager.playlistArray.count-1)") //플레이리스트 추가 아이템 제외
                        .foregroundStyle(LibraryColorSet.lightGrayTitle)
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .padding(.trailing, 4)
                        .opacity(userManager.playlistArray.count > 0 ? 1 : 0) //개수 없을 때는 안 보이게 하기
                    
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
                        ForEach(userManager.playlistArray, id: \.title) { playlist in
                            PlaylistItem(playlist: playlist, isAddSongItem: playlist.isAddItme)
                                .environmentObject(manager)
                        }
                    })
                    .padding(.horizontal, 20)
                }
                .padding(.top, 16)
                .scrollIndicators(.hidden)
//                .onChange(of: playlistArray, perform: { value in
//                    playlistArray = value.sorted(by: { playlist1, playlist2 in
//                        return playlist1.isFavorite
//                    })
//                })
            })
            
            Spacer()
            
            
        }
        .onAppear(perform: {
            getPlayList()
        })
        
    }
    
    func getPlayList(){
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        let auth = Firebase.auth
        
        //기본셋팅
        
        userManager.playlistArray = [MusicPlaylist(id: "addItem", title: "", songIDs: [], isPrivate: false, isFavorite: false, isAddItme: true)]
        
        let query = db.collection("User").document(userManager.uid).collection("Playlist")
        query.getDocuments { snapshot, error in
            if let error = error {
                print(error)
            }else if let snapshot = snapshot {
                snapshot.documents.forEach { snapshot in
                    guard let title = snapshot.data()["title"] as? String else {
                        print("no title")
                        return
                    }
                    guard let isPrivate = snapshot.data()["is_private"] as? Bool else {
                        print("no private thing")
                        return
                    }
                    guard let isFavorite = snapshot.data()["is_favorite"] as? Bool else {
                        print("no favorite thing")
                        return
                    }
                    guard let songIDs = snapshot.data()["song_IDs"] as? [String] else {
                        print("no id list")
                        return
                    }
                    let id = snapshot.reference.documentID
                    
                    if isFavorite {
                        withAnimation {
                            userManager.playlistArray.insert(MusicPlaylist(id: id, title: title, songIDs: songIDs, isPrivate: isPrivate, isFavorite: isFavorite, isAddItme: false), at: 0)
                        }
                    }else {
                        let index = userManager.playlistArray.count - 1
                        withAnimation {
                            userManager.playlistArray.insert(MusicPlaylist(id: id, title: title, songIDs: songIDs, isPrivate: isPrivate, isFavorite: isFavorite, isAddItme: false), at: index)
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
