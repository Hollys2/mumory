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

struct RecommendationBottomSheetView: View {
    var songs: [Song]
    var title: String
    init(songs: [Song], title: String) {
        self.songs = songs
        self.title = title
    }
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appCoordinator: AppCoordinator
    private let lineGray = Color(red: 0.28, green: 0.28, blue: 0.28)
    
    var body: some View {
        VStack(spacing: 0, content: {
            HStack(alignment: .center,spacing: 10,content: {
                MiniPlaylistImage(songs: songs)
                
                Text(title)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            
            Divider05()
                .padding(.horizontal, 4)
                .padding(.bottom, 10)
            
            BottomSheetItem(image: SharedAsset.addPlaylist.swiftUIImage, title: "플레이리스트에 추가")
                .onTapGesture {
                    dismiss()
                    appCoordinator.rootPath.append(LibraryPage.saveToPlaylist(songs: songs))
                }
      
            BottomSheetItem(image: SharedAsset.report.swiftUIImage, title: "신고")
                .onTapGesture {
                    dismiss()
                    appCoordinator.rootPath.append(MumoryPage.report)
                }
        })
        .padding(.bottom, 15)
        .background(ColorSet.background)
    }
}

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
                        .fill(ColorSet.darkGray)
                        .frame(width: imageSize, height: imageSize)
                }else{
                    AsyncImage(url: songs[0].artwork?.url(width: 100, height: 100),transaction: Transaction(animation: .default)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: imageSize, height: imageSize)
                        default:
                            Rectangle()
                                .fill(ColorSet.skeleton)
                                .frame(width: imageSize, height: imageSize)
                        }
                    }
                }
                
                //세로줄(구분선)
                Rectangle()
                    .frame(width: border, height: imageSize)
                    .foregroundStyle(ColorSet.background)
                
                //2번째 이미지
                if songs.count < 2{
                    Rectangle()
                        .fill(ColorSet.darkGray)
                        .frame(width: imageSize, height: imageSize)
                }else{
                    AsyncImage(url: songs[0].artwork?.url(width: 100, height: 100),transaction: Transaction(animation: .default)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: imageSize, height: imageSize)
                        default:
                            Rectangle()
                                .fill(ColorSet.skeleton)
                                .frame(width: imageSize, height: imageSize)
                        }
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
                        .fill(ColorSet.darkGray)
                        .frame(width: imageSize, height: imageSize)
                }else{
                    AsyncImage(url: songs[0].artwork?.url(width: 100, height: 100),transaction: Transaction(animation: .default)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: imageSize, height: imageSize)
                        default:
                            Rectangle()
                                .fill(ColorSet.skeleton)
                                .frame(width: imageSize, height: imageSize)
                        }
                    }
                }
                
                //세로줄 구분선
                Rectangle()
                    .frame(width: 0.5, height: imageSize)
                    .foregroundStyle(ColorSet.background)
                
                //4번째 이미지
                if songs.count <  4 {
                    Rectangle()
                        .fill(ColorSet.darkGray)
                        .frame(width: imageSize, height: imageSize)
                }else{
                    AsyncImage(url: songs[0].artwork?.url(width: 100, height: 100),transaction: Transaction(animation: .default)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: imageSize, height: imageSize)
                        default:
                            Rectangle()
                                .fill(ColorSet.skeleton)
                                .frame(width: imageSize, height: imageSize)
                        }
                    }
                }
                
            })
        })
        .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
    }
}
