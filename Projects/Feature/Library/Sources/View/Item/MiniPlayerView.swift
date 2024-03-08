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
    @State var isPresentPlayingView: Bool = false
    var body: some View {
  
                HStack(spacing: 0, content: {
                    //재생 화면 나올 터치 뷰
                    HStack(spacing: 0) {
                        AsyncImage(url: playerManager.currentSong?.artwork?.url(width: 100, height: 100), content: { image in
                            image
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5), style: .circular))
                        }, placeholder: {
                            SharedAsset.albumTopbar.swiftUIImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5), style: .circular))
                        })
                        .padding(.leading, 25)
                        
                        
                        if let playingSong = playerManager.currentSong {
                            //노래 제목 밑 아티스트 이름 - 세로정렬
                            VStack(spacing: 4, content: {
                                Text(playingSong.title)
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                      
                                
                                Text(playingSong.artistName)
                                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                                    .foregroundStyle(Color(red: 0.89, green: 0.89, blue: 0.89))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                
                            })
                            .padding(.leading, 11)
                        }else {
                            Text("재생중인 음악이 없습니다.")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                .foregroundStyle(Color.white)
                                .padding(.leading, 8)
                        }
                
                    }
                    .onTapGesture {
                        isPresentPlayingView = true
                    }
                    .fullScreenCover(isPresented: $isPresentPlayingView) {
                        NowPlayingView()
                    }
                  
                    Spacer()
                    
                    if playerManager.isPlaying{
                        SharedAsset.pause.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .padding(.trailing, 30)
                            .onTapGesture {
                                playerManager.pause()
                            }
                    }else {
                        SharedAsset.play.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .padding(.trailing, 30)
                            .onTapGesture {
                                playerManager.play()
                            }
                    }
    
                    
                    SharedAsset.musicForward.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 30)
                        .onTapGesture {
                            playerManager.skipToNext()
                        }
                        
                    
                    
                    SharedAsset.playerX.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 20)
                        .onTapGesture {
                            playerManager.isMiniPlayerPresent = false
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
                .padding(.horizontal, 8)
                .opacity(playerManager.isMiniPlayerPresent ? 1 : 0)

        }
        
    
}

//#Preview {
//    MiniPlayerView()
//}