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

struct MusicChartBottomSheetView: View {
    @EnvironmentObject var manager: LibraryManageModel
    private let lineGray = Color(red: 0.28, green: 0.28, blue: 0.28)
    var song: Song
    var body: some View {
     
            VStack(spacing: 0, content: {
                HStack(alignment: .center,spacing: 0,content: {
                    AsyncImage(url: song.artwork?.url(width: 300, height: 300)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 5, style: .circular)
                            .frame(width: 60, height: 60)
                            .foregroundStyle(ColorSet.lightGray)
                            .padding(.trailing, 13)
                    }
                    .padding(.trailing, 13)

                    
                    VStack(alignment: .leading, spacing: 5, content: {
                        Text(song.title)
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundStyle(.white)
                            .truncationMode(.tail)
                        
                        Text(song.artistName)
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                            .foregroundStyle(ColorSet.charSubGray)
                            .truncationMode(.tail)
                    })
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    SharedAsset.next.swiftUIImage
                        .resizable()
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
                
                BottomSheetItem(image: SharedAsset.artist.swiftUIImage, title: "아티스트 노래 목록 보기")
                    .onTapGesture {
                        manager.push(destination: .artist(.fromSong(data: song)))
                    }
                BottomSheetItem(image: SharedAsset.bookmark.swiftUIImage, title: "즐겨찾기 목록에 추가")
                BottomSheetItem(image: SharedAsset.addPurple.swiftUIImage, title: "뮤모리 추가")
                BottomSheetItem(image: SharedAsset.addPlaylist.swiftUIImage, title: "플레이리스트에 추가")
                BottomSheetItem(image: SharedAsset.share.swiftUIImage, title: "공유하기")
                BottomSheetItem(image: SharedAsset.report.swiftUIImage, title: "신고")
                
            })
            .padding(.bottom, 15)
            .background(ColorSet.background)
        }

}
