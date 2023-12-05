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
    @Binding var term: String
    @State var musicList: MusicItemCollection<Song> = []
    @State var albumList: MusicItemCollection<Album> = []
    @State var artistList: MusicItemCollection<Artist> = []
    
    var body: some View {
        ZStack{
            Text(term)
                .opacity(0)
                .onChange(of: term, perform: { value in
                    requestSearch(term: value)
                    print("term change")
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
                        NavigationLink {
                            //가수 페이지로 넘어가기
                        } label: {
                            SearchArtistItem(artist: artist)
                        }
                    }
                })
                
                Text("곡")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(.white)
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                LazyVStack(content: {
                    ForEach(musicList){ music in
                        NavigationLink {
                            //곡 눌렀을 때 동작
                        } label: {
                            SearchSongItem(song: music)
                        }
                    }
                    
                })
            }
        }
    }
    public func requestSearch(term: String){
        print("request search")
        Task{
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
