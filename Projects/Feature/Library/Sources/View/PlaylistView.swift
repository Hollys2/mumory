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

struct PlaylistView: View {    
    @EnvironmentObject var manager: LibraryManageModel
    @State var playlistArray: [Playlist] = []
    @State var isShowCreatePopup: Bool = false
    var cols: [GridItem] = [
        GridItem(.flexible(minimum: 150, maximum: 220), spacing: 0),
        GridItem(.flexible(minimum: 150, maximum: 220), spacing: 0)
    ]
    var body: some View {
        ZStack{
            LibraryColorSet.background.ignoresSafeArea()
            
            VStack{
                TopBar(leftButton: SharedAsset.back.swiftUIImage, title: "내 플레이리스트", rightButton: SharedAsset.add
                    .swiftUIImage) {
                        //left action
                        manager.page = .entry(.myMusic)
                } rightButtonAction: {
                        //right action
                    isShowCreatePopup = true
                }
                
                ScrollView(.vertical) {
                    LazyVGrid(columns: cols, content: {
                        ForEach(playlistArray, id: \.title) { playlist in
                            PlaylistItem(playlist: playlist)
                                .frame(minWidth: 163, minHeight: 209)
                        }
                    })
                    .padding(.leading, 20)
                }
                .padding(.top, 26)
                .scrollIndicators(.hidden)

                Spacer()
            }
            if isShowCreatePopup{
                Color(red: 0, green: 0, blue: 0, opacity: 0.5)
                    .ignoresSafeArea()
            }
            if isShowCreatePopup{
                CreatePlaylistPopupView(xButtonAction: {
                    isShowCreatePopup = false
                })
                    .padding(.leading, 40)
                    .padding(.trailing, 40)
            }
        }
        .onAppear(perform: {
            getPlayList()
        })
    }
    
    func getPlayList(){
        let db = Firestore.firestore().collection("Playlist")
        
        let uid = "a1234"//uid userdefault에서 가져오는 걸로 수정하기
        db.whereField("uid", isEqualTo: uid).getDocuments { snapShot, error in
            if let error = error {
                print(error)
            }else if let documents = snapShot?.documents{
               for data in documents {
                    let playlist = data.data()
                    guard let title = playlist["title"] as? String else {return}
                    guard let IDs = playlist["IDs"] as? [String] else {return}
                    Task{
                        let songs = try await fetchSongInfo(songIDs: IDs)
                        playlistArray.append(Playlist(title: title, songs: songs, songIDs: IDs, isPrivate: false))
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
//    PlaylistView()
//}
