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

@available(iOS 16.0, *)

//가장 처음 샤잠, 최근 검색, 검색텍스트필드 등이 있음
//검색 단어 존재 유무에 따라서 초반 뷰와 결과 뷰를 나눠서 보여주는 역할
struct SearchMusicViewInCreateMumory: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    @State var term: String = ""
    @State var musicList: MusicItemCollection<Song> = []
    @State var artistList: MusicItemCollection<Artist> = []
    @GestureState var dragAmount = CGSize.zero
    
    var body: some View {
        ZStack{
            Color(red: 0.09, green: 0.09, blue: 0.09, opacity: 1).ignoresSafeArea()
            VStack(spacing: 0) {
                HStack(spacing: 0, content: {
                    HStack(spacing: 0, content: {
                        SharedAsset.graySearch.swiftUIImage
                            .frame(width: 23, height: 23)
                            .padding(.leading, 15)
                        
                        TextField("노래 및 아티스트 검색", text: $term, prompt: searchPlaceHolder())
                            .textFieldStyle(.plain)
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                            .padding(.leading, 7)
                            .foregroundColor(.white)
                        
                        
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
                
                if term.count > 0 {
                    SearchSelectableResultView(term: $term)
                }else{
                    SearchMusicEntryView(term: $term)
                }
                
                
                
                Spacer()
            }
            .padding(.top, appCoordinator.safeAreaInsetsTop)
            
            PreviewMiniPlayer()
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, appCoordinator.safeAreaInsetsBottom)
                .offset(y: playerViewModel.isShownPreview ? 0 : 120)
                .animation(.spring, value: playerViewModel.isShownPreview)
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .background(.black)
        .onAppear {
            AnalyticsManager.shared.setScreenLog(screenTitle: "SearchMusicView")
        }
        
    }
    
    
    private func searchPlaceHolder() -> Text {
        return Text("노래 및 아티스트 검색")
            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
    }
}


//검색 결과 뷰
struct SearchSelectableResultView: View {
    @EnvironmentObject private var recentSearchObject: RecentSearchObject
    @EnvironmentObject private var playerViewModel: PlayerViewModel
    @EnvironmentObject private var currentUserData: CurrentUserData
    @EnvironmentObject private var appCoordinator: AppCoordinator
    
    @Binding var term: String
    @State private var musicList: MusicItemCollection<Song> = []
    @State private var artistList: MusicItemCollection<Artist> = []
    
    @State private var timer: Timer?
    @State private var localTime = 0.0
    
    @State private var offset: CGPoint = .zero
    @State private var contentSize: CGSize = .zero
    @State private var requestIndex = 0
    @State private var haveToLoadNextPage: Bool = false
    @State private var isLoading: Bool = false
    
    
    var body: some View {
        ZStack(alignment: .top){
            ScrollWrapperWithContentSize(contentOffset: $offset, contentSize: $contentSize){
                VStack(spacing: 0, content: {
                    if musicList.count == 0 && artistList.count == 0 {
                        Text("검색 결과가 없습니다")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                            .foregroundStyle(ColorSet.subGray)
                            .padding(.top, 130)
                    }else {
                        LazyVStack(spacing: 0, content: {
                            //아티스트 검색 결과 타이틀 및 리스트
                            Text("아티스트")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                .foregroundStyle(.white)
                                .padding(.leading, 20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 16)
                                .padding(.bottom, 9)
                            
                            ForEach(artistList){ artist in
                                SearchArtistItem(artist: artist)
                                    .onTapGesture {
                                        appCoordinator.rootPath.append(LibraryPage.selectableArtist(artist: artist))
                                        //최근 검색어 저장
                                        let userDefault = UserDefaults.standard
                                        var recentSearchList = userDefault.value(forKey: "recentSearchList") as? [String] ?? []
                                        recentSearchList.removeAll(where: {$0 == artist.name})
                                        recentSearchList.insert(artist.name, at: 0)
                                        userDefault.set(recentSearchList, forKey: "recentSearchList")
                                    }
                            }
                            
                            //구분선
                            Rectangle()
                                .fill(Color.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 8)
                            
                            //음악 검색 결과 타이틀 및 리스트
                            Text("곡")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.white)
                                .padding(.leading, 20)
                                .padding(.top, 16)
                                .padding(.bottom, 9)
                            
                            ForEach(musicList){ music in
                                SearchSelectableSongItem(song: music)
                                    .onTapGesture {
                                        playerViewModel.setPreviewPlayer(tappedSong: music)
                                        //최근 검색어 저장
                                        let userDefault = UserDefaults.standard
                                        var recentSearchList = userDefault.value(forKey: "recentSearchList") as? [String] ?? []
                                        recentSearchList.removeAll(where: {$0 == music.title})
                                        recentSearchList.insert(music.title, at: 0)
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
                .onChange(of: term, perform: { value in
                    localTime = 0.0
                    requestIndex = 0
                    isLoading = true
                })
                .onChange(of: localTime, perform: { value in
                    if localTime == 0.8 {
                        requestArtist(term: term)
                        requestSong(term: term, index: 0)
                    }
                })
                .onChange(of: offset, perform: { value in
                    if offset.y/contentSize.height > 0.7 {
                        if !haveToLoadNextPage {
                            haveToLoadNextPage = true
                            requestIndex += 1
                            requestSong(term: term, index: requestIndex)
                        }
                    }else {
                        haveToLoadNextPage = false
                    }
                })
                
                
            }
            .ignoresSafeArea()
            .onAppear(perform: {
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
                    localTime += 0.2
                }
            })
            .onDisappear(perform: {
                timer?.invalidate()
            })
            
        }
    }
    public func requestArtist(term: String){
        var request = MusicCatalogSearchRequest(term: term, types: [Artist.self])
        request.limit = 20
        request.includeTopResults = true
        
        Task {
            do {
                let response = try await request.response()
                DispatchQueue.main.async {
                    self.artistList = response.artists
                    isLoading = false
                }
            }catch(let error) {
                print("error: \(error.localizedDescription)")
            }
            
        }
        
    }
    
    public func requestSong(term: String, index: Int) {
        print("request song")
        var request = MusicCatalogSearchRequest(term: term, types: [Song.self])
        request.limit = 20
        request.includeTopResults = true
        request.offset = index * 20
        Task {
            do {
                let response = try await request.response()
                DispatchQueue.main.async {
                    self.musicList += response.songs
                }
            }catch(let error) {
                print("error: \(error.localizedDescription)")
            }
            
        }
    }
    
}

//선택 가능한 노래 아이템(우측에 하얀 플러스 아이콘)
struct SearchSelectableSongItem: View {
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
                    let musicModel = MusicModel(songID: song.id, title: song.title, artist: song.artistName, artworkUrl: song.artwork?.url(width: 300, height: 300))
                    mumoryDataViewModel.choosedMusicModel = musicModel
                    appCoordinator.rootPath.removeLast()
                }
        })
        .padding(.vertical, 19)
        .padding(.horizontal, 20)
        .background(ColorSet.background)    

    }
    
    
}
