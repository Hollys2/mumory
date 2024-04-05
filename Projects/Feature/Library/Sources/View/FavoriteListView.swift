//
//  FavoriteListView.swift
//  Feature
//
//  Created by 제이콥 on 3/18/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct FavoriteListView: View {
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserData: CurrentUserData
    @State var isLoading: Bool = true
    @State var isPresentBottomSheet: Bool = false
    @State var showFavoriteInfo: Bool = false
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            VStack(spacing: 0, content: {
                //상단바
                HStack(content: {
                    SharedAsset.back.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            appCoordinator.rootPath.removeLast()
                        }
                    Spacer()
                    Text("즐겨찾기 목록")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundStyle(.white)
              
                    Spacer()
                    
                    SharedAsset.menuWhite.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            UIView.setAnimationsEnabled(false)
                            isPresentBottomSheet = true
                        }
                })
                .frame(height: 65)
                .padding(.horizontal, 20)
                
                HStack(alignment: .bottom){
                    Text("\(currentUserData.playlistArray[0].songIDs.count)곡")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                        .foregroundStyle(ColorSet.subGray)
                    
                    Spacer()
                    
                    PlayAllButton()
                        .onTapGesture {
                            playerViewModel.playAll(title: "즐겨찾기 목록", songs: currentUserData.playlistArray[0].songs)
                            AnalyticsManager.shared.setSelectContentLog(title: "FavoriteListViewPlayAllButton")
                        }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .overlay {
                    if showFavoriteInfo {
                        SharedAsset.speechBubbleMedium.swiftUIImage
                            .transition(.opacity)
                            .overlay {
                                HStack(spacing: 3, content: {
                                    Text("회원님에게만 보이는 페이지 입니다.")
                                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                                        .foregroundStyle(Color.black)
                                    
                                    SharedAsset.xBlackBold.swiftUIImage
                                        .scaledToFit()
                                        .frame(width: 13, height: 13)
                                        .onTapGesture {
                                            showFavoriteInfo = false
                                            UserDefaults.standard.setValue(Date(), forKey: "favoriteInfo")
                                        }
                                })
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                .offset(y: 3.5)
                                .transition(.opacity)
                            }
                            .offset(y:-20)
                    }
                }

                
                Divider05()
                    .padding(.top, 15)
                
                if !isLoading && currentUserData.playlistArray[0].songIDs.isEmpty {
                    InitialSettingView(title: "즐겨찾기한 곡이 없습니다\n좋아하는 음악을 즐겨찾기 목록에 추가해보세요", buttonTitle: "추천 음악 보러가기") {
                        let myRandomGenre = currentUserData.favoriteGenres[Int.random(in: currentUserData.favoriteGenres.indices)]
                        appCoordinator.rootPath.append(LibraryPage.recommendation(genreID: myRandomGenre))
                    }
                    .padding(.top, getUIScreenBounds().height * 0.25)
                } else {
                    
                    ScrollView {
                        LazyVStack(spacing: 0, content: {
                            ForEach(currentUserData.playlistArray[0].songs, id: \.id) { song in
                                SongListBigItem(song: song)
                                    .onTapGesture {
                                        let tappedSong = song
                                        playerViewModel.playAll(title: "즐겨찾기 목록", songs: currentUserData.playlistArray[0].songs, startingItem: tappedSong)
                                    }
                            }
                            if isLoading {
                                FavoriteSongSkeletonView()
                            }
                            
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 90)
                        })
                    }
                    .refreshable {
                        Task {
                            self.isLoading = true
                            currentUserData.playlistArray[0].songs = await currentUserData.requestMorePlaylistSong(playlistID: "favorite")
                            self.isLoading = false
                        }
                    }
                    .scrollIndicators(.hidden)
                }
        
            })
            CreateMumoryBottomSheetView(isSheetShown: $appCoordinator.isCreateMumorySheetShown, offsetY: $appCoordinator.offsetY)
                .ignoresSafeArea()
        }
        .onAppear {
            UIRefreshControl.appearance().tintColor = UIColor(white: 0.47, alpha: 1)
            playerViewModel.setLibraryPlayerVisibility(isShown: !appCoordinator.isCreateMumorySheetShown, moveToBottom: true)
            Task {
                currentUserData.playlistArray[0].songs = await currentUserData.requestMorePlaylistSong(playlistID: "favorite")
                self.isLoading = false
            }
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
                withAnimation {
                    showFavoriteInfo = UserDefaults.standard.value(forKey: "favoriteInfo") == nil
                }
            }

        }
        .fullScreenCover(isPresented: $isPresentBottomSheet) {
            BottomSheetDarkGrayWrapper(isPresent: $isPresentBottomSheet) {
                BottomSheetItem(image: SharedAsset.report.swiftUIImage, title: "신고")
                    .onTapGesture {
                        isPresentBottomSheet.toggle()
                        appCoordinator.rootPath.append(MumoryPage.report)
                    }
            }
            .background(TransparentBackground())
        }
    }

}

struct SongListBigItem: View {
    enum ViewType {
        case favorite
        case recentMumory
    }
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    @State var isPresentBottomSheet: Bool = false
    let song: Song
    var type: ViewType = .favorite
    init(song: Song) {
        self.song = song
    }
    init(song: Song, type: ViewType) {
        self.song = song
        self.type = type
    }
    
    
    var body: some View {
        HStack(spacing: 0, content: {
            AsyncImage(url: song.artwork?.url(width: 200, height: 200)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(ColorSet.skeleton)
            }
            .overlay {
                if type == .recentMumory {
                    LinearGradient(colors: [ColorSet.mainPurpleColor, Color.clear], startPoint: .bottom, endPoint: .init(x: 0.5, y: 0.6 ))
                }
            }
            .frame(width: 57, height: 57)
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
            .padding(.trailing, 16)
            
            VStack(spacing: 4, content: {
                Text(song.title)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(song.artistName)
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(Color(white: 0.72))
                    .frame(maxWidth: .infinity, alignment: .leading)
            })
            .padding(.trailing, 27)
            
            if playerViewModel.favoriteSongIds.contains(song.id.rawValue) {
                SharedAsset.bookmarkFilled.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 20)
                    .onTapGesture {
                        playerViewModel.removeFromFavorite(uid: currentUserData.uId, songId: self.song.id.rawValue)
                        snackBarViewModel.setSnackBar(type: .favorite, status: .delete)
                    }
            }else {
                SharedAsset.bookmark.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 20)
                    .onTapGesture {
                        self.generateHapticFeedback(style: .medium)
                        playerViewModel.addToFavorite(uid: currentUserData.uId, songId: self.song.id.rawValue)
                        snackBarViewModel.setSnackBar(type: .favorite, status: .success)
                    }
            }
            
            SharedAsset.menu.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .onTapGesture {
                    UIView.setAnimationsEnabled(false)
                    isPresentBottomSheet.toggle()
                }
        })
        .padding(.horizontal, 20)
        .frame(height: 95)
        .background(ColorSet.background)
//        .onLongPressGesture(perform: {
//            self.generateHapticFeedback(style: .medium)
//            UIView.setAnimationsEnabled(false)
//            isPresentBottomSheet = true
//        })
        .fullScreenCover(isPresented: $isPresentBottomSheet) {
            BottomSheetWrapper(isPresent: $isPresentBottomSheet) {
                SongBottomSheetView(song: song, types: [.withoutBookmark])
            }
            .background(TransparentBackground())
        }
    }
}

struct FavoriteSongSkeletonView: View {
    @State var startAnimation: Bool = false
    var body: some View {
        ForEach(0...10, id: \.self) { index in
            item
        }
        .onAppear {
            startAnimation.toggle()
        }
    }
    
    var item: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 5, style: .circular)
                .fill(startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                .frame(width: 57, height: 57)
                .padding(.trailing, 16)

            VStack(alignment: .leading, spacing: 7) {
                RoundedRectangle(cornerRadius: 5, style: .circular)
                    .fill(startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                    .frame(width: 91, height: 15)
                
                RoundedRectangle(cornerRadius: 5, style: .circular)
                    .fill(startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                    .frame(width: 71, height: 11)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(height: 95)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: startAnimation)
    }
}
