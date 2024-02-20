//
//  PlayingMusicBarView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/17.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Shared

public struct PlayingMusicBarView: View {
    @EnvironmentObject var playerManager: PlayerViewModel
    @State var isProfileTapped = false
    @State var isPresentPlayingView: Bool = false
    
    @State var isSliding: Bool = false
    let artistTextColor = Color(white: 0.89)
    public init() {}
    
    public var body: some View {
        
        HStack(spacing: 0, content: {
            
            //재생페이지로 넘어가는 터치 영역
            HStack(spacing: 0, content: {
                AsyncImage(url: playerManager.playingSong?.artwork?.url(width: 100, height: 100)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 31, height: 31)
                    
                } placeholder: {
                    SharedAsset.albumTopbar.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 31, height: 31)
                }
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
                .padding(.leading, 15)
                .padding(.trailing, 13)

                
                if playerManager.playingSong == nil {
                    Text("재생 중인 음악이 없습니다.")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 11))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.trailing, 21)
                }else {
                    ScrollView(.horizontal) {
                        HStack(spacing: 0){
                            Text(playerManager.playingSong?.artistName ?? "")
                                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                                .foregroundColor(artistTextColor)
                                .lineLimit(1)
                            
                            Text("  •  \(playerManager.playingSong?.title ?? "")" )
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                .foregroundColor(Color.white)
                                .lineLimit(1)
                        }
                    }
                    .scrollIndicators(.hidden)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 21)

                }
            })
            .onTapGesture {
                UIView.setAnimationsEnabled(true)
                isPresentPlayingView = true
            }
            .fullScreenCover(isPresented: $isPresentPlayingView, content: {
                NowPlayingView()
            })
            
            
            //재생버튼. 재생 여부에 따라 다르게 보여야함
            Circle()
                .trim(from: 0, to: playerManager.playingInfo.playbackRate) //재생률에 따라 변화해야함
                .stroke(ColorSet.mainPurpleColor, lineWidth: 2)
                .frame(width: 26, height: 26)
                .rotationEffect(.degrees(-90))
                .overlay {
                    if playerManager.isPlaying {
                        SharedAsset.pauseButtonTopbar.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .onTapGesture {
                                playerManager.pause()
                            }
                    }else {
                        SharedAsset.playButtonTopbar.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .onTapGesture {
                                playerManager.play()
                            }
                    }
                }
            
            //세로 구분선 - 좌우 여백 둘 다 구분선에 적용시킴
            Rectangle()
              .foregroundColor(.clear)
              .frame(width: 0.5, height: 35)
              .background(Color(white: 0.52))
              .padding(.trailing, 17)
              .padding(.leading, 20)
            
            //사용자 프로필 이미지 들어갈 곳
            SharedAsset.profileTopbar.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 31, height: 31)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(Color.white, lineWidth: 0.5)
                }
                .padding(.trailing, 11)
            
            
        })
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Color.black.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
        .padding(.horizontal, 15)

    }
}

//struct PlayingMusicBarVIew_Previews: PreviewProvider {
//    static var previews: some View {
//        PlayingMusicBarVIew()
//    }
//}
