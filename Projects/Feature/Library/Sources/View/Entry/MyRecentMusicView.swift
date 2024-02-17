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
public struct MyRecentMusicView: View {
    @EnvironmentObject var playerManager: PlayerViewModel
    @State var MusicList: [Song] = []
    @State var exists: Bool = false
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
                    
                    SharedAsset.next.swiftUIImage
                })
                .padding(.trailing, 20)
                .padding(.leading, 20)
                .padding(.top, 10)
                .padding(.bottom, 10)
                
                if exists{
                    //기록 존재O
                    //나의 최근 뮤모리 뮤직 횡스크롤 아이템
                    ScrollView(.horizontal) {
                        LazyHStack(alignment: .top,spacing: 16,content: {
                            ForEach(MusicList, id: \.title) { song in
//                                RecentMusicItem(song: song)
//                                    .onTapGesture {
//                                        playerManager.song = song
//                                    }
                            }
                        })
                        .padding(.leading, 20)
                    }
                    .scrollIndicators(.hidden)
                    .padding(.top, 14)
                }else {
                    //기록 존재 X
                    NoMumoryView()
                        .frame(height: 151)
                }
                
            })
            .onAppear(perform: {
                searchRecentMusicPost()
            })
        }
    }
    
    private func searchRecentMusicPost(){
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        let query = db.collection("Mumory").document("111")
            query.getDocument { snaptshot, error in
                if let error = error {
                    print(error)
                    exists = false
                }else if let snapshot = snaptshot{
                    exists = snapshot.exists
                }
        }
    }
    
    func fetchSongInfo(songId: String) async throws -> Song {
        let musicItemID = MusicItemID(rawValue: songId)
        var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
        request.properties = [.genres, .artists]
        let response = try await request.response()
        guard let song = response.items.first else {
            throw NSError(domain: "GoogleMapSample", code: 1, userInfo: [NSLocalizedDescriptionKey: "Song not found"])
        }
        
        let artworkUrl = song.artwork?.url(width: 400, height: 400)
        return song
    }
}




struct NoMumoryView: View {
    var body: some View {
        VStack(alignment: .center,spacing: 0, content: {
            Text("나의 뮤모리를 기록하고")
                .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 13))
                .foregroundStyle(ColorSet.charSubGray)
            Text("음악 리스트를 채워보세요!")
                .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 13))
                .foregroundStyle(ColorSet.charSubGray)
                .padding(.top, 3)
            
            Text("뮤모리 기록하러 가기")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundStyle(ColorSet.mainPurpleColor)
                .padding(.top, 9)
                .padding(.bottom, 9)
                .padding(.leading, 13)
                .padding(.trailing, 13)
                .background(ColorSet.darkGray)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .circular))
                .padding(.top, 25)

        })
    }
}
#Preview {
    NoMumoryView()
}
