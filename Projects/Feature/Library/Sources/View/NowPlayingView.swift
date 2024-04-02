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
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    @State var isPresentQueue: Bool = false
    @State var playTogetherSongs: [Song] = []
    
    @State var albumCoverSize: CGFloat = .zero
    @State var horizontalSpacing: CGFloat = .zero
    @State var isSE: Bool = false
    init() {
        UISlider.appearance().setThumbImage(UIImage(asset: SharedAsset.playSphere)?.resized(to: CGSize(width: 10.45, height: 10)), for: .normal)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            //재생페이지에서 보여줄 배경 사진(앨범 커버)
            AsyncImage(url: playerViewModel.playingSong()?.artwork?.url(width: 1000, height: 1000)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(ColorSet.charSubGray)
            }
            .frame(width: getUIScreenBounds().width, height: getUIScreenBounds().height)
            .overlay {
                Color.black.opacity(0.3)
                ColorSet.background.opacity(isPresentQueue ? 1 : 0)
            }
            
            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        if isPresentQueue {
                            QueueView()
                        }else {
                            PlayingView()
                            
                        }
                        PlayControlView(isPresentQueue: $isPresentQueue)
                    }
                    .id("main")
                    .frame(height: getUIScreenBounds().height - appCoordinator.safeAreaInsetsBottom - (isSE ? 35 : 45))
                    
                    PlayTogetherView(songs: $playTogetherSongs)
                        .opacity(isPresentQueue ? 0 : 1)
                        .padding(.bottom, 100)
                        .onChange(of: playerViewModel.currentSong, perform: { value in
                            guard let song = value else {return}
                            Task {
                                self.playTogetherSongs = await requestPlayTogetherSongs(title: song.title, artist: song.artistName)
                            }
                        })
                }
                .scrollIndicators(.hidden)
                .scrollDisabled(isPresentQueue)
                .onChange(of: isPresentQueue) { newValue in
                    if isPresentQueue{
                        proxy.scrollTo("main", anchor: .top)
                    }
                }
            }
            .preferredColorScheme(.dark)
            .background(.ultraThinMaterial.opacity(isPresentQueue ? 0 : 1))
    
            SnackBarView(additionalAction: {
                Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { timer in
                    dismiss()
                }
            })
            .frame(width: getUIScreenBounds().width)


            
        }
        .ignoresSafeArea()
        .onAppear {
            guard let song = playerViewModel.currentSong else {return}
            isSE = getUIScreenBounds().height < 700
            albumCoverSize = getUIScreenBounds().height < 700 ? getUIScreenBounds().width * 0.77 : getUIScreenBounds().width * 0.87
            horizontalSpacing = getUIScreenBounds().height < 700 ? getUIScreenBounds().width * 0.1 : getUIScreenBounds().width * 0.065
            Task {
                print("\(song.title), \(song.artistName)")
                self.playTogetherSongs = await requestPlayTogetherSongs(title: song.title, artist: song.artistName)
            }
        }

    }
}

struct PlayControlView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    @Binding var isPresentQueue: Bool
    let durationTextColor = Color(white: 0.83)
    
    @State var albumCoverSize: CGFloat = .zero
    @State var horizontalSpacing: CGFloat = .zero
    @State var isSE: Bool = false
    
    var body: some View {
        //재생 제어 버튼들
        HStack(spacing: 0, content: {
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
                        .frame(width: 28, height: 28)
                }else {
                    SharedAsset.playlist.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }
            }
            
            Spacer()
            
            //뒤로가기 버튼
            Button(action: {
                playerViewModel.skipToPrevious()
                
            }, label: {
                SharedAsset.playBack.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            })
            Spacer()

            
            //재생, 멈춤 버튼
            if playerViewModel.isPlaying {
                Button(action: {
                    playerViewModel.pause()
                }, label: {
                    SharedAsset.pauseBig.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                })
            }else {
                Button(action: {
                    playerViewModel.play()
                }, label: {
                    SharedAsset.playBig.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                })
            }
            Spacer()

            
            //앞으로 가기 버튼
            Button(action: {
                playerViewModel.skipToNext()
            }, label: {
                SharedAsset.playForward.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            })
            
            Spacer()

            //북마크 버튼
            Button(action: {
                guard let nowSong = playerViewModel.currentSong else {return}
                if playerViewModel.favoriteSongIds.contains(nowSong.id.rawValue) {
                    playerViewModel.removeFromFavorite(uid: currentUserData.uId, songId: nowSong.id.rawValue)
                    snackBarViewModel.setSnackBar(type: .favorite, status: .delete)
                }else {
                    self.generateHapticFeedback(style: .medium)
                    playerViewModel.addToFavorite(uid: currentUserData.uId, songId: nowSong.id.rawValue)
                    snackBarViewModel.setSnackBar(type: .favorite, status: .success)
                }
                
            }, label: {
                if playerViewModel.favoriteSongIds.contains(playerViewModel.currentSong?.id.rawValue ?? "") {
                    SharedAsset.bookmarkFilled.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                }else {
                    SharedAsset.bookmarkLight.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                }
                
            })
        })
        .padding(.horizontal, horizontalSpacing)
        .padding(.bottom, isSE ? 12 : 15)
        .onAppear {
            isSE = getUIScreenBounds().height < 700
            albumCoverSize = getUIScreenBounds().height < 700 ? getUIScreenBounds().width * 0.77 : getUIScreenBounds().width * 0.87
            horizontalSpacing = getUIScreenBounds().height < 700 ? getUIScreenBounds().width * 0.1 : getUIScreenBounds().width * 0.065
        }
        
    }
}

struct PlayingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State var animationDuration: Double = 5.0
    @State var titleWidth: CGFloat = 0
    @State private var startAnimation : Bool = false
    @State var changeOffset: CGFloat = .zero
    @State var isPresentAddBottomSheet: Bool = false
    @State var isPresentSongBottmSheet: Bool = false
    
    @State var albumCoverSize: CGFloat = .zero
    @State var horizontalSpacing: CGFloat = .zero
    @State var isSE: Bool = false
    
    @State var id: UUID = UUID()
    @State var titleMaxWidth: CGFloat = .zero
    @State var endInit: Bool = true
    
    let delay: Double = 1.0
    let artistTextColor = Color(white: 0.89)
    let durationTextColor = Color(white: 0.83)
    
    
    var body: some View {
        VStack(spacing: 0) {
            //일반 재생화면
            
            //상단바
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
                    .onTapGesture {
                        guard let song = playerViewModel.currentSong else {return}
                        UIView.setAnimationsEnabled(false)
                        isPresentSongBottmSheet = true
                    }
            })
            .frame(height: 65)
            .padding(.top, appCoordinator.safeAreaInsetsTop)
            .padding(.horizontal, isSE ? 20 : horizontalSpacing)
            
            AsyncImage(url: playerViewModel.currentSong?.artwork?.url(width: 1000, height: 1000)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                SharedAsset.albumCoverPlaceholder.swiftUIImage
                    .resizable()
                    .scaledToFit()
            }
            .frame(width: albumCoverSize, height: albumCoverSize)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
            .padding(.bottom, isSE ? 16 : 20)
            
            //아티스트 이름 및 노래 이름, 추가버튼
            HStack(alignment: .top, spacing: 0, content: {
                VStack(spacing: 6, content: {
                    if endInit {
                        ScrollView(.horizontal) {
                            Text(playerViewModel.currentSong?.title ?? "재생 중인 음악이 없습니다.")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: getUIScreenBounds().height < 700 ? 18 : 20))
                                .foregroundStyle(Color.white)
                                .offset(x: startAnimation ? changeOffset : 0)
                                .animation(.linear(duration: 4.0).delay(2.0).repeatForever(autoreverses: true).delay(2.0), value: startAnimation)
                                .onAppear(perform: {
                                    startAnimation = true
                                })
                        }
                        
                        
                    } else {
                        Text(" ")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: getUIScreenBounds().height < 700 ? 18 : 20))
                    }
         
                    Text(playerViewModel.currentSong?.artistName ?? "--")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: isSE ? 16 : 18))
                        .foregroundStyle(artistTextColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onChange(of: playerViewModel.currentSong, perform: { value in
                            DispatchQueue.main.async {
                                endInit = false
                                changeOffset = 0
                                startAnimation = false
                                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in
                                    endInit = true
                                }
                            }
                        })
                   
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 20)
                
                //추가버튼
                if playerViewModel.currentSong != nil {
                    SharedAsset.addPurpleCircleFilled.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .onTapGesture {
                            print("taptaptap")
                            UIView.setAnimationsEnabled(false)
                            isPresentAddBottomSheet = true
                        }
                }else {
                    SharedAsset.addGrayCircle.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                }
                
            })
            .padding(.horizontal, horizontalSpacing)


            Spacer()
            
            HStack{
                //랜덤 버튼
                Image(asset: {
                    switch playerViewModel.shuffleState {
                    case .off:
                        return SharedAsset.playRandomOff
                    case .on:
                        return SharedAsset.playRandom
                    }
                }())
                .resizable()
                .scaledToFit()
                .frame(width: isSE ? 26 : 28, height: isSE ? 26 : 28)
                .onTapGesture {
                    playerViewModel.setShuffleMode()
                }
  
                Spacer()
                
                //곡 반복 버튼
                Image(asset: {
                    switch playerViewModel.repeatState {
                    case .off:
                        return SharedAsset.playRepeatOff
                    case .all:
                        return SharedAsset.playRepeatAll
                    case .one:
                        return SharedAsset.playRepeatOneItem
                    }
                }())
                .resizable()
                .scaledToFit()
                .frame(width: isSE ? 26 : 28, height: isSE ? 26 : 28)
                .onTapGesture {
                    playerViewModel.setRepeatMode()
                }
                
            }
            .padding(.bottom, 5)
            .padding(.horizontal, horizontalSpacing)

            
            //슬라이드 바 및 재생시간
            VStack(spacing: 0, content: {
                Slider(value: $playerViewModel.playingTime, in: 0...(playerViewModel.playingSong()?.duration ?? 0.0), onEditingChanged: { isEditing in
                    DispatchQueue.main.async {
                        if isEditing {
                            playerViewModel.startEditingSlider()
                        }else {
                            playerViewModel.updatePlaybackTime(to: playerViewModel.playingTime )
                        }
                    }
                })
                .tint(Color.white)
            
                
                
                HStack(content: {
                    //재생시간
                    Text(getMinuteSecondString(time: playerViewModel.playingTime))
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                        .foregroundStyle(durationTextColor)
                    
                    Spacer()
                    
                    //남은시간
                    Text("-\(getMinuteSecondString(time: (playerViewModel.playingSong()?.duration ?? 0) - playerViewModel.playingTime))")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                        .foregroundStyle(durationTextColor)
                })
                .offset(y: -5)
            })
            .padding(.horizontal, horizontalSpacing)
            .padding(.bottom, isSE ? 0 : 12)
        }
        .frame(width: getUIScreenBounds().width)
        .fullScreenCover(isPresented: $isPresentAddBottomSheet) {
            BottomSheetDarkGrayWrapper(isPresent: $isPresentAddBottomSheet) {
                PlayingViewBottomSheet()
            }
            .background(TransparentBackground())
        }
        .fullScreenCover(isPresented: $isPresentSongBottmSheet) {
            BottomSheetWrapper(isPresent: $isPresentSongBottmSheet) {
                OptionalSongBottomSheetViewWithoutPlaying(song: $playerViewModel.currentSong, types: [.inPlayingView])
            }
            .background(TransparentBackground())
        }
        .onAppear {
            isSE = getUIScreenBounds().height < 700
            albumCoverSize = getUIScreenBounds().height < 700 ? getUIScreenBounds().width * 0.77 : getUIScreenBounds().width * 0.87
            horizontalSpacing = getUIScreenBounds().height < 700 ? getUIScreenBounds().width * 0.1 : getUIScreenBounds().width * 0.065
            
            let addIconWidth: CGFloat = 35
            let spacing: CGFloat = 20
            let horizontalTotalSpacing: CGFloat = getUIScreenBounds().height < 700 ? getUIScreenBounds().width * 0.2 : getUIScreenBounds().width * 0.13
            titleMaxWidth = getUIScreenBounds().width - addIconWidth - spacing - horizontalTotalSpacing
            
//            guard let song = playerViewModel.currentSong else {return}
//            DispatchQueue.main.async {
//                titleWidth = getTextWidth(term: song.title)
//                changeOffset = titleWidth < titleMaxWidth ? 0 : (titleMaxWidth - titleWidth)
//            }

        }
        
    }
}

struct PlayingViewBottomSheet: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var albumCoverSize: CGFloat = .zero
    @State var horizontalSpacing: CGFloat = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            BottomSheetItem(image: SharedAsset.addPlaylist.swiftUIImage, title: "플레이리스트에 추가")
                .onTapGesture {
                    guard let song = playerViewModel.currentSong else {return}
                    appCoordinator.rootPath.append(LibraryPage.saveToPlaylist(songs: [song]))
                    dismiss()
                    playerViewModel.isPresentNowPlayingView = false

                }
            BottomSheetItem(image: SharedAsset.addPurple.swiftUIImage, title: "뮤모리 만들기", type: .accent)
                .onTapGesture {
                    guard let song = playerViewModel.currentSong else {return}
                    appCoordinator.selectedTab = .home
                    appCoordinator.rootPath = NavigationPath()
                    mumoryDataViewModel.choosedMusicModel = MusicModel(songID: song.id, title: song.title, artist: song.artistName, artworkUrl: song.artwork?.url(width: 300, height: 300))
                    appCoordinator.isCreateMumorySheetShown = true
                    dismiss()
                    playerViewModel.isPresentNowPlayingView = false
                }
        }
    }
}

struct QueueView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    let playlistTitleBackgroundColor = Color(white: 0.12)
    @State var isSE: Bool = false
    @State var albumCoverSize: CGFloat = .zero
    @State var horizontalSpacing: CGFloat = .zero
    
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
                    .frame(height: 63)
                    .padding(.top, appCoordinator.safeAreaInsetsTop)
            }
            .padding(.trailing, isSE ? 20 : horizontalSpacing)
            
            
            HStack(content: {
                Text(playerViewModel.queueTitle.isEmpty ? "재생중" : playerViewModel.queueTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(playerViewModel.queueTitle.isEmpty ? "" : "목록 재생중 \(playerViewModel.nowPlayingIndex())/\(playerViewModel.queue.count)")
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
                        ForEach(playerViewModel.queue, id: \.id){ song in
                            QueueItem(song: song, scrollProxy: proxy)
                                .id(song.id)
                                .onTapGesture {
                                    withAnimation {
                                        proxy.scrollTo(song.id, anchor: .top)
                                    }
                                    playerViewModel.changeCurrentEntry(song: song)
                                }
//                                .highPriorityGesture(
//                                    TapGesture()
//                                        .onEnded({ _ in
//                                            withAnimation {
//                                                proxy.scrollTo(song.id, anchor: .top)
//                                            }
//                                            playerViewModel.changeCurrentEntry(song: song)
//                                        })
//                                )
                            
                        }
                    }
                    
                }
                .scrollIndicators(.hidden)
//                .overlay(content: {
//                    VStack(content: {
//                        Spacer()
//                        LinearGradient(colors: [ColorSet.background, Color.clear], startPoint: .bottom, endPoint: .init(x: 0.5, y: 0.2))
//                            .frame(maxWidth: .infinity)
//                            .frame(height: 30)
//                    })
//
//                })
                .onAppear {
                    proxy.scrollTo(playerViewModel.playingSong()?.id, anchor: .top)
                }
            }
        }
        .frame(width: getUIScreenBounds().width)
        .onAppear {
            isSE = getUIScreenBounds().height < 700
            albumCoverSize = getUIScreenBounds().height < 700 ? getUIScreenBounds().width * 0.77 : getUIScreenBounds().width * 0.87
            horizontalSpacing = getUIScreenBounds().height < 700 ? getUIScreenBounds().width * 0.1 : getUIScreenBounds().width * 0.065
        }
    }
}
public func requestPlayTogetherSongs(title: String, artist: String) async -> [Song]{
    var returnValue: [Song] = []
    var request = MusicCatalogSearchRequest(term: "\(title) \(artist)", types: [Song.self])
    request.limit = 20
    request.includeTopResults = true
    request.offset = 0
    var count = 0
    guard let response = try? await request.response() else {return []}
    for song in response.songs {
        if song.title == title {
            continue
        }
        if count > 3 {
            break
        }
        returnValue.append(song)
        count += 1
    }

    return returnValue
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


struct PlayTogetherView: View {
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @Binding var songs: [Song]
    init(songs: Binding<[Song]>) {
        self._songs = songs
    }
    var body: some View {
        VStack(spacing: 0) {
            Text("함께 많이 재생된 음악")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.white)
                .padding(.top, 25)
                .padding(.leading, 15)
                .padding(.bottom, 12)
            
            if let currentSong = playerViewModel.currentSong {
                VStack(spacing: 0) {
                    if songs.isEmpty {
                        Text("함께 재생된 음악이 없습니다.")
                            .foregroundStyle(ColorSet.subGray)
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 30)
                            .frame(height: 280)
                    } else {
                        ForEach(songs, id: \.id) { song in
                            PlayTogetherItem(song: song)
                                .onTapGesture {
                                    playerViewModel.playNewSong(song: song)
                                }
                        }
                    }
                }
                .padding(.bottom, 25)
            }else {
                Text("재생중인 음악이 없습니다.")
                    .foregroundStyle(ColorSet.subGray)
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 30)
                    .frame(height: 280)
            }
            
        }
        .frame(width: getUIScreenBounds().width * 0.92)
        .background(ColorSet.background)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
    }
}

struct PlayTogetherItem: View {
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
    @State var isPresentBottomSheet: Bool = false
    @State var viewWidth: CGFloat = .zero
    var song: Song
    init(song: Song){
        self.song = song
    }
    var body: some View {
        HStack(spacing: 0, content: {
            AsyncImage(url: song.artwork?.url(width: 300, height: 300)) { image in
                image
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 5,style: .circular))
            } placeholder: {
                RoundedRectangle(cornerRadius: 5, style: .circular)
                    .foregroundStyle(.gray)
                    .frame(width: 40, height: 40)
            }
            .padding(.trailing, 13)
            
            
            VStack(content: {
                Text(song.title)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(song.artistName)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(LibraryColorSet.lightGrayTitle)
                    .lineLimit(1)
                    .truncationMode(.tail)
            })
            
            Spacer()
            
            if playerViewModel.favoriteSongIds.contains(song.id.rawValue) {
                SharedAsset.bookmarkFilled.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 23)
                    .onTapGesture {
                        playerViewModel.removeFromFavorite(uid: currentUserData.uId, songId: self.song.id.rawValue)
                        snackBarViewModel.setSnackBar(type: .favorite, status: .delete)
                    }
            }else {
                SharedAsset.bookmark.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 23)
                    .onTapGesture {
                        self.generateHapticFeedback(style: .medium)
                        playerViewModel.addToFavorite(uid: currentUserData.uId, songId: self.song.id.rawValue)
                        snackBarViewModel.setSnackBar(type: .favorite, status: .success)
                    }
            }
            
            
            SharedAsset.menu.swiftUIImage
                .frame(width: 22, height: 22)
                .onTapGesture {
                    guard let song = playerViewModel.currentSong else {return}
                    UIView.setAnimationsEnabled(false)
                    isPresentBottomSheet = true
                }
       
            
        })
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 15)
        .frame(height: 70)
        .background(ColorSet.background)
//        .onLongPressGesture {
//            self.generateHapticFeedback(style: .medium)
//            UIView.setAnimationsEnabled(false)
//            isPresentBottomSheet = true
//        }
        .fullScreenCover(isPresented: $isPresentBottomSheet) {
            BottomSheetWrapper(isPresent: $isPresentBottomSheet) {
                //아티스트 페이지의 바텀시트면 아티스트 노래 보기 아이템 제거. 그 외의 경우에는 즐겨찾기 추가만 제거
                //현재 MusicListItem은 북마크 버튼이 있는 아이템이라 즐겨찾기 추가 버튼이 음악 아이템 내부에 원래 있음
                SongBottomSheetView(song: song, types: [.withoutBookmark])
            }
            .background(TransparentBackground())
        }
    }
}

