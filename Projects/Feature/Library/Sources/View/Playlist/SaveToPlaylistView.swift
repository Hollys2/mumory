//
//  SelectPlaylistView.swift
//  Feature
//
//  Created by 제이콥 on 2/20/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit
import Core

//struct SimplePlaylist: Equatable {
//    var title: String
//    var id: String
//    var isFavorite: Bool
//    var isPrivate: Bool
//}

struct SaveToPlaylistView: View {
    @EnvironmentObject var userManager: UserViewModel
    @EnvironmentObject var manager: LibraryManageModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    @State var selectedPlaylist: [MusicPlaylist] = []
    @State var playlistArray: [MusicPlaylist] = []
    @State var isCreatePopupPresent: Bool = false
    var song: Song

    init(song: Song) {
        self.song = song
    }
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            VStack(spacing: 0, content: {
                //상단바
                HStack(alignment: .top,content: {
                    Rectangle()
                        .foregroundStyle(.clear)
                        .frame(width: 30, height: 30)
                    Spacer()
                    Text("플레이리스트에 추가")
                        .foregroundStyle(Color.white)
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))

                    Spacer()
                    Button {
                        manager.pop()
                    } label: {
                        SharedAsset.xWhite.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }

             
                })
                .padding(.horizontal, 20)
                .frame(height: 70)
                
                //구분선
                Divider()
                    .frame(maxWidth: .infinity)
                    .frame(height: 0.5)
                    .background(ColorSet.lineGray)
                
                //새 플레이리스트 만들기 버튼
                HStack(spacing: 10, content: {
                    SharedAsset.addPurpleCircle.swiftUIImage
                    
                    Text("새 플레이리스트 만들기")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                        .foregroundStyle(ColorSet.mainPurpleColor)
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 70)
                .padding(.horizontal, 20)
                .onTapGesture {
                    UIView.setAnimationsEnabled(true)
                    isCreatePopupPresent = true
                }
                .fullScreenCover(isPresented: $isCreatePopupPresent) {
                    CreatePlaylistPopupView()
                        .background(TransparentBackground())
                }
                .onChange(of: isCreatePopupPresent) { newValue in
                    if !newValue {
                        getUserPlaylist()
                    }
                }
                
                //새 플레이리스트 만들기 버튼 하단 굵은 구분선
                Divider()
                    .frame(maxWidth: .infinity)
                    .frame(height: 0.5)
                    .background(ColorSet.lineGray)
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 16)
                Divider()
                    .frame(maxWidth: .infinity)
                    .frame(height: 0.5)
                    .background(ColorSet.lineGray)
                
                
                LazyVStack(spacing: 0, content: {
                    ForEach(playlistArray, id: \.id) { playlist in
                        SaveToPlaylistItem(playlist: playlist, selectedPlaylists: $selectedPlaylist)
                            .onTapGesture {
                                if selectedPlaylist.contains(where: {$0==playlist}) {
                                    selectedPlaylist.removeAll(where: {$0==playlist})
                                }else {
                                    selectedPlaylist.append(playlist)
                                }
                            }
                    }
                })

                
            })
        }
        .onAppear(perform: {
            getUserPlaylist()
            withAnimation {
                appCoordinator.isHiddenTabBar = true
            }
        })
        .onDisappear(perform: {
            saveSongToPlaylist()
            withAnimation {
                appCoordinator.isHiddenTabBar = false
            }
            
        })
    }
    
    private func saveSongToPlaylist()  {
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        
        let path = db.collection("User").document(userManager.uid).collection("Playlist")
        
        DispatchQueue.global().async {
            
            //기존에 해당 곡이 포함되어있는 플레이리스트였는데, 현재 페이지에서 체크를 해제한(플리에서 곡을 삭제한) 경우
            playlistArray.forEach { playlist in
                if !selectedPlaylist.contains(where: {$0==playlist}) {
                    if playlist.songIDs.contains(song.id.rawValue) {
                        var data = playlist.songIDs
                        data.removeAll(where: {$0 == song.id.rawValue})
                        path.document(playlist.id).setData(["song_IDs" : data], merge: true)
                        print("good1")
                    }
                }
            }
            
            //기존에 없던 노래여서 새로 추가해야하는 경우(이미 해당 곡이 있는 플리면 다시 저장하지 않음)
            selectedPlaylist.forEach { playlist in
                if !playlist.songIDs.contains(song.id.rawValue) {
                    var data = playlist.songIDs
                    data.append(song.id.rawValue)
                    path.document(playlist.id).setData(["song_IDs" : data], merge: true)
                    print("good2")
                }
            }
        }
      
    }
    
    private func getUserPlaylist() {
        self.playlistArray = []
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        
        let path = db.collection("User").document(userManager.uid).collection("Playlist")

        path.getDocuments { snapshots, error in
            if error == nil {
                guard let snapshots = snapshots else {
                    print("no snapshot")
                    return
                }
                
                snapshots.documents.forEach { document in
                    guard let title = document.data()["title"] as? String else {
                        print("no title")
                        return
                    }
                    
                    let id = document.documentID

                    guard let isPrivate = document.data()["is_private"] as? Bool else {
                        print("no is Private")
                        return
                    }

                    guard let isFavorite = document.data()["is_favorite"] as? Bool else {
                        print("no is Favorite")
                        return
                    }
                    
                    guard let songIDs = document.data()["song_IDs"] as? [String] else {
                        print("no song id")
                        return
                    }
                    
                    if songIDs.contains(where: {$0 == song.id.rawValue}) {
                        selectedPlaylist.append(MusicPlaylist(id: id, title: title, songIDs: songIDs, isPrivate: isPrivate, isFavorite: isFavorite, isAddItme: false))
                    }
                    
                    withAnimation {
                        if isFavorite {
                            self.playlistArray.insert(MusicPlaylist(id: id, title: title, songIDs: songIDs, isPrivate: isPrivate, isFavorite: isFavorite, isAddItme: false), at: 0)
                        }else {
                            self.playlistArray.append(MusicPlaylist(id: id, title: title, songIDs: songIDs, isPrivate: isPrivate, isFavorite: isFavorite, isAddItme: false))
                        }
                    }
                  
                }
                
            }else {
                print("error: \(error!.localizedDescription)")
            }
        }
    }
}

//#Preview {
//    SaveToPlaylistView()
//}
