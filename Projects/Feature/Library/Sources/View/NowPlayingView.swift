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
    @State var horizontalSpacing: CGFloat = .zero
    @State var playTogetherSongs: [Song] = []
 
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
                AsyncImage(url: playerViewModel.playingSong()?.artwork?.url(width: 1000, height: 1000)) { image in
                    image
                        .resizable()
                        .blur(radius: 20)
                        .overlay {
                            ColorSet.moreDeepGray.opacity(0.6).ignoresSafeArea()
                        }
                } placeholder: {
                    Rectangle()
                        .fill(Color(white: 0.28))
                }
                .frame(width: getUIScreenBounds().width, height: getUIScreenBounds().height)
                .overlay {
                    LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear]), startPoint: .bottom, endPoint: .init(x: 0.5, y: 0.90)).ignoresSafeArea()
                }
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
                    .frame(height: getUIScreenBounds().height - appCoordinator.safeAreaInsetsBottom - 45)
                    
                    PlayTogetherView(songs: $playTogetherSongs)
                        .opacity(isPresentQueue ? 0 : 1)
                        .padding(.bottom, 100)
                        .onChange(of: playerViewModel.currentSong, perform: { value in
                            guard let song = value else {return}
                            print("\(song.title), \(song.artistName)")
                            Task {
                                self.playTogetherSongs = await requestPlayTogetherSongs(title: song.title, artist: song.artistName)
                            }
                        })
                }
                .scrollDisabled(isPresentQueue)
                .onChange(of: isPresentQueue) { newValue in
                    if isPresentQueue{
                        proxy.scrollTo("main", anchor: .top)
                    }
                }
            }
 
            
            
            SnackBarView {
                Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { timer in
                    dismiss()
                }
            }

            
        }
        .ignoresSafeArea()
        .onAppear {
            horizontalSpacing = (getUIScreenBounds().width * 0.13) / 2
            guard let song = playerViewModel.currentSong else {return}
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
                                .frame(width: 28, height: 28)
                                .frame(maxWidth: .infinity)
                                .padding(.trailing, 5)
                        }else {
                            SharedAsset.playlist.swiftUIImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .frame(maxWidth: .infinity)
                                .padding(.trailing, 5)
                        }
                    }
                    
                    //뒤로가기 버튼
                    Button(action: {
                        playerViewModel.skipToPrevious()

                    }, label: {
                        SharedAsset.playBack.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .frame(maxWidth: .infinity)
                    })

                    //재생, 멈춤 버튼
                    if playerViewModel.isPlaying() {
                        Button(action: {
                            playerViewModel.pause()
                        }, label: {
                            SharedAsset.pauseBig.swiftUIImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .frame(maxWidth: .infinity)
                        })
                    }else {
                        Button(action: {
                            playerViewModel.play()
                        }, label: {
                            SharedAsset.playBig.swiftUIImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .frame(maxWidth: .infinity)
                        })
                    }
                    
                    //앞으로 가기 버튼
                    Button(action: {
                        playerViewModel.skipToNext()
                    }, label: {
                        SharedAsset.playForward.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .frame(maxWidth: .infinity)
                    })
                 
                    
                    
                    //북마크 버튼
                    Button(action: {
                        guard let nowSong = playerViewModel.currentSong else {return}
                        if playerViewModel.favoriteSongIds.contains(nowSong.id.rawValue) {
                            playerViewModel.removeFromFavorite(uid: currentUserData.uId, songId: nowSong.id.rawValue)
                            snackBarViewModel.setSnackBar(type: .favorite, status: .delete)
                        }else {
                            playerViewModel.addToFavorite(uid: currentUserData.uId, songId: nowSong.id.rawValue)
                            snackBarViewModel.setSnackBar(type: .favorite, status: .success)
                        }
                        
                    }, label: {
                        if playerViewModel.favoriteSongIds.contains(playerViewModel.currentSong?.id.rawValue ?? "") {
                            SharedAsset.bookmarkFilled.swiftUIImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .frame(maxWidth: .infinity)
                        }else {
                            SharedAsset.bookmarkLight.swiftUIImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .frame(maxWidth: .infinity)
                        }
                       
                    })
                })
                .padding(.horizontal, getUIScreenBounds().width * 0.13 / 2)
                .padding(.bottom, 15)
            })
        })
        
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
                
            })
            .padding(.horizontal, getUIScreenBounds().width * 0.13 / 2)
            .frame(height: 63)
            .padding(.top, appCoordinator.safeAreaInsetsTop)
            
            //선명한 앨범 커버(정방형) 폰 기준 가로의 87%
            AsyncImage(url: playerViewModel.currentSong?.artwork?.url(width: 1000, height: 1000)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                SharedAsset.albumCoverPlaceholder.swiftUIImage
                    .resizable()
                    .scaledToFit()
            }
            .frame(width: getUIScreenBounds().width * 0.87, height: getUIScreenBounds().width * 0.87)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
            .padding(.bottom, 20)
            
            //아티스트 이름 및 노래 이름, 추가버튼
            HStack(alignment: .top, spacing: 0, content: {
                VStack(spacing: 6, content: {
                    MarqueeText(song: $playerViewModel.currentSong)

                    Text(playerViewModel.currentSong?.artistName ?? "아티스트이름")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 18))
                        .foregroundStyle(artistTextColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                   
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 20)
                
                if playerViewModel.currentSong != nil {
                    SharedAsset.addPurpleCircleFilled.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                }else {
                    SharedAsset.addGrayCircle.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                }
                
            })
            .padding(.horizontal, getUIScreenBounds().width * 0.13 / 2)

            Spacer()
            
            HStack{
                Button(action: {
                    playerViewModel.setShuffleMode()
                }, label: {
                    switch playerViewModel.shuffleState {
                    case .off:
                        SharedAsset.playRandomOff.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                    case .on:
                        SharedAsset.playRandom.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                    }
                    
                })
                Spacer()
                Button(action: {
                    playerViewModel.setRepeatMode()
                }, label: {
                    switch playerViewModel.repeatState {
                    case .off:
                        SharedAsset.playRepeatOff.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                    case .all:
                        SharedAsset.playRepeatAll.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                    case .one:
                        SharedAsset.playRepeatOneItem.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                    }
                })
            }
            .padding(.horizontal, 25)
            .padding(.bottom, 16)
            
            //슬라이드 바 및 재생시간
            VStack(spacing: 0, content: {
                Slider(value: $playerViewModel.playingTime, in: 0...(playerViewModel.playingSong()?.duration ?? 0.0), onEditingChanged: { isEditing in
                    if isEditing {
                        playerViewModel.startEditingSlider()
                    }else {
                        playerViewModel.updatePlaybackTime(to: playerViewModel.playingTime )
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
            .padding(.horizontal, 25)
            .padding(.bottom, 12)
            
            
        }
    }

    
}

struct QueueView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
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
                    .padding(.trailing, getUIScreenBounds().width * 0.13 / 2)
                    .frame(height: 63)
                    .padding(.top, appCoordinator.safeAreaInsetsTop)
            }
            
            
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
                    proxy.scrollTo(playerViewModel.playingSong()?.id, anchor: .top)
                }
            }
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
            
            VStack(spacing: 0) {
                ForEach(songs, id: \.id) { song in
                    PlayTogetherItem(song: song)
                }
            }
            .padding(.bottom, 25)
            
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
                        playerViewModel.addToFavorite(uid: currentUserData.uId, songId: self.song.id.rawValue)
                        snackBarViewModel.setSnackBar(type: .favorite, status: .success)
                    }
            }
            
            
            SharedAsset.menu.swiftUIImage
                .frame(width: 22, height: 22)
                .onTapGesture {
                    UIView.setAnimationsEnabled(false)
                    isPresentBottomSheet = true
                }
                .fullScreenCover(isPresented: $isPresentBottomSheet) {
                    BottomSheetWrapper(isPresent: $isPresentBottomSheet) {
                        //아티스트 페이지의 바텀시트면 아티스트 노래 보기 아이템 제거. 그 외의 경우에는 즐겨찾기 추가만 제거
                        //현재 MusicListItem은 북마크 버튼이 있는 아이템이라 즐겨찾기 추가 버튼이 음악 아이템 내부에 원래 있음
                        SongBottomSheetView(song: song, types: [.withoutBookmark])
                    }
                    .background(TransparentBackground())
                }
            
        })
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 15)
        .frame(height: 70)
        .background(ColorSet.background)
        
    }
}

struct MarqueeText: View {
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State var animationDuration: Double = 5.0
    @State var titleWidth: CGFloat = 0
    @State private var startAnimation : Bool = false
    @State var changeOffset: CGFloat = .zero
    @Binding var song: Song?
    @State var id: UUID = UUID()
    init(song: Binding<Song?>) {
        self._song = song
    }
    var body: some View {
        ScrollView(.horizontal) {
            Text(song?.title ?? "재생중인 어쩌구가 업시용")
                .id(self.id)
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                .foregroundStyle(Color.white)
                .onAppear {
                    guard let song = playerViewModel.currentSong else {return}
                    titleWidth = getTextWidth(term: song.title)
                    changeOffset = titleWidth < 280 ? 0 : -titleWidth
                    withAnimation(.linear(duration: 4.0).delay(2.0).repeatCount(2, autoreverses: true)) {
                        startAnimation.toggle()
                    }
                }
                .onChange(of: playerViewModel.currentSong, perform: { value in
                    guard let song = value else {return}
                    self.id = UUID()
                    titleWidth = getTextWidth(term: song.title)
                    changeOffset = titleWidth < 280 ? 0 : -titleWidth
                    withAnimation(.linear(duration: 4.0).delay(2.0).repeatCount(2, autoreverses: true)) {
                        startAnimation.toggle()
                    }
                    Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { timer in
                        changeOffset = 0
                    }
                    //애니메이션이 끝나면 음수로 가거나...어쩌구...
                    //이 부분 해결하기
                })
                .offset(x: startAnimation ? changeOffset: 0 )
//                .animation(.linear(duration: 4.0).delay(2.0).repeatCount(1, autoreverses: true), value: startAnimation)
        }
        .scrollIndicators(.hidden)
        .scrollDisabled(true)
    }
    
}
