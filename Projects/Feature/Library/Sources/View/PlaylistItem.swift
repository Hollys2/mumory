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
                
                //                AsyncImage(url: getArtWork(songId: playlist.musicList[0])) { image in
                //                    image
                //                } placeholder: {
                //                    ProgressView()
                //                }
                
                
                Rectangle()
                    .frame(width: 81, height: 81)
                    .foregroundStyle(.gray)
                    .clipShape(RoundedCorner(radius: radius, corners: [.topLeft]))
                
                Rectangle()
                    .frame(width: 81, height: 81)
                    .foregroundStyle(.black)
                    .clipShape(RoundedCorner(radius: radius, corners: [.topRight]))

            })
            
            HStack(spacing: 0,content: {
                Rectangle()
                    .frame(width: 81, height: 81)
                    .foregroundStyle(.black)
                    .clipShape(RoundedCorner(radius: radius, corners: [.bottomLeft]))

                
                Rectangle()
                    .frame(width: 81, height: 81)
                    .foregroundStyle(.gray)
                    .clipShape(RoundedCorner(radius: radius, corners: [.bottomRight]))

            })
            
            Text(playlist.name)
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .frame(maxWidth: 160, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.top, 10)
                .foregroundStyle(.white)
            
            Text("\(playlist.musicList.count)곡")
                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(LibraryColorSet.lightGrayTitle)
                .frame(maxWidth: 160, alignment: .leading)
                .padding(.top, 5)

        }
    }
    
    struct thumbnailImage{
        var playlist: Playlist = Playlist(name: "", musicList: [])
        var index = 0
        var body: some View{
            Group{
                if index > playlist.musicList.count{
                    Rectangle()
                }else{
                    Image(systemName: "")
                }
            }
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


