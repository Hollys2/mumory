//
//  SearchView.swift
//  Feature
//
//  Created by 제이콥 on 12/4/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit
import MapKit

struct SearchMusicView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    @State var term: String
    @State var songs: MusicItemCollection<Song> = []
    @State var artists: MusicItemCollection<Artist> = []
    @State var offset: CGPoint = .zero
    @State var isLoading: Bool = false
    @State var searchIndex: Int = 0
    let itemHeight: CGFloat = 95.0
    
    var body: some View {
        ZStack(alignment: .top) {
            ColorSet.background.ignoresSafeArea()
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
                    SearchMusicResultView(term: $term, songs: $songs, artists: $artists, isLoading: $isLoading, offset: $offset)
                        .onChange(of: offset, perform: { value in
                            print(offset)
                            if offset.y > CGFloat(searchIndex) * itemHeight * 20 + (itemHeight * 10) {
                                searchIndex += 1
                                Task {
                                    self.songs += await requestSong(term: self.term, index: searchIndex)
                                }
                            }
                        })
                    
                }else{
                    SearchMusicEntryView(term: $term, songs: $songs, artists: $artists, isLoading: $isLoading)
                }
                
            }
            .padding(.top, appCoordinator.safeAreaInsetsTop)
            
            CreateMumoryBottomSheetView(isSheetShown: $appCoordinator.isCreateMumorySheetShown, offsetY: $appCoordinator.offsetY)
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .background(.black)
        .onAppear(perform: {
            playerViewModel.setLibraryPlayerVisibility(isShown: true, moveToBottom: true)
        })
    }

    
    private func searchPlaceHolder() -> Text {
        return Text("노래 및 아티스트 검색")
            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
            .foregroundColor(ColorSet.subGray)
    }
}
public func requestArtist(term: String) async -> MusicItemCollection<Artist> {
    var request = MusicCatalogSearchRequest(term: term, types: [Artist.self])
    request.limit = 5
    request.includeTopResults = true
    do {
        let response = try await request.response()
        return response.artists
    }catch(let error) {
        print("error: \(error.localizedDescription)")
    }
    return []
}

public func requestSong(term: String, index: Int) async -> MusicItemCollection<Song> {
    print("request song")
    var request = MusicCatalogSearchRequest(term: term, types: [Song.self])
    request.limit = 20
    request.includeTopResults = true
    request.offset = index * 20
    do {
        let response = try await request.response()
        return response.songs
    }catch(let error) {
        print("error: \(error.localizedDescription)")
    }
    return []
}
