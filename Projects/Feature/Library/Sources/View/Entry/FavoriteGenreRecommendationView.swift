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
    @State var recommendationSongList: [Int: [Song]] = [:]
    @State var recommendationIDList: [Int: [String]] = [:]
    @State var isEditGenreViewPresent: Bool = false
    
    var body: some View {
        ZStack{
            VStack(alignment: .leading, spacing: 0) {
                ForEach(userManager.favoriteGenres, id: \.self){genreID in
                    RecommendationScrollView(genreID: genreID, songs: $recommendationSongList )
                        .frame(height: 210)
                        .padding(.top, 35)
                        .onAppear {
                            DispatchQueue.global().async {
                                getRecommendationSongIDs(genreID: genreID)
                            }
                        }
                }
                
                //장르 변경 아이템들
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
                        .padding(.leading, 20)

                    
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
                .padding(.top, 75)
           
            }
        }
        .onAppear {
            recommendationIDList.removeAll()
            recommendationSongList.removeAll()

        }
    }
    //애플뮤직 테스트
    private func getRecommendationSongIDs(genreID: Int){
        let appleMusicService = AppleMusicService.shared
        appleMusicService.getRecommendationMusicIDList(genre: genreID, limit: 10, offset: 0) { result in
            switch(result){
            case .success(let data):
                if let songs = data as? [song]{
                    print("get song id success")
                    let songIDs = songs.map({$0.id})
                    recommendationIDList[genreID] = songIDs
                    Task{
                        recommendationSongList[genreID] = await fetchSongInfo(genreID:genreID, songIDs: songIDs)
                    }
                }
            case .failure(_):
                print("error")
            }
        }
    }
    
    private func fetchSongInfo(genreID: Int, songIDs: [String]) async -> [Song] {
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
                recommendationSongList[genreID]?.append(song)
                songs.append(song)
            } catch {
                print("Error: \(error)")
            }
        }
        return songs
    }
}

private struct RecommendationScrollView: View {
    let genreID: Int
    @Binding var songs: [Int: [Song]]
    var body: some View {
        VStack(spacing: 0) {
            GenreTitle(genreName: MusicGenreHelper().genreName(id: genreID))
            
            ScrollView(.horizontal) {
                LazyHStack (spacing: 0){
                    ForEach(songs[genreID] ?? [], id: \.self){ song in
                        RecommendationMusicItem(song: song)
                    }
                }
                .padding(.leading, 20)
            }
            .padding(.top, 12)
            .scrollIndicators(.hidden)
            
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
