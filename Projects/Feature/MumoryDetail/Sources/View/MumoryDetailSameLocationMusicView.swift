//
//  MumoryDetailSameLocationMusicView.swift
//  Feature
//
//  Created by 다솔 on 2023/12/28.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Shared

struct MumoryDetailSameLocationMusicView: View {
    
    let mumory: Mumory
    
    var body: some View {
        ZStack {
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: getUIScreenBounds().width - 40, height: 70)
                .overlay(
                    Rectangle()
                        .fill(Color(red: 0.651, green: 0.651, blue: 0.651, opacity: 0.502))
                        .frame(height: 0.5)
                    , alignment: .bottom
                )
            
            HStack(spacing: 0) {
                
                AsyncImage(url: self.mumory.musicModel.artworkUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                    default:
                        Color(red: 0.184, green: 0.184, blue: 0.184)
                    }
                }
                
                .frame(width: 40, height: 40)
                .cornerRadius(6)
                
                Spacer().frame(width: 13)
                
                VStack(spacing: 0) {
                    
                    Text("\(mumory.musicModel.title)")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .frame(width: 169, alignment: .leading)
                    
                    Text("\(mumory.musicModel.artist)")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                        .lineLimit(1)
                        .lineLimit(1)
                        .frame(width: 169, alignment: .leading)
                }
                
                Spacer()
                
                Button(action: {}, label: {
                    SharedAsset.bookmarkOffMumoryDatail.swiftUIImage
                        .resizable()
                        .frame(width: 20, height: 20)
                })
                
                Spacer().frame(width: 29)
                
                Button(action: {}, label: {
                    SharedAsset.musicMenuMumoryDatail.swiftUIImage
                        .resizable()
                        .frame(width: 20, height: 20)
                })
            } // HStack
        } // ZStack
    }
}
