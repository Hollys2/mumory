//
//  FavoriteGenreRecommendationView.swift
//  Feature
//
//  Created by 제이콥 on 2/10/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit


struct FavoriteGenreRecommendationView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var manager: LibraryCoordinator
    @State var isEditGenreViewPresent: Bool = false
    @State var isEditGenreInfoPresent: Bool = false
    @State var genreInfoTimer: Timer?
    
    var body: some View {
        ZStack{
            VStack(alignment: .leading, spacing: 0) {
                ForEach(currentUserData.favoriteGenres, id: \.self){genreID in
                    RecommendationScrollView(genreID: genreID)
                        .environmentObject(manager)
                        .frame(height: 210)
                        .padding(.top, 35)
                }
                
                
                //내 선호 장르들 및 수정 버튼
                ScrollView(.horizontal) {
                    LazyHStack(alignment: .bottom, spacing: 8) {
                        Text("장르")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                            .padding(.leading, 14)
                            .padding(.trailing, 14)
                            .frame(height: 30)
                            .foregroundStyle(Color.white)
                            .overlay {
                                RoundedRectangle(cornerRadius: 30, style: .circular)
                                    .stroke(Color.white, lineWidth: 1)
                            }
                        
                        ForEach(currentUserData.favoriteGenres, id: \.self){ genreID in
                            GenreItem(genreID: genreID)
                        }
                        
                        Circle()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(ColorSet.mainPurpleColor)
                            .overlay {
                                SharedAsset.addBlack.swiftUIImage
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                
                                if isEditGenreInfoPresent {
                                    SharedAsset.speechBubblePurple.swiftUIImage
                                        .overlay {
                                            Text("관심 장르를 수정해보세요!")
                                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 11))
                                                .foregroundStyle(Color.black)
                                                .padding(.bottom, 6)
                                        }
                                        .offset(y: -37)
                                        .transition(.scale(scale: 0.0, anchor: .top).combined(with: .opacity))
                                }
                                
                            }
                            .onTapGesture {
                                isEditGenreViewPresent = true
                            }
                            .fullScreenCover(isPresented: $isEditGenreViewPresent, content: {
                                EditFavoriteGenreView()
                            })
                            .onAppear(perform: {
                                withAnimation(.spring()) {
                                    isEditGenreInfoPresent = true
                                }
                                genreInfoTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { timer in
                                    withAnimation (.spring()){
                                        isEditGenreInfoPresent = false
                                    }
                                }
                            })
                            .onDisappear(perform: {
                                isEditGenreInfoPresent = false
                                genreInfoTimer?.invalidate()
                            })
                        
                    }
                    .frame(height: 80)
                    .padding(.vertical, 1)
                    .padding(.leading, 20)
                    .padding(.trailing, 60)
                }
                .scrollIndicators(.hidden)
                .padding(.top, 25)
                
           
            }
        }
        .onAppear {
//            let db = FBManager.shared.db.coll
//            recommendationIDList.removeAll()
//            recommendationSongList.removeAll()

        }
    }
    //애플뮤직 테스트
   
}

private struct RecommendationScrollView: View {
    @EnvironmentObject var manager: LibraryCoordinator
    @EnvironmentObject var playerManager: PlayerViewModel
    @State var songs: [Song] = []
    @State var songIDs: [String] = []
    let genreID: Int
    init(genreID: Int) {
        self.genreID = genreID
    }
//    @Binding var songs: [Int: [Song]]
    var body: some View {
        VStack(spacing: 0) {
            GenreTitle(genreName: MusicGenreHelper().genreName(id: genreID))
                .onTapGesture {
                    manager.push(destination: .recommendation(genreID: genreID))
                }
            
            ScrollView(.horizontal) {
                LazyHStack (spacing: 0){
                    ForEach(songs, id: \.self){ song in
                        RecommendationMusicItem(song: song)
                            .onTapGesture {
                                playerManager.playNewSong(song: song)
                            }
                    }
                }
                .padding(.leading, 20)
            }
            .padding(.top, 12)
            .scrollIndicators(.hidden)
            
        }
        .onAppear {
            getRecommendationSongIDs(genreID: self.genreID)
        }
    }
    
    private func getRecommendationSongIDs(genreID: Int){
        let appleMusicService = AppleMusicService.shared
        appleMusicService.getRecommendationMusicIDList(genre: genreID, limit: 10, offset: 0) { result in
            switch(result){
            case .success(let data):
                if let songs = data as? [song]{
                    let songIDs = songs.map({$0.id})
                    self.songIDs = songIDs
                    Task{
                        await fetchSongInfo(songIDs: songIDs)
                    }
                }
            case .failure(_):
                print("error")
            }
        }
    }
    
    private func fetchSongInfo(songIDs: [String]) async {
        for id in songIDs {
            let musicItemID = MusicItemID(rawValue: id)
            let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
            
            do {
                let response = try await request.response()
                guard let song = response.items.first else {
                    print("no song")
                    continue
                }
                withAnimation {
                    self.songs.append(song)
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
}

struct GenreTitle: View {
    let genreName: String
    var body: some View {
        HStack(spacing: 0){
            Text("\(genreName) 추천곡 리스트")
                .foregroundStyle(.white)
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
            
            Spacer()
            
            SharedAsset.next.swiftUIImage
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
  
}

private struct GenreItem: View {
    let genreID: Int
    var body: some View {
        Text(MusicGenreHelper().genreName(id: genreID))
            .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 13))
            .padding(.leading, 14)
            .padding(.trailing, 14)
            .frame(height: 30)
            .overlay {
                RoundedRectangle(cornerRadius: 30, style: .circular)
                    .stroke(Color.white, lineWidth: 1)
            }
            .foregroundStyle(Color.black)
            .background(Color.white)
            .cornerRadius(30, corners: .allCorners)
    }
}

private struct test: View {
    var body: some View {
        
        Circle()
            .frame(width: 30, height: 30)
            .foregroundStyle(ColorSet.mainPurpleColor)
            .overlay {
                SharedAsset.addBlack.swiftUIImage
                    .resizable()
                    .frame(width: 20, height: 20)
            }
    }
}


//#Preview {
//    test()
//        
//}
