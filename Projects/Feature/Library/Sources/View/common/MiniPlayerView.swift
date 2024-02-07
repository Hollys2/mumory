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
    @State var isDisappear = false
    @State var isPlaying = false
    
    var body: some View {
        ZStack{
            VStack{
                Spacer()
                HStack(spacing: 0, content: {
                    AsyncImage(url: playerManager.song?.artwork?.url(width: 100, height: 100), content: { image in
                        image
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)))
                    }, placeholder: {
                        //
                    })
                    .padding(.leading, 25)
                    
                    //                RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                    //                    .fill(.gray)
                    //                    .frame(width: 40, height: 40)
                    
                    
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
                                        isPlaying = true
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
                    
                    ZStack{
                        SharedAsset.pause.swiftUIImage
                            .disabled(!isPlaying)
                            .opacity(isPlaying ? 1 : 0)
                        
                        SharedAsset.play.swiftUIImage
                            .disabled(isPlaying)
                            .opacity(isPlaying ? 0 : 1)
                    }
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 30)
                    .onTapGesture {
                        isPlaying = !isPlaying
                        
                        if isPlaying {
                            Task{
                                do {
                                    try await player.play()
                                } catch {
                                    print("Failed to prepare to play with error: \(error).")
                                }
                            }
                        }else {
                            player.pause()
                        }
                    }
                    
                    SharedAsset.musicForward.swiftUIImage
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 30)
                    
                    
                    SharedAsset.playerX.swiftUIImage
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 20)
                    
                    
                    
                })
                .padding(.leading, 8)
                .padding(.trailing, 8)
                .frame(width: 370, height: 70)
                .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 35, height: 35)))
                .overlay( /// apply a rounded border
                    RoundedRectangle(cornerRadius: 35, style: .circular)
                        .stroke(Color(red: 0.65, green: 0.65, blue: 0.65), lineWidth: 0.3)
                )
                .padding(.bottom, 10)
                
                
                
            }
        }
        
    }
}

//#Preview {
//    MiniPlayerView()
//}
