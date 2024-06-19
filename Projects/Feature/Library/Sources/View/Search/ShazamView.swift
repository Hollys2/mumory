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
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var playerViewModel: PlayerViewModel

    @State var startsRecording: Bool = false
    @State var isPresentBottomSheet: Bool = false
    @State var isListen: Bool = false
    @State var song: Song?
    @State var shazamHistory: [SHMediaItem] = []
    @State var selectedShazamHistory: [SHMediaItem] = []
    @State var isEditing: Bool = false
    var type: ShazamViewType = .normal
    init(){}
    init(type: ShazamViewType) {
        self.type = type
    }
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
                                if let appleMusicID = shazamManager.shazamSong?.appleMusicID {
                                    SharedAsset.menu.swiftUIImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                        .padding(.trailing, 5)
                                        .padding(.top, 8)
                                        .onTapGesture {
                                            Task {
                                                print("tap menu")
                                                guard let recieveSong = await fetchSong(songID: appleMusicID) else {return}
                                                self.song = recieveSong
                                                UIView.setAnimationsEnabled(false)
                                                isPresentBottomSheet = true
                                            }
                                        }
                                }else {
                                    Color.black.opacity(0.7)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
                                    
                                    Text("애플 뮤직에\n등록되지 않은\n음악 입니다 :(")
                                        .multilineTextAlignment(.center)
                                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                                        .foregroundStyle(Color.white)
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
                                
                                if self.type == .normal {
                                    ShazamPlayButton(shazamItem: $shazamManager.shazamSong)
                                }else {
                                    ShazamAddButton(shazamItem: $shazamManager.shazamSong)
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
                    
                    if !shazamHistory.isEmpty {
                        if isEditing {
                            Text("완료")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                                .foregroundStyle(Color.white)
                                .onTapGesture {
                                    playerViewModel.setLibraryPlayerVisibility(isShown: !appCoordinator.isCreateMumorySheetShown)
                                    isEditing = false
                                }
                            
                        }else {
                            Text("편집")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                                .foregroundStyle(ColorSet.subGray)
                                .onTapGesture {
                                    selectedShazamHistory.removeAll()
                                    playerViewModel.setLibraryPlayerVisibility(isShown: false)
                                    isEditing = true
                                }
                        }
                    }
                    
                    
                }
                .frame(height: 41)
                .padding(.horizontal, 20)
                .padding(.top, 30)
                .padding(.bottom, 12)
                
                ScrollView(.horizontal) {
                    HStack(alignment: .center, spacing: 12) {
                        ForEach(shazamHistory, id: \.self) { item in
                            ShazamHistoryItem(shazamItem: item, selectedShazamHistory: $selectedShazamHistory, isEditing: $isEditing)
                                .onTapGesture {
                                    guard isEditing == false else {return}
                                    let shazamItem = item as SHMediaItem
                                    guard let appleMusicID = shazamItem.appleMusicID else {return}
                                    
                                    if self.type == .createMumory {
                                        guard let title = shazamItem.title else {return}
                                        guard let artist = shazamItem.artist else {return}
                                        let artwork = shazamItem.artworkURL
                                        mumoryDataViewModel.choosedMusicModel = SongModel(songId: appleMusicID, title: title, artist: artist, artworkUrl: artwork)
                                        appCoordinator.rootPath.removeLast(2)
                                    }else {
                                        Task {
                                            guard let song = await fetchSong(songID: appleMusicID) else {return}
                                            playerViewModel.playNewSong(song: song)
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .scrollIndicators(.hidden)
                
                
            })
            .padding(.top, appCoordinator.safeAreaInsetsTop)
            
            //하단 편집 바
            VStack(spacing: 0) {
                Divider05()
                HStack(alignment: .top){
                    Text(selectedShazamHistory.count == shazamHistory.count ? "전체선택 해제" : "전체선택")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                        .onTapGesture {
                            if selectedShazamHistory.count == shazamHistory.count {
                                selectedShazamHistory = []
                            }else {
                                selectedShazamHistory = shazamHistory
                            }
                        }
                    
                    Divider()
                        .frame(width: 1, height: 35)
                        .background(ColorSet.skeleton02)
                        .frame(maxHeight: .infinity, alignment: .top)
                    
                    
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
                    .padding(.top, 8)
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
                .padding(.top, 15)
                .frame(height: 88)
                .background(ColorSet.darkGray)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .offset(y: isEditing ? 0 : 90)
            .animation(.default, value: isEditing)



        }
        .ignoresSafeArea()
        .onChange(of: shazamManager.isRecording, perform: { newValue in
            if newValue {
                isListen.toggle()
            }
        })
        .fullScreenCover(isPresented: $isPresentBottomSheet) {
            BottomSheetWrapper(isPresent: $isPresentBottomSheet) {
                OptionalSongBottomSheetView(song: $song)
            }
            .background(TransparentBackground())
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

struct ShazamPlayButton: View {
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @Binding var item: SHMatchedMediaItem?
    init(shazamItem: Binding<SHMatchedMediaItem?>) {
        self._item = shazamItem
    }
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
        .background(item?.appleMusicID != nil  ? ColorSet.mainPurpleColor : ColorSet.darkGray)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .circular))
        .onTapGesture {
            Task {
                guard let appleMusicID = item?.appleMusicID else {return}
                guard let song = await fetchSong(songID: appleMusicID) else {return}
                playerViewModel.playNewSong(song: song)
            }
        }
        .disabled(item?.appleMusicID == nil)
    }
}

struct ShazamAddButton: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @Binding var item: SHMatchedMediaItem?
    init(shazamItem: Binding<SHMatchedMediaItem?>) {
        self._item = shazamItem
    }
    var body: some View {
        HStack(alignment: .center, spacing: 2, content: {
            SharedAsset.addBlackBig.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 19, height: 19)
            
            Text("음악추가")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundStyle(Color.black)
        })
        .padding(.horizontal, 15)
        .frame(height: 33)
        .background(item?.appleMusicID != nil ? ColorSet.mainPurpleColor : ColorSet.darkGray)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .circular))
        .onTapGesture {
            Task {
                guard let appleMusicID = item?.appleMusicID else {return}
                guard let title = item?.title else {return}
                guard let artist = item?.artist else {return}
                mumoryDataViewModel.choosedMusicModel = SongModel(songId: appleMusicID, title: title, artist: artist, artworkUrl: item?.artworkURL)
                appCoordinator.rootPath.removeLast(2)
            }
        }
        .disabled(item?.appleMusicID == nil)
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
            } placeholder: {
                Rectangle()
                    .fill(ColorSet.moreDeepGray)
            }
            .frame(width: 105, height: 105)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
            .overlay {
                if shazamItem.appleMusicID == nil {
                    Color.black.opacity(0.7)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
                    
                    Text("애플 뮤직에\n등록되지 않은\n음악 입니다 :(")
                        .multilineTextAlignment(.center)
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                        .foregroundStyle(Color.white)
                }
                
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
            .padding(.bottom, 10)



            
            Text(shazamItem.title ?? "")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                .foregroundStyle(shazamItem.appleMusicID == nil ? ColorSet.subGray : Color.white)
                .frame(width: 105, alignment: .leading)
                .lineLimit(1)
            
            Text(shazamItem.artist ?? "")
                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(shazamItem.appleMusicID == nil ? ColorSet.subGray : Color.white)
                .frame(width: 105, alignment: .leading)
                .lineLimit(1)

        }
    }
}


