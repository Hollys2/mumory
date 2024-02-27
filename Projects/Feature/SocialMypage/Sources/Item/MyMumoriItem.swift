//
//  MyMumoriItem.swift
//  Feature
//
//  Created by 제이콥 on 2/25/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct MyMumoriItem: View {
    var body: some View {
            VStack(spacing: 0, content: {
                AsyncImage(url: URL(string: "https://upload.wikimedia.org/wikipedia/en/f/f7/Usher_-_Confessions_album_cover.png")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 170, height: 170)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
                    
                } placeholder: {
                    RoundedRectangle(cornerRadius: 10, style: .circular)
                        .frame(width: 170, height: 170)

                }
                .overlay {
                    Text("10월 4일")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                        .foregroundStyle(Color.white)
                        .frame(height: 20)
                        .padding(.horizontal, 10)
                        .overlay {
                            RoundedRectangle(cornerRadius: 35, style: .circular)
                                .stroke(Color.white, lineWidth: 1)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(11)
                    
                    SharedAsset.lockPurple.swiftUIImage
                        .resizable()
                        .frame(width: 21, height: 21)
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(11)
                    
                    HStack(spacing: 4, content: {
                        SharedAsset.locationMumoryPopup.swiftUIImage
                            .resizable()
                            .frame(width: 18, height: 18)
                            .scaledToFit()
                        
                        Text("망원 한강 공원")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    })
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(11)
                    
                }

            })
    }
}

#Preview {
    MyMumoriItem()
}