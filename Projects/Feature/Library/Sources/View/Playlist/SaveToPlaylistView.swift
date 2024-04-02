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
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
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
                        appCoordinator.rootPath.removeLast()
                    } label: {
                        SharedAsset.xWhite.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                    
                    
                })
                .padding(.horizontal, 20)
                .frame(height: 70)
                
                Divider05()
                
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
                Divider05()
                
                Rectangle()
                    .fill(Color.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 16)
                
                Divider05()
                
                
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
            playerViewModel.setLibraryPlayerVisibility(isShown: false)
        })

    }
    
    private func saveSongToPlaylist(to: MusicPlaylist)  {
        let Firebase = FBManager.shared
        let db = Firebase.db
        
        let path = db.collection("User").document(currentUserData.uId).collection("Playlist")
        
        if self.songIDs.count > 1 {
            //리스트로 저장할 때
            DispatchQueue.global(qos: .background ).async {
                path.document(to.id).updateData(["songIds": FBManager.Fieldvalue.arrayUnion(songIDs)]) { error in
                    guard error == nil else {
                        return
                    }
                    guard let firstSongId = songIDs.first else {return}
                    let monthlyStatData = [
                        "date": Date(),
                        "songId": firstSongId,
                        "type": "playlist"
                    ]
                    db.collection("User").document(currentUserData.uId).collection("MonthlyStat").addDocument(data: monthlyStatData)
                    snackBarViewModel.setRecentSaveData(playlist: to, songIds: songIDs)
                    snackBarViewModel.setSnackBarAboutPlaylist(status: .success, playlistTitle: to.title)
                }
            }
            appCoordinator.rootPath.removeLast()
        }else {
            //1곡씩 저장할 때
            guard let song = self.songIDs.first else {
                return
            }
            //이미 있으면 실패 스낵바, 없으면 저장
            if to.songIDs.contains(song) {
                snackBarViewModel.setSnackBarAboutPlaylist(status: .failure, playlistTitle: to.title)
            }else {
                DispatchQueue.global().async {
                    path.document(to.id).updateData(["songIds": FBManager.Fieldvalue.arrayUnion([song])]) { error in
                        guard error == nil else {
                            return
                        }
                        let monthlyStatData = [
                            "date": Date(),
                            "songId": song,
                            "type": "playlist"
                        ]
                        db.collection("User").document(currentUserData.uId).collection("MonthlyStat").addDocument(data: monthlyStatData)
                        snackBarViewModel.setRecentSaveData(playlist: to, songIds: [song])
                        snackBarViewModel.setSnackBarAboutPlaylist(status: .success, playlistTitle: to.title)
                    }
                }
                appCoordinator.rootPath.removeLast()
            }
        }
        
        
        
    }
    
    private func getUserPlaylist() {
        self.playlistArray = []
        let Firebase = FBManager.shared
        let db = Firebase.db
        
        let path = db.collection("User").document(currentUserData.uId).collection("Playlist")
        
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
                    
                    guard let songIDs = document.data()["songIds"] as? [String] else {
                        print("no song id")
                        return
                    }
                    
                    guard let date = (document.data()["date"] as? FBManager.TimeStamp)?.dateValue() else {
                        return
                    }
                    
                    let id = document.documentID

                    
                    withAnimation {
                        if !(id == "favorite") {
                            self.playlistArray.append(MusicPlaylist(id: id, title: title, songIDs: songIDs, isPublic: isPublic, createdDate: date))
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
