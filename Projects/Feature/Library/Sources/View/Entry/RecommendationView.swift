//
//  RecommendationView.swift
//  Feature
//
//  Created by 제이콥 on 11/20/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit
import Core

public struct RecommendationView: View {
    @State var isShowing: Bool = false
    @State var isTouch: Bool = false
    @State private var path = NavigationPath()
    @EnvironmentObject var playerManager: PlayerViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var manager: LibraryManageModel
    
    @State private var contentOffset: CGPoint = .zero
    @State private var scrollViewHeight: CGFloat = .zero
    @State private var scrollViewVisibleHeight: CGFloat = .zero
    
    var rows: [GridItem] = [
        GridItem(.flexible(minimum: 70, maximum: 70),spacing: 0),
        GridItem(.flexible(minimum: 70, maximum: 70),spacing: 0),
        GridItem(.flexible(minimum: 70, maximum: 70),spacing: 0),
        GridItem(.flexible(minimum: 70, maximum: 70),spacing: 0)
    ]
    let titleList = Array(0..<40).map { "title\($0)" }
    
    @State var musicChart: MusicItemCollection<Song> = []
    @State var chartChangeDetectValue: Bool = false
    @State var testValue: CGFloat = 200
    public init() {
        
    }
    
    public var body: some View {
        
        ZStack(alignment: .top){
            LibraryColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0, content: {
                //최신 인기곡 타이틀
                SubTitle()
                    .onTapGesture {
                        manager.push(destination: .chart)
                    }
                
                //차트 - 가로 페이징
                ChartPagingScrollView(musicChart: $musicChart, scrollViewHeight: $scrollViewHeight) {
                    LazyHGrid(rows: rows, spacing: 0,content: {
                        ForEach(0 ..< musicChart.count, id: \.self) { index in
                            let song = musicChart[index]
                            MusicChartItem(rank: index+1, song: song) //순위 곡 item
                                .frame(width: currentUserData.width - 40)
                                .onTapGesture {
                                    playerManager.playNewSong(song: song)
                                }
                        }
                    })
                }
                .frame(height: 300)
                
                Divider()
                    .frame(maxWidth: .infinity)
                    .frame(height: 0.3)
                    .background(ColorSet.subGray)
                    .padding(.top, 15)
                
                FavoriteGenreRecommendationView()
                
                Rectangle()
                    .foregroundStyle(Color.clear)
                    .frame(height: 90)
                
                
            })
            
        }
        .onAppear(perform: {
            searchChart(offset: 0)
        })
        
        
    }
    
    private func searchChart(offset: Int){
        
    Task {
            var request = MusicCatalogChartsRequest(kinds: [.dailyGlobalTop], types: [Song.self])
            request.offset = offset
            let response = try await request.response().songCharts
            
            print("검색 성공")
            musicChart = (response.first?.items)!
            chartChangeDetectValue = !chartChangeDetectValue
    
        }
        
        
        
    }
}

private struct SubTitle: View {
    var body: some View {
        HStack(spacing: 0, content: {
            Text("최신 인기곡")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                .foregroundStyle(.white)
            Spacer()
            SharedAsset.next.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 17, height: 17)
        })
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}



