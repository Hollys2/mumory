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
    @EnvironmentObject var userManager: UserViewModel
    @EnvironmentObject var playerManager: PlayerViewModel
    @State var MusicList: [Song] = []
    @State var exists: Bool = false
    public init() {
        
    }
    
    public var body: some View {
        VStack(spacing: 0, content: {
            HStack(spacing: 0, content: {
                Text("나의 최근 뮤모리 뮤직")
                    .foregroundStyle(.white)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                Spacer()
                SharedAsset.next.swiftUIImage
            })
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            if MusicList.isEmpty{
                NoMumoryView()
                    .frame(maxHeight: .infinity, alignment: .center)
                    .padding(.bottom, 7)
            }else {
                ScrollView(.horizontal) {
                    LazyHStack(alignment: .top,spacing: 8, content: {
                        ForEach(MusicList, id: \.title) { song in
                            RecentMusicItem(song: song)
                        }
                    })
                    .padding(.horizontal, 20)
                }
                .scrollIndicators(.hidden)
                .padding(.top, 12)
            }
        })
        .onAppear(perform: {
            searchRecentMusicPost()
        })
    }
    
    private func searchRecentMusicPost(){
        //임의로 즐겨찾기 목록이 나오게 함
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        let query = db.collection("User").document(userManager.uid).collection("Playlist").document("favorite")
        query.getDocument { snapshot, error in
            guard error == nil else {
                return
            }
            guard let data = snapshot?.data() else {
                return
            }
            
            guard let songIDs = data["song_IDs"] as? [String] else {
                return
            }
            
            fetchSongInfo(songIDs: songIDs)
        }
    }
    
    func fetchSongInfo(songIDs: [String]){
        for id in songIDs {
            let musicItemID = MusicItemID(rawValue: id)
            var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
            Task {
                let response = try await request.response()
                guard let song = response.items.first else {
                    return
                }
                self.MusicList.append(song)
            }
        }
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
