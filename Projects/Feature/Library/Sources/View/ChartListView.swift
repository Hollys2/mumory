//
//  ChartListView.swift
//  Feature
//
//  Created by 제이콥 on 2/8/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct ChartListView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @State var contentOffset: CGPoint = .zero
    @State var viewWidth: CGFloat = .zero
    @State var scrollDirection: ScrollDirection = .up
    @State var songs: [Song] = []
    @State var searchIndex = 0
//    let song = Musicit
    
    let dateTextColor = Color(red: 0.51, green: 0.51, blue: 0.51)
    
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
                        Text("최신 인기곡")
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
                .frame(height: 63)
                
                HStack(alignment: .bottom){
                    Text("100곡")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                        .foregroundStyle(ColorSet.subGray)
                        .padding(.leading, 20)
                    
                    Spacer()
                    
                    PlayAllButton()
                        .padding(.trailing, 20)
                        .onTapGesture {
                            playerViewModel.playAll(title: "최신 인기곡", songs: songs)
                            requestTop100(startIndex: searchIndex + 1)
                            AnalyticsManager.shared.setSelectContentLog(title: "ChartListViewPlayAllButton")
                        }
                }
                .padding(.top, 20)
                
                Divider05()
                    .padding(.top, 15)
                
                ScrollWrapperWithIndex(songs: $songs, index: $searchIndex, contentOffset: $contentOffset, scrollDirection: $scrollDirection) {
                    LazyVStack(spacing: 0, content: {
                        ForEach(0..<songs.count, id: \.self) { index in
                            MusicChartDetailItem(rank: index + 1, song: songs[index])
                        }
                    })
                    .frame(width: getUIScreenBounds().width)
                    
                    Rectangle()
                        .foregroundStyle(.clear)
                        .frame(height: 87)
                }
                .onChange(of: searchIndex, perform: { value in
                    if value < 5 {
                        requestChart(index: value)
                    }
                })
                


                
                
            })
        }
        .navigationBarBackButtonHidden()
        .onAppear(perform: {
            requestChart(index: 0)
            AnalyticsManager.shared.setScreenLog(screenTitle: "RecommendationListView")
        })
    }
    
    private func getUpdateDateText() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M월 d일에 업데이트됨"
        return dateFormatter.string(from: Date())
    }
    
    private func requestChart(index: Int){
        searchIndex = index
        //offset: 시작하는 수. 20 입력시 20등부터 40등까지 보여줌(no limit)
        Task {
            var request = MusicCatalogChartsRequest(kinds: [.dailyGlobalTop], types: [Song.self])
            request.limit = 20
            request.offset = index * 20
            let response = try await request.response().songCharts
            
            print("검색 성공")
            guard let chart = response.first?.items else {
                print("chart error")
                return
            }
            songs += chart
        }

    }
    
    private func requestTop100(startIndex: Int) {
        self.searchIndex = 5 //재생 후 스크롤 시 증가하는 것을 막기위함
        
        for index in startIndex ..< 5 {
            Task {
                var request = MusicCatalogChartsRequest(kinds: [.dailyGlobalTop], types: [Song.self])
                request.limit = 20
                request.offset = index * 20
                let response = try await request.response().songCharts
                
                print("검색 성공")
                guard let chart = response.first?.items else {
                    print("chart error")
                    return
                }
                songs += chart
                print("song count: \(songs.count), index: \(index)")
                playerViewModel.setQueue(songs: songs)
            }
        }
    }
}

//#Preview {
//    ChartListView()
//}
