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
    
    @Binding var mumoryAnnotation: Mumory
    
    @State var isOn: Bool
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject private var mumoryDataViewModel: MumoryDataViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: UIScreen.main.bounds.width, height: 64 + appCoordinator.safeAreaInsetsBottom)
                .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                        .offset(y: self.isOn ? -(64 + appCoordinator.safeAreaInsetsBottom + 0.5) / 2 : 21.25 + 22)
                )
        
            HStack(alignment: .center) {
                Button(action: {
                    mumoryDataViewModel.likeMumory(mumoryAnnotation: self.mumoryAnnotation, loginUserID: "tester")
                }, label: {
                    mumoryAnnotation.likes.contains("tester") ?
                    Image(uiImage: SharedAsset.heartOnButtonMumoryDetail.image)
                        .resizable()
                        .frame(width: 42, height: 42)
                    : Image(uiImage: SharedAsset.heartOffButtonMumoryDetail.image)
                        .resizable()
                        .frame(width: 42, height: 42)
                })
                
                Spacer().frame(width: 4)
                
                Text("\(mumoryAnnotation.likes.count)")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .foregroundColor(.white)
                
                Spacer().frame(width: 12)
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.appCoordinator.isMumoryDetailCommentSheetViewShown = true
                    }
                }, label: {
                    Image(uiImage: SharedAsset.commentButtonMumoryDetail.image)
                        .resizable()
                        .frame(width: 42, height: 42)
                })
                
                Spacer().frame(width: 4)
                
                Text("\(mumoryAnnotation.comments.count)")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
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
        .offset(y: self.isOn ? UIScreen.main.bounds.height - 64 - appCoordinator.safeAreaInsetsBottom : 0)
    }
}

