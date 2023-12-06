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
    let name: String
    let musicList: [String]
}
struct MyPlaylistView: View {
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
                
                ScrollView(.horizontal) {
                    LazyHGrid(rows: rows, content: {
                        ForEach(playlistArray, id: \.name) { playlist in
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
            getNumberOfPlaylist()
        })
       
    }
    
    func getNumberOfPlaylist(){
        let db = Firestore.firestore().collection("Playlist")
        //실제로는 저장된 uid로 해당 문서 접근하기
//        guard let uid = UserDefaults.standard.string(forKey: "uid") else {print("no uid");return}
//        db.document(uid)
        
        db.document("userid").getDocument { snapshot, error in
            if let snapshot = snapshot{
                guard let data = snapshot.data() as? [String: [String]] else {print("snap shot error");return}
                numberOfPlaylist = data.count
                data.forEach { (key: String, value: [String]) in
                    playlistArray.append(Playlist(name: key, musicList: value))
                }
                
            }else {
                
            }
        }
        
    }
    

    func nothing(){
        let data: [String : Any] = [
            "name" : "놀때 듣는 노래",
            "musiclist" : ["1234", "2345", "4556"],
            "isPrivate" : false,
            "isFavorite" : true
        ]
        let db = Firestore.firestore()
        db.collection("Playlist").document("uid").collection("")
        
        
    }
}



//#Preview {
//    MyPlaylistView()
//}
