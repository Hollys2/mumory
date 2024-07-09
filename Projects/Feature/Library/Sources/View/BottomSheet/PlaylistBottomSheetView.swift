//
//  PlaylistBottomSheetView.swift
//  Feature
//
//  Created by 제이콥 on 2/14/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct PlaylistBottomSheetView: View {
    // MARK: - Object lifecycle
    init(playlist: SongPlaylist, editPlaylistNameAction: @escaping () -> Void) {
        self.playlist = playlist
        self.editPlaylistNameAction = editPlaylistNameAction
    }
    
    // MARK: - Propoerties
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @State var isPresentDeletePlaylistBottomSheet: Bool = false
    private let lineGray = Color(white: 0.28)
    var playlist: SongPlaylist
    var editPlaylistNameAction: () -> Void
    

    
    var body: some View {
        VStack(spacing: 0, content: {
            HStack(alignment: .center,spacing: 10,content: {
                MiniPlaylistImage(songs: playlist.songs)
                
                
                Text(playlist.title)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(.white)
                    .truncationMode(.tail)
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            
            Divider05()
                .padding(.horizontal, 4)
                .padding(.bottom, 10)
            
            BottomSheetItem(image: SharedAsset.editPlaylist.swiftUIImage, title: "플레이리스트 이름 수정")
                .onTapGesture {
                    editPlaylistNameAction()
                }
            
            BottomSheetItem(image: SharedAsset.addMusic.swiftUIImage, title: "음악 추가")
                .onTapGesture {
                    dismiss()
                    appCoordinator.rootPath.append(MumoryPage.addSong(originPlaylist: playlist))
                }
            BottomSheetItem(image: SharedAsset.deleteMumoryDetailMenu.swiftUIImage, title: "플레이리스트 삭제", type: .warning)
                .onTapGesture {
                    UIView.setAnimationsEnabled(false)
                    isPresentDeletePlaylistBottomSheet.toggle()
                }
            BottomSheetItem(image: SharedAsset.report.swiftUIImage, title: "신고")
                .onTapGesture {
                    dismiss()
                    appCoordinator.rootPath.append(MumoryPage.report)
                }
        })
        .padding(.bottom, 15)
        .background(ColorSet.background)
        .fullScreenCover(isPresented: $isPresentDeletePlaylistBottomSheet, content: {
            TwoButtonPopupView(title: "해당 플레이리스트를 삭제하시겠습니까?", positiveButtonTitle: "플레이리스트 삭제") {
                let db = FirebaseManager.shared.db
                let playlistId = playlist.id
                let path = db.collection("User").document(currentUserViewModel.user.uId).collection("Playlist").document(playlist.id)
                path.delete()
                appCoordinator.rootPath.removeLast()
                currentUserViewModel.playlistViewModel.playlists.removeAll(where: {$0.id == playlistId})
            }
            .background(TransparentBackground())
        })
    }
}

private struct MiniPlaylistImage: View {
    // MARK: - Object lifecycle
    init(songs: [SongModel]) {
        self.songs = songs
    }
    
    // MARK: - Propoerties
    var songs: [SongModel]
    let imageSize = 30.0
    let border = 0.5
    
    // MARK: - View
    var body: some View {
        VStack(spacing: 0, content: {
            HStack(spacing: 0, content: {
                //1번째 이미지
                if songs.count < 1 {
                    Rectangle()
                        .fill(ColorSet.darkGray)
                        .frame(width: imageSize, height: imageSize)
                }else{
                    AsyncImage(url: songs[0].artworkUrl, transaction: Transaction(animation: .default)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: imageSize, height: imageSize)
                        default:
                            Rectangle()
                                .fill(ColorSet.skeleton)
                                .frame(width: imageSize, height: imageSize)
                        }
                    }
                }
                
                //세로줄(구분선)
                Rectangle()
                    .frame(width: border, height: imageSize)
                    .foregroundStyle(ColorSet.background)
                
                //2번째 이미지
                if songs.count < 2{
                    Rectangle()
                        .fill(ColorSet.darkGray)
                        .frame(width: imageSize, height: imageSize)
                }else{
                    AsyncImage(url: songs[1].artworkUrl, transaction: Transaction(animation: .default)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: imageSize, height: imageSize)
                        default:
                            Rectangle()
                                .fill(ColorSet.skeleton)
                                .frame(width: imageSize, height: imageSize)
                        }
                    }
                }
                
                
            })
            
            //가로줄(구분선)
            Rectangle()
                .frame(width: imageSize * 2 + border, height: border)
                .foregroundStyle(ColorSet.background)
            
            HStack(spacing: 0,content: {
                //3번째 이미지
                if songs.count < 3 {
                    Rectangle()
                        .fill(ColorSet.darkGray)
                        .frame(width: imageSize, height: imageSize)
                }else{
                    AsyncImage(url: songs[2].artworkUrl, transaction: Transaction(animation: .default)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: imageSize, height: imageSize)
                        default:
                            Rectangle()
                                .fill(ColorSet.skeleton)
                                .frame(width: imageSize, height: imageSize)
                        }
                    }
                }
                
                //세로줄 구분선
                Rectangle()
                    .frame(width: 0.5, height: imageSize)
                    .foregroundStyle(ColorSet.background)
                
                //4번째 이미지
                if songs.count <  4 {
                    Rectangle()
                        .fill(ColorSet.darkGray)
                        .frame(width: imageSize, height: imageSize)
                }else{
                    AsyncImage(url: songs[3].artworkUrl, transaction: Transaction(animation: .default)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: imageSize, height: imageSize)
                        default:
                            Rectangle()
                                .fill(ColorSet.skeleton)
                                .frame(width: imageSize, height: imageSize)
                        }
                    }
                }
                
                
            })
        })
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
    }
}
