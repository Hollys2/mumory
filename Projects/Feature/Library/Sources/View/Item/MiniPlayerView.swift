//
//  MiniPlayerView.swift
//  Feature
//
//  Created by 제이콥 on 11/27/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct MiniPlayerView: View {
    @EnvironmentObject var playerManager: PlayerViewModel
    private var player = ApplicationMusicPlayer.shared
    
    var body: some View {
  
                HStack(spacing: 0, content: {
                    AsyncImage(url: playerManager.song?.artwork?.url(width: 100, height: 100), content: { image in
                        image
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5), style: .circular))
                    }, placeholder: {
                        RoundedRectangle(cornerSize: CGSize(width: 5, height: 5), style: .circular)
                            .fill(.gray)
                            .frame(width: 40, height: 40)
                    })
                    .padding(.leading, 25)
                    
                    
                    
                    
                    VStack(spacing: 4, content: {
                        Text(playerManager.song?.title ?? "NO TITLE")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .onChange(of: playerManager.song, perform: { value in
                                guard let music = playerManager.song else {return}
                                player.queue = [music]
                                Task{
                                    do {
                                        try await player.play()
                                        playerManager.isPlaying = true
                                    } catch {
                                        print("Failed to prepare to play with error: \(error).")
                                    }
                                }
                            })
                        
                        Text(playerManager.song?.artistName ?? "NO ARTIST")
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                            .foregroundStyle(Color(red: 0.89, green: 0.89, blue: 0.89))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                    })
                    .padding(.leading, 8)
                    Spacer()
                    
                    if playerManager.isPlaying{
                        SharedAsset.pause.swiftUIImage
                            .frame(width: 20, height: 20)
                            .padding(.trailing, 30)
                            .onTapGesture {
                                player.pause()
                            }
                    }else {
                        SharedAsset.play.swiftUIImage
                            .frame(width: 20, height: 20)
                            .padding(.trailing, 30)
                            .onTapGesture {
                                Task{
                                    do {
                                        try await player.play()
                                    } catch {
                                        print("Failed to prepare to play with error: \(error).")
                                    }
                                }
                            }
                    }
    
                    
                    SharedAsset.musicForward.swiftUIImage
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 30)
                    
                    
                    SharedAsset.playerX.swiftUIImage
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 20)
                        .onTapGesture {
                            playerManager.isPresent = false
                        }
                    
                    
                    
                })
                .frame(maxWidth: .infinity)
                .padding(.top, 15)
                .padding(.bottom, 15)
                .background(ColorSet.background)
                .clipShape(RoundedRectangle(cornerRadius: 35, style: .circular))
                .overlay( /// apply a rounded border
                    RoundedRectangle(cornerRadius: 35, style: .circular)
                        .stroke(Color(red: 0.65, green: 0.65, blue: 0.65), lineWidth: 0.5)
                )
                .padding(.bottom, 10)
                .padding(.leading, 8)
                .padding(.trailing, 8)
                .opacity(playerManager.isPresent ? 1 : 0)

        }
        
    
}

//#Preview {
//    MiniPlayerView()
//}
