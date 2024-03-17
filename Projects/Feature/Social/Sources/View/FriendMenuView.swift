//
//  FriendMenuView.swift
//  Feature
//
//  Created by 다솔 on 2024/01/09.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import Shared


struct TopBarTitleView: View {
    
    let title: String
    
    var body: some View {
        Text(title)
            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
    }
}


struct FriendMenuView: View {
    
    @State private var type: SearchFriendType
    
    @State private var isSendFriendRequestPopUpShown: Bool = false
    @State private var isAcceptFriendRequestPopUpShown: Bool = false
    @State private var isDeleteFriendRequestPopUpShown: Bool = false
    @State private var isCancelFriendRequestPopUpShown: Bool = false
    @State private var isUnblockFriendPopUpShown: Bool = false
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    init(type: SearchFriendType) {
        self.type = type
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Spacer().frame(height: self.appCoordinator.safeAreaInsetsTop + 19)
                
                HStack(spacing: 0) {
                    Button(action: {
                        self.appCoordinator.rootPath.removeLast()
                    }, label: {
                        SharedAsset.backButtonTopBar.swiftUIImage
                            .frame(width: 30, height: 30)
                        
                    })
                    
                    Spacer()
                    
                    switch type {
                    case .addFriend:
                        EmptyView()
                    case .requestFriend:
                        EmptyView()
                    case .cancelRequestFriend:
                        TopBarTitleView(title: "내가 보낸 요청")
                    case .unblockFriend:
                        TopBarTitleView(title: "차단친구 관리")
                    }
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 30, height: 30)
                }
                
                Spacer().frame(height: 28)
            }
            .padding(.horizontal, 20)
            .overlay(
                Rectangle()
                    .fill(Color(red: 0.65, green: 0.65, blue: 0.65))
                    .frame(height: 0.5)
                , alignment: .bottom
            )
            
            
            ScrollView {
                switch type {
                case .addFriend:
                    EmptyView()
                case .requestFriend:
                    EmptyView()
                case .cancelRequestFriend:
                    FriendItemView(type: .cancelRequestFriend, friend: FriendSearch(nickname: "", id: ""), isSendFriendRequestPopUpShown: self.$isSendFriendRequestPopUpShown, isAcceptFriendRequestPopUpShown: self.$isAcceptFriendRequestPopUpShown, isDeleteFriendRequestPopUpShown: self.$isDeleteFriendRequestPopUpShown, isCancelFriendRequestPopUpShown: self.$isCancelFriendRequestPopUpShown, isUnblockFriendPopUpShown: self.$isUnblockFriendPopUpShown)
                case .unblockFriend:
                    FriendItemView(type: .unblockFriend, friend: FriendSearch(nickname: "", id: ""), isSendFriendRequestPopUpShown: self.$isSendFriendRequestPopUpShown, isAcceptFriendRequestPopUpShown: self.$isAcceptFriendRequestPopUpShown, isDeleteFriendRequestPopUpShown: self.$isDeleteFriendRequestPopUpShown, isCancelFriendRequestPopUpShown: self.$isCancelFriendRequestPopUpShown, isUnblockFriendPopUpShown: self.$isUnblockFriendPopUpShown)
                }
            }
        }
        .background(Color(red: 0.09, green: 0.09, blue: 0.09))
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
        .popup(show: self.$isCancelFriendRequestPopUpShown, content: {
            PopUpView(isShown: self.$isCancelFriendRequestPopUpShown, type: .twoButton, title: "친구 요청을 취소하시겠습니까?", buttonTitle: "요청 취소", buttonAction: {

            })
        })
        .popup(show: self.$isUnblockFriendPopUpShown, content: {
            PopUpView(isShown: self.$isUnblockFriendPopUpShown, type: .twoButton, title: "차단을 해제 하시겠습니까?", buttonTitle: "차단 해제", buttonAction: {

            })
        })
    }
}
