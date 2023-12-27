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
    @EnvironmentObject var setView: SetView
    @EnvironmentObject var nowPlaySong: NowPlaySong
    var rows: [GridItem] = [
        GridItem(.flexible(minimum: 70, maximum: 70)),
        GridItem(.flexible(minimum: 70, maximum: 70)),
        GridItem(.flexible(minimum: 70, maximum: 70)),
        GridItem(.flexible(minimum: 70, maximum: 70))
    ]
    let titleList = Array(0..<40).map { "title\($0)" }
    @State var musicChart: MusicItemCollection<Song> = []
    
    public init() {
        
    }
    
    public var body: some View {
            ZStack{
                LibraryColorSet.background.ignoresSafeArea() //임시 배경 색. 나중에 삭제하기
                Color.clear.ignoresSafeArea()
                VStack(spacing: 0, content: {
                    HStack(spacing: 0, content: {
                        Text("최신 인기곡")
                            .foregroundStyle(.white)
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        
                        Spacer()
                        
                        NavigationLink {
                            //
                        } label: {
                            SharedAsset.next.swiftUIImage
                        }
                    })
                    .padding(20)
                    .padding(.top, 6)
                    
                    //최신 곡 순위
                    UIScrollViewWrapper{
                        LazyHGrid(rows: rows, content: {
                            ForEach(0 ..< musicChart.count, id: \.self) { index in
                                let song = musicChart[index]
                                let rank = index + 1
                                
                                MusicChartItem(rank: rank, song: song) //순위 곡 item
                                    .frame(width: 330, alignment: .leading)
                                    .onTapGesture {
                                        nowPlaySong.song = song
//                                        isShowing = true
                                    }
//                                    .sheet(isPresented: $isShowing, content: {
//                                        bottomView(isTouch: $isShowing)
//                                            .presentationDragIndicator(.visible)
//                                            .presentationDetents([.fraction(0.5)])
//                                            .environmentObject(setView)
//    
//                                    })
                                
                            }
                        })
                    }
                    
    //                UIScrollViewWrapper{
//                        ScrollView(.horizontal) {
                      
//                    }
//                    .scrollIndicators(.hidden)

    //                .onChange(of: musicChart) { newValue in
    //
    //                }
    //                }
                    
                    

                    
                    Spacer()
                })
                .onAppear(perform: {
                    searchChart(offset: 0)
                })
                
            }
        
    }
    
    private func searchChart(offset: Int){
     
        
        //offset: 시작하는 수. 20 입력시 20등부터 40등까지 보여줌(no limit)
        Task {
            
//            switch(authRequest){
//            case .authorized:
//                do{
//                    print("허락됨")
//                    let request = MusicCatalogChartsRequest(kinds: [.dailyGlobalTop], types: [Song.self])
//                    let response = try await request.response()
//                    print("검색 성공")
//                }catch{
//                    print("search error")
//                }
//                
//            default:
//                print("안됨")
//            }
            
            var request = MusicCatalogChartsRequest(kinds: [.dailyGlobalTop], types: [Song.self])
            request.offset = offset
            let response = try await request.response().songCharts
            
            print("검색 성공")
            musicChart = (response.first?.items)!
            musicChart.forEach { song in
                print(song.title)
            }
            print(musicChart.count)
        }

   
 
    }
}

struct bottomView: View{
    @State var height: CGFloat = 300
    @Binding var isTouch: Bool
    @EnvironmentObject var setView: SetView

    var body: some View{
        GeometryReader(content: { geometry in
            VStack{
                Text("아티스트페이지로 이동")
                    .onTapGesture {
                        setView.isSearchViewShowing = true
                        isTouch = false
                        print("tap 탭탭탭")
                        print("set view isShowing: \(setView.isSearchViewShowing)")
                    }
            }
            .frame(width: geometry.size.width, height: height)
        })
    }
}

//#Preview {
//    RecommendationView()
//}



