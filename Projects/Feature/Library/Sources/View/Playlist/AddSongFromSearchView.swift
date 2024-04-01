//
//  AddSongFromSearchView.swift
//  Feature
//
//  Created by 제이콥 on 2/14/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct AddSongFromSearchView: View {
    @Binding var originPlaylist: MusicPlaylist
    
    @EnvironmentObject var currentUserData: CurrentUserData

    @State var term: String = ""
    @State var timer: Timer?
    @State var localTimer = 0.0
    @State var searchIndex = 0
    @State var songs: MusicItemCollection<Song> = []
    @State var scrollOffset: CGPoint = .zero
    @State var isLoading: Bool = false
    private let lineGray = Color(white: 0.31)

    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
        
            VStack(spacing: 0, content: {
                SongSearchTextField(term: $term)
                    .onChange(of: term, perform: { value in
                        DispatchQueue.main.async {
                            localTimer = 0
                            songs = []
                            isLoading = !term.isEmpty
                        }
                    })
                    .onChange(of: localTimer, perform: { value in
                        if localTimer == 0.8 {
                            if !term.isEmpty{
                                searchIndex = 0
                                searchSong(term: term, index: searchIndex)
                            }
                        }
                    })
                                
                SimpleScrollView(contentOffset: $scrollOffset) {
                    LazyVStack(spacing: 0, content: {
                        ForEach(songs, id: \.self) { song in
                            AddMusicItem(song: song, originPlaylist: $originPlaylist)
                                .id("\(song.artistName) \(song.id)")
                        }
                    })
                    .frame(width: getUIScreenBounds().width)
                }   
                .scrollIndicators(.hidden)
                .ignoresSafeArea()
                .onChange(of: scrollOffset, perform: { value in
                    //아이템 높이: 70. 첫 페이지에서는 offset이 700일 때 다음 페이지 요청을 보내고, 두번째 페이지에서는 2100일 때 요청을 보냄...반복
                    if scrollOffset.y > (1400.0 * CGFloat(searchIndex) + 700.0) {
                        searchIndex += 1
                        searchSong(term: term, index: searchIndex)
                    }
                })
                
                    
            })
            
            if songs.isEmpty && !isLoading {
                Text("검색 후 음악을 추가해보세요")
                    .foregroundStyle(ColorSet.subGray)
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .padding(.top, getUIScreenBounds().height * 0.25)
            }
            
            LoadingAnimationView(isLoading: $isLoading)
                .padding(.top, getUIScreenBounds().height * 0.25)
        }
        .onAppear(perform: {
            timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { timer in
                localTimer += 0.2
            })
        })
        .onDisappear(perform: {
            timer?.invalidate()
        })
    }
    
    private func searchSong(term: String, index: Int) {
        isLoading = songs.isEmpty
        Task {
            var request = MusicCatalogSearchRequest(term: term, types: [Song.self])
            request.limit = 20
            request.offset = index * 20
            
            do {
                let response = try await request.response()
                DispatchQueue.main.async {
                    self.songs += response.songs
                    isLoading = false
                }
            }catch(let error) {
                print("error: \(error.localizedDescription)")
            }
            
        }
    }

}

struct SongSearchTextField: View {
    @Binding var term: String
    
    let textfieldBackground = Color(white: 0.24)
    var body: some View {
        HStack(spacing: 0, content: {
            TextField("", text: $term, prompt: getPrompt())
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .foregroundStyle(Color.white)
            
            Button {
                term = ""
            } label: {
                SharedAsset.xWhiteCircle.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 23, height: 23)
            }                    
            .padding(.leading, 10)
            .opacity(term.isEmpty ? 0 : 1)
        })
        .padding(.leading, 25)
        .padding(.trailing, 17)
        .frame(height: 45)
        .background(textfieldBackground)
        .clipShape(RoundedRectangle(cornerRadius: 35, style: .circular))
        .padding(20)
        .padding(.top, 2)
    }
    
    
    private func getPrompt() -> Text {
        return Text("음악 또는 아티스트 검색")
            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
            .foregroundColor(ColorSet.subGray)
    }
}
