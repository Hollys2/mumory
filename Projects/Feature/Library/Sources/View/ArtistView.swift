//
//  ArtistView.swift
//  Feature
//
//  Created by 제이콥 on 2/14/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct ArtistView: View {
    @EnvironmentObject private var currentUserData: CurrentUserData
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var playerManager: PlayerViewModel
    @State private var isBottomSheetPresent: Bool = false
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
                        HStack(alignment: .bottom, spacing: 0, content: {
                            Text(songs.count > 0 ? "\(songs.count)곡" : "")
                                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                                .foregroundStyle(ColorSet.subGray)
                            Spacer()
                            PlayAllButton()
                                .onTapGesture {
                                    playerManager.playAll(title: artist.name , songs: songs)
                                    AnalyticsManager.shared.setSelectContentLog(title: "ArtistViewPlayAllButton")

                                }
                        })
                        .padding(.horizontal, 20)
                        .padding(.leading, 1)
                        .padding(.top, 39)
                        .padding(.bottom, 18)
                        
                        //구분선
                        Divider05()
                        
                        //노래 리스트
                        ForEach(songs, id: \.id){ song in
                            MusicListItem(song: song, type: .artist)
                                .onTapGesture {
                                    playerManager.playNewSong(song: song)
                                }
                            Divider05()
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
                    .onTapGesture {
                        UIView.setAnimationsEnabled(false)
                        isBottomSheetPresent = true
                    }
                
            })
            .frame(height: 50)
            .padding(.top, currentUserData.topInset)
            .fullScreenCover(isPresented: $isBottomSheetPresent, content: {
                BottomSheetWrapper(isPresent: $isBottomSheetPresent)  {
                   ArtistBottomSheetView(artist: artist, songs: songs)
                }
                .background(TransparentBackground())
            })
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



//#Preview {
//    ArtistView()
//}
