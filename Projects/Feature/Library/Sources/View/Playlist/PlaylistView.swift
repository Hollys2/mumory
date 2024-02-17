//
//  PlaylistView.swift
//  Feature
//
//  Created by 제이콥 on 2/12/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit
import Core

struct PlaylistView: View {
    @EnvironmentObject var manager: LibraryManageModel
    @EnvironmentObject var userManager: UserViewModel
    @State var playlist: MusicPlaylist
    @State var offset: CGPoint = .zero
    @State var isBottomSheetPresent: Bool = false
    @State var songs: [Song] = []
    @State var isEditing: Bool = false
    @State var selectedSongsForDelete: [Song] = []
    @State var addSongButtonHeight: CGFloat = 70
    var body: some View {
        ZStack(alignment: .top){
            //이미지
            PlaylistImage(playlist: $playlist, songs: $songs)
                .offset(y: offset.y < -userManager.topInset ? -(offset.y+userManager.topInset) : 0)
            
            SimpleScrollView(contentOffset: $offset) {
                
                VStack(spacing: 0, content: {
                    ZStack(alignment: .top){
                        SharedAsset.bottomGradient.swiftUIImage
                            .resizable()
                            .frame(width: userManager.width, height: 45)
                            .padding(.top, userManager.width - userManager.topInset - 30) //사진 세로 길이 - 세이프공간 높이 - 그라데이션과 사진이 겹치는 부분
                    }
                    
                    VStack(spacing: 0, content: {
                        Text(playlist.title)
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 24))
                            .frame(width: userManager.width, alignment: .center)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .foregroundStyle(.white)
                        
                        HStack(spacing: 5, content: {
                            SharedAsset.lock.swiftUIImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 13, height: 13)
                            
                            Text("나만보기")
                                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                                .foregroundStyle(ColorSet.subGray)
                        })
                        .padding(.top, 10)
           
                        HStack(spacing: 0, content: {
                            if isEditing {
                                //편집할 때 나오는 뷰
                                HStack(alignment: .bottom, spacing: 0, content: {
                                    if songs.count == selectedSongsForDelete.count {
                                        SharedAsset.checkCircleFill.swiftUIImage
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 28, height: 28)
                                            .padding(.trailing, 14)
                                            .onTapGesture {
                                                DispatchQueue.main.async {
                                                    selectedSongsForDelete = []
                                                }
                                            }
                                    }else {
                                        SharedAsset.checkCircle.swiftUIImage
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 28, height: 28)
                                            .padding(.trailing, 14)
                                            .onTapGesture {
                                                DispatchQueue.main.async {
                                                    selectedSongsForDelete = songs
                                                }
                                            }
                                    }
                                    
                                    Text("전체선택")
                                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                                        .foregroundStyle(Color.white)
                                    
                                    Spacer()
                                })
                                .padding(.bottom, 17)
                            }else {
                                HStack(alignment: .bottom,spacing: 8, content: {
                                    Text("\(playlist.songIDs.count)곡")
                                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                                        .foregroundStyle(ColorSet.subGray)
                                    Spacer()
                                    
                                    EditButton()
                                        .onTapGesture {
                                            DispatchQueue.main.async {
                                                withAnimation {
                                                    isEditing = true
                                                    addSongButtonHeight = 0
                                                }
                                            }
                                        }
                                    
                                    PlayAllButton()
                                })
                                .padding(.bottom, 15)
                            }
                        })
                        .frame(maxWidth: .infinity)
                        .frame(height: 74, alignment: .bottom)
                        .padding(.horizontal, 20)
                        
                        AddSongButtonInPlaylistView()
                            .frame(height: addSongButtonHeight)
                            .opacity(isEditing ? 0 : 1)
                        
                        LazyVStack(spacing: 0, content: {
                            ForEach(songs, id: \.self) { song in
                                PlaylistMusicListItem(song: song, isEditing: $isEditing, selectedSongsForDelete: $selectedSongsForDelete)
                                Divider()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 0.5)
                                    .background(ColorSet.subGray)
                            }
                        })
                        
                        
                        Rectangle()
                            .foregroundStyle(.yellow)
                            .frame(height: 100)
                            .padding(.top, 1000)
                    })
                    .offset(y: -30)
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
                
                if isEditing {
                    Text("완료")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                        .frame(width: 45, height: 45)
                        .foregroundStyle(Color.white)
                        .padding(.trailing, 20)
                        .onTapGesture {
                            DispatchQueue.main.async {
                                withAnimation {
                                    isEditing = false
                                    addSongButtonHeight = 70
                                }
                            }
                        }
                }else {
                    SharedAsset.menuWhite.swiftUIImage
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.trailing, 20)
                        .onTapGesture {
                            isBottomSheetPresent = true
                        }
                }
                
                
            })
            .frame(height: 50)
            .padding(.top, userManager.topInset)
            .fullScreenCover(isPresented: $isBottomSheetPresent, content: {
                BottomSheetWrapper(isPresent: $isBottomSheetPresent)  {
                    PlaylistBottomSheetView(playlist: playlist, songs: songs)
                        .environmentObject(manager)
                }
                .background(TransparentBackground())
            })
            
            
        }
        .onAppear(perform: {
            getPlaylist()
        })
    }
    
    private func getPlaylist() {
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        
        db.collection("User").document(userManager.uid).collection("Playlist").document(playlist.id).getDocument { snapshot, error in
            if error == nil {
                guard let data = snapshot?.data() else {
                    print("no data")
                    return
                }
                
                guard let songIDs = data["song_IDs"] as? [String] else {
                    print("no song id")
                    return
                }
                
                DispatchQueue.main.async {
                    playlist.songIDs = songIDs
                }
            }
        }
    }
}


private struct PlaylistImage: View {
    @EnvironmentObject var userManager: UserViewModel
    var emptyGray = Color(red: 0.18, green: 0.18, blue: 0.18)
    @Binding var playlist: MusicPlaylist
    @State var imageWidth: CGFloat = 0
    @Binding var songs: [Song]
    var body: some View {
        VStack(spacing: 0, content: {
            HStack(spacing: 0, content: {
                //1번째 이미지
                if songs.count < 1 {
                    Rectangle()
                        .frame(width: imageWidth, height: imageWidth)
                        .foregroundStyle(emptyGray)
                }else{
                    AsyncImage(url: songs[0].artwork?.url(width: 600, height: 600) ?? URL(string: "")) { image in
                        image
                            .resizable()
                            .frame(width: imageWidth, height: imageWidth)
                    } placeholder: {
                        Rectangle()
                            .frame(width: imageWidth, height: imageWidth)
                            .foregroundStyle(emptyGray)
                    }
                }
                
                //세로줄(구분선)
                Rectangle()
                    .frame(width: 1, height: imageWidth)
                    .foregroundStyle(ColorSet.background)
                
                //2번째 이미지
                if songs.count < 2{
                    Rectangle()
                        .frame(width: imageWidth, height: imageWidth)
                        .foregroundStyle(emptyGray)
                }else{
                    AsyncImage(url: songs[1].artwork?.url(width: 600, height: 600) ?? URL(string: "")) { image in
                        image
                            .resizable()
                            .frame(width: imageWidth, height: imageWidth)
                    } placeholder: {
                        Rectangle()
                            .frame(width: imageWidth, height: imageWidth)
                            .foregroundStyle(emptyGray)
                    }
                }
                
                
            })
            
            //가로줄(구분선)
            Rectangle()
                .frame(width: userManager.width, height: 1)
                .foregroundStyle(ColorSet.background)
            
            HStack(spacing: 0,content: {
                //3번째 이미지
                if songs.count < 3 {
                    Rectangle()
                        .frame(width: imageWidth, height: imageWidth)
                        .foregroundStyle(emptyGray)
                }else{
                    AsyncImage(url: songs[2].artwork?.url(width: 600, height: 600) ?? URL(string: "")) { image in
                        image
                            .resizable()
                            .frame(width: imageWidth, height: imageWidth)
                    } placeholder: {
                        Rectangle()
                            .frame(width: imageWidth, height: imageWidth)
                            .foregroundStyle(emptyGray)
                    }
                }
                
                //세로줄 구분선
                Rectangle()
                    .frame(width: 1, height: imageWidth)
                    .foregroundStyle(ColorSet.background)
                
                //4번째 이미지
                if songs.count <  4 {
                    Rectangle()
                        .frame(width: imageWidth, height: imageWidth)
                        .foregroundStyle(emptyGray)
                }else{
                    AsyncImage(url: songs[3].artwork?.url(width: 600, height: 600) ?? URL(string: "")) { image in
                        image
                            .resizable()
                            .frame(width: imageWidth, height: imageWidth)
                    } placeholder: {
                        Rectangle()
                            .frame(width: imageWidth, height: imageWidth)
                            .foregroundStyle(emptyGray)
                    }
                }
                
            })
        })
        .onAppear(perform: {
            imageWidth = userManager.width/2
            Task{
                await fetchSongInfo(songIDs: playlist.songIDs)
            }
        })
        .onChange(of: playlist.songIDs, perform: { value in
            Task{
                await fetchSongInfo(songIDs: value)
            }
        })
    }
    
    private func fetchSongInfo(songIDs: [String]) async {
        self.songs.removeAll()
        for id in songIDs {
            let musicItemID = MusicItemID(rawValue: id)
            let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
            
            do {
                let response = try await request.response()
                
                guard let song = response.items.first else {
                    print("no song")
                    continue
                }
                
                self.songs.append(song)
            } catch {
                print("Error: \(error)")
            }
        }
    }
}

private struct AddSongButtonInPlaylistView: View {
    var body: some View {
        VStack(spacing: 0, content: {
            HStack(spacing: 13, content: {
                RoundedRectangle(cornerRadius: 5, style: .circular)
                    .frame(width: 40, height: 40)
                    .foregroundStyle(ColorSet.skeleton)
                    .overlay {
                        SharedAsset.addPurple.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                
                Text("음악 추가")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(Color.white)
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
            
            Divider()
                .frame(maxWidth: .infinity)
                .frame(height: 0.5)
                .background(ColorSet.subGray)
        })
    }
}
