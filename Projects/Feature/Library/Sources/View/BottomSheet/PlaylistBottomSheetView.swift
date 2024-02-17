//
//  PlaylistBottomSheetView.swift
//  Feature
//
//  Created by 제이콥 on 2/14/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct PlaylistBottomSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var manager: LibraryManageModel
    private let lineGray = Color(red: 0.28, green: 0.28, blue: 0.28)
    
    @State var playlist: MusicPlaylist
    @State var songs: [Song]
    var body: some View {
        VStack(spacing: 0, content: {
            HStack(alignment: .center,spacing: 10,content: {
                MiniPlaylistImage(songs: songs)
                
                
                Text(playlist.title)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(.white)
                    .truncationMode(.tail)
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            
            Divider()
                .frame(maxWidth: .infinity)
                .frame(height: 0.5)
                .background(lineGray)
                .padding(.horizontal, 4)
            
            BottomSheetItem(image: SharedAsset.editPlaylist.swiftUIImage, title: "플레이리스트 이름 수정")
            
            BottomSheetItem(image: SharedAsset.addMusic.swiftUIImage, title: "음악 추가")
                .onTapGesture {
                    dismiss()
                    manager.push(destination: .addSong(originPlaylist: playlist))
                }
            BottomSheetItem(image: SharedAsset.share.swiftUIImage, title: "공유하기")
            BottomSheetItem(image: SharedAsset.deleteMumoryDetailMenu.swiftUIImage, title: "플레이리스트에 삭제")
            BottomSheetItem(image: SharedAsset.report.swiftUIImage, title: "신고")
            
        })
        .padding(.bottom, 15)
        .background(ColorSet.background)
    }
}

//#Preview {
//    PlaylistBottomSheetView()
//}

private struct MiniPlaylistImage: View {
    var songs: [Song]
    
    let emptyGray = Color(red: 0.18, green: 0.18, blue: 0.18)
    let imageSize = 30.0
    let border = 0.5
    var body: some View {
        VStack(spacing: 0, content: {
            HStack(spacing: 0, content: {
                //1번째 이미지
                if songs.count < 1 {
                    Rectangle()
                        .frame(width: imageSize, height: imageSize)
                        .foregroundStyle(emptyGray)
                }else{
                    AsyncImage(url: songs[0].artwork?.url(width: 100, height: 100) ?? URL(string: "")) { image in
                        image
                            .resizable()
                            .frame(width: imageSize, height: imageSize)
                    } placeholder: {
                        Rectangle()
                            .frame(width: imageSize, height: imageSize)
                            .foregroundStyle(emptyGray)
                    }
                }
                
                //세로줄(구분선)
                Rectangle()
                    .frame(width: border, height: imageSize)
                    .foregroundStyle(ColorSet.background)
                
                //2번째 이미지
                if songs.count < 2{
                    Rectangle()
                        .frame(width: imageSize, height: imageSize)
                        .foregroundStyle(emptyGray)
                }else{
                    AsyncImage(url: songs[1].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                        image
                            .resizable()
                            .frame(width: imageSize, height: imageSize)
                    } placeholder: {
                        Rectangle()
                            .frame(width: imageSize, height: imageSize)
                            .foregroundStyle(emptyGray)
                    }
                }
                
                
            })
            
            //가로줄(구분선)
            Rectangle()
                .frame(width: imageSize * 2 + border, height: border)
                .foregroundStyle(ColorSet.background)
            
            HStack(spacing: 0,content: {
                //3번째 이미지
                if songs.count < 3 {
                    Rectangle()
                        .frame(width: imageSize, height: imageSize)
                        .foregroundStyle(emptyGray)
                }else{
                    AsyncImage(url: songs[2].artwork?.url(width: 100, height: 100) ?? URL(string: "")) { image in
                        image
                            .resizable()
                            .frame(width: imageSize, height: imageSize)
                    } placeholder: {
                        Rectangle()
                            .frame(width: imageSize, height: imageSize)
                            .foregroundStyle(emptyGray)
                    }
                }
                
                //세로줄 구분선
                Rectangle()
                    .frame(width: 0.5, height: imageSize)
                    .foregroundStyle(ColorSet.background)
                
                //4번째 이미지
                if songs.count <  4 {
                    Rectangle()
                        .frame(width: imageSize, height: imageSize)
                        .foregroundStyle(emptyGray)
                }else{
                    AsyncImage(url: songs[3].artwork?.url(width: 100, height: 100) ?? URL(string: "")) { image in
                        image
                            .resizable()
                            .frame(width: imageSize, height: imageSize)
                    } placeholder: {
                        Rectangle()
                            .frame(width: imageSize, height: imageSize)
                            .foregroundStyle(emptyGray)
                    }
                }
                
            })
        })
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
    }
}
