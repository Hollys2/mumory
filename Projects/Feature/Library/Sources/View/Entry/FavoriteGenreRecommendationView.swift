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
    @EnvironmentObject var currentUserData: CurrentUserViewModel
    @State var isEditGenreViewPresent: Bool = false
    @State var isEditGenreInfoPresent: Bool = false
    
    var body: some View {
        ZStack{
            VStack(alignment: .leading, spacing: 0) {
                ForEach(currentUserData.favoriteGenres, id: \.self){genreID in
                    RecommendationScrollView(genreID: genreID)
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
                            .fill(ColorSet.mainPurpleColor)
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                isEditGenreViewPresent = true
                            }
                            .overlay {
                                SharedAsset.addBlack.swiftUIImage
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                
                                if isEditGenreInfoPresent {
                                    SharedAsset.speechBubblePurple.swiftUIImage
                                        .frame(width: 178)
                                        .overlay {
                                            HStack(spacing: 3, content: {
                                                Text("관심 장르를 수정해보세요!")
                                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                                                    .foregroundStyle(Color.black)
                                                
                                                SharedAsset.xBlackBold.swiftUIImage
                                                    .scaledToFit()
                                                    .frame(width: 13, height: 13)
                                                    .onTapGesture {
                                                        UserDefaults.standard.set(Date(), forKey: "EditFavoriteGenre")
                                                        withAnimation(.spring()){
                                                            isEditGenreInfoPresent = false
                                                        }
                                                    }
                                            })
                                            .padding(.bottom, 6)
                                            
                                        }
                                        .offset(y: -40)
                                        .offset(x: -63)
                                        .transition(.scale(scale: 0.0, anchor: .top).combined(with: .opacity))
                                }
                                
                            }
                            .onAppear(perform: {
                                withAnimation(.spring()) {
                                    isEditGenreInfoPresent = UserDefaults.standard.value(forKey: "EditFavoriteGenre") == nil
                                }
                            })
                            .onDisappear(perform: {
                                isEditGenreInfoPresent = false
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
        .fullScreenCover(isPresented: $isEditGenreViewPresent, content: {
            EditFavoriteGenreView()
        })
    }
    //애플뮤직 테스트
   
}

private struct RecommendationScrollView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @State var songs: [Song] = []
    @State var songIDs: [String] = []
    let genreID: Int
    init(genreID: Int) {
        self.genreID = genreID
    }
    var body: some View {
        VStack(spacing: 0) {
            GenreTitle(genreName: MusicGenreHelper().genreName(id: genreID))
                .onTapGesture {
                    appCoordinator.rootPath.append(MumoryPage.recommendation(genreID: genreID))
                }
            
            ScrollView(.horizontal) {
                LazyHStack (spacing: 12){
                    if songs.count < 4 {
                        RecommendationMusicSkeletonView()
                        RecommendationMusicSkeletonView()
                        RecommendationMusicSkeletonView()
                        RecommendationMusicSkeletonView()
                    }else {
                        ForEach(songs, id: \.self){ song in
                            RecommendationMusicItem(song: song)
                                .onTapGesture {
                                    playerViewModel.playAll(title: "\(MusicGenreHelper().genreName(id: genreID)) 추천곡 리스트", songs: songs, startingItem: song)
                                    playerViewModel.setPlayerVisibilityWithoutAnimation(isShown: false)
                                }
                        }
                        
                    }
                }
                .padding(.horizontal, 20)
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
            Task {
                let musicItemID = MusicItemID(rawValue: id)
                let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
                guard let response = try? await request.response() else {
                    return
                }
                guard let song = response.items.first else {
                    print("no song")
                    return
                }
                withAnimation {
                    self.songs.append(song)
                }
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

