//
//  MostPostedSongListView.swift
//  Feature
//
//  Created by 제이콥 on 3/30/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct MostPostedSongListView: View {
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    @State var offset: CGPoint = .zero
    @State var isBottomSheetPresent: Bool = false
    @Binding var songs: [Song]
    
    init(songs: Binding<[Song]>) {
        self._songs = songs
    }
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()

            //이미지
            PlaylistImage(songs: $songs)
                .frame(width: getUIScreenBounds().width)
                .offset(y: offset.y < -getSafeAreaInsets().top ? -(offset.y+getSafeAreaInsets().top) : 0)
                .overlay {
                    LinearGradient(colors: [ColorSet.background.opacity(0.8), Color.clear], startPoint: .top, endPoint: .init(x: 0.5, y: 0.3))
                }

            
            SimpleScrollView(contentOffset: $offset) {
                
                VStack(spacing: 0, content: {
                    SharedAsset.bottomGradient.swiftUIImage
                        .resizable()
                        .frame(width: getUIScreenBounds().width, height: 45)
                        .ignoresSafeArea()
                        .padding(.top, getUIScreenBounds().width - getSafeAreaInsets().top - 30) //사진 세로 길이 - 세이프공간 높이 - 그라데이션과 사진이 겹치는 부분
                    
                    VStack(spacing: 0, content: {
                        Text("뮤모리로 많이 기록된 음악")
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
                                    playerViewModel.playAll(title: "뮤모리로 많이 기록된 음악", songs: songs)
                                    AnalyticsManager.shared.setSelectContentLog(title: "MostPostedSongListView")
                                }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 15)
                        .padding(.top, 30)
                        
                        
                        ForEach(songs.indices, id: \.self) { index in
                            MusicChartDetailItem(rank: index + 1, song: songs[index])
                                .onTapGesture {
                                    let tappedSong = songs[index]
                                    playerViewModel.playAll(title: "뮤모리로 많이 기록된 음악", songs: songs, startingItem: tappedSong)
                                }
                        }
                        
                        if songs.isEmpty {
                            SongListSkeletonView(isLineShown: true)
                        }
                        
                        
                        //플레이어에 가려지는 높이만큼 채워주기
                        //노래가 채워지면서 뷰의 크기가 바뀌면 에러발생함. 따라서 맨 처음에는 1000만큼 공간을 채워줘서 안정적으로 데이터를 받아올 수 있도록 함
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(height: songs.count > 0 ? 100 : 1000)
                        
                        
                    })
                    .offset(y: -30) //그라데이션과 겹치도록 위로 30만큼 땡김
                    .background(ColorSet.background)
                    
                    
                })
                .frame(width: getUIScreenBounds().width)
                .frame(minHeight: getUIScreenBounds().height)
                
            }
            .refreshAction {
                generateHapticFeedback(style: .light)
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
            .padding(.top, getSafeAreaInsets().top)
            
            if self.appCoordinator.isCreateMumorySheetShown {
                CreateMumorySheetUIViewRepresentable()
            }

  
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .onAppear(perform: {
//            playerViewModel.setLibraryPlayerVisibility(isShown: !appCoordinator.isCreateMumorySheetShown, moveToBottom: true)
            AnalyticsManager.shared.setScreenLog(screenTitle: "RecommendationListView")
        })
        .fullScreenCover(isPresented: $isBottomSheetPresent, content: {
            BottomSheetWrapper(isPresent: $isBottomSheetPresent)  {
                RecommendationBottomSheetView(songs: $songs, title: "뮤모리로 많이 기록된 음악")
            }
            .background(TransparentBackground())
        })
        
        
    }

}


