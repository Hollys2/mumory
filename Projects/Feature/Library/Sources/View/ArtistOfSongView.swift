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

struct ArtistOfSongView: View {
    @EnvironmentObject private var userManager: UserViewModel
    @EnvironmentObject private var manager: LibraryManageModel
    @EnvironmentObject private var playerManager: PlayerViewModel
    @State private var isBottomSheetPresent: Bool = false
    @State private var offset: CGPoint = .zero
    @State private var contentSize: CGSize = .zero
    @State private var songs: [Song] = []
    @State private var haveToLoadNextPage: Bool = false
    @State private var requestIndex: Int = 0
    @State var artist: Artist?
    let song: Song

    init(song: Song){
        self.song = song
    }

    
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            
            
            AsyncImage(url: artist?.artwork?.url(width: 1000, height: 1000)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: userManager.width, height: userManager.width)
            } placeholder: {
                SharedAsset.artistProfile.swiftUIImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: userManager.width, height: userManager.width)
            }
            .offset(y: offset.y < -userManager.topInset ? -(offset.y+userManager.topInset) : 0)


        
            
            ScrollWrapperWithContentSize(contentOffset: $offset, contentSize: $contentSize) {
                LazyVStack(spacing: 0, content: {
                    //그라데이션
                    SharedAsset.bottomGradient.swiftUIImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: userManager.width, height: 45)
                        .padding(.top, userManager.width - userManager.topInset - 30) //사진 세로 길이 - 세이프공간 높이 - 그라데이션과 사진이 겹치는 부분
                    
                    //그라데이션 하위
                    VStack(spacing: 0, content: {
                        Text(artist?.name ?? "ARTIST")
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
                                    playerManager.playAll(songs: songs)
                                }
                        })
                        .padding(.horizontal, 20)
                        .padding(.leading, 1)
                        .padding(.top, 39)
                        .padding(.bottom, 18)
                        
                        //구분선
                        Divider()
                            .frame(maxWidth: .infinity)
                            .frame(height: 0.5)
                            .background(ColorSet.subGray)
                        
                        //노래 리스트
                        ForEach(songs, id: \.id){ song in
                            MusicListItem(song: song)
                            Divider()
                                .frame(maxWidth: .infinity)
                                .frame(height: 0.5)
                                .background(ColorSet.subGray)
                        }
                        
                        Rectangle()
                            .frame(height: 87)
                            .foregroundStyle(.clear)
                    })
                    .offset(y: -33)
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
                        manager.pop()
                    }
                
                Spacer()
                
                SharedAsset.menuWhite.swiftUIImage
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 20)
                    .onTapGesture {
                        isBottomSheetPresent = true
                    }
                
            })
            .frame(height: 50)
            .padding(.top, userManager.topInset)
//            .fullScreenCover(isPresented: $isBottomSheetPresent, content: {
//                BottomSheetWrapper(isPresent: $isBottomSheetPresent)  {
//                    ArtistBottomSheetView(artist: artist)
//                }
//                .background(TransparentBackground())
//            })
        }
        .onAppear(perform: {
            Task{
                await requestDetailSongInfo()
            }
//            requestArtistSongs(offset: 0)
            
        })
    }
    
    private func requestDetailSongInfo() async {
        var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: song.id)
        request.properties = [.artists, .genres]
        
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
            self.artist = artist
            requestArtistSongs(artistName: artist.name, offset: 0)
            
        }catch(let error) {
            print("error: \(error.localizedDescription)")
        }
        
    }
    
    private func requestArtistSongs(artistName: String, offset: Int) {
        var request = MusicCatalogSearchRequest(term: artistName, types: [Song.self])
        request.includeTopResults = true
        request.limit = 20
        request.offset = offset * 20
    
        Task{
            do {
                let response = try await request.response()
                if response.songs.count > 0 {
                    requestArtistSongs(artistName: artistName, offset: offset + 1)
                }
                
                DispatchQueue.main.async {
                    songs += response.songs.filter({$0.artistName == artistName})
                }
                
            }catch(let error){
                print("request error: \(error.localizedDescription)")
            }
        }
        
    }
    
    private func getTopSongs(artist: Artist) {
        var request = MusicCatalogResourceRequest<Artist>(matching: \.id, equalTo: artist.id)
        request.properties = [.topSongs]
        
        
    }
}



//#Preview {
//    ArtistView()
//}
