//
//  RequestFriendListView.swift
//  Feature
//
//  Created by 제이콥 on 3/16/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct MyFriendRequestListView: View {
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
                
                Divider05()
                
                ScrollView {
                    LazyVStack(spacing: 0, content: {
                        ForEach(currentUserData.friendRequests, id: \.self){ friend in
                            MyRequestFriendItem(friend: friend)
                        }
                    })
                }
                
            }
        }

    }

}


public struct MyRequestFriendItem: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @State var isPresentDeletePopup: Bool = false
    var friend: MumoriUser
    public init(friend: MumoriUser) {
        self.friend = friend
    }
    let Firebase = FBManager.shared
    
    public var body: some View {
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
            
            
            
            Text("요청 취소")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .frame(height: 33)
                .background(ColorSet.subGray)
                .clipShape(RoundedRectangle(cornerRadius: 16.5, style: .circular))
                .onTapGesture {
                    UIView.setAnimationsEnabled(false)
                    isPresentDeletePopup = true
                }
        })
        .padding(.horizontal, 20)
        .background(ColorSet.background)
        .frame(height: 84)
        .fullScreenCover(isPresented: $isPresentDeletePopup) {
            TwoButtonPopupView(title: "친구 요청을 취소하시겠습니까?", positiveButtonTitle: "요청취소") {
                Task {
                    guard let result = await deleteFriendRequest(uId: currentUserData.uId, friendUId: friend.uId) else {
                        return
                    }
                    currentUserData.friendRequests.removeAll(where: {$0.uId == friend.uId})
                }
            }
            .background(TransparentBackground())
        }

    }
}

public func deleteFriendRequest(uId: String, friendUId: String) async -> Bool?{
    let db = FBManager.shared.db
    
    let deleteMyQuery = db.collection("User").document(uId).collection("Friend")
        .whereField("uId", isEqualTo: friendUId)
        .whereField("type", isEqualTo: "request")
    
    let deleteFriendQuery = db.collection("User").document(friendUId).collection("Friend")
        .whereField("uId", isEqualTo: uId)
        .whereField("type", isEqualTo: "recieve")
    
    guard let result = try? await deleteMyQuery.getDocuments() else {
        return nil
    }
    guard let deleteResult = try? await result.documents.first?.reference.delete() else {
        return nil
    }
    guard let resultFriend = try? await deleteFriendQuery.getDocuments() else {
        return nil
    }
    guard let deleteResultFriend = try? await resultFriend.documents.first?.reference.delete() else {
        return nil
    }
    return true
}
