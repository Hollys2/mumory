//
//  RequestFriendListView.swift
//  Feature
//
//  Created by 제이콥 on 3/16/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct MyRequestFriendListView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State var myRequestFriendList: [MumoriUser] = []
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
                    Text("내가 보낸 요청")
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
                        ForEach(myRequestFriendList, id: \.uid){ friend in
                            MyRequestFriendItem(friend: friend)
                        }
                    })
                }
                
            }
        }
        .onTapGesture {
            let query = db.collection("User").document(currentUserData.uid).collection("Friend")
                .whereField("type", isEqualTo: "request")
            Task {
                guard let snapshot = try? await query.getDocuments() else {
                    return
                }
                snapshot.documents.forEach { document in
                    guard let uid = document.data()["uid"] as? String else {
                        return
                    }
                    Task {
                        myRequestFriendList.append(await MumoriUser(uid: uid))
                    }
                }
            }
        }
    }
}


struct MyRequestFriendItem: View {
    let friend: MumoriUser
    init(friend: MumoriUser) {
        self.friend = friend
    }
    let Firebase = FBManager.shared
    @State var isPresentRequestPopup: Bool = false
    
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
                    .frame(width: 55)
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
            
            
            
            Text("친구추가")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .frame(height: 33)
                .background(ColorSet.subGray)
                .clipShape(RoundedRectangle(cornerRadius: 16.5, style: .circular))
                .onTapGesture {
             
                }
        })
        .padding(.horizontal, 20)
        .background(ColorSet.background)
        .frame(height: 84)
    }
}

struct FriendBottomSheet: View {
    var body: some View {
        VStack{
            
        }
    }
}
