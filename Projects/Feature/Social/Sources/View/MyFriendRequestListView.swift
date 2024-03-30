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
                .frame(height: 65)
                
                Divider05()
                
                if currentUserData.friendRequests.isEmpty {
                    VStack(spacing: 20) {
                        Text("보낸 요청 내역이 없어요")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                            .foregroundStyle(Color.white)
                        
                        Text("친구 요청을 보내면 여기에 표시됩니다.")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                            .foregroundStyle(ColorSet.subGray)
                    }
                    .padding(.top, getUIScreenBounds().height * 0.25)
                }else {
                    ScrollView {
                        LazyVStack(spacing: 0, content: {
                            ForEach(currentUserData.friendRequests, id: \.self){ friend in
                                MyRequestFriendItem(friend: friend)
                            }
                        })
                    }
                    .scrollIndicators(.hidden)
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
                friend.defaultProfileImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
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
            
            
            HStack(spacing: 2) {
                SharedAsset.cancelFriendRequest.swiftUIImage
                    .resizable()
                    .frame(width: 17, height: 17)
                
                Text("요청취소")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                    .foregroundColor(.black)
            }
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
    
    let deleteFriendQuery = db.collection("User").document(friendUId).collection("Friend")
        .whereField("uId", isEqualTo: uId)
    
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
