//
//  SearchResultView.swift
//  Feature
//
//  Created by 제이콥 on 12/4/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct SearchResultView: View {
    @EnvironmentObject private var recentSearchObject: RecentSearchObject
    @EnvironmentObject private var manager: LibraryManageModel
    @EnvironmentObject private var userManager: UserViewModel
    
    @Binding var term: String
    @State private var musicList: MusicItemCollection<Song> = []
    @State private var artistList: MusicItemCollection<Artist> = []
    
    @State private var timer: Timer?
    @State private var localTime = 0.0
    
    @State private var offset: CGPoint = .zero
    @State private var contentSize: CGSize = .zero
    @State private var requestIndex = 0
    @State private var haveToLoadNextPage: Bool = false
    
    var body: some View {
        ZStack{
            ScrollWrapperWithContentSize(contentOffset: $offset, contentSize: $contentSize){
                VStack(spacing: 0, content: {
                    if musicList.count == 0 && artistList.count == 0 {
                        Text("검색 결과가 없습니다")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                            .foregroundStyle(ColorSet.subGray)
                            .padding(.top, 130)
                            .onChange(of: term, perform: { value in
                                localTime = 0.0
                                requestIndex = 0
                            })
                            .onChange(of: localTime, perform: { value in
                                if localTime == 0.8 {
                                        requestArtist(term: term)
                                        requestSong(term: term, index: 0)
                                }
                            })
                        
                    }else {
                        LazyVStack(spacing: 0, content: {
                            Text("아티스트")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                .foregroundStyle(.white)
                                .padding(.leading, 20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 16)
                                .padding(.bottom, 9)
                            
                            ForEach(artistList){ artist in
                                SearchArtistItem(artist: artist)
                                    .onTapGesture {
                                        print("tap item")
                                        manager.page = .search(term: term)
                                        manager.push(destination: .artist(.fromArtist(data: artist)))
                                        let userDefault = UserDefaults.standard
                                        var recentSearchList = userDefault.value(forKey: "recentSearchList") as? [String] ?? []
                                        recentSearchList.removeAll(where: {$0 == artist.name})
                                        recentSearchList.insert(artist.name, at: 0)
                                        userDefault.set(recentSearchList, forKey: "recentSearchList")
                                    }
                            }
                            
                            Rectangle()
                                .frame(maxWidth: .infinity)
                                .frame(height: 8)
                                .background(Color.black)
                            
                            Text("곡")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.white)
                                .padding(.leading, 20)
                                .padding(.top, 16)
                                .padding(.bottom, 9)
                            
                            ForEach(musicList){ music in
                                SearchSongItem(song: music)
                                    .onTapGesture {
                                        print("tap item")
                                        let userDefault = UserDefaults.standard
                                        var recentSearchList = userDefault.value(forKey: "recentSearchList") as? [String] ?? []
                                        recentSearchList.removeAll(where: {$0 == music.title})
                                        recentSearchList.insert(music.title, at: 0)
                                        userDefault.set(recentSearchList, forKey: "recentSearchList")
                                    }
                                
                            }
                            
                            Rectangle()
                                .frame(height: 87)
                                .foregroundStyle(.clear)
                        })
                        
                    }
                })
                .frame(width: userManager.width)
                
                
                
            }
            .onChange(of: offset, perform: { value in
                if offset.y/contentSize.height > 0.7 {
                    if !haveToLoadNextPage {
                        haveToLoadNextPage = true
                        requestIndex += 1
                        requestSong(term: term, index: requestIndex)
                    }
                }else {
                    haveToLoadNextPage = false
                }
            })
        }
        .onAppear(perform: {
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
                localTime += 0.2
            }
        })
        .onDisappear(perform: {
            timer?.invalidate()
        })
        
    }
    public func requestArtist(term: String){
        var request = MusicCatalogSearchRequest(term: term, types: [Artist.self])
        request.limit = 20
        
        Task {
            do {
                let response = try await request.response()
                DispatchQueue.main.async {
                    self.artistList = response.artists
                }
            }catch(let error) {
                print("error: \(error.localizedDescription)")
            }
            
        }
        
    }
    
    public func requestSong(term: String, index: Int) {
        print("request song")
        var request = MusicCatalogSearchRequest(term: term, types: [Song.self])
        request.limit = 20
        request.offset = index * 20
        Task {
            do {
                let response = try await request.response()
                DispatchQueue.main.async {
                    self.musicList += response.songs
                }
            }catch(let error) {
                print("error: \(error.localizedDescription)")
            }
            
        }
    }
}

//#Preview {
//    SearchResultView()
//}
