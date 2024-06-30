//
//  MumoryDetailSameLocationMusicView.swift
//  Feature
//
//  Created by 다솔 on 2023/12/28.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Shared
import MusicKit

struct MumoryDetailSameLocationMusicView: View {
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    @State var isPresentBottomSheet: Bool = false
    @State var song: Song?
    let mumory: Mumory
    
    var body: some View {
        ZStack {
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: getUIScreenBounds().width - 40, height: 70)
                .overlay(
                    Rectangle()
                        .fill(Color(red: 0.651, green: 0.651, blue: 0.651, opacity: 0.502))
                        .frame(height: 0.5)
                    , alignment: .bottom
                )
            
            HStack(spacing: 0) {
                
                AsyncImage(url: self.mumory.musicModel.artworkUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                    default:
                        Color(red: 0.184, green: 0.184, blue: 0.184)
                    }
                }
                
                .frame(width: 40, height: 40)
                .cornerRadius(6)
                
                Spacer().frame(width: 13)
                
                VStack(spacing: 0) {
                    
                    Text("\(mumory.musicModel.title)")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .frame(width: 169, alignment: .leading)
                    
                    Text("\(mumory.musicModel.artist)")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                        .lineLimit(1)
                        .lineLimit(1)
                        .frame(width: 169, alignment: .leading)
                }
                
                Spacer()
                
                if playerViewModel.favoriteSongIds.contains(mumory.musicModel.songID.rawValue) {
                    SharedAsset.bookmarkOnMumoryDatail.swiftUIImage
                        .resizable()
                        .frame(width: 20, height: 20)
                        .onTapGesture {
                            playerViewModel.removeFromFavorite(uid: currentUserViewModel.user.uId, songId: mumory.musicModel.songID.rawValue)
                            snackBarViewModel.setSnackBar(type: .favorite, status: .delete)
                        }
                } else {
                    SharedAsset.bookmarkOffMumoryDatail.swiftUIImage
                        .resizable()
                        .frame(width: 20, height: 20)
                        .onTapGesture {
                            self.generateHapticFeedback(style: .medium)
                            playerViewModel.addToFavorite(uid: currentUserViewModel.user.uId, songId: mumory.musicModel.songID.rawValue)
                            snackBarViewModel.setSnackBar(type: .favorite, status: .success)
                        }
                }
          
                
                Spacer().frame(width: 29)
                
                Button(action: {
                    UIView.setAnimationsEnabled(false)
                    isPresentBottomSheet = true
                }, label: {
                    SharedAsset.musicMenuMumoryDatail.swiftUIImage
                        .resizable()
                        .frame(width: 20, height: 20)
                })
            } // HStack
        } // ZStack
        .background(ColorSet.background)
        .onAppear(perform: {
            Task {
                song = await fetchSong(songID: mumory.musicModel.songID.rawValue)
            }
        })
        .fullScreenCover(isPresented: $isPresentBottomSheet, content: {
            BottomSheetWrapper(isPresent: $isPresentBottomSheet) {
                OptionalSongBottomSheetView(song: $song, types: [.withoutBookmark])
            }
            .background(TransparentBackground())
        })
        .onTapGesture {
            guard let playSong = self.song else {return}
            playerViewModel.playNewSongShowingPlayingView(song: playSong)
            playerViewModel.userWantsShown = true
            playerViewModel.isShownMiniPlayer = true
        }
    }
}
