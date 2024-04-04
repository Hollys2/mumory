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
import MapKit

struct PlaylistView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    @State var offset: CGPoint = .zero
    @State var isBottomSheetPresent: Bool = false
    @State var isEditing: Bool = false
    @State var isSongDeletePopupPresent: Bool = false
    @State var selectedSongsForDelete: [Song] = []
    @State var isPresentModifyPlaylistView: Bool = false
    @State var selectedTab: Tab = .library
    @State private var isLoading: Bool = false
    @State var searchIndex: Int = 0
    @Binding var playlist: MusicPlaylist
    let itemHeight: CGFloat = 70
    init(playlist: Binding<MusicPlaylist>){
        self._playlist = playlist
    }
    
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()

            //이미지
            PlaylistImage(songs: $playlist.songs)
                .frame(width: getUIScreenBounds().width)
                .offset(y: offset.y < -currentUserData.topInset ? -(offset.y+currentUserData.topInset) : 0)
                .overlay {
                    LinearGradient(colors: [ColorSet.background.opacity(0.8), Color.clear], startPoint: .top, endPoint: .init(x: 0.5, y: 0.3))
                    ColorSet.background.opacity(offset.y/(getUIScreenBounds().width-50.0))
                }
        
            
            
            SimpleScrollView(contentOffset: $offset) {
                
                VStack(spacing: 0, content: {
                    SharedAsset.bottomGradient.swiftUIImage
                        .resizable()
                        .frame(width: getUIScreenBounds().width, height: 45)
                        .ignoresSafeArea()
                        .padding(.top, getUIScreenBounds().width - currentUserData.topInset - 30) //사진 세로 길이 - 세이프공간 높이 - 그라데이션과 사진이 겹치는 부분
                    
                    VStack(spacing: 0, content: {
                        Text(playlist.title)
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 24))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .foregroundStyle(.white)
                            .padding(.bottom, 8)

                        
                        //나만보기 아이템
                        HStack(spacing: 5, content: {
                            SharedAsset.lock.swiftUIImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 13, height: 13)
                            
                            Text("나만보기")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                .foregroundStyle(ColorSet.subGray)
                        })
                        .opacity(playlist.isPublic ? 0 : 1)
                        .padding(.bottom, 24)
                        
                        ZStack(alignment: .bottom){
                            
                            //편집시 전체선택
                            HStack(spacing: 0, content: {
                                if playlist.songs.count == selectedSongsForDelete.count {
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
                                    SharedAsset.checkCircleDefault.swiftUIImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 28, height: 28)
                                        .padding(.trailing, 14)
                                        .onTapGesture {
                                            DispatchQueue.main.async {
                                                selectedSongsForDelete = playlist.songs
                                            }
                                        }
                                }
                                
                                Text("전체선택")
                                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                                    .foregroundStyle(Color.white)
                                
                                Spacer()
                            })
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .opacity(isEditing ? 1 : 0)
                            
                            //평소 보이는 곡 개수와 편집, 전체 재생 버튼
                            HStack(alignment: .bottom,spacing: 8, content: {
                                Text("\(playlist.songIDs.count)곡")
                                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                                    .foregroundStyle(ColorSet.subGray)
                                Spacer()
                                
                                EditButton()
                                    .onTapGesture {
                                        playerViewModel.setLibraryPlayerVisibility(isShown: false)
                                        self.selectedSongsForDelete.removeAll()
                                        setEditMode(isEditing: true)
                                        AnalyticsManager.shared.setSelectContentLog(title: "PlaylistViewEditButton")
                                    }
                                
                                PlayAllButton()
                                    .onTapGesture {
                                        playerViewModel.playAll(title: playlist.title, songs: playlist.songs)
                                    }
                            })
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .opacity(isEditing ? 0 : 1)

                        }
                        .animation(.default, value: isEditing)
                        .frame(maxWidth: .infinity)
                        .frame(height: 33)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 15)
                        
                        if playlist.songs.isEmpty {
                            Text("음악이 없습니다")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                .foregroundStyle(ColorSet.subGray)
                                .padding(.top, getUIScreenBounds().height * 0.15)
                        }
                        //플레이리스트 곡 목록
                        ForEach(playlist.songs, id: \.self) { song in
                            PlaylistMusicListItem(song: song, isEditing: $isEditing, selectedSongs: $selectedSongsForDelete)
                                .animation(.default, value: isEditing)
                                .onTapGesture {
                                    if isEditing{
                                        if selectedSongsForDelete.contains(song) {
                                            selectedSongsForDelete.removeAll(where: {$0.id == song.id})
                                        }else {
                                            selectedSongsForDelete.append(song)
                                        }
                                    }else {
                                        playerViewModel.playAll(title: playlist.title, songs: playlist.songs, startingItem: song)
                                        searchIndex = playlist.songIDs.count / 20 + 1 //스크롤 이동 시 새로 로드되는 걸 막기 위해서
                                        let startIndex = playlist.songs.count
                                        let endIndex = playlist.songIDs.endIndex
                                        let requestSongIds = Array(playlist.songIDs[startIndex..<endIndex])
                                        Task {
                                            let songs = await fetchSongs(songIDs: requestSongIds)
                                            guard let index = currentUserData.playlistArray.firstIndex(where: {$0.id == playlist.id}) else {return}
                                            currentUserData.playlistArray[index].songs.append(contentsOf: songs)
                                            playerViewModel.setQueue(songs: playlist.songs, startSong: song)
                                        }
                                    }
                                }
                        }
                        
                        if isLoading {
                            SongListSkeletonView()
                        }
                  
                        
                        
                        //플레이어에 가려지는 높이만큼 채워주기
                        //노래가 채워지면서 뷰의 크기가 바뀌면 에러발생함. 따라서 맨 처음에는 1000만큼 공간을 채워줘서 안정적으로 데이터를 받아올 수 있도록 함
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(height: isLoading ? 1000 : playlist.songs.count < 10 ? 400 : 90)
                        
                        
                    })
                    .offset(y: -30) //그라데이션과 겹치도록 위로 30만큼 땡김
                    .frame(width: getUIScreenBounds().width, alignment: .center)
                    .background(ColorSet.background)
                    
                    
                    
                })
                .frame(width: getUIScreenBounds().width)
                .frame(minHeight: getUIScreenBounds().height)

            }
            .refreshAction {
                Task {
                    self.isLoading = true
                    let songs = await currentUserData.requestMorePlaylistSong(playlistID: playlist.id)
                    guard let index = currentUserData.playlistArray.firstIndex(where: {$0.id == playlist.id}) else {return}
                    currentUserData.playlistArray[index].songs = songs
                    self.isLoading = false
                }
            }
            .scrollIndicators(.hidden)
            .onChange(of: offset, perform: { value in
                if offset.y > CGFloat(searchIndex) * itemHeight * 17 {
                    searchIndex += 1
                    DispatchQueue.main.async {
                        Task {
                            let startIndex = searchIndex * 20
                            guard startIndex < playlist.songIDs.endIndex else {return}
                            var endIndex = startIndex + 20
                            endIndex = playlist.songIDs.endIndex < endIndex ? playlist.songIDs.endIndex : endIndex
                            let requestSongIds = Array(playlist.songIDs[startIndex..<endIndex])
                            guard let index = currentUserData.playlistArray.firstIndex(where: {$0.id == playlist.id}) else {return}
                            currentUserData.playlistArray[index].songs.append(contentsOf: await fetchSongs(songIDs: requestSongIds))
                        }
                    }
                }
            })
            
            //상단바 - z축 최상위
            HStack(spacing: 0, content: {
                SharedAsset.backGradient.swiftUIImage
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.leading, 20)
                    .opacity(isEditing ? 0 : 1)
                    .onTapGesture {
                        appCoordinator.rootPath.removeLast()
                    }
                
                Spacer()
                
                if isEditing {
                    Button(action: {
                        setEditMode(isEditing: false)
                        playerViewModel.setLibraryPlayerVisibility(isShown: true)
                    }, label: {
                        Text("완료")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                            .foregroundStyle(Color.white)
                            .frame(width: 45, height: 45)
                            .shadow(color: Color.black.opacity(0.5), radius: 5)
                            .padding(.trailing, 20)
                    })
                    
                }else {
                    SharedAsset.menuGradient.swiftUIImage
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.trailing, 20)
                        .onTapGesture {
                            UIView.setAnimationsEnabled(false)
                            isBottomSheetPresent = true
                        }
                }
                
                
            })
            .frame(height: 65)
            .padding(.top, currentUserData.topInset)
            
            
            SharedAsset.underGradientLarge.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .opacity(isEditing ? 1 : 0)
            
            //삭제버튼
            DeleteSongButton(title: "삭제", isEnabled: selectedSongsForDelete.count > 0, deleteSongCount: selectedSongsForDelete.count) {
                UIView.setAnimationsEnabled(false)
                isSongDeletePopupPresent = true
            }
            .shadow(color: Color.black.opacity(0.25), radius: 10, y: 6)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, currentUserData.bottomInset-10)
            .opacity(isEditing ? 1 : 0)

            CreateMumoryBottomSheetView(isSheetShown: $appCoordinator.isCreateMumorySheetShown, offsetY: $appCoordinator.offsetY)
                .ignoresSafeArea()

        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .onAppear(perform: {
            UIView.setAnimationsEnabled(true)
            playerViewModel.setLibraryPlayerVisibility(isShown: !appCoordinator.isCreateMumorySheetShown, moveToBottom: true)
            Task {
                isLoading = true
                let startIndex = 0
                var endIndex = playlist.songIDs.endIndex < 20 ? playlist.songIDs.endIndex : 20
                let requestSongIds = Array(playlist.songIDs[startIndex..<endIndex])

                let songs = await currentUserData.requestMorePlaylistSong(playlistID: playlist.id)
                guard let index = currentUserData.playlistArray.firstIndex(where: {$0.id == playlist.id}) else {return}
                currentUserData.playlistArray[index].songs = await fetchSongs(songIDs: requestSongIds)
                isLoading = false
            }
            AnalyticsManager.shared.setScreenLog(screenTitle: "PlaylistView")
        })
        //플레이리스트의 바텀시트
        .fullScreenCover(isPresented: $isBottomSheetPresent, content: {
            BottomSheetWrapper(isPresent: $isBottomSheetPresent)  {
                PlaylistBottomSheetView(playlist: playlist, songs: playlist.songs, editPlaylistNameAction: {
                    isBottomSheetPresent = false
                    DispatchQueue.main.async {
                        UIView.setAnimationsEnabled(true)
                        isPresentModifyPlaylistView = true
                    }
                })
            }
            .background(TransparentBackground())
        })
        //플레이리스트 이름 수정 바텀시트
        .fullScreenCover(isPresented: $isPresentModifyPlaylistView) {
            ModifyPlaylistPopupView(playlist: $playlist)
                .background(TransparentBackground())
        }
        //음악 삭제 확인 팝업
        .fullScreenCover(isPresented: $isSongDeletePopupPresent, content: {
            TwoButtonPopupView(title: "\(selectedSongsForDelete.count)개의 음악을 삭제하시겠습니까?", positiveButtonTitle: "음악 삭제") {
                // 삭제버튼 action
                deleteSongsFromPlaylist()
            }
            .background(TransparentBackground())
        })
    }

    
    private func setEditMode(isEditing: Bool) {
        withAnimation {
            self.isEditing = isEditing
        }
    }
    private func deleteSongsFromPlaylist() {
        let Firebase = FBManager.shared
        let db = Firebase.db
        
        let songIdsForDelete = selectedSongsForDelete.map{$0.id.rawValue}

        
        db.collection("User").document(currentUserData.uId).collection("Playlist").document(playlist.id)
            .updateData(["songIds": FBManager.Fieldvalue.arrayRemove(songIdsForDelete)])
        
        playlist.songs.removeAll(where: {selectedSongsForDelete.contains($0)})
        setEditMode(isEditing: false)
    }
}


public struct PlaylistImage: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @State var imageWidth: CGFloat = 0
    @Binding var songs: [Song]
    
    let emptyGray = Color(red: 0.18, green: 0.18, blue: 0.18)
    
    public init(songs: Binding<[Song]>) {
        self._songs = songs
    }
    
    public var body: some View {
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
                .frame(width: getUIScreenBounds().width, height: 1)
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
        .onAppear {
            self.imageWidth = getUIScreenBounds().width/2
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
            
            Divider05()
        })
    }
}

struct SongListSkeletonView: View {
    @State var startAnimation: Bool = true
    var isLineShown: Bool = false
    init(){}
    init(isLineShown: Bool) {
        self.isLineShown = isLineShown
    }
    var body: some View {
        ForEach(0...10, id: \.self) { index in
            SongSkeletonItem
            if isLineShown {
                Divider05()
            }
        }
        .onAppear(perform: {
            startAnimation.toggle()
        })
    }
    
    var SongSkeletonItem: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 5, style: .circular)
                .fill(startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                .frame(width: 40, height: 40)
                .padding(.trailing, 13)
            
            VStack(alignment: .leading, spacing: 5,content: {
                Rectangle()
                    .fill(startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                    .frame(width: 97, height: 14)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                
                Rectangle()
                    .fill(startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                    .frame(width: 24, height: 12)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            })
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .frame(height: 70)
        .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: startAnimation)

    }

}
