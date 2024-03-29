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
                        .fill(ColorSet.skeleton)
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
                        UIView.setAnimationsEnabled(false)
                        isBottomSheerPresent = true
                    }
                    .fullScreenCover(isPresented: $isBottomSheerPresent, content: {
                        BottomSheetWrapper(isPresent: $isBottomSheerPresent) {
                            SongBottomSheetView(song: song)
                        }
                        .background(TransparentBackground())
                    })
            }
            .frame(height: 70)
            .background(ColorSet.background)
//            .onLongPressGesture {
//                self.generateHapticFeedback(style: .medium)
//                UIView.setAnimationsEnabled(false)
//                isBottomSheerPresent = true
//            }

            Divider05()
                .opacity(rank%4 == 0 ? 0 : 1)
        }
        .padding(.leading, 20)
        .frame(width: getUIScreenBounds().width * 0.9)

    }
}

struct MusicChartSkeletonView: View {
    @State var startAnimation: Bool = false
    var lineVisible: Bool = true
    init(lineVisible: Bool) {
        self.lineVisible = lineVisible
    }
    init(){}
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 5, style: .circular)
                    .fill(startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                    .frame(width: 40, height: 40)
                
                RoundedRectangle(cornerRadius: 5, style: .circular)
                    .fill(startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                    .frame(width: 19, height: 20)
                
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
            .frame(height: 70)

            Divider05()
                .opacity(lineVisible ? 1 : 0)
        }
        .padding(.leading, 20)
        .frame(width: getUIScreenBounds().width * 0.9)
        .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: startAnimation)
        .onAppear {
            startAnimation.toggle()
        }
    }
}


