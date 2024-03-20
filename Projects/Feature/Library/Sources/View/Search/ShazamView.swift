//
//  ShazamView.swift
//  Feature
//
//  Created by 제이콥 on 2/14/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Lottie
import MusicKit
import ShazamKit

struct ShazamView: View {
    @StateObject var shazamManager: ShazamViewModel = ShazamViewModel()
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State var startsRecording: Bool = false
    @State var isPresentBottomSheet: Bool = false
    @State var song: Song?
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            VStack(spacing: 0, content: {
                //상단바
                HStack{
                    SharedAsset.back.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onTapGesture {
                            appCoordinator.rootPath.removeLast()
                        }
                }
                .padding(.horizontal, 20)
                .frame(height: 63)
           
                
                    if shazamManager.isRecording {
                        VStack(spacing: 0, content: {
                            Text("음악을 듣고 있어요")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                                .foregroundStyle(ColorSet.mainPurpleColor)
                            
                            LottieView(animation: .named("shazam", bundle: .module))
                                .looping()
                        })
                        .transition(.opacity)
                        
                    }else {
                        if shazamManager.isShazamCompleted {
                            VStack(spacing: 0, content: {
                                
                                AsyncImage(url: shazamManager.shazamSong?.artworkURL) { image in
                                    image.resizable()
                                        .scaledToFill()
                                        .frame(width: 145, height: 145)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: 10, style: .circular)
                                        .frame(width: 145, height: 145)
                                        .foregroundStyle(.gray)
                                }
                                .overlay(content: {
                                    SharedAsset.menu.swiftUIImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                        .padding(.trailing, 5)
                                        .padding(.top, 8)
                                        .onTapGesture {
                                            guard let song = self.song else {
                                                return
                                            }
                                            UIView.setAnimationsEnabled(false)
                                            isPresentBottomSheet = true
                                        }
                                })
                                .padding(.top, 36)
                                
                                Text(shazamManager.shazamSong?.title ?? "NO TITLE")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                    .foregroundStyle(.white)
                                    .padding(.top, 16)
                                
                                Text(shazamManager.shazamSong?.artist ?? "NO ARTIST")
                                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                                    .foregroundStyle(ColorSet.charSubGray)
                                    .padding(.top, 5)
                                
                                HStack(spacing: 12, content: {
                                    AgainButton()
                                        .onTapGesture {
                                            shazamManager.startOrEndListening()
                                        }
                                    PlayButton()
                                })
                                .padding(.top, 25)
                            })
                            .transition(.opacity)
                            
                        }else {
                            VStack(spacing: 0) {
                                Text("음악을 찾지 못했어요")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                                    .foregroundStyle(ColorSet.mainPurpleColor)
                                
                                Text("주변의 소음이 없는 곳에서 다시 시도해주세요")
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                    .foregroundStyle(ColorSet.subGray)
                                    .padding(.top, 12)
                                
                                SharedAsset.shazamFailure.swiftUIImage
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 78)
                                    .padding(.leading, 20)
                                    .padding(.trailing, 25)
                                    .padding(.top, 5)
                                
                                AgainButton()
                                    .padding(.top, 5)
                                    .onTapGesture {
                                        shazamManager.startOrEndListening()
                                    }
                            }
                            .transition(.opacity)
                            
                            
                        }
                    }
                
                Divider05()
                    .padding(.top, 60)
                
            })
        }
        .onAppear(perform: {
            shazamManager.startOrEndListening()
        })
        .onChange(of: shazamManager.shazamSong, perform: { newValue in
            Task {
                self.song = await fetchSong(songID: shazamManager.shazamSong?.appleMusicID ?? "")
            }
        })
        .fullScreenCover(isPresented: $isPresentBottomSheet) {
            if let song = self.song {
                BottomSheetWrapper(isPresent: $isPresentBottomSheet) {
                    SongBottomSheetView(song: song)
                }
                .background(TransparentBackground())
            }
        }
    }
}


struct AgainButton: View {
    private let backgroundColor = Color(red: 0.24, green: 0.24, blue: 0.24)
    private let textColor = Color(red: 0.87, green: 0.87, blue: 0.87)
    var body: some View {
        HStack(alignment: .center, spacing: 4, content: {
            SharedAsset.reload.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 15, height: 15)
            
            Text("다시시도")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundStyle(textColor)
        })
        .padding(.horizontal, 15)
        .frame(height: 33)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .circular))
    }
}

struct PlayButton: View {

    var body: some View {
        HStack(alignment: .center, spacing: 6, content: {
            SharedAsset.playBlack.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 10, height: 10)
            
            Text("음악 재생")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundStyle(Color.black)
        })
        .padding(.horizontal, 15)
        .frame(height: 33)
        .background(ColorSet.mainPurpleColor)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .circular))
    }
}
