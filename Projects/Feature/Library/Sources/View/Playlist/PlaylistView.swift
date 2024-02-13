//
//  PlaylistView.swift
//  Feature
//
//  Created by 제이콥 on 2/12/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct PlaylistView: View {
    @EnvironmentObject var manager: LibraryManageModel
    @EnvironmentObject var userManager: UserViewModel
    @State var playlist: MusicPlaylist
    @State var offset: CGPoint = .zero
    var body: some View {
        ZStack(alignment: .top){
            //이미지
            PlaylistImage(playlist: $playlist)
                .offset(y: offset.y < -userManager.topInset ? -(offset.y+userManager.topInset) : 0)
            
            SimpleScrollView(contentOffset: $offset) {
                
                VStack(spacing: 0, content: {
                    ZStack(alignment: .top){
                        SharedAsset.bottomGradient.swiftUIImage
                            .resizable()
                            .frame(width: userManager.width, height: 45)
                        
                        Text(playlist.title)
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 24))
                            .frame(width: userManager.width, alignment: .center)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .foregroundStyle(.white)
                            .padding(.top, 20)
                    }
                    .padding(.top, userManager.width - userManager.topInset - 30) //사진 세로 길이 - 세이프공간 높이 - 그라데이션과 사진이 겹치는 부분
              
                   
                        VStack(spacing: 0, content: {
                            HStack(spacing: 5, content: {
                                SharedAsset.lock.swiftUIImage
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 13, height: 13)
                                
                                Text("나만보기")
                                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                                    .foregroundStyle(ColorSet.subGray)
                            })
                            .padding(.top, 10)
                            
                            HStack(alignment: .bottom,spacing: 8, content: {
                                Text("\(playlist.songIDs.count)곡")
                                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                                    .foregroundStyle(ColorSet.subGray)
                                Spacer()
                                EditButton()
                                PlayAllButton()
                            })
                            .padding(.horizontal, 20)
                            .padding(.top, 25)
                            
                            LazyVStack(spacing: 0, content: {
                                ForEach(playlist.songs, id: \.self) { song in
                                    MusicListItem(song: song)
                                    Divider()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 0.5)
                                        .background(ColorSet.subGray)
                                }
                            })
                            .padding(.vertical, 15)
                            
                            
                            Rectangle()
                                .foregroundStyle(.yellow)
                                .frame(height: 100)
                                .padding(.top, 1000)
                        })
                        .background(ColorSet.background)
                        
                    
                })
                .frame(width: userManager.width)

            }
            
            
            //상단바 - z축 최상위
            HStack(spacing: 0, content: {
                SharedAsset.back.swiftUIImage
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.leading, 20)
                    .onTapGesture {
                        manager.page = manager.previousPage
                    }
                
                Spacer()
                
                SharedAsset.menuWhite.swiftUIImage
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 20)
            })
            .frame(height: 50)
            .padding(.top, userManager.topInset)
            
            
        }
    }
}

//#Preview {
//    PlaylistView()
//}

private struct PlaylistImage: View {
    @EnvironmentObject var userManager: UserViewModel
    var emptyGray = Color(red: 0.18, green: 0.18, blue: 0.18)
    @Binding var playlist: MusicPlaylist
    @State var imageWidth: CGFloat = 0
    var body: some View {
        VStack(spacing: 0, content: {
            HStack(spacing: 0, content: {
                //1번째 이미지
                if playlist.songs.count < 1 {
                    Rectangle()
                        .frame(width: imageWidth, height: imageWidth)
                        .foregroundStyle(emptyGray)
                }else{
                    AsyncImage(url: playlist.songs[0].artwork?.url(width: 600, height: 600) ?? URL(string: "")) { image in
                        image
                            .resizable()
                            .frame(width: imageWidth, height: imageWidth)
                    } placeholder: {
                        Rectangle()
                            .frame(width: imageWidth, height: imageWidth)
                            .foregroundStyle(emptyGray)
                    }
                }
                
                //세로줄(구분선)
                Rectangle()
                    .frame(width: 1, height: imageWidth)
                    .foregroundStyle(ColorSet.background)
                
                //2번째 이미지
                if playlist.songs.count < 2{
                    Rectangle()
                        .frame(width: imageWidth, height: imageWidth)
                        .foregroundStyle(emptyGray)
                }else{
                    AsyncImage(url: playlist.songs[1].artwork?.url(width: 600, height: 600) ?? URL(string: "")) { image in
                        image
                            .resizable()
                            .frame(width: imageWidth, height: imageWidth)
                    } placeholder: {
                        Rectangle()
                            .frame(width: imageWidth, height: imageWidth)
                            .foregroundStyle(emptyGray)
                    }
                }
                
                
            })
            
            //가로줄(구분선)
            Rectangle()
                .frame(width: userManager.width, height: 1)
                .foregroundStyle(ColorSet.background)
            
            HStack(spacing: 0,content: {
                //3번째 이미지
                if playlist.songs.count < 3 {
                    Rectangle()
                        .frame(width: imageWidth, height: imageWidth)
                        .foregroundStyle(emptyGray)
                }else{
                    AsyncImage(url: playlist.songs[2].artwork?.url(width: 600, height: 600) ?? URL(string: "")) { image in
                        image
                            .resizable()
                            .frame(width: imageWidth, height: imageWidth)
                    } placeholder: {
                        Rectangle()
                            .frame(width: imageWidth, height: imageWidth)
                            .foregroundStyle(emptyGray)
                    }
                }
                
                //세로줄 구분선
                Rectangle()
                    .frame(width: 1, height: imageWidth)
                    .foregroundStyle(ColorSet.background)
                
                //4번째 이미지
                if playlist.songs.count <  4 {
                    Rectangle()
                        .frame(width: imageWidth, height: imageWidth)
                        .foregroundStyle(emptyGray)
                }else{
                    AsyncImage(url: playlist.songs[3].artwork?.url(width: 600, height: 600) ?? URL(string: "")) { image in
                        image
                            .resizable()
                            .frame(width: imageWidth, height: imageWidth)
                    } placeholder: {
                        Rectangle()
                            .frame(width: imageWidth, height: imageWidth)
                            .foregroundStyle(emptyGray)
                    }
                }
                
            })
        })
        .onAppear(perform: {
            imageWidth = userManager.width/2
        })
    }
}
