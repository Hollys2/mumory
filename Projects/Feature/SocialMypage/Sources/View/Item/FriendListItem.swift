//
//  FriendListItem.swift
//  Feature
//
//  Created by 제이콥 on 3/6/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct FriendListItem: View {
    let friend: UserProfile
    @EnvironmentObject var currentUserData: CurrentUserViewModel
    @State var isPresentBottomSheet: Bool = false
    @State var isPresentBlockConfirmPopup: Bool = false
    @State var isPresentDeleteConfirmPopup: Bool = false
    
    init(friend: UserProfile) {
        self.friend = friend
    }
    
    var body: some View {
        HStack(spacing: 13, content: {
            AsyncImage(url: friend.profileImageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
            } placeholder: {
                friend.defaultProfileImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 1, content: {
                Text(friend.nickname)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(Color.white)
                
                Text("@\(friend.id)")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                    .foregroundStyle(ColorSet.charSubGray)
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            
            SharedAsset.menu.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .onTapGesture {
                    UIView.setAnimationsEnabled(false)
                    isPresentBottomSheet.toggle()
                }
        })
        .padding(.horizontal, 20)
        .background(ColorSet.background)
        .frame(height: 79)
        .fullScreenCover(isPresented: $isPresentBottomSheet, content: {
            BottomSheetDarkGrayWrapper(isPresent: $isPresentBottomSheet) {
                FriendDeleteBlockBottomSheetView(friend: friend,
                                                 isPresentBlockConfirmPopup: $isPresentBlockConfirmPopup,
                                                 isPresentDeleteConfirmPopup: $isPresentDeleteConfirmPopup)
                
            }
            .background(TransparentBackground())
        })
        .fullScreenCover(isPresented: $isPresentBlockConfirmPopup, content: {
            TwoButtonPopupView(title: "\(friend.nickname)님을 차단하시겠습니까?", subTitle: "차단 관리는 친구 추가 > 메뉴 >\n차단친구 관리 페이지에서 관리할 수 있습니다.", positiveButtonTitle: "차단") {
                blockFriend(uId: currentUserData.uId, friendUId: friend.uId)
            }
            .background(TransparentBackground())
        })
        .fullScreenCover(isPresented: $isPresentDeleteConfirmPopup, content: {
            TwoButtonPopupView(title: "\(friend.nickname)님과 친구를 끊겠습니까?", positiveButtonTitle: "친구 끊기") {
                deleteFriend(uId: currentUserData.uId, friendUId: friend.uId)
            }
        })
    }
}

