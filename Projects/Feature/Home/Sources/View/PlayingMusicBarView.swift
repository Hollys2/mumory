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
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
//    @State var isPresentPlayingView: Bool = false
    @State var isPresentMyPage: Bool = false
    
    let artistTextColor = Color(white: 0.89)
    public init() {}
    
    public var body: some View {
        
        HStack(spacing: 0, content: {
            
            //재생페이지로 넘어가는 터치 영역
            HStack(spacing: 0, content: {
                AsyncImage(url: playerViewModel.playingSong()?.artwork?.url(width: 100, height: 100)) { image in
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

                
                if let playingSong = playerViewModel.currentSong {
                    VStack(spacing: 2) {
                        Text(playingSong.title)
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color.white)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Text(playingSong.artistName)
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(ColorSet.charSubGray)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }else {
                    Text("재생 중인 음악이 없습니다.")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.trailing, 21)
                }
                
            })
            .onTapGesture {
                playerViewModel.isPresentNowPlayingView = true
//                appCoordinator.setBottomAnimationPage(page: .play)
            }
            
            //재생버튼. 재생 여부에 따라 다르게 보여야함
            Circle()
                .trim(from: 0, to: playerViewModel.playbackRate()) //재생률에 따라 변화해야함
                .stroke(ColorSet.mainPurpleColor, lineWidth: 2)
                .frame(width: 26, height: 26)
                .rotationEffect(.degrees(-90))
                .overlay {
                    if playerViewModel.isPlaying() {
                        SharedAsset.pauseButtonTopbar.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .onTapGesture {
                                playerViewModel.pause()
                            }
                    }else {
                        SharedAsset.playButtonTopbar.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .onTapGesture {
                                playerViewModel.play()
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
            
            //사용자 프로필 이미지
            AsyncImage(url: currentUserData.user.profileImageURL) { image in
                image
                    .resizable()
                 
            } placeholder: {
                currentUserData.user.defaultProfileImage
                    .resizable()
            }
            .scaledToFill()
            .frame(width: 31, height: 31)
            .clipShape(Circle())
            .padding(.trailing, 14)
            .onTapGesture {
                appCoordinator.setBottomAnimationPage(page: .myPage)
            }
            .onAppear {
                print("currentUserData.user: \(currentUserData.user)")
            }
     
                        
        })
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Color.black.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
        .padding(.horizontal, 15)
        .fullScreenCover(isPresented: $playerViewModel.isPresentNowPlayingView) {
            NowPlayingView()
        }

    }

}

//struct PlayingMusicBarVIew_Previews: PreviewProvider {
//    static var previews: some View {
//        PlayingMusicBarVIew()
//    }
//}
