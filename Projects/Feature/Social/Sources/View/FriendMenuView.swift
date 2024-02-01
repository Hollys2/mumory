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
            .font(
                Font.custom("Pretendard", size: 18)
                    .weight(.semibold)
            )
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
    }
}


struct FriendMenuView: View {
    
    @State private var type: SearchFriendType
    
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
                    FriendItemView(type: .cancelRequestFriend)
                case .unblockFriend:
                    FriendItemView(type: .unblockFriend)
                }
            }
        }
        .background(Color(red: 0.09, green: 0.09, blue: 0.09))
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
    }
}




//struct RequestFriendView_Previews: PreviewProvider {
//    static var previews: some View {
//        FriendMenuView(type: .addFriend)
//            .environmentObject(AppCoordinator())
//    }
//}
