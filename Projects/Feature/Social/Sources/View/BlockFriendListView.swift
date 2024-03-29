//
//  RequestFriendListView.swift
//  Feature
//
//  Created by 제이콥 on 3/16/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct BlockFriendListView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var appCoordinator: AppCoordinator
    let db = FBManager.shared.db
    var body: some View {
        ZStack(alignment: .top) {
            ColorSet.background.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack{
                    SharedAsset.back.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            appCoordinator.rootPath.removeLast()
                        }
                    Spacer()
                    Text("차단친구 관리")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    Spacer()
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 30, height: 30)
                }
                .padding(.horizontal, 20)
                .frame(height: 65)
                
                Divider05()
                
                ScrollView {
                    LazyVStack(spacing: 0, content: {
                        ForEach(currentUserData.blockFriends, id: \.uId){ friend in
                            BlockFriendItem(friend: friend)
                        }
                    })
                }
                
            }
        }

    }
}


struct BlockFriendItem: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @State var isPresentRequestPopup: Bool = false
    let Firebase = FBManager.shared
    let friend: MumoriUser
    init(friend: MumoriUser) {
        self.friend = friend
    }
    
    var body: some View {
        HStack(spacing: 13, content: {
            AsyncImage(url: friend.profileImageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .fill(ColorSet.darkGray)
                    .frame(width: 50)
            }
            
            VStack(alignment: .leading, spacing: 1, content: {
                Text(friend.nickname)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                    .foregroundStyle(Color.white)
                
                Text("@\(friend.id)")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                    .foregroundStyle(ColorSet.charSubGray)
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            
            
            
            Text("차단해제")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .frame(height: 33)
                .background(ColorSet.subGray)
                .clipShape(RoundedRectangle(cornerRadius: 16.5, style: .circular))
                .onTapGesture {
                    let query = Firebase.db.collection("User").document(currentUserData.uId)
                    query.updateData(["blockFriends": FBManager.Fieldvalue.arrayRemove([self.friend.uId])])
                }
        })
        .padding(.horizontal, 20)
        .frame(height: 84)
        .background(ColorSet.background)
    }
}

