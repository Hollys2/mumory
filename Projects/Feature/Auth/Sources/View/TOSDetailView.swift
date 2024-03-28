//
//  TOSDetailView.swift
//  Feature
//
//  Created by 제이콥 on 3/22/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct TOSDetailView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            VStack(spacing: 0, content: {
                //상단바
                HStack(content: {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 30, height: 30)
                    Spacer()

                    Text("이용약관")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundStyle(Color.white)
                    Spacer()

                    SharedAsset.xWhite.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            dismiss()
                        }
             
                })
                .padding(.horizontal, 20)
                .frame(height: 63)
                
                ScrollView {
                    AsyncImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/music-app-62ca9.appspot.com/o/Admin%2FtosImage.png?alt=media&token=1cb513a0-3c29-4130-86fc-ada1ee577e36")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Rectangle()
                            .fill(ColorSet.background)
                    }

                }

         
            })
        }
    }
}



