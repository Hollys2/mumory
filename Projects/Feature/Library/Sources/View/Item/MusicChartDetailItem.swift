//
//  MusicChartDetailItem.swift
//  Feature
//
//  Created by 제이콥 on 2/8/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct MusicChartDetailItem: View {
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    @State var isPresentBottomSheet: Bool = false
    
    var rank: Int
    var song: Song

    let title = "타이틀"
    let artist = "아티스트"
    
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
            .padding(.trailing, 15)

            
            Text(String(format: "%02d", rank))
                .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                .foregroundStyle(LibraryColorSet.purpleBackground)
                .padding(.trailing, 14)
            
            VStack(spacing: 3, content: {
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
                        playerViewModel.removeFromFavorite(uid: currentUserViewModel.user.uId, songId: self.song.id.rawValue)
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
                        playerViewModel.addToFavorite(uid: currentUserViewModel.user.uId, songId: self.song.id.rawValue)
                        snackBarViewModel.setSnackBar(type: .favorite, status: .success)
                    }
            }
            
            SharedAsset.menu.swiftUIImage
                .frame(width: 22, height: 22)
                .onTapGesture {
                    UIView.setAnimationsEnabled(false)
                    isPresentBottomSheet = true
                }
            
        })
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 70)
        .padding(.horizontal, 20)
        .background(ColorSet.background)
//        .onLongPressGesture(minimumDuration: 0.7, perform: {
//            self.generateHapticFeedback(style: .medium)
//            UIView.setAnimationsEnabled(false)
//            isPresentBottomSheet = true
//        })
        .fullScreenCover(isPresented: $isPresentBottomSheet) {
            BottomSheetWrapper(isPresent: $isPresentBottomSheet) {
                SongBottomSheetView(song: song,
                                    types: [.withoutBookmark])
            }
            .background(TransparentBackground())
        }
    }
}
