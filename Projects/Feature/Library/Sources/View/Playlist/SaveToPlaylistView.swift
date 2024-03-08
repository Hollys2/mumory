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

struct SaveToPlaylistView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var manager: LibraryManageModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var snackbarManager: SnackBarViewModel
    
    @State var playlistArray: [MusicPlaylist] = []
    @State var isCreatePopupPresent: Bool = false
    var songIDs: [String]
    
    init(songs: [Song]) {
        self.songIDs = songs.map({$0.id.rawValue})
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
                        SaveToPlaylistItem(playlist: playlist)
                            .onTapGesture {
                                saveSongToPlaylist(to: playlist)
                            }
                    }
                })
                
                
            })
        }
        .onAppear(perform: {
            getUserPlaylist()
            appCoordinator.isHiddenTabBarWithoutAnimation = true
            withAnimation {
                appCoordinator.isHiddenTabBar = true
            }
        })
        .onDisappear(perform: {
            appCoordinator.isHiddenTabBarWithoutAnimation = false
            withAnimation {
                appCoordinator.isHiddenTabBar = false
            }
            
        })
    }
    
    private func saveSongToPlaylist(to: MusicPlaylist)  {
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        
        let path = db.collection("User").document(currentUserData.uid).collection("Playlist")
        var data = to.songIDs //기존 노래ID들
        
        if self.songIDs.count > 1 {
            //리스트로 저장할 때
            DispatchQueue.global().async {
                data += self.songIDs.filter({!data.contains($0)}) //중복 제거 후 업로드할 데이터에 추가
                
                let uploadData = [
                    "songIdentifiers" : data
                ]
                
                path.document(to.id).setData(uploadData, merge: true) { error in
                    if error == nil {
                        snackbarManager.setSnackBarAboutPlaylist(status: .success, playlistTitle: to.title)
                    }
                }
            }
            
            manager.pop()
        }else {
            //1곡씩 저장할 때
            guard let song = self.songIDs.first else {
                return
            }
            
            if to.songIDs.contains(song) {
                //이미 해당 플리에 존재할 때
                snackbarManager.setSnackBarAboutPlaylist(status: .failure, playlistTitle: to.title)
            }else {
                //새롭게 추가할 때
                DispatchQueue.global().async {
                    data.append(song)
                    
                    let uploadData = [
                        "songIdentifiers" : data
                    ]
                    
                    path.document(to.id).setData(uploadData, merge: true) { error in
                        if error == nil {
                            snackbarManager.setSnackBarAboutPlaylist(status: .success, playlistTitle: to.title)
                        }
                    }
                }
                manager.pop()
            }
        }
        
        
        
    }
    
    private func getUserPlaylist() {
        self.playlistArray = []
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        
        let path = db.collection("User").document(currentUserData.uid).collection("Playlist")
        
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
                    
                    guard let isPublic = document.data()["isPublic"] as? Bool else {
                        print("no is Private")
                        return
                    }
                    
                    guard let songIDs = document.data()["songIdentifiers"] as? [String] else {
                        print("no song id")
                        return
                    }
                    
                    let id = document.documentID

                    
                    withAnimation {
                        if !(id == "favorite") {
                            self.playlistArray.append(MusicPlaylist(id: id, title: title, songIDs: songIDs, isPublic: isPublic, isAddItme: false))
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