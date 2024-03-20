//
//  PlaySongView.swift
//  Feature
//
//  Created by 제이콥 on 2/19/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct NowPlayingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var playerManager: PlayerViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    @State var isPresentQueue: Bool = false
    
 
    init() {
        let thumbImage = UIImage(systemName: "circle.fill")?.withTintColor(.white).resized(to: CGSize(width: 11, height: 11))
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            //재생목록 보여줄 때와 기본 재생화면
            ColorSet.background.ignoresSafeArea()
            
            //재생페이지에서 보여줄 배경 사진(앨범 커버)
            if !isPresentQueue{
                AsyncImage(url: playerManager.playingSong()?.artwork?.url(width: 1000, height: 1000)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .blur(radius: 20)
                        .overlay {
                            ColorSet.moreDeepGray.opacity(0.6).ignoresSafeArea()
                            
                        }
                } placeholder: {
                    Rectangle()
                        .foregroundStyle(Color(white: 0.41))
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                }
                .frame(width: getUIScreenBounds().width)
                
                LinearGradient(colors: [Color.black, .clear], startPoint: .bottom, endPoint: .init(x: 0.5, y: 0.85)).ignoresSafeArea()
                
            }
            
            
            VStack(spacing: 0, content: {
                if isPresentQueue {
                    QueueView()
                }else {
                    PlayingView()
                }
                PlayControlView(isPresentQueue: $isPresentQueue)
            })
            
            SnackBarView()

            
        }
    }
}

struct PlayControlView: View {
    @EnvironmentObject var playerManager: PlayerViewModel
    @Binding var isPresentQueue: Bool
    
    let durationTextColor = Color(white: 0.83)
    var body: some View {
        ZStack(alignment: .bottom, content: {
            VStack(spacing: 0, content: {
          
                    
                //재생 제어 버튼들
                HStack(spacing: 34, content: {
                    //플레이리스트 버튼
                    Button {
                        withAnimation(.easeOut) {
                            self.isPresentQueue.toggle()
                        }
                    } label: {
                        if isPresentQueue {
                            SharedAsset.playlistPurple.swiftUIImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .frame(maxWidth: .infinity)
                                .padding(.trailing, 5)
                        }else {
                            SharedAsset.playlist.swiftUIImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .frame(maxWidth: .infinity)
                                .padding(.trailing, 5)
                        }
                    }
                    
                    //뒤로가기 버튼
                    
                    SharedAsset.playBack.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            playerManager.skipToPrevious()
                        }
                    
                    
                    
                    
                    //재생, 멈춤 버튼
                    if playerManager.isPlaying {
                        Button(action: {
                            playerManager.pause()
                        }, label: {
                            SharedAsset.pauseBig.swiftUIImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 56, height: 56)
                                .frame(maxWidth: .infinity)
                        })
                    }else {
                        Button(action: {
                            playerManager.play()
                        }, label: {
                            SharedAsset.playBig.swiftUIImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 56, height: 56)
                                .frame(maxWidth: .infinity)
                        })
                    }
                    
                    //앞으로 가기 버튼
                    SharedAsset.playForward.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            playerManager.skipToNext()
                        }
                    
                    
                    
                    //북마크 버튼
                    SharedAsset.bookmarkLight.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .frame(maxWidth: .infinity)
                    
                })
                .padding(.horizontal, 33)
                .padding(.bottom, 32)
                
                //아래 화살표 버튼
                SharedAsset.downArrow.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 33, height: 33)
                    .padding(.bottom, 10)
                    .opacity(isPresentQueue ? 0 : 1)
            })
        })
        
    }
}

struct PlayingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var playerManager: PlayerViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State var animationDuration: Double = 5.0
    @State var titleWidth: CGFloat = 0
    @State private var startAnimation : Bool = false

    
    let delay: Double = 1.0
    let artistTextColor = Color(white: 0.89)
    let durationTextColor = Color(white: 0.83)
    
    var body: some View {
        VStack(spacing: 0) {
            //일반 재생화면
            
            //상단바
            HStack(alignment: .bottom, content: {
                Button(action: {
//                    appCoordinator.bottomAnimationViewStatus = .remove
                    dismiss()
                }, label: {
                    SharedAsset.downArrow.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                })
                
                Spacer()
                SharedAsset.menuWhite.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                
            })
            .padding(.horizontal, 20)
            .padding(.top, 19)
            
            //선명한 앨범 커버(정방형)
            AsyncImage(url: playerManager.currentSong?.artwork?.url(width: 1000, height: 1000)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                SharedAsset.albumCoverPlaceholder.swiftUIImage
                    .resizable()
                    .scaledToFit()
            }
            .frame(width: 390 - 52, height: 390 - 52)
            .padding(.top, 26)
            .padding(.bottom, 35)
            
            //아티스트 이름 및 노래 이름, 추가버튼
            HStack(alignment: .top, spacing: 0, content: {
                VStack(spacing: 6, content: {
                    Text(playerManager.currentSong?.title ?? " ")
                        .fixedSize()
                        .frame(maxWidth: 280, alignment: startAnimation ? .leading : .trailing)
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 23))
                        .foregroundStyle(Color.white)
                        .clipped()
                        .onAppear {
                            startAnimation = true
                            guard let title = playerManager.currentSong?.title else {
                                return
                            }
                            self.animationDuration = Double(title.count) * 0.1
                            self.titleWidth = getTextWidth(term: title)
//                                        self.titleWidth = textWidth > 280 ? 280 : textWidth
                        }
                        .onDisappear {self.startAnimation = false}
                        .animation( self.titleWidth < 280 ? nil : Animation.linear(duration: animationDuration).delay(delay).repeatForever(autoreverses: true), value: startAnimation)
                        .onChange(of: playerManager.currentSong) { newValue in
                            guard let title = newValue?.title else {
                                return
                            }
                            self.animationDuration = Double(title.count) * 0.1
                            self.titleWidth = getTextWidth(term: title)
//                                        let textWidth = getTextWidth(term: title)
//                                        print("text width: \(textWidth)")
//                                        self.titleWidth = textWidth > 280 ? 280 : textWidth
                            
                        }
                    

                    
                    Text(playerManager.currentSong?.artistName ?? " ")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 20))
                        .foregroundStyle(artistTextColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                   
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                
                SharedAsset.addPurpleCircleFilled.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                
            })
            .padding(.leading, 33)
            .padding(.trailing, 26)
            
            Spacer()
            
            //슬라이드 바 및 재생시간
            VStack(spacing: 0, content: {
                Slider(value: $playerManager.playingTime, in: 0...(playerManager.playingSong()?.duration ?? 0.0), onEditingChanged: { isEditing in
                    if isEditing {
                        playerManager.startEditingSlider()
                    }else {
                        playerManager.updatePlaybackTime(to: playerManager.playingTime )
                    }
                })
                .tint(Color.white)
                
                
                HStack(content: {
                    //재생시간
                    Text(getMinuteSecondString(time: playerManager.playingTime))
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                        .foregroundStyle(durationTextColor)
                    
                    Spacer()
                    
                    //남은시간
                    Text("-\(getMinuteSecondString(time: (playerManager.playingSong()?.duration ?? 0) - playerManager.playingTime))")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                        .foregroundStyle(durationTextColor)
                })
                .offset(y: -5)
            })
            .padding(.horizontal, 33)
            .padding(.bottom, 25)
            
            
        }
    }

    
}

struct QueueView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var playerManager: PlayerViewModel

    let playlistTitleBackgroundColor = Color(white: 0.12)
    
    var body: some View {
        VStack(spacing: 0) {
            //플레이리스트 보여줄때
            Button {
                dismiss()
            } label: {
                SharedAsset.xWhite.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 20)
                    .padding(.vertical, 15)
            }
            
            HStack(content: {
                Text(playerManager.queueTitle.isEmpty ? "재생중" : playerManager.queueTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(playerManager.queueTitle.isEmpty ? "" : "목록 재생중 1/\(playerManager.queue.count)")
                    .fixedSize()
                    .padding(.leading, 6)
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                    .foregroundStyle(ColorSet.subGray)
                
            })
            .padding(.horizontal, 15)
            .frame(height: 45)
            .background(playlistTitleBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
            .padding(.horizontal, 15)
            
            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        ForEach(playerManager.queue, id: \.id){ song in
                            QueueItem(song: song, scrollProxy: proxy)
                                .id(song.id)
                                .onTapGesture {
                                    withAnimation {
                                        proxy.scrollTo(song.id, anchor: .top)
                                    }
                                    playerManager.changeCurrentEntry(song: song)
                                }
                        }
                    }
                    
                }
                .overlay(content: {
                    VStack(content: {
                        Spacer()
                        LinearGradient(colors: [ColorSet.background, Color.clear], startPoint: .bottom, endPoint: .init(x: 0.5, y: 0.2))
                            .frame(maxWidth: .infinity)
                            .frame(height: 30)
                    })
                  
                })
                .onAppear {
                    proxy.scrollTo(playerManager.playingSong()?.id, anchor: .top)
                }
            }
        }
    }
}


private func getMinuteSecondString(time: TimeInterval?) -> String {
    guard let time = time else {
        print("error")
        return "0:00"
    }
    let tvm = timeval(tv_sec: Int(time), tv_usec: 0)
    return Duration(tvm).formatted(.time(pattern: .minuteSecond))
}

private func getTextWidth(term: String) -> CGFloat {
    let fontAttribute = [NSAttributedString.Key.font: SharedFontFamily.Pretendard.semiBold.font(size: 23)]
    let width = (term as NSString).size(withAttributes: fontAttribute).width
    return width
}
