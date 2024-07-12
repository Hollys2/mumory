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

struct SelectableShazamView: View {
    @StateObject var shazamManager: ShazamViewModel = ShazamViewModel()
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
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
                .frame(height: 65)
                
                
                if shazamManager.isRecording {
                    VStack(spacing: 0, content: {
                        Text(isListen ? "음악을 듣고 있어요" : "같은 음악을 찾는 중이에요")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                            .foregroundStyle(ColorSet.mainPurpleColor)
                            .animation(shazamAnimation.delay(2.0), value: isListen)
                            .frame(height: 45, alignment: .top)

                        
                        LottieView(animation: .named("shazam", bundle: .module))
                            .looping()
                            .frame(height: 78)
                     
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
                                ShazamSelectButton(enabled: shazamManager.shazamSong?.appleMusicID != nil)
                                    .onTapGesture {
                                        guard let appleMusicID = shazamManager.shazamSong?.appleMusicID else {return}
                                        guard let title = shazamManager.shazamSong?.title else {return}
                                        guard let artist = shazamManager.shazamSong?.artist else {return}
                                        guard let artworkUrl = shazamManager.shazamSong?.artworkURL else {return}
                                        mumoryDataViewModel.choosedMusicModel = SongModel(id: appleMusicID, title: title, artist: artist, artworkUrl: artworkUrl)
                                        appCoordinator.rootPath = NavigationPath()
                                    }
                            })
                            .padding(.top, 25)
                        })
                        .transition(.opacity)
                        
                    }else {
                        VStack(spacing: 0) {
                            VStack(alignment: .center, spacing: 6) {
                                Text("음악을 찾지 못했어요")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                                    .foregroundStyle(ColorSet.mainPurpleColor)
                                
                                Text("주변의 소음이 없는 곳에서 다시 시도해주세요")
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                    .foregroundStyle(ColorSet.subGray)
                            }
                            .frame(height: 45, alignment: .top)
          
                            SharedAsset.shazamFailure.swiftUIImage
                                .resizable()
                                .scaledToFit()
                                .frame(height: 78)
                       
                            
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
                    
                    if isEditing {
                        Text("완료")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                            .foregroundStyle(Color.white)
                            .onTapGesture {
                                isEditing = false
                            }
                        
                    }else {
                        HStack(spacing: 6, content: {
                            SharedAsset.editMumoryDetailMenu.swiftUIImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                            
                            Text("편집")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                                .foregroundStyle(ColorSet.subGray)
                        })
                        .onTapGesture {
                            selectedShazamHistory.removeAll()
                            isEditing = true
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
            .padding(.top, appCoordinator.safeAreaInsetsTop)
            
            //하단 편집 바
            HStack(alignment: .center){
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
                
                Divider()
                    .ignoresSafeArea()
                    .frame(width: 1, height: 32)
                    .background(ColorSet.skeleton02)
                
                
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
                .onTapGesture {
                    if !selectedShazamHistory.isEmpty {
                        shazamHistory.forEach { item in
                            if selectedShazamHistory.contains(item) {
                                shazamHistory.removeAll(where: {$0 == item})
                            }
                        }
                        let result = shazamHistory.map({$0.shazamID ?? ""})
                        UserDefaults.standard.setValue(result, forKey: "shazamHistory")
                        isEditing = false
                    }
                }
        
            }
            .frame(height: 88)
            .background(ColorSet.darkGray)
            .offset(y: isEditing ? 0 : 90)
            .animation(.default, value: isEditing)
            .frame(maxHeight: .infinity, alignment: .bottom)

        }
        .ignoresSafeArea()
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
        Animation.linear(duration: 2.0)
            .repeatForever(autoreverses: true)
        
    }
    
    private func fetchShazamSearchHistory() {
        let userdefaults = UserDefaults.standard
        guard let shazamHistory = userdefaults.stringArray(forKey: "shazamHistory") else {return}
        shazamHistory.forEach { shazamID in
            SHMediaItem.fetch(shazamID: shazamID) { item, error in
                guard let item = item else {return}
                withAnimation {
                    self.shazamHistory.append(item)
                }
            }
        }
        print("success")

    }
}

struct ShazamSelectButton: View {

    var enabled: Bool = true
    init(enabled: Bool) {
        self.enabled = enabled
    }
    var body: some View {
        HStack(alignment: .center, spacing: 6, content: {
            SharedAsset.addBlack.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 19, height: 19)
            
            Text("음악 추가")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundStyle(Color.black)
        })
        .padding(.horizontal, 15)
        .frame(height: 33)
        .background(enabled ? ColorSet.mainPurpleColor : ColorSet.darkGray)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .circular))

    }
}

