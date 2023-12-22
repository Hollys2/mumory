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
            appCoordinator.path.removeLast()
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
                    Text(musicModel.title ?? "NO TITLE ")
                        .lineLimit(1)
                        .font(Font.custom("Pretendard", size: 15).weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(musicModel.artist ?? "NO ARTIST")
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
    
    @Binding var translation: CGSize
    
    @State private var searchText = ""
    
    @StateObject var localSearchViewModel: LocalSearchViewModel = .init()
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    @GestureState var dragAmount = CGSize.zero
    
    var body: some View {
        VStack(spacing: 0) {
            Image(uiImage: SharedAsset.dragIndicator.image)
                .frame(maxWidth: .infinity)
                .padding(.top, 14)
                .padding(.bottom, 14)
                .background(SharedAsset.backgroundColor.swiftUIColor) // 색이 존재해야 제스처 동작함
                .gesture(
                    DragGesture()
                        .updating($dragAmount) { value, state, _ in
                            if value.translation.height > 0 {
                                translation.height = value.translation.height
                            }
                        }
                        .onEnded { value in
                            withAnimation(Animation.easeInOut(duration: 0.1)) {
                                if value.translation.height > 130 {
                                    appCoordinator.isCreateMumorySheetShown = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        appCoordinator.path.removeLast(appCoordinator.path.count)
                                    }
                                }
                                translation.height = 0
                            }
                        }
                )
            
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
                            mumoryDataViewModel.musicModels = searchAppleMusic()
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
                    appCoordinator.path.removeLast()
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
                .onAppear {
                    fetchMusic()
                }
            } // ScrollView
            .scrollIndicators(.hidden)
        } // VStack
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal, 21)
        .frame(width: UIScreen.main.bounds.width + 1)
        .background(Color(red: 0.09, green: 0.09, blue: 0.09))
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
                    print("do: \(self.mumoryDataViewModel.musicModels)")
                } catch {
                    print("catch: \(String(describing: error))")
                }
            default :
                break
            }
        }
    }
    
    private func searchAppleMusic() -> [MusicModel] {
        mumoryDataViewModel.musicModels = []
        
        Task {
            do {
                var request = MusicCatalogSearchRequest(term: searchText, types: [Song.self])
                request.limit = 10
                let response = try await request.response()

                response.songs.forEach { song in
                    let newMusicModel = MusicModel(songID: song.id, title: song.title, artist: song.artistName, artworkUrl: song.artwork?.url(width: 500, height: 500))
                    mumoryDataViewModel.musicModels.append(newMusicModel)
                }
            } catch {
                print("에러2: \(error)")
            }
        }
        return mumoryDataViewModel.musicModels
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

//    private func loadSongs() {
//        db.collection("favorite").document("musicIDs").getDocument { (document, error) in
//            if let error = error {
//                print("Error getting document: \(error)")
//            } else if let document = document, document.exists {
//                if let musicIDs = document.data()?["IDs"] as? [String] {
//                    print("Music IDs: \(musicIDs)")
//                    songIDs = musicIDs
//                    
//                    Task {
//                        for songId in musicIDs {
//                            do {
//                                let songItem = try await fetchSongInfo(songId: songId)
//                                songs.append(songItem)
//                            } catch {
//                                print("Error fetching song info for ID \(songId): \(error)")
//                            }
//                        }
//                    }
//                } else {
//                    print("No Music IDs")
//                }
//            } else {
//                print("Document does not exist")
//            }
//        }
//    }
}


@available(iOS 16.0, *)
struct SearchMusicView_Previews: PreviewProvider {
    @State static var x: CGSize = CGSize(width: 100, height: 100)
    
    static var previews: some View {
        SearchMusicView(translation: $x)
    }
}



//            if self.musicViewModel.musicModels.isEmpty {
//                ScrollView {
//                    VStack(spacing: 15) {
//                        VStack(spacing: 0) {
//                            Button(action: {
//                                if let currentLocation = locationManager.currentLocation {
//                                    mumoryDataViewModel.getChoosedeMumoryModelLocation(location: currentLocation) { model in
//                                        mumoryDataViewModel.choosedMumoryModel = model
//                                    }
//                                    appCoordinator.path.removeLast()
//                                } else {
//                                    print("ERROR: locationManager.userLocation is nil")
//                                }
//                            }) {
//                                ZStack {
//                                    Rectangle()
//                                        .foregroundColor(.clear)
//                                        .frame(maxWidth: .infinity)
//                                        .frame(height: 55)
//                                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
//
//                                    HStack(spacing: 10) {
//                                        Image(uiImage: SharedAsset.userSearchLocation.image)
//                                            .resizable()
//                                            .frame(width: 29, height: 29)
//
//                                        Text("음악 인식")
//                                            .font(
//                                                Font.custom("Apple SD Gothic Neo", size: 14)
//                                                    .weight(.medium)
//                                            )
//                                            .foregroundColor(.white)
//
//                                        Spacer()
//                                    }
//                                    .padding(.leading, 20)
//                                }
//                            }
//                        }
//                        .cornerRadius(15)
//                        .background(SharedAsset.backgroundColor.swiftUIColor)
//
//                        VStack(spacing: 0) {
//                            HStack {
//                                Text("최근 검색")
//                                    .font(
//                                        Font.custom("Pretendard", size: 13)
//                                            .weight(.medium)
//                                    )
//                                    .foregroundColor(.white)
//
//                                Spacer()
//
//                                Button(action: {
//
//                                }) {
//                                    Text("전체삭제")
//                                        .font(
//                                            Font.custom("Pretendard", size: 12)
//                                                .weight(.medium)
//                                        )
//                                        .multilineTextAlignment(.trailing)
//                                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
//                                }
//                            }
//                            .padding([.horizontal, .top], 20)
//                            .padding(.bottom, 11)
//
//                            ForEach(1...10, id: \.self) { index in
//                                HStack {
//                                    Image(systemName: "magnifyingglass")
//                                        .frame(width: 23, height: 23)
//                                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
//
//                                    Text("검색검색 \(index)")
//                                        .font(
//                                            Font.custom("Pretendard", size: 14)
//                                                .weight(.semibold)
//                                        )
//                                        .foregroundColor(.white)
//
//                                    Spacer()
//
//                                    Button(action: {}) {
//                                        Image(systemName: "xmark")
//                                            .frame(width: 19, height: 19)
//                                            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
//                                    }
//                                }
//                                .frame(maxWidth: .infinity)
//                                .frame(height: 50)
//                                .padding(.leading, 15)
//                                .padding(.trailing, 20)
//                            }
//                        }
//                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
//                        .cornerRadius(15)
//                    } // VStack
//                    .padding(.bottom, 66)
//                } // ScrollView
//                .scrollIndicators(.hidden)
//                .cornerRadius(15)
//            } else {
