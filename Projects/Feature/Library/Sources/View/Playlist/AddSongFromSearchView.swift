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
    @EnvironmentObject var snackbarManager: SnackBarViewModel

    @State var term: String = ""
    @State var timer: Timer?
    @State var localTimer = 0.0
    @State var searchIndex = 0
    @State var songs: MusicItemCollection<Song> = []
    
    @State var scrollOffset: CGPoint = .zero
    
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
                            AddMusicItem(songID: song.id.rawValue, originPlaylist: $originPlaylist)
                                .environmentObject(snackbarManager)
                            Divider()
                                .frame(maxWidth: .infinity)
                                .frame(height: 0.5)
                                .background(lineGray)
                        }
                    })
                    .frame(width: getUIScreenBounds().width)
                }        
                .onChange(of: scrollOffset, perform: { value in
                    //아이템 높이: 70. 첫 페이지에서는 offset이 700일 때 다음 페이지 요청을 보내고, 두번째 페이지에서는 2100일 때 요청을 보냄...반복
                    if scrollOffset.y > (1400.0 * CGFloat(searchIndex) + 700.0) {
                        searchIndex += 1
                        searchSong(term: term, index: searchIndex)
                    }
                })
                
                    
            })
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
        Task {
            var request = MusicCatalogSearchRequest(term: term, types: [Song.self])
            request.limit = 20
            request.offset = index * 20
            
            do {
                let response = try await request.response()
                DispatchQueue.main.async {
                    self.songs += response.songs
                }
            }catch(let error) {
                print("error: \(error.localizedDescription)")
            }
            
        }
    }

}

//#Preview {
//    AddSongFromSearchView()
//}

struct SongSearchTextField: View {
    @Binding var term: String
    
    let textfieldBackground = Color(white: 0.24)
    var body: some View {
        HStack(spacing: 0, content: {
            SharedAsset.graySearch.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 23, height: 23)
                .padding(.leading, 15)
            
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
