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
struct MusicRow: View {
    
    @State var musicModel: MusicModel
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    var body: some View {
        Button(action: {
            mumoryDataViewModel.choosedMusicModel = musicModel
            appCoordinator.rootPath.removeLast()
        }) {
            HStack(alignment: .center, spacing: 13) {
                AsyncImage(url: musicModel.artworkUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                    default:
                        Color.purple
                            .frame(width: 50, height: 50)
                    }
                }
                
                VStack(spacing: 6) {
                    Text(musicModel.title)
                        .lineLimit(1)
                        .font(Font.custom("Pretendard", size: 15).weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(musicModel.artist)
                        .lineLimit(1)
                        .font(Font.custom("Pretendard", size: 13))
                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } // HStack
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .padding(.horizontal, 5)
        }
    }
}

@available(iOS 16.0, *)
struct SearchMusicView: View {
    
    //    @Binding var translation: CGSize
    
    @State private var searchText = ""
    
    @StateObject var localSearchViewModel: LocalSearchViewModel = .init()
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    @GestureState var dragAmount = CGSize.zero
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            Image(uiImage: SharedAsset.dragIndicator.image)
                .frame(maxWidth: .infinity)
                .padding(.top, 14)
                .padding(.bottom, 14)
                .background(SharedAsset.backgroundColor.swiftUIColor) // 색이 존재해야 제스처 동작함
            
            //        onCommit: {
            //            UIApplication.shared.resignFirstResponder() // 리턴 누르면 키보드 내림
            //        },
            HStack {
                ZStack(alignment: .leading) {
                    TextField("", text: $searchText, prompt: Text("음악 검색").font(Font.custom("Pretendard", size: 16))
                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47)))
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .padding(.horizontal, 15 + 23 + 7)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color(red: 0.24, green: 0.24, blue: 0.24))
                    )
                    .foregroundColor(.white)
                    .onChange(of: searchText){ newValue in
                        if !searchText.isEmpty {
                            //                            mumoryDataViewModel.musicModels = searchAppleMusic()
                        } else {
                            mumoryDataViewModel.musicModels = []
                        }
                    }
                    
                    Image(systemName: "magnifyingglass")
                        .frame(width: 23, height: 23)
                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                        .padding(.leading, 15)
                    
                    if !self.searchText.isEmpty {
                        Button(action: {
                            self.searchText = ""
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white)
                            }
                            .padding(.trailing, 17)
                        }
                    }
                }
                
                Button(action: {
                    self.appCoordinator.rootPath.removeLast()
                }) {
                    Text("취소")
                        .font(
                            Font.custom("Pretendard", size: 16)
                                .weight(.medium)
                        )
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.white)
                }
            } // HStack
            .frame(maxWidth: .infinity)
            .padding(.bottom, 15)
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(self.mumoryDataViewModel.musicModels, id: \.self) { musicModel in
                        MusicRow(musicModel: musicModel)
                    }
                } // VStack
                .padding(.bottom, 66)
            } // ScrollView
            .scrollIndicators(.hidden)
        } // VStack
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal, 21)
        .frame(width: UIScreen.main.bounds.width + 1)
        .background(Color(red: 0.09, green: 0.09, blue: 0.09))
        .onAppear {
            fetchMusic()
        }
        .onDisappear {
            appCoordinator.isSearchLocationViewShown = false
            self.searchText = ""
            mumoryDataViewModel.musicModels = []
        }
        
    }
    
    private let requestSearch: MusicCatalogSearchRequest = {
        var req = MusicCatalogSearchRequest(term: "ADOY", types: [Song.self])
        req.limit = 10
        return req
    }()
    
    private func fetchMusic()  {
        Task {
            let status = await MusicAuthorization.request()
            switch status {
            case .authorized:
                do {
                    let response = try await requestSearch.response()
                    
                    self.mumoryDataViewModel.musicModels = response.songs.compactMap({
                        .init(songID: $0.id, title: $0.title, artist: $0.artistName, artworkUrl: $0.artwork?.url(width: 500, height: 500))
                    })
//                    print("do: \(self.mumoryDataViewModel.musicModels)")
                } catch {
                    print("catch: \(String(describing: error))")
                }
            default :
                break
            }
        }
    }
    
    func fetchSongInfo(songId: String) async throws -> MusicModel {
        let musicItemID = MusicItemID(rawValue: songId)
        let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
        let response = try await request.response()
        guard let song = response.items.first else {
            throw NSError(domain: "GoogleMapSample", code: 1, userInfo: [NSLocalizedDescriptionKey: "Song not found"])
        }
        let artworkUrl = song.artwork?.url(width: 500, height: 500)
        return MusicModel(songID: musicItemID, title: song.title, artist: song.artistName, artworkUrl: artworkUrl)
    }
}
