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
    var type: RecommendationType
    @Binding var songs: [Song]
    let title: String
    init(type: RecommendationType, songs: Binding<[Song]>) {
        self.type = type
        self._songs = songs
        switch type {
        case .mostPosted:
            self.title = "뮤모리 사용자가 많이 기록한 음악"
        case .similiarTaste:
            self.title = "비슷한 취향을 가진 사람들이 찜한 음악"
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
                VStack(alignment: .leading, spacing: 0, content: {
                    Text(title)
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundStyle(Color.white)

                    
                    Text(getUpdateDateText())
                        .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                        .foregroundStyle(Color.white)

                })
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(20)
            }
            
            ForEach(songs.indices, id: \.self) { index in
                ExtraRecommendationItem(rank: index, song: songs[index], type: self.type)
            }
        })
        .frame(width: getUIScreenBounds().width * 0.9)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))



    }
}



struct ExtraRecommendationItem: View {
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    @State var isPresentBottomSheet: Bool = false
    
    var rank: Int
    var song: Song
    var type: RecommendationType

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
                        isPresentBottomSheet = true
                    }
                
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .frame(height: 70)
            .background(ColorSet.moreDeepGray)
            
//            Divider03()

        })
        .fullScreenCover(isPresented: $isPresentBottomSheet) {
            BottomSheetWrapper(isPresent: $isPresentBottomSheet) {
                SongBottomSheetView(song: song,
                                    types: [.withoutBookmark])
            }
            .background(TransparentBackground())
        }
    }
}
