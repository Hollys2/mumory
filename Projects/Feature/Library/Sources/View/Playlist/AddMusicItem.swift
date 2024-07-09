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
    // MARK: - Object lifecycle
    init(song: Song, originPlaylist: Binding<SongPlaylist>) {
        self._originPlaylist = originPlaylist
        self.song = song
    }
    
    // MARK: - Propoerties
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    @Binding var originPlaylist: SongPlaylist
    @State var isSnackBarPresent: Bool = false
    let song: Song

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
                Text(song.title)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(song.artistName)
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
                    addSongToPlaylist()
                }
        })
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .frame(height: 70)
        
    }
    private func addSongToPlaylist() {
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        let alreadyExists: Bool = originPlaylist.songs.contains(where: {$0.id == song.id.rawValue})
        
        if alreadyExists {
            snackBarViewModel.setSnackBarAboutPlaylist(status: .failure, playlistTitle: originPlaylist.title)
        } else {
            let song: SongModel = SongModel(id: song.id.rawValue, title: song.title, artistName: song.artistName, artworkUrl: song.artwork?.url(width: 500, height: 500))
            originPlaylist.songs.append(song)
            
            let songData = [
                "id" : song.id,
                "title": song.title,
                "artistName": song.artistName,
                "image": song.artworkUrl?.absoluteString ?? ""
            ]
            
            let monthlyStatData: [String: Any] = [
                "date": Date(),
                "songId": song.id,
                "type": "playlist"
            ]
            
            db.collection("User").document(currentUserViewModel.user.uId).collection("Playlist").document(originPlaylist.id)
                .updateData(["songs": FirebaseManager.Fieldvalue.arrayUnion([songData])])
            db.collection("User").document(currentUserViewModel.user.uId).collection("MonthlyStat").addDocument(data: monthlyStatData)
            
            snackBarViewModel.setSnackBarAboutPlaylist(status: .success, playlistTitle: originPlaylist.title)
            snackBarViewModel.setRecentSaveData(playlist: originPlaylist, songs: [song])
            
            guard let index = currentUserViewModel.playlistViewModel.playlists.firstIndex(where: {$0.id == originPlaylist.id}) else {return}
            currentUserViewModel.playlistViewModel.playlists[index].songs.append(song)

        }
    }
}
