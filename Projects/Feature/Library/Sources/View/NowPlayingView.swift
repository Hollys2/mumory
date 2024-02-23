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
    @EnvironmentObject var userManager: UserViewModel
    @EnvironmentObject var playerManager: PlayerViewModel
    let artistTextColor = Color(white: 0.89)
    let durationTextColor = Color(white: 0.83)
    @State var sliderValue: CGFloat = 0.0
    @State var isPresentQueue: Bool = false
    
    @State var timer: Timer?
    
    init() {
        let thumbImage = UIImage(systemName: "circle.fill")?.withTintColor(.white).resized(to: CGSize(width: 11, height: 11))
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            //재생목록 보여줄 때와 기본 재생화면
            ColorSet.background.ignoresSafeArea()
            
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
                .frame(width: userManager.width)
                
                LinearGradient(colors: [Color.black, .clear], startPoint: .bottom, endPoint: .init(x: 0.5, y: 0.85)).ignoresSafeArea()
                
            }
            
            VStack(spacing: 0, content: {
                if isPresentQueue {
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
                            .onAppear {
                                proxy.scrollTo(playerManager.playingSong()?.id, anchor: .top)
                            }
                        }
                    }
        
                    
                }else {
                    VStack(spacing: 0) {
                        //일반 재생화면
                        HStack(alignment: .bottom, content: {
                            Button(action: {
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
                        AsyncImage(url: playerManager.playingSong()?.artwork?.url(width: 1000, height: 1000)) { image in
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
                                Text(playerManager.playingSong()?.artistName ?? " ")
                                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 20))
                                    .foregroundStyle(artistTextColor)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                
                                Text(playerManager.playingSong()?.title ?? " ")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 23))
                                    .foregroundStyle(Color.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(height: 89, alignment: .top)
                            })
                            
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
                        })
                        .padding(.horizontal, 33)
                        
                        
                    }
                    }
                    

                
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
                .padding(.bottom, 34)
                
                //아래 화살표 버튼
                SharedAsset.downArrow.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 33, height: 33)
                    .padding(.bottom, 10)
                    .opacity(isPresentQueue ? 0 : 1)
                
            })
            
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
    
    
}

//#Preview {
//    NowPlayingView()
//}
