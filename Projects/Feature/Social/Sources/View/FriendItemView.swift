//
//  FriendItemView.swift
//  Feature
//
//  Created by 제이콥 on 6/18/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct FriendItemView: View {
    
    private let type: SearchFriendType
    
    var friend: FriendSearch
    
    @Binding var isSendFriendRequestPopUpShown: Bool
    @Binding var isAcceptFriendRequestPopUpShown: Bool
    @Binding var isDeleteFriendRequestPopUpShown: Bool
    @Binding var isCancelFriendRequestPopUpShown: Bool
    @Binding var isUnblockFriendPopUpShown: Bool
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    init(type: SearchFriendType,
         friend: FriendSearch,
         isSendFriendRequestPopUpShown: Binding<Bool>,
         isAcceptFriendRequestPopUpShown: Binding<Bool>,
         isDeleteFriendRequestPopUpShown: Binding<Bool>,
         isCancelFriendRequestPopUpShown: Binding<Bool>,
         isUnblockFriendPopUpShown: Binding<Bool>
    ) {
        self.type = type
        self.friend = friend
        _isSendFriendRequestPopUpShown = isSendFriendRequestPopUpShown
        _isAcceptFriendRequestPopUpShown = isAcceptFriendRequestPopUpShown
        _isDeleteFriendRequestPopUpShown = isDeleteFriendRequestPopUpShown
        _isCancelFriendRequestPopUpShown = isCancelFriendRequestPopUpShown
        _isUnblockFriendPopUpShown = isUnblockFriendPopUpShown
    }
    
    var body: some View {
        
        ZStack {
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(height: 84)
            
            HStack(spacing: 0) {
                SharedAsset.profileMumoryDetail.swiftUIImage
                    .resizable()
                    .frame(width: 50, height: 50)
                
                Spacer().frame(width: 15)
                
                VStack(spacing: 5) {
                    
                    Text(friend.nickname)
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    (Text("@") + Text(friend.id))
                        .font(SharedFontFamily.Pretendard.extraLight.swiftUIFont(size: 13))
                        .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                
                Spacer()
                
                switch type {
                case .addFriend:
                    Button(action: {
                        self.isSendFriendRequestPopUpShown = true
                    }) {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 96, height: 33)
                                .background(Color(red: 0.64, green: 0.51, blue: 0.99))
                                .cornerRadius(16.5)
                            
                            
                            HStack(spacing: 0) {
                                SharedAsset.friendIconSocial.swiftUIImage
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                
                                Text("친구추가")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                case .requestFriend:
                    Button(action: {
                        self.isAcceptFriendRequestPopUpShown = true
                    }) {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 81.92771, height: 33)
                                .background(Color(red: 0.64, green: 0.51, blue: 0.99))
                                .cornerRadius(16.5)
                            
                            Text("수락")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                                .foregroundColor(.black)
                        }
                    }
                    
                    Spacer().frame(width: 6.14)
                    
                    Button(action: {
                        self.isDeleteFriendRequestPopUpShown = true
                    }) {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 81.92771, height: 33)
                                .background(Color(red: 0.47, green: 0.47, blue: 0.47))
                                .cornerRadius(16.5)
                            
                            Text("삭제")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                                .foregroundColor(.black)
                        }
                    }
                case .cancelRequestFriend:
                    Button(action: {
                        self.isCancelFriendRequestPopUpShown = true
                    }) {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 77, height: 33)
                                .background(Color(red: 0.47, green: 0.47, blue: 0.47))
                                .cornerRadius(16.5)
                            
                            Text("요청취소")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                                .foregroundColor(.black)
                        }
                    }
                case .unblockFriend:
                    Button(action: {
                        self.isUnblockFriendPopUpShown = true
                    }) {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 77, height: 33)
                                .background(Color(red: 0.47, green: 0.47, blue: 0.47))
                                .cornerRadius(16.5)
                            
                            Text("차단해제")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            
        }
        .padding(.horizontal, 20)
    }
}
