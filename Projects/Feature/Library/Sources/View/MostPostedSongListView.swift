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
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @State var contentOffset: CGPoint = .zero
    @State var viewWidth: CGFloat = .zero
    @State var scrollDirection: ScrollDirection = .up
    @Binding var songs: [Song]
    @State var searchIndex = 0
    let dateTextColor = Color(red: 0.51, green: 0.51, blue: 0.51)
    
    init(songs: Binding<[Song]>) {
        self._songs = songs
    }
    
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            VStack(spacing: 0, content: {
                //상단 바
                HStack(spacing: 0, content: {
                    SharedAsset.back.swiftUIImage
                        .frame(width: 30, height: 30)
                        .padding(.leading, 20)
                        .onTapGesture {
                            appCoordinator.rootPath.removeLast()
                        }
                    Spacer()
                    VStack(spacing: 5, content: {
                        Text("뮤모리 사용자가 많이 기록한 음악")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                            .foregroundStyle(.white)
                        
                        Text(getUpdateDateText())
                            .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                            .foregroundStyle(dateTextColor)
                        
                    })
                    Spacer()
                    SharedAsset.search.swiftUIImage
                        .frame(width: 30, height: 30)
                        .padding(.trailing, 20)
                        .onTapGesture {
                            appCoordinator.rootPath.append(LibraryPage.search(term: ""))
                        }
                })
                .frame(height: 65)
                .padding(.top, appCoordinator.safeAreaInsetsTop)
                
                HStack(alignment: .bottom){
                    Text("\(songs.count)곡")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                        .foregroundStyle(ColorSet.subGray)
                        .padding(.leading, 20)
                    
                    Spacer()
                    
                    PlayAllButton()
                        .padding(.trailing, 20)
                        .onTapGesture {
                            playerViewModel.playAll(title: "뮤모리 사용자가 많이 기록한 음악", songs: songs)
                            AnalyticsManager.shared.setSelectContentLog(title: "MostPostedSongListView")
                        }
                }
                .padding(.top, 20)
                
                Divider05()
                    .padding(.top, 15)
                
                ScrollWrapperWithIndex(songs: $songs, index: $searchIndex, contentOffset: $contentOffset, scrollDirection: $scrollDirection) {
                    LazyVStack(spacing: 0, content: {
                        ForEach(songs.indices, id: \.self) { index in
                            MusicChartDetailItem(rank: index + 1, song: songs[index])
                                .simultaneousGesture(TapGesture().onEnded({ _ in
                                    playerViewModel.playAll(title: "뮤모리 사용자가 많이 기록한 음악", songs: songs, startingItem: songs[index])
                                }))
                        
                        }
                    })
                    .frame(width: getUIScreenBounds().width)
                    
                    Rectangle()
                        .foregroundStyle(.clear)
                        .frame(height: 87)
                }
                .scrollIndicators(.hidden)
                .ignoresSafeArea()
            })
            
            CreateMumoryBottomSheetView(isSheetShown: $appCoordinator.isCreateMumorySheetShown, offsetY: $appCoordinator.offsetY)
            
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .onAppear(perform: {
            AnalyticsManager.shared.setScreenLog(screenTitle: "RecommendationListView")
        })
    }

}


