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
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    
    let songID: String
    @Binding var originPlaylist: MusicPlaylist
    @State var isSnackBarPresent: Bool = false
    
    @State var song: Song?
    var body: some View {
        HStack(spacing: 0, content: {
            AsyncImage(url: song?.artwork?.url(width: 300, height: 300)) { image in
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
                Text(song?.title ?? "")
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(song?.artistName ?? "")
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
                    addMusicToPlaylist()
                    
                }
        })
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .frame(height: 70)
        .onAppear(perform: {
            Task{
                await fetchSongInfo(songID: songID)
            }
        })
        
    }
    private func addMusicToPlaylist() {
        let Firebase = FBManager.shared
        let db = Firebase.db
        
        if !originPlaylist.songIDs.contains(songID) {
            //선택한 곡이 기존 플리에 없을 때 - 추가 진행
            originPlaylist.songIDs.append(songID)
            
            let songData: [String: Any] = [
                "songIds" : FBManager.Fieldvalue.arrayUnion([songID])
            ]
            db.collection("User").document(currentUserData.uId).collection("Playlist").document(originPlaylist.id)
                .updateData(["songIds": FBManager.Fieldvalue.arrayUnion([songID])])
            snackBarViewModel.setSnackBarAboutPlaylist(status: .success, playlistTitle: originPlaylist.title)

        }else {
            //선택한 곡이 기존 플리에 존재할 때 - 추가 안 함
            snackBarViewModel.setSnackBarAboutPlaylist(status: .failure, playlistTitle: originPlaylist.title)
        }
    }
    
    private func fetchSongInfo(songID: String) async {
        let musicItemID = MusicItemID(rawValue: songID)
        var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
        request.properties = [.genres, .artists]
        do {
            let response = try await request.response()
            
            guard let song = response.items.first else {
                print("no song")
                return
            }
            DispatchQueue.main.async {
                self.song = song
            }
        } catch {
            print("Error: \(error)")
        }
    }
}

//#Preview {
//    AddSongItem()
//}
