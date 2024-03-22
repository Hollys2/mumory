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
    @State var isListen: Bool = false
    @State var song: Song?
    @State var shazamHistory: [SHMediaItem] = []
    @State var selectedShazamHistory: [SHMediaItem] = []
    @State var isEditing: Bool = false
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
                        Text(isListen ? "음악을 듣고 있어요" : "같은 음악을 찾는 중이에요")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                            .foregroundStyle(ColorSet.mainPurpleColor)
                            .animation(shazamAnimation, value: isListen)
                        
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
                                        guard let appleMusicID = shazamManager.shazamSong?.appleMusicID else {
                                            print("no apple music")
                                            return
//                                            UIView.setAnimationsEnabled(false)
//                                            isPresentBottomSheet = true
                                        }
                                        print("yes apple music")
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
                
                HStack {
                    Text("최근에 찾은 음악")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundStyle(Color.white)
                    
                    Spacer()
                    
                    EditButton()
                        .onTapGesture {
                            withAnimation {
                                isEditing.toggle()
                            }
                        }
                }
                .frame(height: 41)
                .padding(.horizontal, 20)
                .padding(.top, 40)
                .padding(.bottom, 20)
                
                ScrollView(.horizontal) {
                    HStack(alignment: .center, spacing: 12) {
                        ForEach(shazamHistory, id: \.self) { item in
                            ShazamHistoryItem(shazamItem: item, selectedShazamHistory: $selectedShazamHistory, isEditing: $isEditing)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .scrollIndicators(.hidden)
                
                
            })
            
            //하단 편집 바
            VStack(alignment: .center, spacing: 0) {
                Divider03()
                
                HStack{
                    Text(selectedShazamHistory.count == shazamHistory.count ? "전체선택 해제" : "전체선택")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onTapGesture {
                            if selectedShazamHistory.count == shazamHistory.count {
                                selectedShazamHistory = []
                            }else {
                                selectedShazamHistory = shazamHistory
                            }
                        }
                    
                    HorizontalDivider10()
                        .frame(height: 32)
                    
                    HStack(alignment: .center, spacing: 10) {
                        Text("삭제")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundStyle(selectedShazamHistory.isEmpty ? ColorSet.subGray : ColorSet.accentRed)
                        
                        if !selectedShazamHistory.isEmpty {
                            Text("\(selectedShazamHistory.count)")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                                .foregroundStyle(Color.black)
                                .frame(height: 19)
                                .padding(.horizontal, 7)
                                .background(ColorSet.accentRed)
                                .clipShape(RoundedRectangle(cornerRadius: 40, style: .circular))
                        }
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .ignoresSafeArea()
            .frame(height: isEditing ? 88 : 0)
            .background(ColorSet.darkGray)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .opacity(isEditing ? 1 : 0)
        }
        .onChange(of: shazamManager.isRecording, perform: { newValue in
            if newValue {
                isListen.toggle()
            }
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
        .onAppear(perform: {
            shazamManager.startOrEndListening()
            AnalyticsManager.shared.setScreenLog(screenTitle: "shazamView")
            fetchShazamSearchHistory()
        })
    }
    
    private var shazamAnimation: Animation {
        Animation.linear(duration: 1.0)
                .repeatForever(autoreverses: true)
                .delay(2.0)
    }
    
    private func fetchShazamSearchHistory() {
        let userdefaults = UserDefaults.standard
        guard let shazamHistory = userdefaults.stringArray(forKey: "shazamHistory") else {return}
        shazamHistory.forEach { shazamID in
            print("\(shazamID)   1")
            SHMediaItem.fetch(shazamID: shazamID) { item, error in
                guard let item = item else {return}
                print("\(shazamID)   2")
                withAnimation {
                    self.shazamHistory.append(item)
                }
            }
        }
        print("success")

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

struct ShazamHistoryItem: View {
    @Binding var selectedShazamHistory: [SHMediaItem]
    @Binding var isEditing: Bool
    let shazamItem: SHMediaItem
    init(shazamItem: SHMediaItem, selectedShazamHistory: Binding<[SHMediaItem]>, isEditing: Binding<Bool>) {
        self.shazamItem = shazamItem
        self._selectedShazamHistory = selectedShazamHistory
        self._isEditing = isEditing
    }
    
    var body: some View {
        VStack(spacing: 1) {
            AsyncImage(url: shazamItem.artworkURL) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 105, height: 105)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))

            } placeholder: {
                Rectangle()
                    .fill(ColorSet.moreDeepGray)
                    .frame(width: 105, height: 105)
            }
            .padding(.bottom, 10)
            .overlay {
                if isEditing {
                    SharedAsset.checkTranslucent.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .opacity(selectedShazamHistory.contains(self.shazamItem) ? 0 : 1)
                        .padding(6)
                        .onTapGesture {
                            selectedShazamHistory.append(shazamItem)
                        }
                    
                    SharedAsset.checkTranslucentFilled.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .opacity(selectedShazamHistory.contains(self.shazamItem) ? 1 : 0)
                        .padding(6)
                        .onTapGesture {
                            selectedShazamHistory.removeAll(where: {$0 == shazamItem})
                        }

                }

            }
            
            Text(shazamItem.title ?? "")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                .foregroundStyle(Color.white)
                .frame(width: 105, alignment: .leading)
                .lineLimit(1)
            
            Text(shazamItem.artist ?? "")
                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(ColorSet.charSubGray)
                .frame(width: 105, alignment: .leading)
                .lineLimit(1)

        }
    }
}
