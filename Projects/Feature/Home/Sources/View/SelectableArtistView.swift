//
//  SelectableArtistView.swift
//  Feature
//
//  Created by 제이콥 on 3/16/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct SelectableArtistView: View {
    @EnvironmentObject private var currentUserData: CurrentUserData
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var playerViewModel: PlayerViewModel
    
    @State private var offset: CGPoint = .zero
    @State private var contentSize: CGSize = .zero
    @State private var songs: [Song] = []
    @State private var haveToLoadNextPage: Bool = false
    @State private var requestIndex: Int = 0
    let artist: Artist
    
    init(artist: Artist) {
        self.artist = artist
    }
    
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            
            AsyncImage(url: artist.artwork?.url(width: 1000, height: 1000)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: getUIScreenBounds().width, height: getUIScreenBounds().width)
            } placeholder: {
                SharedAsset.artistProfile.swiftUIImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: getUIScreenBounds().width, height: getUIScreenBounds().width)
            }
            .offset(y: offset.y < -currentUserData.topInset ? -(offset.y+currentUserData.topInset) : 0)
            .overlay {
                ColorSet.background.opacity(offset.y/(getUIScreenBounds().width-50.0))
            }


        
            
            ScrollWrapperWithContentSize(contentOffset: $offset, contentSize: $contentSize) {
                LazyVStack(spacing: 0, content: {
                    //그라데이션
                    SharedAsset.bottomGradient.swiftUIImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: getUIScreenBounds().width, height: 45)
                        .padding(.top, getUIScreenBounds().width - currentUserData.topInset - 30) //사진 세로 길이 - 세이프공간 높이 - 그라데이션과 사진이 겹치는 부분
                    
                    //그라데이션 하위
                    VStack(spacing: 0, content: {
                        Text(artist.name)
                            .foregroundStyle(.white)
                            .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 40))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                        
                        //곡 개수와 전체 재생 버튼
                        Text(songs.count > 0 ? "\(songs.count)곡" : "")
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                            .foregroundStyle(ColorSet.subGray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.leading, 1)
                            .padding(.top, 39)
                            .padding(.bottom, 18)
                        
                        //구분선
                        Divider05()
                        
                        //노래 리스트
                        ForEach(songs, id: \.id){ song in
                            SelectableMusicListItem(song: song)
                                .onTapGesture {
                                    playerViewModel.setPreviewPlayer(tappedSong: song)
                                }
                        }
                        
                        Rectangle()
                            .frame(height: 87)
                            .foregroundStyle(.clear)
                    })
                    .offset(y: -33)
                    .background(ColorSet.background)
                })
                .frame(width: getUIScreenBounds().width)

            }
            .ignoresSafeArea()

            //상단바 - z축 최상위
            HStack(spacing: 0, content: {
                SharedAsset.backGradient.swiftUIImage
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.leading, 20)
                    .onTapGesture {
                        appCoordinator.rootPath.removeLast()
                    }
                
                Spacer()
                
                SharedAsset.menuGradient.swiftUIImage
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 20)
                
            })
            .frame(height: 50)
            .padding(.top, currentUserData.topInset)
            
            PreviewMiniPlayer()
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, appCoordinator.safeAreaInsetsBottom)
                .offset(y: playerViewModel.isShownPreview ? 0 : 120)
                .animation(.spring(), value: playerViewModel.isShownPreview)
            
        }
        .ignoresSafeArea()
        .onAppear(perform: {
            requestArtistSongs(offset: 0)
        })
    }
    
    private func requestArtistSongs(offset: Int) {
        print("request")
        let artistName = artist.name
        var request = MusicCatalogSearchRequest(term: artist.name, types: [Song.self])
        request.includeTopResults = true
        request.limit = 20
        request.offset = offset * 20
        Task{
            do {
                let response = try await request.response()
                if response.songs.count > 0 {
                    requestArtistSongs(offset: offset + 1)
                }
                
                DispatchQueue.main.async {
                    songs += response.songs.filter({$0.artistName == artistName})
                }
                
            }catch(let error){
                print("request error: \(error.localizedDescription)")
            }
        }
        
    }
}

struct SelectableMusicListItem: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var playerViewModel: PlayerViewModel
    var song: Song
    init(song: Song) {
        self.song = song
    }
        
    var body: some View {
            HStack(spacing: 0, content: {
                AsyncImage(url: song.artwork?.url(width: 300, height: 300)) { image in
                    image
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 5,style: .circular))
                } placeholder: {
                    RoundedRectangle(cornerRadius: 5, style: .circular)
                        .foregroundStyle(.gray)
                        .frame(width: 40, height: 40)
                }
                .padding(.trailing, 13)

                
                VStack(content: {
                    Text(song.title)
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Text(song.artistName)
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundStyle(LibraryColorSet.lightGrayTitle)
                        .lineLimit(1)
                        .truncationMode(.tail)
                })
                
                Spacer()
                
                SharedAsset.addPurpleCircleFilled.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        let musicModel = MusicModel(songID: song.id, title: song.title, artist: song.artistName, artworkUrl: song.artwork?.url(width: 300, height: 300))
                        mumoryDataViewModel.choosedMusicModel = musicModel
                        appCoordinator.rootPath.removeLast()
                        appCoordinator.rootPath.removeLast()
                    }
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
            .background(ColorSet.background)
     
    }
}
