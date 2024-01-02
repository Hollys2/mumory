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
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(height: 70)
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                        .offset(y: 34.75)
                )
            
            HStack(spacing: 0) {
                Spacer().frame(width: 9)
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 40, height: 40)
                    .background(
                        //                                        Image("PATH_TO_IMAGE")
                        Color.gray
                        //                                            .resizable()
                        //                                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                        //                                            .clipped()
                    )
                    .cornerRadius(6)
                
                Spacer().frame(width: 13)
                
                VStack(spacing: 0) {
                    Text("Cruel Summer")
                        .font(
                            Font.custom("Pretendard", size: 16)
                                .weight(.semibold)
                        )
                        .foregroundColor(.white)
                        .frame(width: 169, alignment: .leading)
                    
                    //                                    Spacer().frame(height: 11)
                    
                    Text("Taylor Swift")
                        .font(Font.custom("Pretendard", size: 14))
                        .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
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
                
                Spacer().frame(width: 10)
            } // HStack
        } // ZStack
    }
}

struct MumoryDetailSameLocationMusicView_Previews: PreviewProvider {
    static var previews: some View {
        MumoryDetailSameLocationMusicView()
    }
}
