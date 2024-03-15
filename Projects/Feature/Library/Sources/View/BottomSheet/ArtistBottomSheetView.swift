//
//  ArtistBottomSheet.swift
//  Feature
//
//  Created by 제이콥 on 2/14/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct ArtistBottomSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var manager: LibraryCoordinator
    private let lineGray = Color(red: 0.28, green: 0.28, blue: 0.28)
    let artist: Artist
    let songs: [Song]
    
    init(artist: Artist, songs: [Song]) {
        self.artist = artist
        self.songs = songs
    }
    
    var body: some View {
        VStack(spacing: 0, content: {
            HStack(spacing: 13, content: {
                AsyncImage(url: artist.artwork?.url(width: 300, height: 300)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        
                } placeholder: {
                    Circle()
                        .frame(width: 60, height: 60)
                        .foregroundStyle(.gray)
                }

              
                Text(artist.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(.white)
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            
            Divider()
                .frame(maxWidth: .infinity)
                .frame(height: 0.5)
                .background(lineGray)
                .padding(.horizontal, 4)
                .padding(.bottom, 10)
            
            BottomSheetItem(image: SharedAsset.addPlaylist.swiftUIImage, title: "플레이리스트에 추가")
                .onTapGesture {
                    dismiss()
                    manager.push(destination: .saveToPlaylist(songs: songs))
                }
            BottomSheetItem(image: SharedAsset.share.swiftUIImage, title: "공유하기")
            BottomSheetItem(image: SharedAsset.report.swiftUIImage, title: "신고")
           
        })
        .background(ColorSet.background)
    }
}

//#Preview {
//    ArtistBottomSheet()
//}
