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

enum SongItemType {
    case normal
    case artist
}
struct MusicListItem: View {
    var song: Song
    var type: SongItemType = .normal
    
    init(song: Song, type: SongItemType) {
        self.song = song
        self.type = type
    }
    
    init(song: Song){
        self.song = song
    }
    
    @State var isPresentBottomSheet: Bool = false
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
        
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
                        playerViewModel.removeFromFavorite(uid: currentUserData.uid, songId: self.song.id.rawValue)
                        snackBarViewModel.setSnackBar(type: .favorite, status: .delete)
                    }
            }else {
                SharedAsset.bookmark.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 23)
                    .onTapGesture {
                        playerViewModel.addToFavorite(uid: currentUserData.uid, songId: self.song.id.rawValue)
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
                        SongBottomSheetView(song: song,
                                            types: type == .artist ? [.withoutArtist, .withoutBookmark] : [.withoutBookmark])
                    }
                    .background(TransparentBackground())
                }
            
        })
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .background(ColorSet.background)
    }
}


