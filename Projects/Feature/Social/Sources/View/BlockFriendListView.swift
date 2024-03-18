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
    @State var blockFriendList: [MumoriUser] = []
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
                .frame(height: 77)
                
                Divider()
                    .frame(maxWidth: .infinity)
                    .frame(height: 0.5)
                    .background(ColorSet.subGray)
                
                ScrollView {
                    LazyVStack(spacing: 0, content: {
                        ForEach(blockFriendList, id: \.uid){ friend in
                            BlockFriendItem(friend: friend, blockFriendList: $blockFriendList)
                        }
                    })
                }
                
            }
        }
        .onAppear {
            getBlockFriendList()
        }
    }
    
    private func getBlockFriendList() {
        let query = db.collection("User").document(currentUserData.uid)
        Task {
            guard let data = try? await query.getDocument().data() else {
                return
            }
            guard let blockFriends = data["blockFriends"] as? [String] else {
                return
            }
            blockFriends.forEach { uid in
                Task{
                    self.blockFriendList.append(await MumoriUser(uid: uid))
                }
            }
        }
    }
}


struct BlockFriendItem: View {
    let friend: MumoriUser
    @Binding var blockFriendList: [MumoriUser]
    init(friend: MumoriUser, blockFriendList: Binding<[MumoriUser]>) {
        self.friend = friend
        self._blockFriendList = blockFriendList
    }
    let Firebase = FBManager.shared
    @State var isPresentRequestPopup: Bool = false
    @EnvironmentObject var currentUserData: CurrentUserData
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
                    .font(SharedFontFamily.Pretendard.thin.swiftUIFont(size: 13))
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
                    let query = Firebase.db.collection("User").document(currentUserData.uid)
                    query.updateData(["blockFriends": FBManager.Fieldvalue.arrayRemove([self.friend.uid])])
                    self.blockFriendList.removeAll(where: {$0.uid == self.friend.uid})
                }
        })
        .padding(.horizontal, 20)
        .background(ColorSet.background)
        .frame(height: 84)
    }
}

