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
import MapKit

struct RecommendationListView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
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
                .frame(width: getUIScreenBounds().width)
                .offset(y: offset.y < -currentUserData.topInset ? -(offset.y+currentUserData.topInset) : 0)
                .overlay {
                    LinearGradient(colors: [ColorSet.background.opacity(0.8), Color.clear], startPoint: .top, endPoint: .init(x: 0.5, y: 0.3))
                    ColorSet.background.opacity(offset.y/(getUIScreenBounds().width-50.0))
                }

            
            SimpleScrollView(contentOffset: $offset) {
                
                VStack(spacing: 0, content: {
                    SharedAsset.bottomGradient.swiftUIImage
                        .resizable()
                        .frame(width: getUIScreenBounds().width, height: 45)
                        .ignoresSafeArea()
                        .padding(.top, getUIScreenBounds().width - currentUserData.topInset - 30) //사진 세로 길이 - 세이프공간 높이 - 그라데이션과 사진이 겹치는 부분
                    
                    VStack(spacing: 0, content: {
                        Text(title)
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 24))
                            .frame(width: getUIScreenBounds().width, alignment: .center)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .foregroundStyle(.white)
                        
                        Text(getUpdateDateText())
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                            .foregroundStyle(ColorSet.subGray)
                            .padding(.top, 5)
                        
                        HStack(alignment: .bottom){
                            Text("\(songs.count)곡")
                                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                                .foregroundStyle(ColorSet.subGray)
                            
                            Spacer()
                            
                            PlayAllButton()
                                .onTapGesture {
                                    playerViewModel.playAll(title: title, songs: songs)
                                }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 15)
                        .padding(.top, 30)
                        
                        
                        //추천 곡 목록
                        ForEach(songs, id: \.self) { song in
                            MusicListItem(song: song, type: .normal)
                                .onTapGesture {
                                    playerViewModel.playAll(title: title, songs: songs, startingItem: song)
                                }
                        }
                        
                        
                        //플레이어에 가려지는 높이만큼 채워주기
                        //노래가 채워지면서 뷰의 크기가 바뀌면 에러발생함. 따라서 맨 처음에는 1000만큼 공간을 채워줘서 안정적으로 데이터를 받아올 수 있도록 함
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(height: songs.count < 50 ? 1000 : 90)
                        
                        
                    })
                    .offset(y: -30) //그라데이션과 겹치도록 위로 30만큼 땡김
                    .background(ColorSet.background)
                    
                    
                })
                .frame(width: getUIScreenBounds().width)
                .frame(minHeight: getUIScreenBounds().height)
                
            }
            .scrollIndicators(.hidden)
            
            
            //상단바 - z축 최상위
            HStack(spacing: 0, content: {
                SharedAsset.backGradient.swiftUIImage
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.leading, 20)
                    .onTapGesture {
                        appCoordinator.rootPath.removeLast()
                    }
                
                Spacer()
                
                
                SharedAsset.menuGradient.swiftUIImage
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 20)
                    .onTapGesture {
                        UIView.setAnimationsEnabled(false)
                        isBottomSheetPresent.toggle()
                    }
            })
            .frame(height: 65)
            .padding(.top, currentUserData.topInset)
            
            CreateMumoryBottomSheetView(isSheetShown: $appCoordinator.isCreateMumorySheetShown, offsetY: $appCoordinator.offsetY)
                .ignoresSafeArea()

  
        }
        .ignoresSafeArea()
        .onAppear(perform: {
            getRecommendationSongIDs(genreID: self.genreID)
            playerViewModel.setLibraryPlayerVisibility(isShown: !appCoordinator.isCreateMumorySheetShown, moveToBottom: true)
            AnalyticsManager.shared.setScreenLog(screenTitle: "RecommendationListView")
        })
        .fullScreenCover(isPresented: $isBottomSheetPresent, content: {
            BottomSheetWrapper(isPresent: $isBottomSheetPresent)  {
                RecommendationBottomSheetView(songs: $songs, title: title)
            }
            .background(TransparentBackground())
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
        if self.songs.count >= 50 {
            return
        }
        self.songs = []
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
        isCompletedGetSongs = true
    }   
    
    private func getUpdateDateText() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M월 d일에 업데이트됨"
        return dateFormatter.string(from: Date())
    }
    
    
}


//private struct PlaylistImage: View {
//    @EnvironmentObject var currentUserData: CurrentUserData
//    @State var imageWidth: CGFloat = 0
//    @Binding var songs: [Song]
//    
//    let emptyGray = Color(red: 0.18, green: 0.18, blue: 0.18)
//    
//    init(songs: Binding<[Song]>) {
//        self._songs = songs
//    }
//    
//    var body: some View {
//        VStack(spacing: 0, content: {
//            HStack(spacing: 0, content: {
//                //1번째 이미지
//                if songs.count < 1 {
//                    Rectangle()
//                        .frame(width: imageWidth, height: imageWidth)
//                        .foregroundStyle(emptyGray)
//                }else{
//                    AsyncImage(url: songs[0].artwork?.url(width: 600, height: 600) ?? URL(string: "")) { image in
//                        image
//                            .resizable()
//                            .frame(width: imageWidth, height: imageWidth)
//                    } placeholder: {
//                        Rectangle()
//                            .frame(width: imageWidth, height: imageWidth)
//                            .foregroundStyle(emptyGray)
//                    }
//                }
//                
//                //세로줄(구분선)
//                Rectangle()
//                    .frame(width: 1, height: imageWidth)
//                    .foregroundStyle(ColorSet.background)
//                
//                //2번째 이미지
//                if songs.count < 2{
//                    Rectangle()
//                        .frame(width: imageWidth, height: imageWidth)
//                        .foregroundStyle(emptyGray)
//                }else{
//                    AsyncImage(url: songs[1].artwork?.url(width: 600, height: 600) ?? URL(string: "")) { image in
//                        image
//                            .resizable()
//                            .frame(width: imageWidth, height: imageWidth)
//                    } placeholder: {
//                        Rectangle()
//                            .frame(width: imageWidth, height: imageWidth)
//                            .foregroundStyle(emptyGray)
//                    }
//                }
//                
//                
//            })
//            
//            //가로줄(구분선)
//            Rectangle()
//                .frame(width: getUIScreenBounds().width, height: 1)
//                .foregroundStyle(ColorSet.background)
//            
//            HStack(spacing: 0,content: {
//                //3번째 이미지
//                if songs.count < 3 {
//                    Rectangle()
//                        .frame(width: imageWidth, height: imageWidth)
//                        .foregroundStyle(emptyGray)
//                }else{
//                    AsyncImage(url: songs[2].artwork?.url(width: 600, height: 600) ?? URL(string: "")) { image in
//                        image
//                            .resizable()
//                            .frame(width: imageWidth, height: imageWidth)
//                    } placeholder: {
//                        Rectangle()
//                            .frame(width: imageWidth, height: imageWidth)
//                            .foregroundStyle(emptyGray)
//                    }
//                }
//                
//                //세로줄 구분선
//                Rectangle()
//                    .frame(width: 1, height: imageWidth)
//                    .foregroundStyle(ColorSet.background)
//                
//                //4번째 이미지
//                if songs.count <  4 {
//                    Rectangle()
//                        .frame(width: imageWidth, height: imageWidth)
//                        .foregroundStyle(emptyGray)
//                }else{
//                    AsyncImage(url: songs[3].artwork?.url(width: 600, height: 600) ?? URL(string: "")) { image in
//                        image
//                            .resizable()
//                            .frame(width: imageWidth, height: imageWidth)
//                    } placeholder: {
//                        Rectangle()
//                            .frame(width: imageWidth, height: imageWidth)
//                            .foregroundStyle(emptyGray)
//                    }
//                }
//                
//            })
//        })
//        .onAppear {
//            DispatchQueue.main.async {
//                self.imageWidth = getUIScreenBounds().width/2
//            }
//        }
//        
//    }
//    
//    
//}

