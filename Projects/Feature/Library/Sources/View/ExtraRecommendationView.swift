//
//  ExtraRecommendationView.swift
//  Feature
//
//  Created by 제이콥 on 3/28/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

public enum RecommendationType {
    case mostPosted
    case similiarTaste
}
struct ExtraRecommendationView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel

    @Binding var songs: [Song]
    @State var firstSong: Song?
    @State var offset: CGPoint = .zero
    var type: RecommendationType
    let title: String
    init(type: RecommendationType, songs: Binding<[Song]>) {
        self.type = type
        self._songs = songs
        switch type {
        case .mostPosted:
            self.title = "뮤모리로 많이 기록된 음악"
        case .similiarTaste:
            self.title = "비슷한 취향 사용자의 선호 음악"
        }
    }
    
    var body: some View {
        VStack(spacing: 0, content: {
            AsyncImage(url: songs.first?.artwork?.url(width: 500, height: 500)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } placeholder: {
                Rectangle()
                    .fill(ColorSet.skeleton)
            }
            .frame(height: 98)
            .overlay {
                Color.black.opacity(0.4)
                LinearGradient(colors: [ColorSet.moreDeepGray, Color.clear], startPoint: .bottom, endPoint: .init(x: 0.5, y: 0.8))
                VStack(alignment: .leading, spacing: 5, content: {
                    Text(title)
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundStyle(Color.white)

                    
                    Text(getUpdateDateText())
                        .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                        .foregroundStyle(Color.white)

                })
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(20)
                
                SharedAsset.nextSetting.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.trailing, 15)
                    .padding(.top, 20)
                    .onTapGesture {
                        switch type {
                        case .mostPosted:
                            appCoordinator.rootPath.append(MumoryPage.mostPostedSongList(songs: $songs))
                        case .similiarTaste:
                            appCoordinator.rootPath.append(MumoryPage.similarTasteList(songs: $songs))
                        }
                    }
            }
            SimpleScrollView(contentOffset: $offset) {
                LazyVStack(spacing: 0, content: {
                    if songs.isEmpty {
                        if type == .mostPosted {
                            MusicChartSkeletonLongView()
                                .frame(maxWidth: .infinity)

                        }else if type == .similiarTaste {
                            SongListSkeletonView()
                                .frame(maxWidth: .infinity)

                        }
                    }else {
                        ForEach(songs.indices, id: \.self) { index in
                            ExtraRecommendationItem(song: songs[index], rank: index, type: self.type)
                                .frame(maxWidth: .infinity)
                                .onTapGesture {
                                    let tappedSong = songs[index]
                                    playerViewModel.playAll(title: title, songs: songs, startingItem: tappedSong)
                                }
                        }
                    }
                })
                .frame(width: getUIScreenBounds().width * 0.9)
            }
            .scrollIndicators(.hidden)
            .onChange(of: offset, perform: { value in
                if offset.y < 0 {
                    offset.y = 0
                }
            })
            
        })
        .frame(width: getUIScreenBounds().width * 0.9)
        .background(ColorSet.moreDeepGray)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))


    }
}



struct ExtraRecommendationItem: View {
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var currentUserData: CurrentUserViewModel
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    @State var isPresentBottomSheet: Bool = false
    let song: Song
    var rank: Int
    var type: RecommendationType
    
    init(song: Song, rank: Int, type: RecommendationType) {
        self.song = song
        self.rank = rank
        self.type = type
    }
    
    var body: some View {
        VStack(spacing: 0, content: {
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
                .padding(.trailing, type == .similiarTaste ? 13 : 16)

                if type != .similiarTaste {
                    Text(String(format: "%02d", rank+1))
                        .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                        .foregroundStyle(LibraryColorSet.purpleBackground)
                        .padding(.trailing, 15)
                }
                
                VStack(spacing: 1, content: {
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
                
                SharedAsset.menu.swiftUIImage
                    .frame(width: 22, height: 22)
                    .onTapGesture {
                        UIView.setAnimationsEnabled(false)
                        isPresentBottomSheet.toggle()
                    }
                
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .frame(height: 70)
            .background(ColorSet.moreDeepGray)
            
        })
        .fullScreenCover(isPresented: $isPresentBottomSheet) {
            BottomSheetWrapper(isPresent: $isPresentBottomSheet) {
                SongBottomSheetView(song: song)
            }
            .background(TransparentBackground())
        }
    }
}
