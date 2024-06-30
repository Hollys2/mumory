//
//  PreviewMiniPlayer.swift
//  Feature
//
//  Created by 제이콥 on 3/23/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct PreviewMiniPlayer: View {
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    var body: some View {
        HStack(spacing: 0, content: {
            AsyncImage(url: playerViewModel.currentSong?.artwork?.url(width: 300, height: 300)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 37, height: 37)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
            } placeholder: {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 37, height: 37)
            }
            
            VStack(spacing: 1, content: {
                Text(playerViewModel.currentSong?.title ?? "")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                
                Text(playerViewModel.currentSong?.artistName ?? "")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(Color(white: 0.89))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)

            })
            .padding(.leading, 12)
            .padding(.trailing, 25)
            
            //재생버튼. 재생 여부에 따라 다르게 보여야함
            Circle()
                .trim(from: 0, to: playerViewModel.playbackRate()) //재생률에 따라 변화해야함
                .stroke(ColorSet.mainPurpleColor, lineWidth: 2)
                .frame(width: 35, height: 35)
                .rotationEffect(.degrees(-90))
                .overlay {
                    if playerViewModel.isPlaying {
                        SharedAsset.previewPauseSolid.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 33, height: 33)
                            .transition(.identity)
                            .onTapGesture {
                                playerViewModel.pause()
                            }
                        
                    }else {
                        SharedAsset.previewPlaySolid.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 33, height: 33)
                            .transition(.identity)
                            .onTapGesture {
                                playerViewModel.play()
                            }
                    }
                }
                .padding(.trailing, 29)

            
            Text("추가")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                .foregroundStyle(Color.black)
                .padding(.horizontal, 10)
                .frame(height: 24)
                .background(ColorSet.mainPurpleColor)
                .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .circular))
                .padding(.trailing, 30)
                .onTapGesture {
                    guard let song = playerViewModel.currentSong else {return}
                    mumoryDataViewModel.choosedMusicModel = MusicModel(songID: song.id, title: song.title, artist: song.artistName, artworkUrl: song.artwork?.url(width: 300, height: 300))
                    appCoordinator.rootPath = NavigationPath()
                    playerViewModel.pause()
                    playerViewModel.isShownPreview = false
                }


        })
        .padding(.leading, 23)
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .background(ColorSet.background.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 35, style: .circular))
        .overlay(content: {
            RoundedRectangle(cornerRadius: 35, style: .circular).stroke(ColorSet.skeleton02, lineWidth: 0.3)
        })
        .shadow(color: Color.black.opacity(0.2), radius: 10, y: 10)
        .padding(.horizontal, 8)
        
        
    }
}

