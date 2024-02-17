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
    @EnvironmentObject var manager: LibraryManageModel
    @EnvironmentObject var userManager: UserViewModel
    @State var playlist: MusicPlaylist
    var isAddSongItem: Bool
    var radius: CGFloat = 10
    @State var songs: [Song] = []
    var emptyGray = Color(red: 0.18, green: 0.18, blue: 0.18)
    var body: some View {
        ZStack{
            if isAddSongItem {
                AddSongItem()
            }else{
                VStack(spacing: 0){
                    ZStack(alignment: .bottom){
                        VStack(spacing: 0, content: {
                            HStack(spacing: 0, content: {
                                //1번째 이미지
                                if songs.count < 1 {
                                    Rectangle()
                                        .frame(width: 81, height: 81)
                                        .foregroundStyle(emptyGray)
                                }else{
                                    AsyncImage(url: songs[0].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                                        image
                                            .resizable()
                                            .frame(width: 81, height: 81)
                                    } placeholder: {
                                        Rectangle()
                                            .frame(width: 81, height: 81)
                                            .foregroundStyle(emptyGray)
                                    }
                                }
                                
                                //세로줄(구분선)
                                Rectangle()
                                    .frame(width: 1, height: 81)
                                    .foregroundStyle(ColorSet.background)
                                
                                //2번째 이미지
                                if songs.count < 2{
                                    Rectangle()
                                        .frame(width: 81, height: 81)
                                        .foregroundStyle(emptyGray)
                                }else{
                                    AsyncImage(url: songs[1].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                                        image
                                            .resizable()
                                            .frame(width: 81, height: 81)
                                    } placeholder: {
                                        Rectangle()
                                            .frame(width: 81, height: 81)
                                            .foregroundStyle(emptyGray)
                                    }
                                }
                                
                                
                            })
                            
                            //가로줄(구분선)
                            Rectangle()
                                .frame(width: 163, height: 1)
                                .foregroundStyle(ColorSet.background)
                            
                            HStack(spacing: 0,content: {
                                //3번째 이미지
                                if songs.count < 3 {
                                    Rectangle()
                                        .frame(width: 81, height: 81)
                                        .foregroundStyle(emptyGray)
                                }else{
                                    AsyncImage(url: songs[2].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                                        image
                                            .resizable()
                                            .frame(width: 81, height: 81)
                                    } placeholder: {
                                        Rectangle()
                                            .frame(width: 81, height: 81)
                                            .foregroundStyle(emptyGray)
                                    }
                                }
                                
                                //세로줄 구분선
                                Rectangle()
                                    .frame(width: 1, height: 81)
                                    .foregroundStyle(ColorSet.background)
                                
                                //4번째 이미지
                                if songs.count <  4 {
                                    Rectangle()
                                        .frame(width: 81, height: 81)
                                        .foregroundStyle(emptyGray)
                                }else{
                                    AsyncImage(url: songs[3].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                                        image
                                            .resizable()
                                            .frame(width: 81, height: 81)
                                    } placeholder: {
                                        Rectangle()
                                            .frame(width: 81, height: 81)
                                            .foregroundStyle(emptyGray)
                                    }
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
                                .opacity(playlist.isFavorite ? 1 : 0)
                            
                            SharedAsset.lockPurple.swiftUIImage
                                .resizable()
                                .frame(width: 23, height: 23)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .opacity(playlist.isFavorite ? 0 : playlist.isPrivate ? 1 : 0)
                        }
                    }
                    
                    
                    Text(playlist.title)
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                        .frame(maxWidth: 163, alignment: .leading)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.top, 10)
                        .foregroundStyle(.white)
                    
                    Text("\(playlist.songIDs.count)곡")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundStyle(LibraryColorSet.lightGrayTitle)
                        .frame(maxWidth: 163, alignment: .leading)
                        .padding(.top, 5)
                    
                }
                .onTapGesture {
                    manager.push(destination: .playlist(playlist: playlist))
                }
            }

        }
        .onAppear(perform: {
            songs.removeAll()
            Task{
                await fetchSongInfo(songIDs: playlist.songIDs)
            }
        })
    }
    
    private func fetchSongInfo(songIDs: [String]) async {
        for id in songIDs {
            let musicItemID = MusicItemID(rawValue: id)
            var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
            request.properties = [.genres, .artists]
            
            do {
                let response = try await request.response()
                
                guard let song = response.items.first else {
                    print("no song")
                    continue
                }
                
                self.songs.append(song)
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
}

private struct AddSongItem: View {
    var emptyGray = Color(red: 0.18, green: 0.18, blue: 0.18)
    @State var isPresent: Bool = false
    var body: some View {
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
            UIView.setAnimationsEnabled(true)
            isPresent = true
        }
        .fullScreenCover(isPresented: $isPresent, content: {
            CreatePlaylistPopupView()
                .background(TransparentBackground())
        })
    }
}
