//
//  MumoryDetailReactionBarView.swift
//  Feature
//
//  Created by 다솔 on 2023/12/27.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Shared

struct MumoryDetailReactionBarView: View {
    
    @State var isOn: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: UIScreen.main.bounds.width, height: 85)
                .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                .overlay(
                    self.isOn ?
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                        .offset(y: -42.75)
                    : Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                        .offset(y: 32.25)
                )
        
            HStack(alignment: .center) {
                Button(action: {
                    
                }, label: {
                    Image(uiImage: SharedAsset.heartButtonMumoryDetail.image)
                        .resizable()
                        .frame(width: 42, height: 42)
                })
                
                Spacer().frame(width: 4)
                
                Text("10")
                    .font(
                        Font.custom("Pretenard", size: 16)
                            .weight(.medium)
                    )
                    .foregroundColor(.white)
                
                Spacer().frame(width: 12)
                
                Button(action: {
                    
                }, label: {
                    Image(uiImage: SharedAsset.commentButtonMumoryDetail.image)
                        .resizable()
                        .frame(width: 42, height: 42)
                })
                
                Spacer().frame(width: 4)
                
                Text("3")
                    .font(
                        Font.custom("Pretendard", size: 16)
                            .weight(.medium)
                    )
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    
                }, label: {
                    Image(uiImage: SharedAsset.shareButtonMumoryDetail.image)
                        .resizable()
                        .frame(width: 42, height: 42)
                })
            }
            .padding(.horizontal, 20)
            .padding(.top, 11)
        }
        .offset(y: self.isOn ? UIScreen.main.bounds.height - 85 : 0)
    }
}

struct MumoryDetailReactionBarVIew_Previews: PreviewProvider {
    static var previews: some View {
        MumoryDetailReactionBarView(isOn: false)
    }
}

