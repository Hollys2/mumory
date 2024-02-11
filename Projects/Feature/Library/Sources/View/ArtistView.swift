//
//  ArtistView.swift
//  Feature
//
//  Created by 제이콥 on 12/6/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct ArtistView: View {
    @State private var contentOffset: CGPoint = .zero
    @State private var scrollViewHeight: CGFloat = .zero
    @State private var scrollViewVisibleHeight: CGFloat = .zero
    @EnvironmentObject var manager: LibraryManageModel
    @State var musicList: MusicItemCollection<Song> = []
    
    var body: some View {
        ZStack{
            LibraryColorSet.background.ignoresSafeArea()
//            첫번째 뷰 - 아티스트 이미지
            VStack{
//                ScrollViewWrapper(contentOffset: $contentOffset, scrollViewHeight: $scrollViewHeight, visibleHeight: $scrollViewVisibleHeight) {
                    
                    GeometryReader(content: { geometry in
                        AsyncImage(url: manager.tappedArtist?.artwork?.url(width: 1000, height: 1000)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: geometry.size.width)
                                .clipped()
                                .offset(x: 0, y: contentOffset.y > 0 ? 0 : -contentOffset.y)
                            
                        } placeholder: {
                            Rectangle()
                                .frame(width: geometry.size.width, height: geometry.size.width)
                                .offset(x: 0, y: contentOffset.y > 0 ? 0 : -contentOffset.y)
                        }
                        
                    })
                    
                    Spacer()
                    
                    ForEach(0...50, id: \.self) {index in
                        Rectangle()
                            .foregroundStyle(.clear)
                    }
                    .foregroundStyle(.clear)
                }
                .ignoresSafeArea()
//                .onChange(of: contentOffset, perform: { value in
//                    contentOffset = value.y > 0 ? CGPoint(x: 0, y: 0) : value
//                    print(value)
//                })
//                .onAppear(perform: {
//                    contentOffset = CGPoint(x: 0, y: 0)
//                })

              

//            }
            
            //두번째 뷰 - 상단 버튼들
            VStack(spacing: 0){
                GeometryReader(content: { geometry in
//                    ScrollViewWrapper(contentOffset: $contentOffset, scrollViewHeight: $scrollViewHeight, visibleHeight: $scrollViewVisibleHeight) {
                    
                    ScrollViewWrapper(contentOffset: $contentOffset, scrollViewHeight: $scrollViewHeight, visibleHeight: $scrollViewVisibleHeight) {
                        MusicList(musicList: $musicList)
                            .environmentObject(manager)
                            .padding(.top, geometry.size.width - geometry.safeAreaInsets.top - 45) //사진 사이즈 - 세이프에이리아높이 - (그라데이션 + 아티스트이름)
                        //                    }
                    }

                })
            }
            
            VStack{
                HStack{
                    SharedAsset.back.swiftUIImage
                        .onTapGesture {
                            manager.page = .search
                        }
                    Spacer()
                    SharedAsset.menuWhite.swiftUIImage
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.top, 19)
                
                Spacer()
            }
            
            
        }
        .onAppear(perform: {
            requestSearch(term: manager.tappedArtist?.name ?? "")
        })
    }
    
    public func requestSearch(term: String){
        print("request search")
        Task{
            var request = MusicCatalogSearchRequest(term: term, types: [Song.self])
            request.limit = 20
            let response = try await request.response()
            self.musicList = response.songs
        }
    }
    
}

struct MusicList: View {
    @Binding var musicList: MusicItemCollection<Song>
    @EnvironmentObject var manager: LibraryManageModel
    
    var body: some View {
        ZStack{
            VStack(spacing: 0){
                SharedAsset.artistGradiant.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                
                LibraryColorSet.background
                
                Spacer()
            }

            
            VStack{
                Text(manager.tappedArtist?.name ?? "Artist")
                    .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 40))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.white)
                    .padding(.leading, 20)
                    .padding(.top, 10)
                
                ForEach(musicList, id: \.id) {song in
                    MusicItem(song: song)
                }
                .padding(.top, 50)
            }
            
        }
        
        
    }
}

struct ScrollOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
//#Preview {
//    ArtistView()
//}
