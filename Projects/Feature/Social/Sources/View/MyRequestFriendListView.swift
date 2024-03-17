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
                            MyRequestFriendItem(friend: friend, myRequestFriendList: $myRequestFriendList)
                        }
                    })
                }
                
            }
        }
        .onAppear {
            getMyRequestFriendList()
        }
    }
    private func getMyRequestFriendList(){
        let query = db.collection("User").document(currentUserData.uid).collection("Friend")
            .whereField("type", isEqualTo: "request")
        Task {
            guard let snapshot = try? await query.getDocuments() else {
                return
            }
            snapshot.documents.forEach { document in
                guard let uid = document.data()["uId"] as? String else {
                    return
                }
                Task {
                    myRequestFriendList.append(await MumoriUser(uid: uid))
                }
            }
        }
    }
}


struct MyRequestFriendItem: View {
    let friend: MumoriUser
    @Binding var myRequestFriendList: [MumoriUser]
    init(friend: MumoriUser, myRequestFriendList: Binding<[MumoriUser]>) {
        self.friend = friend
        self._myRequestFriendList = myRequestFriendList
    }
    let Firebase = FBManager.shared
    @State var isPresentDeletePopup: Bool = false
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
            TwoButtonPopupView(title: "친구 요청을 취소하시겠습니까?", positiveButtonTitle: "요청 취소") {
                deleteRequest()
            }
            .background(TransparentBackground())
        }
    }
    
    private func deleteRequest() {
        let db = Firebase.db
        let deleteMyQuery = db.collection("User").document(currentUserData.uid).collection("Friend")
            .whereField("uId", isEqualTo: friend.uid)
            .whereField("type", isEqualTo: "request")
        
        let deleteFriendQuery = db.collection("User").document(friend.uid).collection("Friend")
            .whereField("uId", isEqualTo: currentUserData.uid)
            .whereField("type", isEqualTo: "recieve")
        
        Task {
            guard let result = try? await deleteMyQuery.getDocuments() else {
                return
            }
            guard let deleteResult = try? await result.documents.first?.reference.delete() else {
                return
            }
            myRequestFriendList.removeAll(where: {$0.uid == friend.uid})
        }
        Task {
            guard let resultFriend = try? await deleteFriendQuery.getDocuments() else {
                return
            }
            guard let deleteResultFriend = try? await resultFriend.documents.first?.reference.delete() else {
                return
            }
        }
        
        
    }
}

struct FriendBottomSheet: View {
    var body: some View {
        VStack{
            
        }
    }
}
