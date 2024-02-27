//
//  RecommendationListView.swift
//  Feature
//
//  Created by 제이콥 on 2/21/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit
import Core

struct RecommendationListView: View {
    @EnvironmentObject var manager: LibraryManageModel
    @EnvironmentObject var userManager: UserViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerManager: PlayerViewModel
    
    @State var offset: CGPoint = .zero
    @State var isBottomSheetPresent: Bool = false
    @State var songIDs: [String] = []
    @State var songs: [Song] = []
    @State var isCompletedGetSongs: Bool = false
    let genreID: Int
    let title: String
    
    init(genreID: Int) {
        self.genreID = genreID
        self.title = "\(MusicGenreHelper().genreName(id: genreID)) 추천곡"
    }
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()

            //이미지
            PlaylistImage(songs: $songs)
                .offset(y: offset.y < -userManager.topInset ? -(offset.y+userManager.topInset) : 0)

            
            SimpleScrollView(contentOffset: $offset) {
                
                VStack(spacing: 0, content: {
                    SharedAsset.bottomGradient.swiftUIImage
                        .resizable()
                        .frame(width: userManager.width, height: 45)
                        .ignoresSafeArea()
                        .padding(.top, userManager.width - userManager.topInset - 30) //사진 세로 길이 - 세이프공간 높이 - 그라데이션과 사진이 겹치는 부분
                    
                    VStack(spacing: 0, content: {
                        Text(title)
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 24))
                            .frame(width: userManager.width, alignment: .center)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .foregroundStyle(.white)
                        
                        Text(getUpdateDateText())
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                            .foregroundStyle(ColorSet.subGray)
                            .padding(.top, 5)
                        
                        
                        HStack(alignment: .bottom,spacing: 8, content: {
                            Text("\(songs.count)곡")
                                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                                .foregroundStyle(ColorSet.subGray)
                            Spacer()
                            
                            PlayAllButton()
                                .onTapGesture {
                                    playerManager.playAll(title: "\(MusicGenreHelper().genreName(id: genreID)) 추천곡", songs: songs)
                                }
                        })
                        .padding(.horizontal, 20)
                        .padding(.bottom, 15)
                        .padding(.top, 30)
                        
                        
                        //추천 곡 목록
                        ForEach(songs, id: \.self) { song in
                            MusicListItem(song: song, type: .normal)
                                .onTapGesture {
                                    playerManager.playNewSong(song: song)
                                }
                            Divider()
                                .frame(maxWidth: .infinity)
                                .frame(height: 0.5)
                                .background(ColorSet.subGray)
                        }
                        
                        
                        //플레이어에 가려지는 높이만큼 채워주기
                        //노래가 채워지면서 뷰의 크기가 바뀌면 에러발생함. 따라서 맨 처음에는 1000만큼 공간을 채워줘서 안정적으로 데이터를 받아올 수 있도록 함
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(height: songs.count == 0 ? 1000 : isCompletedGetSongs ? 90 : 1000)
                        
                        
                    })
                    .offset(y: -30) //그라데이션과 겹치도록 위로 30만큼 땡김
                    .background(ColorSet.background)
                    
                    
                })
                .frame(width: userManager.width)
                .frame(minHeight: userManager.height)
                
            }
            
            
            //상단바 - z축 최상위
            HStack(spacing: 0, content: {
                SharedAsset.backGradient.swiftUIImage
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.leading, 20)
                    .onTapGesture {
                        manager.pop()
                    }
                
                Spacer()
                
                
                SharedAsset.menuGradient.swiftUIImage
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 20)
                    .onTapGesture {
                        isBottomSheetPresent = true
                    }
            })
            .frame(height: 50)
            .padding(.top, userManager.topInset)
            .fullScreenCover(isPresented: $isBottomSheetPresent, content: {
                BottomSheetWrapper(isPresent: $isBottomSheetPresent)  {
                    RecommendationBottomSheetView(songs: songs, title: title)
                }
                .background(TransparentBackground())
            })
        }
        .ignoresSafeArea()
        .onAppear(perform: {
            getRecommendationSongIDs(genreID: self.genreID)
        })
        
        
    }
    //스크롤 양에 따라서 로딩되도록 수정하기
    private func getRecommendationSongIDs(genreID: Int){
        let appleMusicService = AppleMusicService.shared
        appleMusicService.getRecommendationMusicIDList(genre: genreID, limit: 50, offset: 0) { result in
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
        self.songs = []
        
        for id in songIDs {
            let musicItemID = MusicItemID(rawValue: id)
            var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
            request.properties = [.genres, .artists]
            
            do {
                let response = try await request.response()
                
                guard let song = response.items.first else {
                    print("no song")
                    continue
                }
                
                DispatchQueue.main.async {
                    self.songs.append(song)
                }
                
                
            } catch {
                print("Error: \(error)")
            }
        }
        
        isCompletedGetSongs = true
    }   
    private func getUpdateDateText() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 dd일에 업데이트됨"
        return dateFormatter.string(from: Date())
    }
    
    
}


private struct PlaylistImage: View {
    @EnvironmentObject var userManager: UserViewModel
    @State var imageWidth: CGFloat = 0
    @Binding var songs: [Song]
    
    let emptyGray = Color(red: 0.18, green: 0.18, blue: 0.18)
    
    init(songs: Binding<[Song]>) {
        self._songs = songs
    }
    
    var body: some View {
        VStack(spacing: 0, content: {
            HStack(spacing: 0, content: {
                //1번째 이미지
                if songs.count < 1 {
                    Rectangle()
                        .frame(width: imageWidth, height: imageWidth)
                        .foregroundStyle(emptyGray)
                }else{
                    AsyncImage(url: songs[0].artwork?.url(width: 600, height: 600) ?? URL(string: "")) { image in
                        image
                            .resizable()
                            .frame(width: imageWidth, height: imageWidth)
                    } placeholder: {
                        Rectangle()
                            .frame(width: imageWidth, height: imageWidth)
                            .foregroundStyle(emptyGray)
                    }
                }
                
                //세로줄(구분선)
                Rectangle()
                    .frame(width: 1, height: imageWidth)
                    .foregroundStyle(ColorSet.background)
                
                //2번째 이미지
                if songs.count < 2{
                    Rectangle()
                        .frame(width: imageWidth, height: imageWidth)
                        .foregroundStyle(emptyGray)
                }else{
                    AsyncImage(url: songs[1].artwork?.url(width: 600, height: 600) ?? URL(string: "")) { image in
                        image
                            .resizable()
                            .frame(width: imageWidth, height: imageWidth)
                    } placeholder: {
                        Rectangle()
                            .frame(width: imageWidth, height: imageWidth)
                            .foregroundStyle(emptyGray)
                    }
                }
                
                
            })
            
            //가로줄(구분선)
            Rectangle()
                .frame(width: userManager.width, height: 1)
                .foregroundStyle(ColorSet.background)
            
            HStack(spacing: 0,content: {
                //3번째 이미지
                if songs.count < 3 {
                    Rectangle()
                        .frame(width: imageWidth, height: imageWidth)
                        .foregroundStyle(emptyGray)
                }else{
                    AsyncImage(url: songs[2].artwork?.url(width: 600, height: 600) ?? URL(string: "")) { image in
                        image
                            .resizable()
                            .frame(width: imageWidth, height: imageWidth)
                    } placeholder: {
                        Rectangle()
                            .frame(width: imageWidth, height: imageWidth)
                            .foregroundStyle(emptyGray)
                    }
                }
                
                //세로줄 구분선
                Rectangle()
                    .frame(width: 1, height: imageWidth)
                    .foregroundStyle(ColorSet.background)
                
                //4번째 이미지
                if songs.count <  4 {
                    Rectangle()
                        .frame(width: imageWidth, height: imageWidth)
                        .foregroundStyle(emptyGray)
                }else{
                    AsyncImage(url: songs[3].artwork?.url(width: 600, height: 600) ?? URL(string: "")) { image in
                        image
                            .resizable()
                            .frame(width: imageWidth, height: imageWidth)
                    } placeholder: {
                        Rectangle()
                            .frame(width: imageWidth, height: imageWidth)
                            .foregroundStyle(emptyGray)
                    }
                }
                
            })
        })
        .onAppear {
            DispatchQueue.main.async {
                self.imageWidth = userManager.width/2
            }
        }
        
    }
    
    
}
