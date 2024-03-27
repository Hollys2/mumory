//
//  AddSongOfFavoriteView.swift
//  Feature
//
//  Created by 제이콥 on 2/14/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core

struct AddSongFromFavoriteView: View {
    @Binding var originPlaylist: MusicPlaylist
    @EnvironmentObject var currentUserData: CurrentUserData
    @State var favoritePlaylist: MusicPlaylist?
    @State var favoriteSong = []
    private let lineGray = Color(white: 0.31)
    
    init(originPlaylist: Binding<MusicPlaylist>) {
        self._originPlaylist = originPlaylist
    }

    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            ScrollView(.vertical) {
                LazyVStack(spacing: 0, content: {
                    ForEach(favoritePlaylist?.songIDs ?? [], id: \.self) { id in
                        AddMusicItem(songID: id, originPlaylist: $originPlaylist)
                    }

                })
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 90)
            }
        }
        .onAppear(perform: {
            Task{
                getFavoritePlaylist()
            }
        })
    }
    
    private func getFavoritePlaylist() {
        let Firebase = FBManager.shared
        let db = Firebase.db
        
        db.collection("User").document(currentUserData.uId).collection("Playlist").document("favorite").getDocument { snapshot, error in
            if error == nil {
                guard let snapshot = snapshot else {
                    print("no snapshot")
                    return
                }
                
                guard let data = snapshot.data() else {
                    print("no data")
                    return
                }
                
                guard let title = data["title"] as? String else {
                    print("no title")
                    return
                }
                guard let isPublic = data["isPublic"] as? Bool else {
                    print("no private thing")
                    return
                }
                guard let songIds = data["songIds"] as? [String] else {
                    print("no id list")
                    return
                }
                guard let date = (data["date"] as? FBManager.TimeStamp)?.dateValue() else {
                    return
                }
                let id = snapshot.reference.documentID
                
                self.favoritePlaylist = MusicPlaylist(id: id, title: title, songIDs: songIds, isPublic: isPublic, createdDate: date)
            }
        }
    }
}

//#Preview {
//    AddSongFromFavoriteView()
//}
