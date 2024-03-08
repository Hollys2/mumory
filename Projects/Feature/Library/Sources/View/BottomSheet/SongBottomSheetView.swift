//
//  MusicChartBottomSheetView.swift
//  Feature
//
//  Created by 제이콥 on 2/14/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import MusicKit
import Shared
enum bottomSheetType {
    case withoutArtist
    case withoutBookmark
}
struct SongBottomSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var manager: LibraryManageModel
    private let lineGray = Color(red: 0.28, green: 0.28, blue: 0.28)
    var song: Song
    var types: [bottomSheetType] = []
    
    init(song: Song, types: [bottomSheetType]) {
        self.song = song
        self.types = types
    }
    
    init(song: Song){
        self.song = song
    }

    var body: some View {
     
            VStack(spacing: 0, content: {
                HStack(alignment: .center,spacing: 0,content: {
                    AsyncImage(url: song.artwork?.url(width: 300, height: 300)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 5, style: .circular)
                            .frame(width: 60, height: 60)
                            .foregroundStyle(ColorSet.lightGray)
                    }

                    
                    VStack(alignment: .leading, spacing: 5, content: {
                        Text(song.title)
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Text(song.artistName)
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                            .foregroundStyle(ColorSet.charSubGray)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    })
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 13)

                    
                    SharedAsset.next.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .padding(.leading, 20)
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                
                Divider()
                    .frame(maxWidth: .infinity)
                    .frame(height: 0.5)
                    .background(lineGray)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 10)
                
                if !types.contains(.withoutArtist) {
                    BottomSheetItem(image: SharedAsset.artist.swiftUIImage, title: "아티스트 노래 목록 보기")
                        .onTapGesture {
                            dismiss()
                            getArtist(song: song) { artist in
                                manager.push(destination: .artist(artist: artist))
                            }
                        }
                }
                
                if !types.contains(.withoutBookmark){
                    BottomSheetItem(image: SharedAsset.bookmark.swiftUIImage, title: "즐겨찾기 목록에 추가")
                }
                
                BottomSheetItem(image: SharedAsset.addPurple.swiftUIImage, title: "뮤모리 추가", type: .accent)
                BottomSheetItem(image: SharedAsset.addPlaylist.swiftUIImage, title: "플레이리스트에 추가")
                    .onTapGesture {
                        dismiss()
                        manager.push(destination: .saveToPlaylist(songs: [song]))
                    }
                BottomSheetItem(image: SharedAsset.share.swiftUIImage, title: "공유하기")
                BottomSheetItem(image: SharedAsset.report.swiftUIImage, title: "신고")
                
            })
            .padding(.bottom, 15)
            .background(ColorSet.background)
        }
    
    private func getArtist(song: Song, completion: @escaping (Artist) -> ())  {
        var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: song.id)
        request.properties = [.artists]
        Task{
            do{
                let response = try await request.response().items
                guard let song = response.first else {
                    print("no song")
                    return
                }
                
                guard let artist = song.artists?.first else {
                    print("no artist")
                    return
                }
                
                completion(artist)
                
            }catch(let error) {
                print("error: \(error.localizedDescription)")
            }
        }
    }

}