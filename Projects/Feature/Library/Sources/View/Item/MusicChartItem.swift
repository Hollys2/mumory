//
//  MusicChartItem.swift
//  Feature
//
//  Created by 제이콥 on 11/22/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct MusicChartItem: View {
    var rank: Int
    let title = "타이틀"
    let artist = "아티스트"
    var song: Song
    @State var isBottomSheerPresent: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16){
                AsyncImage(url: song.artwork?.url(width: 300, height: 300), content: { image in
                    image
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5), style: .circular))
                }, placeholder: {
                    RoundedRectangle(cornerRadius: 5, style: .circular)
                        .foregroundStyle(.gray)
                        .frame(width: 40, height: 40)

                })
                
                Text(String(format: "%02d", rank))
                    .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                    .foregroundStyle(LibraryColorSet.purpleBackground)
                
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
                
                SharedAsset.menu.swiftUIImage
                    .resizable()
                    .frame(width: 22, height: 22)
                    .padding(.trailing, 15)
                    .onTapGesture {
                        UIView.setAnimationsEnabled(true)
                        isBottomSheerPresent = true
                    }
                    .fullScreenCover(isPresented: $isBottomSheerPresent, content: {
                        LibraryBottomSheetView {
                            BottomSheet(song: song)
                        }
                        .background(TransparentBackground())
                    })
            }
            .padding(.top, 15)
            .padding(.bottom, 15)
            
            Divider()
                .frame(maxWidth: .infinity)
                .frame(height: 0.5)
                .background(ColorSet.subGray)
                .opacity(rank%4 == 0 ? 0 : 1)
        }
        .padding(.leading, 20)
       
        }

}

private struct BottomSheet: View {
    private let lineGray = Color(red: 0.28, green: 0.28, blue: 0.28)
    var song: Song
    var body: some View {
     
            VStack(spacing: 0, content: {
                HStack(alignment: .center,spacing: 0,content: {
                    AsyncImage(url: song.artwork?.url(width: 300, height: 300)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 5, style: .circular)
                            .frame(width: 60, height: 60)
                            .foregroundStyle(ColorSet.lightGray)
                            .padding(.trailing, 13)
                    }
                    .padding(.trailing, 13)

                    
                    VStack(alignment: .leading, spacing: 5, content: {
                        Text(song.title)
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundStyle(.white)
                            .truncationMode(.tail)
                        
                        Text(song.artistName)
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                            .foregroundStyle(ColorSet.charSubGray)
                            .truncationMode(.tail)
                    })
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    SharedAsset.next.swiftUIImage
                        .resizable()
                        .frame(width: 26, height: 26)
                        .padding(.leading, 20)
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                
                Divider()
                    .frame(maxWidth: .infinity)
                    .frame(height: 0.5)
                    .background(lineGray)
                    .padding(.horizontal, 4)
                
                BottomSheetItem(image: SharedAsset.artist.swiftUIImage, title: "아티스트 노래 목록 보기")
                BottomSheetItem(image: SharedAsset.bookmark.swiftUIImage, title: "즐겨찾기 목록에 추가")
                BottomSheetItem(image: SharedAsset.addPurple.swiftUIImage, title: "뮤모리 추가")
                BottomSheetItem(image: SharedAsset.addPlaylist.swiftUIImage, title: "플레이리스트에 추가")
                BottomSheetItem(image: SharedAsset.share.swiftUIImage, title: "공유하기")
                BottomSheetItem(image: SharedAsset.report.swiftUIImage, title: "신고")
                
            })
            .padding(.bottom, 15)
            .background(ColorSet.background)
        }
    
}

//#Preview {
//    BottomSheet()
//}
