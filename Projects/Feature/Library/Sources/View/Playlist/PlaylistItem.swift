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
    @Binding var playlist: MusicPlaylist
//    @State var songs: [Song] = []
    
    var radius: CGFloat = 10
    var emptyGray = Color(red: 0.18, green: 0.18, blue: 0.18)
    let itemSize: CGFloat
    
    init(playlist: Binding<MusicPlaylist>,itemSize: CGFloat){
        self._playlist = playlist
        self.itemSize = itemSize
    }
    
    var body: some View {
        ZStack(alignment: .top){
            
            VStack(spacing: 0){
                VStack(spacing: 0, content: {
                    HStack(spacing: 0, content: {
                        //1번째 이미지
                        if playlist.songs.count < 1 {
                            Rectangle()
                                .fill(emptyGray)
                                .frame(width: itemSize, height: itemSize)
                        }else{
                            AsyncImage(url: playlist.songs[0].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Rectangle()
                                    .foregroundStyle(emptyGray)
                            }
                            .frame(width: itemSize, height: itemSize)
                            
                        }
                        
                        //세로줄(구분선)
                        Rectangle()
                            .frame(width: 1)
                            .frame(maxHeight: .infinity)
                            .foregroundStyle(ColorSet.background)
                        
                        //2번째 이미지
                        if playlist.songs.count < 2{
                            Rectangle()
                                .fill(emptyGray)
                                .frame(width: itemSize, height: itemSize)
                        }else{
                            AsyncImage(url: playlist.songs[1].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Rectangle()
                                    .foregroundStyle(emptyGray)
                            }
                            .frame(width: itemSize, height: itemSize)
                            
                        }
                        
                        
                    })
                    
                    //가로줄(구분선)
                    Rectangle()
                        .frame(height: 1)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(ColorSet.background)
                    
                    HStack(spacing: 0,content: {
                        //3번째 이미지
                        if playlist.songs.count < 3 {
                            Rectangle()
                                .fill(emptyGray)
                                .frame(width: itemSize, height: itemSize)
                        }else{
                            AsyncImage(url: playlist.songs[2].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Rectangle()
                                    .foregroundStyle(emptyGray)
                            }
                            .frame(width: itemSize, height: itemSize)
                            
                        }
                        
                        //세로줄 구분선
                        Rectangle()
                            .frame(width: 1)
                            .frame(maxHeight: .infinity)
                            .foregroundStyle(ColorSet.background)
                        
                        //4번째 이미지
                        if playlist.songs.count <  4 {
                            Rectangle()
                                .fill(emptyGray)
                                .frame(width: itemSize, height: itemSize)
                        }else{
                            AsyncImage(url: playlist.songs[3].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Rectangle()
                                    .foregroundStyle(emptyGray)
                            }
                            .frame(width: itemSize, height: itemSize)
                            
                        }
                        
                    })
                })
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
                .overlay {
                    SharedAsset.bookmarkWhite.swiftUIImage
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .opacity(playlist.id == "favorite" ? 1 : 0)
                    
                    SharedAsset.lockPurple.swiftUIImage
                        .resizable()
                        .frame(width: 23, height: 23)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .opacity(playlist.id == "favorite" ? 0 : playlist.isPublic ? 0 : 1)
                }
                
                
                Text(playlist.title)
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.top, 10)
                    .foregroundStyle(.white)
                
                Text("\(playlist.songIDs.count)곡")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(LibraryColorSet.lightGrayTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 5)
                
            }
            
        }
//        .onAppear(perform: {
//            Task{
//                self.songs = await fetchSongInfo(songIDs: playlist.songIDs)
//            }
//        })
    }
    
    private func fetchSongInfo(songIDs: [String]) async -> [Song]{
        var songs: [Song] = []
        var count: Int = 0
        for id in songIDs {
            if count > 3 {
                break
            }
            let musicItemID = MusicItemID(rawValue: id)
            var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
            request.properties = [.genres, .artists]
            let response = try? await request.response()
            guard let song = response?.items.first else {
                continue
            }
            songs.append(song)
            count += 1
        }
        return songs
    }
    
}

public struct AddSongItem: View {
    var emptyGray = Color(red: 0.18, green: 0.18, blue: 0.18)
    @State var isPresent: Bool = false
    public var body: some View {
        VStack(spacing: 0, content: {
            RoundedRectangle(cornerRadius: 10, style: .circular)
                .frame(width: 163, height: 163)
                .foregroundStyle(emptyGray)
                .overlay {
                    SharedAsset.addPurple.swiftUIImage
                        .resizable()
                        .frame(width: 47, height: 47)
                }
            
            Text("새 플레이리스트")
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .foregroundStyle(ColorSet.mainPurpleColor)
                .frame(width: 163, alignment: .leading)
                .padding(.top, 10)
            
            Spacer()
            
        })
        .frame(height: 215)
        .onTapGesture {
            isPresent = true
        }
        .fullScreenCover(isPresented: $isPresent, content: {
            CreatePlaylistPopupView()
                .background(TransparentBackground())
        })
    }
}
