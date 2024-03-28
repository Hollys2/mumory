//
//  RecentMusicCell.swift
//  Feature
//
//  Created by 제이콥 on 11/20/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

public struct RecommendationMusicItem: View {
    let song: Song
    init(song: Song) {
        self.song = song
    }
    public var body: some View {
    
        VStack{
                AsyncImage(url: song.artwork?.url(width: 500, height: 500), content: { image in
                    image
                        .resizable()
                        .frame(width: getUIScreenBounds().width * 0.27, height: getUIScreenBounds().width * 0.27)
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
                  
                }, placeholder: {
                    RoundedRectangle(cornerRadius: 15,style: .circular)
                        .frame(width: getUIScreenBounds().width * 0.27, height: getUIScreenBounds().width * 0.27)
                        .foregroundStyle(ColorSet.skeleton)
                })
            
                
            Text(song.title)
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .frame(width: getUIScreenBounds().width * 0.27, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(.white)
            
            Text(song.artistName)
                .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 14))
                .foregroundStyle(LibraryColorSet.lightGrayTitle)
                .frame(width: getUIScreenBounds().width * 0.27, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)
            
        }

    }
}

struct RecommendationMusicSkeletonView: View {
    @State var startAnimation: Bool = false
    var body: some View {
        VStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 15,style: .circular)
                .fill(startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                .frame(width: getUIScreenBounds().width * 0.27, height: getUIScreenBounds().width * 0.27)
            
            RoundedRectangle(cornerRadius: 5, style: .circular)
                .fill(startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                .frame(width: 91, height: 15)
            
            RoundedRectangle(cornerRadius: 5, style: .circular)
                .fill(startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                .frame(width: 71, height: 11)
            
        }
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: startAnimation)
        .onAppear {
            startAnimation.toggle()
        }
    }
}
