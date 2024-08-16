//
//  SearchMusicView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/28.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Core
import Shared
import MusicKit

//가장 처음 샤잠, 최근 검색, 검색텍스트필드 등이 있음
//검색 단어 존재 유무에 따라서 초반 뷰와 결과 뷰를 나눠서 보여주는 역할
struct SearchMusicViewInCreateMumory: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    @State var term: String = ""
    @State var songs: MusicItemCollection<Song> = []
    @State var artists: MusicItemCollection<Artist> = []
    @State var offset: CGPoint = .zero
    @State var isLoading: Bool = false
    @State var searchIndex: Int = 0
    let itemHeight: CGFloat = 95.0
    
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 0, content: {
                    //검색 텍스트 필드 뷰
                    HStack(spacing: 0, content: {
                        SharedAsset.graySearch.swiftUIImage
                            .frame(width: 23, height: 23)
                            .padding(.leading, 15)
                        
                        TextField("", text: $term, prompt: searchPlaceHolder())
                            .textFieldStyle(.plain)
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                            .padding(.leading, 7)
                            .foregroundColor(.white)
                            .submitLabel(.search)
                            .onSubmit {
                                isLoading = true
                                artists = []
                                songs = []
                                Task {
                                    self.artists = await requestArtist(term: term)
                                    isLoading = false
                                }
                                Task {
                                    self.songs = await requestSong(term: term, index: 0)
                                    isLoading = false
                                }
                                let userDefault = UserDefaults.standard
                                var recentSearchList = userDefault.value(forKey: "recentSearchList") as? [String] ?? []
                                recentSearchList.removeAll(where: {$0 == term})
                                recentSearchList.insert(term, at: 0)
                                userDefault.set(recentSearchList, forKey: "recentSearchList")
                            }
                    
                        
                        SharedAsset.xWhiteCircle.swiftUIImage
                            .frame(width: 23, height: 23)
                            .padding(.trailing, 17)
                            .opacity(term.isEmpty ? 0 : 1)
                            .onTapGesture {
                                term = ""
                            }
                    })
                    .frame(height: 45)
                    .background(Color(red: 0.24, green: 0.24, blue: 0.24))
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .circular))
                    
                    
                    Text("취소")
                        .padding(.leading, 8)
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                        .onTapGesture {
                            appCoordinator.rootPath.removeLast()
                        }
                    
                })
                .padding(.top, 12)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.bottom, 15)
                .background(.clear)

                if term.count > 0{
                    SearchMusicResultViewInCreateMumory(term: $term, songs: $songs, artists: $artists, isLoading: $isLoading, offset: $offset)
                }else{
                    SearchMusicEntryView(term: $term, songs: $songs, artists: $artists, isLoading: $isLoading, shazamViewType: .createMumory)
                }
            }
            .padding(.top, getSafeAreaInsets().top)
            .onChange(of: offset, perform: { value in
                if offset.y > CGFloat(searchIndex) * itemHeight * 20 + (itemHeight * 10) {
                    searchIndex += 1
                    DispatchQueue.main.async {
                        Task {
                            self.songs += await requestSong(term: self.term, index: searchIndex)
                        }
                    }
                }
            })

            PreviewMiniPlayer()
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, getSafeAreaInsets().bottom)
                .offset(y: playerViewModel.isShownPreview ? 0 : 120)
                .animation(.spring(), value: playerViewModel.isShownPreview)
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .background(.black)
    }
    
    private func searchPlaceHolder() -> Text {
        return Text("노래 및 아티스트 검색")
            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
            .foregroundColor(ColorSet.subGray)
    }
}


//검색 결과 뷰
struct SearchMusicResultViewInCreateMumory: View {
    @EnvironmentObject private var recentSearchObject: RecentSearchObject
    @EnvironmentObject private var playerViewModel: PlayerViewModel
    @EnvironmentObject private var currentUserViewModel: CurrentUserViewModel
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
        ZStack(alignment: .top){
            SimpleScrollView(contentOffset: $offset) {
                VStack(spacing: 0, content: {
                    
                    if isLoading {
//                        LoadingAnimationView(isLoading: $isLoading)
//                            .frame(maxWidth: .infinity, alignment: .center)
//                            .padding(.top, getUIScreenBounds().height * 0.25)
                        
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
                                        appCoordinator.rootPath.append(MumoryPage.selectableArtist(artist: artist))
                                        //최근 검색어 저장
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
                            
                            ForEach(songs.indices, id: \.self){ index in
                                let song = songs[index]
                                SearchSelectableSongItem(song: song)
                                    .id("\(song.id.rawValue)\(index)")
                                    .onTapGesture {
                                        playerViewModel.setPreviewPlayer(tappedSong: song)
                                        //최근 검색어 저장
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
            
//            LoadingAnimationView(isLoading: $isLoading)
//                .padding(.top, getUIScreenBounds().height * 0.25)

        }
    }
}

//선택 가능한 노래 아이템(우측에 하얀 플러스 아이콘)
struct SearchSelectableSongItem: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinator
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
                    .frame(width: 57, height: 57)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)))
            } placeholder: {
                RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                    .frame(width: 57, height: 57)
                    .foregroundStyle(.gray)
            }
            
            VStack(spacing: 3, content: {
                Text(song.title)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(song.artistName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(red: 0.72, green: 0.72, blue: 0.72))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
            })
            .padding(.leading, 16)
            .padding(.trailing, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            
            SharedAsset.addPurpleCircleFilled.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .onTapGesture {
                    let song = SongModel(id: song.id.rawValue, title: song.title, artist: song.artistName, artworkUrl: song.artwork?.url(width: 500, height: 500))
                    appCoordinator.draftMumorySong = song
                    appCoordinator.rootPath.removeLast()
                }
        })
        .padding(.vertical, 19)
        .padding(.horizontal, 20)
        .background(ColorSet.background)    

    }
    
    
}
