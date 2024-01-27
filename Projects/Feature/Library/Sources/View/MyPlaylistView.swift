//
//  MyPlaylistView.swift
//  Feature
//
//  Created by 제이콥 on 11/28/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import FirebaseFirestore
import MusicKit

struct Playlist {
    var title: String
    var songs: [Song]
    var songIDs: [String]
}

struct MyPlaylistView: View {
    @EnvironmentObject var manager: LibraryManageModel
    @State var numberOfPlaylist: Int = 0
    @State var playlistArray: [Playlist] = []
    var rows: [GridItem] = [
        GridItem(.fixed(210)),
        GridItem(.fixed(210))
    ]
    
    var body: some View {
        ZStack{
//            LibraryColorSet.background
            VStack(spacing: 0, content: {
                HStack(spacing: 0){
                    Text("내 플레이리스트")
                        .foregroundStyle(.white)
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                    Spacer()
                    Text("\(numberOfPlaylist)")
                        .foregroundStyle(LibraryColorSet.lightGrayTitle)
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .padding(.trailing, 4)
                    SharedAsset.next.swiftUIImage
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .onTapGesture {
                    manager.nowPage = .playlist
                }
                
                ScrollView(.horizontal) {
                    LazyHGrid(rows: rows, content: {
                        ForEach(playlistArray, id: \.title) { playlist in
                            PlaylistItem(playlist: playlist)
                                .frame(minWidth: 163, minHeight: 209)
                        }
                    })
                    .padding(.leading, 20)
                }
                .padding(.top, 26)
                .scrollIndicators(.hidden)
            })
 
            Spacer()
            
 
        }
        .onAppear(perform: {
            getPlayList()
        })
       
    }
    
    func getPlayList(){
        let db = Firestore.firestore().collection("Playlist")
        
        let uid = "a1234"
        db.whereField("uid", isEqualTo: uid).getDocuments { snapShot, error in
            if let error = error {
                print(error)
            }else if let documents = snapShot?.documents{
                numberOfPlaylist = documents.count
                for data in documents {
                    let playlist = data.data()
                    guard let title = playlist["title"] as? String else {return}
                    guard let IDs = playlist["IDs"] as? [String] else {return}
                    Task{
                        let songs = try await fetchSongInfo(songIDs: IDs)
                        playlistArray.append(Playlist(title: title, songs: songs, songIDs: IDs))
                    }
                }
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
//    MyPlaylistView()
//}
