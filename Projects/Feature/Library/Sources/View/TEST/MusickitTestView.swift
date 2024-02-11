//
//  MusickitTestView.swift
//  Feature
//
//  Created by 제이콥 on 2/3/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import MusicKit

public struct MusickitTestView: View {
    @State var list: MusicItemCollection<Album> = []
    public init(){}
    public var body: some View {
        VStack(spacing: 0) {
            GenreTitle(genreName: MusicGenreHelper().genreName(id: 51))
            
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(0...10, id: \.self){ song in
//                        RecentMusicItem()
                    }
                }
            }
            
        }
        .background(.black)

    }
    private func test1(){
        Task {
            var request = MusicCatalogSearchRequest(term: "라이즈", types: [Song.self, Artist.self, Album.self])
            request.limit = 20
            let response = try await request.response()
//            self.musicList = response.songs
            self.list = response.albums
//            self.artistList = response.artists
            
            for album in list {
                print("name: \(album.genreNames), genre: \(String(describing: album.genres?.first?.id))")
            }
        }
    }
    private func getGenre() {
        let musicItemID = MusicItemID(rawValue: String(1289))
        let request = MusicCatalogResourceRequest<Genre>(matching: \.id, equalTo: musicItemID)
        Task{
            let response = try await request.response()
            if let genre = response.items.first {
                print("genre id: \(genre.id), name: \(genre.name)")

                let reque = MusicCatalogChartsRequest(genre: genre, types: [Song.self])
                
                let result = try await reque.response().songCharts.first
                result?.items.forEach { song in
                    print(song.title)
                }
            }else {
                print("no genre")
            }
        }
        
//        let rerquest = MusicCatalogChartsRequest<Genre>()
//        MusicRelationshipProperty.
    }
    private func genreCheck(){
        let genreRequest = MusicCatalogResourceRequest<Genre>(matching: \.id, equalTo: "1153")
//        genreRequest.
//        MusicCatalogResourceRequest(matching: , equalTo: Value)
//        genreRequest.
        Task{
            let response = try await genreRequest.response()
            print(response.items)
        }
    }
    private func MusicTest() {
        var index = 1
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            index += 1
            if index == 2000 {
                timer.invalidate()
            }
            
            let musicItemID = MusicItemID(rawValue: String(index))
            let request = MusicCatalogResourceRequest<Genre>(matching: \.id, equalTo: musicItemID)
            Task{
                let response = try await request.response()
                if let genre = response.items.first {
                    print("genre id: \(genre.id), name: \(genre.name)")
                }else {
                    print("no genre")
                }
            }
            
        }
    }
}

#Preview {
    MusickitTestView()
}
