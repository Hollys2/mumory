//
//  SearchResultView.swift
//  Feature
//
//  Created by 제이콥 on 12/4/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct SearchMusicResultView: View {
    @EnvironmentObject private var recentSearchObject: RecentSearchObject
    @EnvironmentObject private var playerViewModel: PlayerViewModel
    @EnvironmentObject private var currentUserData: CurrentUserData
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @Binding private var term: String
    @Binding private var songs: MusicItemCollection<Song>
    @Binding private var artists: MusicItemCollection<Artist>
    @Binding private var isLoading: Bool
    @Binding private var offset: CGPoint
        
    init(term: Binding<String>, songs: Binding<MusicItemCollection<Song>>, artists: Binding<MusicItemCollection<Artist>>, 
         isLoading: Binding<Bool>, offset: Binding<CGPoint>) {
        self._term = term
        self._songs = songs
        self._artists = artists
        self._isLoading = isLoading
        self._offset = offset
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            SimpleScrollView(contentOffset: $offset) {
                VStack(spacing: 0, content: {
                    
                    if isLoading {
                        LoadingAnimationView(isLoading: $isLoading)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, getUIScreenBounds().height * 0.25)
                        
                    } else if term.isEmpty {
                        EmptyView()
                    } else if songs.isEmpty || artists.isEmpty {
                        Text("검색 결과가 없습니다")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                            .foregroundStyle(ColorSet.subGray)
                            .padding(.top, getUIScreenBounds().height * 0.2)
                    } else {
                        LazyVStack(spacing: 0, content: {
                            Text("아티스트")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                .foregroundStyle(.white)
                                .padding(.leading, 20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 16)
                                .padding(.bottom, 9)
                            
                            ForEach(artists, id: \.id){ artist in
                                SearchArtistItem(artist: artist)
                                    .id(artist.id)
                                    .onTapGesture {
                                        appCoordinator.rootPath.append(LibraryPage.artist(artist: artist))
                                        let userDefault = UserDefaults.standard
                                        var recentSearchList = userDefault.value(forKey: "recentSearchList") as? [String] ?? []
                                        recentSearchList.removeAll(where: {$0 == artist.name})
                                        recentSearchList.insert(artist.name, at: 0)
                                        userDefault.set(recentSearchList, forKey: "recentSearchList")
                                    }
                            }
                            
                            Rectangle()
                                .fill(Color.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 8)
                            
                            Text("곡")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.white)
                                .padding(.leading, 20)
                                .padding(.top, 16)
                                .padding(.bottom, 9)
                            
                            ForEach(songs, id: \.id){ song in
                                SearchSongItem(song: song)
                                    .id("\(song.artistName)\(song.id)")
                                    .onTapGesture {
                                        playerViewModel.playNewSong(song: song)
                                        let userDefault = UserDefaults.standard
                                        var recentSearchList = userDefault.value(forKey: "recentSearchList") as? [String] ?? []
                                        recentSearchList.removeAll(where: {$0 == song.title})
                                        recentSearchList.insert(song.title, at: 0)
                                        userDefault.set(recentSearchList, forKey: "recentSearchList")
                                    }
                            }
                            
                            Rectangle()
                                .frame(height: 87)
                                .foregroundStyle(.clear)
                        })

                    }
                })
                .frame(width: getUIScreenBounds().width)
            }
            .ignoresSafeArea()
            .scrollIndicators(.hidden)
            LoadingAnimationView(isLoading: $isLoading)
                .padding(.top, getUIScreenBounds().height * 0.25)

        }

    }
}

