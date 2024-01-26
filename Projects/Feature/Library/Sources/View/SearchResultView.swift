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
    @EnvironmentObject var recentSearchObject: RecentSearchObject
    @EnvironmentObject var manager: LibraryManageModel

    @Binding var term: String
    @State var musicList: MusicItemCollection<Song> = []
    @State var albumList: MusicItemCollection<Album> = []
    @State var artistList: MusicItemCollection<Artist> = []
    
    var body: some View {
        ZStack{
            //부모뷰의 검색 단어가 변경될 때 마다 검색 요청
            Text(term)
                .opacity(0)
                .onAppear(perform: {
                    requestSearch(term: term)
                })
                .onChange(of: term, perform: { value in
                    Task{
                        requestSearch(term: value)
                        manager.searchTerm = value
                    }
                })
                
            
            ScrollView{
                Text("아티스트")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(.white)
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 35)
                
                LazyVStack(content: {
                    ForEach(artistList){ artist in
                        SearchArtistItem(artist: artist)
                            .gesture(TapGesture().onEnded({ void in
                                print("tap item")
                                manager.nowPage = .artist
                                manager.tappedArtist = artist
                                let userDefault = UserDefaults.standard
                                var recentSearchList = userDefault.value(forKey: "recentSearchList") as? [String] ?? []
                                recentSearchList.removeAll(where: {$0 == artist.name})
                                recentSearchList.insert(artist.name, at: 0)
                                userDefault.set(recentSearchList, forKey: "recentSearchList")
                            }))
                        
                        
                    }
                })
                
                Text("곡")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(.white)
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                LazyVStack(content: {
                    ForEach(musicList){ music in
                        NavigationLink{
                            
                        }label: {
                            SearchSongItem(song: music)
                        }
                        .gesture(TapGesture().onEnded({ void in
                            print("tap item")
                            let userDefault = UserDefaults.standard
                            var recentSearchList = userDefault.value(forKey: "recentSearchList") as? [String] ?? []
                            recentSearchList.removeAll(where: {$0 == music.title})
                            recentSearchList.insert(music.title, at: 0)
                            userDefault.set(recentSearchList, forKey: "recentSearchList")
                        }))
                        
                    }
                })
                
                
            }
        }

    }
    public func requestSearch(term: String){
        Task {
            var request = MusicCatalogSearchRequest(term: term, types: [Song.self, Artist.self])
            request.limit = 20
            let response = try await request.response()
            self.musicList = response.songs
            self.albumList = response.albums
            self.artistList = response.artists
        }
   
    }
}

//#Preview {
//    SearchResultView()
//}
