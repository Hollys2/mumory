//
//  PlaylistItem.swift
//  Feature
//
//  Created by 제이콥 on 11/28/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct PlaylistItem: View {
    var playlist: Playlist
    var radius: CGFloat = 10
    var body: some View {
        VStack(spacing: 0){
            HStack(spacing: 0, content: {
                
                AsyncImage(url: playlist.songs[0].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                    image
                        .resizable()
                        .frame(width: 81, height: 81)
                        .clipShape(RoundedCorner(radius: radius, corners: [.topLeft]))
                } placeholder: {
                    Rectangle()
                        .frame(width: 81, height: 81)
                        .foregroundStyle(.gray)
                        .clipShape(RoundedCorner(radius: radius, corners: [.topLeft]))
                }
                
                
                AsyncImage(url: playlist.songs[1].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                    image
                        .resizable()
                        .frame(width: 81, height: 81)
                        .clipShape(RoundedCorner(radius: radius, corners: [.topRight]))
                } placeholder: {
                    Rectangle()
                        .frame(width: 81, height: 81)
                        .foregroundStyle(.black)
                        .clipShape(RoundedCorner(radius: radius, corners: [.topRight]))
                }


            })
            
            HStack(spacing: 0,content: {
                AsyncImage(url: playlist.songs[2].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                    image
                        .resizable()
                        .frame(width: 81, height: 81)
                        .clipShape(RoundedCorner(radius: radius, corners: [.bottomLeft]))
                } placeholder: {
                    Rectangle()
                        .frame(width: 81, height: 81)
                        .foregroundStyle(.black)
                        .clipShape(RoundedCorner(radius: radius, corners: [.bottomLeft]))
                }
                
                
                AsyncImage(url: playlist.songs[3].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                    image
                        .resizable()
                        .frame(width: 81, height: 81)
                        .clipShape(RoundedCorner(radius: radius, corners: [.bottomRight]))
                } placeholder: {
                    Rectangle()
                        .frame(width: 81, height: 81)
                        .foregroundStyle(.gray)
                        .clipShape(RoundedCorner(radius: radius, corners: [.bottomRight]))
                }

            })
            
            Text(playlist.title)
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .frame(maxWidth: 160, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.top, 10)
                .foregroundStyle(.white)
            
            Text("\(playlist.songIDs.count)곡")
                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(LibraryColorSet.lightGrayTitle)
                .frame(maxWidth: 160, alignment: .leading)
                .padding(.top, 5)

        }
       
    }
    
//    @ViewBuilder
//    func getArtWork(index: Int) -> some View {
//        let listCount = playlist.musicList.count
//        if index > listCount{
//            return Rectangle()
//        }else {
//            let view = Image(systemName: "")
//            return view
//        }
////        let musicItemID = MusicItemID(rawValue: songId)
////        let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
////        let response = try await request.response()
////        guard let song = response.items.first else {
////            throw NSError(domain: "GoogleMapSample", code: 1, userInfo: [NSLocalizedDescriptionKey: "Song not found"])
////        }
////
////        guard let artworkUrl = song.artwork?.url(width: 400, height: 400) else {return nil}
////        return artworkUrl
//   
//    }
}

//#Preview {
//    PlaylistItem()
//}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

//struct Thumbnail: View{
//    var playlist: Playlist = Playlist(name: "", musicList: [])
//    var index = 0
//    var body: some View{
//        
//        VStack{
//            if index > playlist.musicList.count{
//                Rectangle()
//            }else{
//                AsyncImage(url: try await fetchSongInfo(songId: playlist.musicList[index]).artwork?.url(width: 100, height: 100))
//            }
//        }
//    }
//}

//func fetchSongInfo(songId: String) async throws -> Song {
//    let musicItemID = MusicItemID(rawValue: songId)
//    let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
//    let response = try await request.response()
//    guard let song = response.items.first else {
//        throw NSError(domain: "GoogleMapSample", code: 1, userInfo: [NSLocalizedDescriptionKey: "Song not found"])
//    }
//
//    let artworkUrl = song.artwork?.url(width: 400, height: 400)
//    return song
//}

struct AsyncDataFetcher: View {
//    @Binding var playlist: Playlist
//    @Binding var index: Int
    var completion: (Result<Song, Error>) -> Void
    init(completion: @escaping (Result<Song, Error>) -> Void) {
        self.completion = completion
    }

    var body: some View {
        // 여기서 비동기 작업을 수행하고 결과를 completion 클로저에 전달
        Task {
            do {
                let result = try await fetchData(songId: "")
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }

        // 여기에는 빈 내용을 반환해도 되고, 필요한 경우에는 다른 UI를 표시할 수 있습니다.
        return EmptyView()
    }

    func fetchData(songId: String) async throws -> Song {
        let musicItemID = MusicItemID(rawValue: songId)
        let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
        let response = try await request.response()
        guard let song = response.items.first else {
            throw NSError(domain: "GoogleMapSample", code: 1, userInfo: [NSLocalizedDescriptionKey: "Song not found"])
        }
        return song
    }
}

