//
//  PlayingMusicBarView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/17.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Shared

public struct PlayingMusicBarView: View {
    
    public init() {}
    
    public var body: some View {
        
        ZStack {
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(height: 53)
                .background(.black.opacity(0.95))
                .cornerRadius(20)
            
            HStack(spacing: 0) {
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 31, height: 31)
                    .background(
                        Image(uiImage: SharedAsset.albumTopbar.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 31, height: 31)
                            .clipped()
                    )
                    .cornerRadius(5)
                
                //                        Text("제목")
                //                            .font(.headline)
                //                            .foregroundColor(.white)
                //                        Text("가수")
                //                            .font(.subheadline)
                //                            .foregroundColor(.white)
                Text("재생 중인 음악이 없습니다.")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 11))
                    .foregroundColor(.white)
                    .padding(.leading, 13)
                
                Spacer()
                
                Image(uiImage: SharedAsset.playButtonTopbar.image)
                    .resizable()
                    .frame(width: 24, height: 24)
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 0.5, height: 35)
                    .background(Color(red: 0.52, green: 0.52, blue: 0.52))
                    .padding(.leading, 20)
                
                Image(uiImage: SharedAsset.profileTopbar.image)
                    .resizable()
                    .frame(width: 31, height: 31)
                    .padding(.leading, 17)
            }
                .padding(.leading, 15)
                .padding(.trailing, 11)
        }
        .frame(width: getUIScreenBounds().width - 30)
    }
}

//struct PlayingMusicBarVIew_Previews: PreviewProvider {
//    static var previews: some View {
//        PlayingMusicBarVIew()
//    }
//}
