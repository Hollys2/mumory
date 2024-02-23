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
    @EnvironmentObject var userManager: UserViewModel
    @EnvironmentObject var manager: LibraryManageModel
//    @State var recommendationSongList: [Int: [Song]] = [:]
//    @State var recommendationIDList: [Int: [String]] = [:]
    @State var isEditGenreViewPresent: Bool = false
    
    var body: some View {
        ZStack{
            VStack(alignment: .leading, spacing: 0) {
                ForEach(userManager.favoriteGenres, id: \.self){genreID in
                    RecommendationScrollView(genreID: genreID)
                        .environmentObject(manager)
                        .frame(height: 210)
                        .padding(.top, 35)
                }
                
                
                //내 선호 장르들 및 수정 버튼
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
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

                        //
                        ForEach(userManager.favoriteGenres, id: \.self){ genreID in
                            GenreItem(genreID: genreID)
                        }
                        
                        Circle()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(ColorSet.mainPurpleColor)
                            .overlay {
                                SharedAsset.addBlack.swiftUIImage
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                            .onTapGesture {
                                isEditGenreViewPresent = true
                            }
                            .fullScreenCover(isPresented: $isEditGenreViewPresent, content: {
                                EditFavoriteGenreView()
                            })
                        
                    }
                    .padding(.vertical, 2)
                    .padding(.horizontal, 20)
                }
                .scrollIndicators(.hidden)
                .padding(.top, 75)
                
           
            }
        }
        .onAppear {
//            recommendationIDList.removeAll()
//            recommendationSongList.removeAll()

        }
    }
    //애플뮤직 테스트
   
}

private struct RecommendationScrollView: View {
    @EnvironmentObject var manager: LibraryManageModel
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
        .padding(.leading, 20)
        .padding(.trailing, 20)
        .padding(.top, 10)
        .padding(.bottom, 10)
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


#Preview {
    test()
        
}
