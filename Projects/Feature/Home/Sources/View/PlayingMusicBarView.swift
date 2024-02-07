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
        Rectangle()
            .foregroundColor(.clear)
            .frame(width: getUIScreenBounds().width - 30, height: 53)
            .overlay(
                HStack {
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
                    
                    VStack(alignment: .leading) {
//                        Text("제목")
//                            .font(.headline)
//                            .foregroundColor(.white)
//                        Text("가수")
//                            .font(.subheadline)
//                            .foregroundColor(.white)
                        Text("재생 중인 음악이 없습니다.")
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 11))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Image(uiImage: SharedAsset.playButtonTopbar.image)
                    
                    Rectangle()
                      .foregroundColor(.clear)
                      .frame(width: 0.5, height: 35)
                      .background(Color(red: 0.52, green: 0.52, blue: 0.52))
                    
                    Image(uiImage: SharedAsset.profileTopbar.image)
                }
                    .padding()
            )
            .background(.black.opacity(0.95))
            .cornerRadius(20)
    }
}

//struct PlayingMusicBarVIew_Previews: PreviewProvider {
//    static var previews: some View {
//        PlayingMusicBarVIew()
//    }
//}
