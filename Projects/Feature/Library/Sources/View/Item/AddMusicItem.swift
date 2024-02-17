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
    @EnvironmentObject var userManager: UserViewModel
    let songID: String
    @Binding var originPlaylist: MusicPlaylist
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
            SharedAsset.addPurpleCircle.swiftUIImage
                .resizable()
                .scaledToFill()
                .frame(width: 31, height: 31)
                .onTapGesture {
                    addMusicToPlaylist()
                }
            
        })
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .onAppear(perform: {
            Task{
                await fetchSongInfo(songID: songID)
            }
        })
    }
    private func addMusicToPlaylist() {
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        if !originPlaylist.songIDs.contains(songID) {
            originPlaylist.songIDs.append(songID)
            
            let songData: [String: Any] = [
                "song_IDs" : originPlaylist.songIDs
            ]
            
            db.collection("User").document(userManager.uid).collection("Playlist").document(originPlaylist.id).setData(songData, merge: true) { error in
                if error == nil {
                    print("add song success")
                }else {
                    print("add song fail")
                }
            }
        }
    }
    
    private func fetchSongInfo(songID: String) async {
        let musicItemID = MusicItemID(rawValue: songID)
        let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
        
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
