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
    @Binding var songIds: [String]
    @State var firstSong: Song?
    @State var offset: CGPoint = .zero
    var type: RecommendationType
    let title: String
    init(type: RecommendationType, songIds: Binding<[String]>) {
        self.type = type
        self._songIds = songIds
        switch type {
        case .mostPosted:
            self.title = "뮤모리 사용자가 많이 기록한 음악"
        case .similiarTaste:
            self.title = "비슷한 취향을 가진 사람들이 찜한 음악"
        }
    }
    
    var body: some View {
        VStack(spacing: 0, content: {
            AsyncImage(url: firstSong?.artwork?.url(width: 500, height: 500)) { image in
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
                    .frame(width: 17, height: 17)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.trailing, 15)
                    .padding(.top, 20)
                    .onTapGesture {
                        switch type {
                        case .mostPosted:
                            appCoordinator.rootPath.append(MumoryPage.mostPostedSongList(songIds: $songIds))
                        case .similiarTaste:
                            appCoordinator.rootPath.append(MumoryPage.similarTasteList(songIds: $songIds))
                        }
                    }
            }
            SimpleScrollView(contentOffset: $offset) {
                LazyVStack(spacing: 0, content: {
                    ForEach(songIds.indices, id: \.self) { index in
                        ExtraRecommendationItem(songId: songIds[index], rank: index, type: self.type)
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
        .onAppear(perform: {
            Task {
                guard let firstSongId = songIds.first else {return}
                self.firstSong = await fetchSong(songID: firstSongId)
            }
        })


    }
}



struct ExtraRecommendationItem: View {
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    @State var isPresentBottomSheet: Bool = false
    @State var song: Song?
    var songId: String
    var rank: Int
    var type: RecommendationType
    
    init(songId: String, rank: Int, type: RecommendationType) {
        self.songId = songId
        self.rank = rank
        self.type = type
    }
    
    var body: some View {
        VStack(spacing: 0, content: {
            HStack(spacing: 0, content: {
                AsyncImage(url: song?.artwork?.url(width: 300, height: 300)) { image in
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
                    Text(song?.title ?? "")
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Text(song?.artistName ?? "")
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
                        isPresentBottomSheet = true
                    }
                
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .frame(height: 70)
            .background(ColorSet.moreDeepGray)
            
        })
        .onAppear(perform: {
            Task {
                self.song = await fetchSong(songID: self.songId)
            }
        })
        .fullScreenCover(isPresented: $isPresentBottomSheet) {
            BottomSheetWrapper(isPresent: $isPresentBottomSheet) {
                OptionalSongBottomSheetView(song: $song)
            }
            .background(TransparentBackground())
        }
    }
}
