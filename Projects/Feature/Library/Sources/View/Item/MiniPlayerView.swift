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
                        AsyncImage(url: playerManager.playingSong()?.artwork?.url(width: 100, height: 100), content: { image in
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
                        
                        
                        
                        //노래 제목 밑 아티스트 이름 - 세로정렬
                        VStack(spacing: 4, content: {
                            Text(playerManager.playingSong()?.title ?? "NO TITLE")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)
                                .truncationMode(.tail)
                  
                            
                            Text(playerManager.playingSong()?.artistName ?? "NO ARTIST")
                                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                                .foregroundStyle(Color(red: 0.89, green: 0.89, blue: 0.89))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                        })
                        .padding(.leading, 8)
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
                            .frame(width: 20, height: 20)
                            .padding(.trailing, 30)
                            .onTapGesture {
                                playerManager.pause()
                            }
                    }else {
                        SharedAsset.play.swiftUIImage
                            .frame(width: 20, height: 20)
                            .padding(.trailing, 30)
                            .onTapGesture {
                                playerManager.play()
                            }
                    }
    
                    
                    SharedAsset.musicForward.swiftUIImage
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 30)
                    
                    
                    SharedAsset.playerX.swiftUIImage
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
                .padding(.leading, 8)
                .padding(.trailing, 8)
                .opacity(playerManager.isMiniPlayerPresent ? 1 : 0)

        }
        
    
}

//#Preview {
//    MiniPlayerView()
//}
