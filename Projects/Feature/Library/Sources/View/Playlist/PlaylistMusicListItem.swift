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

struct PlaylistMusicListItem: View {
    @Binding var isEditing: Bool
    @Binding var selectedSongs: [Song]
    var song: Song
    
    @State var isPresentBottomSheet: Bool = false

    init( song: Song, isEditing: Binding<Bool>, selectedSongs: Binding<[Song]>) {
        self._isEditing = isEditing
        self._selectedSongs = selectedSongs
        self.song = song
    }
    
    var body: some View {
        
        HStack(spacing: 0, content: {
            
            //편집시에만 체크박스가 보이도록함
            if isEditing{
                HStack{
                    if selectedSongs.contains(song){
                        SharedAsset.checkCircleFill.swiftUIImage
                            .resizable()
                            .scaledToFit()
                    }else {
                        SharedAsset.checkCircleDefault.swiftUIImage
                            .resizable()
                            .scaledToFit()                            
                    }
                }
                .frame(width: 28, height: 28)
                .padding(.trailing, 14)
                .animation(.default, value: isEditing)
            }
            
            
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
            
            //편집아닐 때 나와야하는 북마크, 메뉴 버튼
            if !isEditing {
                HStack(spacing: 0) {
                    Spacer()
                    SharedAsset.bookmark.swiftUIImage
                        .resizable()
                        .frame(width: 20, height: 20)
                        .scaledToFit()
                        .padding(.trailing, 23)
                    
                    SharedAsset.menu.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .onTapGesture {
                            isPresentBottomSheet = true
                        }
                        .fullScreenCover(isPresented: $isPresentBottomSheet, content: {
                            BottomSheetWrapper(isPresent: $isPresentBottomSheet) {
                                SongBottomSheetView(song: song, types: [.withoutBookmark])
                            }
                            .background(TransparentBackground())
                        })
                }
                .animation(.default, value: isEditing)
              
            }
            
        })
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        
    }
}
