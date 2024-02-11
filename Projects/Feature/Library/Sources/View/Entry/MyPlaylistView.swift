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

struct Playlist {
    var title: String
    var songs: [Song]
    var songIDs: [String]
    var isPrivate: Bool
}

struct MyPlaylistView: View {
    @EnvironmentObject var manager: LibraryManageModel
    @State var playlistArray: [Playlist] = []
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
                    
                    Text("\(playlistArray.count)")
                        .foregroundStyle(LibraryColorSet.lightGrayTitle)
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .padding(.trailing, 4)
                        .opacity(playlistArray.count > 0 ? 1 : 0) //개수 없을 때는 안 보이게 하기
                    
                    SharedAsset.next.swiftUIImage
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.top, 10)
                .padding(.bottom, 10)
                
                .onTapGesture {
                    manager.page = .playlist
                }
                
                ScrollView(.horizontal) {
                    LazyHGrid(rows: rows,spacing: 12, content: {
                        ForEach(playlistArray, id: \.title) { playlist in
                            PlaylistItem(playlist: playlist)
                        }
                    })
                    .padding(.leading, 20)
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
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        let auth = Firebase.auth
        
        if let user = auth.currentUser {
            let query = db.collection("User").document(user.uid).collection("Playlist")
            query.getDocuments { snapshot, error in
                if let error = error {
                    print(error)
                }else if let snapshot = snapshot {
                    snapshot.documents.forEach { snapshot in
                        print("each")
                        guard let title = snapshot.data()["title"] as? String else {
                            print("no title")
                            return
                        }
                        guard let isPrivate = snapshot.data()["is_private"] as? Bool else {
                            print("no private thing")
                            return
                        }
                        guard let songIDs = snapshot.data()["song_IDs"] as? [String] else {
                            print("no id list")
                            return
                        }
                        
                        Task{
                            let songs = await fetchSongInfo(songIDs: songIDs)
                            playlistArray.append(Playlist(title: title, songs: songs, songIDs: songIDs, isPrivate: isPrivate))
                            print("song count: \(songs.count), id count: \(songIDs.count)")
                            print("good")
                        }
                        
                    }
                }
            }
        }else {
            //재로그인 유도
        }
  
        
    }

    private func fetchSongInfo(songIDs: [String]) async -> [Song] {
        var songs: [Song] = []
        
        for id in songIDs {
            let musicItemID = MusicItemID(rawValue: id)
            let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
            
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
