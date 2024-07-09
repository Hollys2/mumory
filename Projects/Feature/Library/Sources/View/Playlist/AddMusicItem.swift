//
//  AddSongItem.swift
//  Feature
//
//  Created by 제이콥 on 2/16/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit
import Core

struct AddMusicItem: View {
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    @Binding var originPlaylist: MusicPlaylist
    @State var isSnackBarPresent: Bool = false
    let song: Song
    init(song: Song, originPlaylist: Binding<MusicPlaylist>) {
        self._originPlaylist = originPlaylist
        self.song = song
    }
    var body: some View {
        HStack(spacing: 0, content: {
            AsyncImage(url: song.artwork?.url(width: 300, height: 300)) { image in
                image
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 5,style: .circular))
            } placeholder: {
                RoundedRectangle(cornerRadius: 5, style: .circular)
                    .foregroundStyle(.gray)
                    .frame(width: 40, height: 40)
            }
            .padding(.trailing, 13)
            
            
            VStack(content: {
                Text(song.title ?? "")
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(song.artistName ?? "")
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(LibraryColorSet.lightGrayTitle)
                    .lineLimit(1)
                    .truncationMode(.tail)
            })
            
            Spacer()
            SharedAsset.addPurpleCircleFilled.swiftUIImage
                .resizable()
                .scaledToFill()
                .frame(width: 31, height: 31)
                .onTapGesture {
                    hideKeyboard()
                    addMusicToPlaylist(song: song)
                    
                }
        })
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .frame(height: 70)
        
    }
    private func addMusicToPlaylist(song: Song) {
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        let songID = song.id.rawValue
        
        if !originPlaylist.songIDs.contains(songID) {
            //선택한 곡이 기존 플리에 없을 때 - 추가 진행
            originPlaylist.songIDs.append(songID)
            
            let songData: [String: Any] = [
                "songIds" : FirebaseManager.Fieldvalue.arrayUnion([songID])
            ]
            let monthlyStatData: [String: Any] = [
                "date": Date(),
                "songId": songID,
                "type": "playlist"
            ]
            db.collection("User").document(currentUserViewModel.user.uId).collection("Playlist").document(originPlaylist.id)
                .updateData(["songIds": FirebaseManager.Fieldvalue.arrayUnion([songID])])
            db.collection("User").document(currentUserViewModel.user.uId).collection("MonthlyStat").addDocument(data: monthlyStatData)
            snackBarViewModel.setSnackBarAboutPlaylist(status: .success, playlistTitle: originPlaylist.title)
            snackBarViewModel.setRecentSaveData(playlist: originPlaylist, songIds: [songID])
            guard let index = currentUserViewModel.playlistViewModel.playlistArray.firstIndex(where: {$0.id == originPlaylist.id}) else {return}
            currentUserViewModel.playlistViewModel.playlistArray[index].songIDs.append(songID)
            currentUserViewModel.playlistViewModel.playlistArray[index].songs.append(song)
        }else {
            //선택한 곡이 기존 플리에 존재할 때 - 추가 안 함
            snackBarViewModel.setSnackBarAboutPlaylist(status: .failure, playlistTitle: originPlaylist.title)
        }
    }
}
