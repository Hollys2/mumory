//
//  SearchSongItem.swift
//  Feature
//
//  Created by 제이콥 on 12/4/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct SearchSongItem: View {
    var song: Song
    @State var isPresentBottomSheet: Bool = false
    var body: some View {
        HStack(spacing: 0, content: {
            AsyncImage(url: song.artwork?.url(width: 300, height: 300)) { image in
                image
                    .resizable()
                    .frame(width: 57, height: 57)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)))
            } placeholder: {
                RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                    .frame(width: 57, height: 57)
                    .foregroundStyle(.gray)
            }
            
            VStack(alignment: .leading, spacing: 7, content: {
                Text(song.title)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(song.artistName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(red: 0.72, green: 0.72, blue: 0.72))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
            })
            .frame(maxWidth: .infinity)
            .padding(.leading, 16)
                        
            SharedAsset.menu.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .onTapGesture {
                    UIView.setAnimationsEnabled(false)
                    isPresentBottomSheet.toggle()
                }
         
        })
        .padding(.horizontal, 20)
        .frame(height: 95)
        .background(ColorSet.background)
        .fullScreenCover(isPresented: $isPresentBottomSheet) {
            BottomSheetWrapper(isPresent: $isPresentBottomSheet) {
                SongBottomSheetView(song: song)
            }
            .background(TransparentBackground())
        }
    }
    
    
}

