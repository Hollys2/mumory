//
//  MyRecentMusicView.swift
//  Feature
//
//  Created by 제이콥 on 11/20/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit
import Core
import FirebaseFirestore
public struct MyRecentMusicView: View {
    @EnvironmentObject var playerManager: PlayerViewModel
    @State var MusicList: [Song] = []
    
    public init() {
        
    }
    
    public var body: some View {
        ZStack{
            LibraryColorSet.background.ignoresSafeArea() //임시 배경 색. 나중에 삭제하기
            Color.clear.ignoresSafeArea()
            
            VStack(spacing: 0, content: {
                HStack(spacing: 0, content: {
                    Text("나의 최근 뮤모리 뮤직")
                        .foregroundStyle(.white)
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                    
                    Spacer()
                    
                    NavigationLink {
                        //
                    } label: {
                        SharedAsset.next.swiftUIImage
                            .padding(.trailing, 20)
                    }
                })
                .padding(.top, 40)
                .padding(.leading, 20)
     
                
                //나의 최근 뮤모리 뮤직 횡스크롤 아이템
                ScrollView(.horizontal) {
                    LazyHStack(alignment: .top,spacing: 16,content: {
                        ForEach(MusicList, id: \.title) { song in
                            RecentMusicItem(song: song)
                                .onTapGesture {
                                    playerManager.song = song
                                }
                        }
                    })
                    .padding(.leading, 20)
                    .padding(.top, 26)
                }
                .scrollIndicators(.hidden)
                
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 1)
                    .foregroundStyle(LibraryColorSet.lightGrayLine)
                    .padding(.top, 45)
                
                Spacer()
                
                
            })
            .onAppear(perform: {
                searchRecentMusicPost()
            })
        }
    }
    
    private func searchRecentMusicPost(){
        let db = Firestore.firestore().collection("favorite")
        db.document("musicIDs").getDocument { snapShot, error in
            if let document =  snapShot, document.exists {
                guard let data = document.data() else {print("no data");return}
                guard let idList = data["IDs"] as? [String] else {print("list error");return}
                idList.forEach { id in
                    Task{
                        MusicList.append(try await fetchSongInfo(songId: id))
                    }
                }
                print(idList)
            }else {
                guard let error = error else {print("no error");return}
                print(error)
            }
        }
        
    }
    
    func fetchSongInfo(songId: String) async throws -> Song {
        let musicItemID = MusicItemID(rawValue: songId)
        let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
        let response = try await request.response()
        guard let song = response.items.first else {
            throw NSError(domain: "GoogleMapSample", code: 1, userInfo: [NSLocalizedDescriptionKey: "Song not found"])
        }

        let artworkUrl = song.artwork?.url(width: 400, height: 400)
        return song
    }
}

//#Preview {
//    MyRecentMusicView()
//}


