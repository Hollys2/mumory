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

public struct MumoryRecommendationView: View {
    @State var isShowing: Bool = false
    @State var isTouch: Bool = false
    @State private var path = NavigationPath()
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var appCoordinator: AppCoordinator
    
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
    
    @State var mostPostedSongIds: [String] = []
    @State var similiarTasteSongIds: [String] = []
    @State var selection: Int = 0
    public init() {
        
    }
    
    public var body: some View {
        
        ZStack(alignment: .top){
            LibraryColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0, content: {
                //최신 인기곡 타이틀
                SubTitle()
                    .onTapGesture {
                        appCoordinator.rootPath.append(LibraryPage.chart)
                    }
                
                //차트 - 가로 페이징
                ChartPagingScrollView(musicChart: $musicChart, scrollViewHeight: $scrollViewHeight) {
                    LazyHGrid(rows: rows, spacing: 0,content: {
                        ForEach(0 ..< musicChart.count, id: \.self) { index in
                            let song = musicChart[index]
                            MusicChartItem(rank: index+1, song: song) //순위 곡 itemv
                                .onTapGesture {
                                    playerViewModel.playNewSong(song: song)
                                    playerViewModel.isShownMiniPlayer = true
                                }
//                                .highPriorityGesture(
//                                    TapGesture()
//                                        .onEnded({ _ in
//                                            playerViewModel.playNewSong(song: song)
//                                            playerViewModel.isShownMiniPlayer = true
//                                        })
//                                )
                        }
                        
                        if musicChart.isEmpty {
                            MusicChartSkeletonView()
                            MusicChartSkeletonView()
                            MusicChartSkeletonView()
                            MusicChartSkeletonView(lineVisible: false)
                            MusicChartSkeletonView()
                            MusicChartSkeletonView()
                            MusicChartSkeletonView()
                            MusicChartSkeletonView(lineVisible: false)

                        }
                    })
                    .padding(.trailing, 33)
                }
                .frame(height: 300)
                
                Divider03()
                    .padding(.top, 15)
                
                FavoriteGenreRecommendationView()
                
                Divider03()
                    .padding(.vertical, 50)
                


                TabView(selection: $selection){
                    ExtraRecommendationView(type: .mostPosted, songIds: $mostPostedSongIds).tag(0)
                    ExtraRecommendationView(type: .similiarTaste, songIds: $similiarTasteSongIds).tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 420)
                
                HStack(spacing: 8, content: {
                    Circle()
                        .fill(selection == 0 ? ColorSet.mainPurpleColor : ColorSet.darkGray)
                        .frame(width: 6, height: 6)
                    
                    Circle()
                        .fill(selection == 1 ? ColorSet.mainPurpleColor : ColorSet.darkGray)
                        .frame(width: 6, height: 6)
                })
                .padding(.top, 25)
                
                Rectangle()
                    .foregroundStyle(Color.clear)
                    .frame(height: 90)
                
                
            })
            
        }
        .onAppear(perform: {
            searchChart(offset: 0)
            Task {
                mostPostedSongIds = await getMostPostedSongs()
                similiarTasteSongIds = await getSimiliarTasteSongs()
            }
            AnalyticsManager.shared.setScreenLog(screenTitle: "MumoryRecommendationView")
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
    
    private func getMostPostedSongs() async -> [String] {
        let db = FBManager.shared.db
        let query = db.collection("RecordData")
            .order(by: "count", descending: true)
            .limit(to: 100)
        var songIds: [String] = []
        guard let snapshots = try? await query.getDocuments() else {return []}
        snapshots.documents.forEach { document in
            let data = document.data()
            guard let songId = data["songId"] as? String else {return}
            songIds.append(songId)
        }
        
        return songIds
    }
    
    private func getSimiliarTasteSongs() async -> [String]{
        let db = FBManager.shared.db
        var songIds: [String] = []
        return await withTaskGroup(of: [String].self) { taskGroup -> [String] in
            for favoriteGenre in currentUserData.favoriteGenres {
                let query = db.collection("User")
                    .whereField("favoriteGenres", arrayContains: favoriteGenre)
                guard let snapshots = try? await query.getDocuments() else {print("a");return []}
                var documents = snapshots.documents.shuffled()
                documents.removeAll(where: {$0.documentID == currentUserData.uId})
                for document in documents {
                    taskGroup.addTask {
                        guard let favoriteDoc = try? await db.collection("User").document(document.documentID).collection("Playlist").document("favorite").getDocument() else {print("c");return []}
                        guard let data = favoriteDoc.data() else {print("d");return []}
                        guard var songIds = data["songIds"] as? [String] else {print("e");return []}
                        return songIds
                    }
                }
            }
            
            for await value in taskGroup {
                songIds.append(contentsOf: value)
                if songIds.count > 100 {
                    let set: Set = Set(songIds)
                    songIds = Array(set)
                    songIds.shuffle()
                    return songIds
                }
            }
            
            let set: Set = Set(songIds)
            songIds = Array(set)
            songIds.shuffle()
            return songIds
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




  
