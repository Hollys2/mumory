//
//  FriendPageView.swift
//  Feature
//
//  Created by 제이콥 on 3/8/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core
import MusicKit
import _MapKit_SwiftUI

struct FriendPageView: View {
    @EnvironmentObject var friendDataViewModel: FriendDataViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserData: CurrentUserData
    @State var isStranger: Bool = true
    @State var isPresentFriendBottomSheet: Bool = false
    @State var isPresentBlockConfirmPopup: Bool = false
    
    @State var friend: MumoriUser
    
    init(friend: MumoriUser) {
        self._friend = .init(initialValue: friend)
    }
    
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background
            
            //친구 여부에 따라 친구 페이지 혹은 모르는 사람 페이지 띄우기
            if currentUserData.getFriendStatus(friend: friend) == .friend{
                KnownFriendPageView(friend: friend)
                    .environmentObject(friendDataViewModel)
            }else {
                UnkownFriendPageView(friend: friend)
                
            }
            
            //상단바
            HStack{
                SharedAsset.back.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        appCoordinator.rootPath.removeLast()
                    }
                
                Spacer()
                
                SharedAsset.menuGradient.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        UIView.setAnimationsEnabled(false)
                        isPresentFriendBottomSheet.toggle()
                    }
            }
            .padding(.horizontal, 20)
            .frame(height: 65)
            .padding(.top, currentUserData.topInset)
        }
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $isPresentFriendBottomSheet, content: {
            BottomSheetDarkGrayWrapper(isPresent: $isPresentFriendBottomSheet) {
                FriendPageCommonBottomSheetView(friend: self.friend, isPresentBlockConfirmPopup: $isPresentBlockConfirmPopup)
            }
            .background(TransparentBackground())
        })
        .onAppear(perform: {
            Task {
                self.friend = await MumoriUser(uId: self.friend.uId)
            }
        })
    }
}

struct KnownFriendPageView: View {
    let friend: MumoriUser
    let lineGray = Color(white: 0.37)
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var friendDataViewModel: FriendDataViewModel
    @State private var isMapViewShown: Bool = false
    @State private var mumorys: [Mumory] = []
    @State private var firstMumory: Mumory = Mumory()
    @State private var isLoading: Bool = true
    @State private var playlists: [MusicPlaylist] = []
    @State private var isPlaylistLoading: Bool = true
    init(friend: MumoriUser) {
        self.friend = friend
    }
    
    var body: some View {
        ScrollView{
            VStack(spacing: 0, content: {
                //구성: 프로필 뷰, 맵뷰, 뮤모리뷰, 플레이리스트뷰
                
                //친구 프로필 뷰
                FriendInfoView(friend: friend)
                    .environmentObject(friendDataViewModel)
                
                Divider05()
                
                //맵뷰
                ZStack {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(maxWidth: .infinity)
                        .frame(height: 195)
       
                    FriendMapViewRepresentable(friendMumorys: self.mumorys)
                        .frame(width: getUIScreenBounds().width - 40, height: 129)
                        .cornerRadius(10)
                    
                    SharedAsset.enlargeMapButton.swiftUIImage
                        .resizable()
                        .frame(width: 30, height: 30)
                        .offset(x: (getUIScreenBounds().width - 40) / 2 - 14 - 12, y: -(129 / 2) + 14 + 12 )
                        .onTapGesture {
                            self.isMapViewShown = true
                        }
                }
                
                Divider05()
                
                FriendMumoryView(mumorys: $mumorys)
                    .environmentObject(friendDataViewModel)
                
                Divider05()
                
                FriendPlaylistView()
                    .environmentObject(friendDataViewModel)
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 110)
            })
        }
        .scrollIndicators(.hidden)
        .fullScreenCover(isPresented: $isMapViewShown) {
            FriendMumoryMapView(isShown: self.$isMapViewShown, mumorys: self.mumorys, user: self.friend, isFriendPage: true)
        }
        .onAppear {
            friendDataViewModel.isPlaylistLoading = true
            friendDataViewModel.isMumoryLoading = true
            
            self.mumoryDataViewModel.fetchMumorys(uId: self.friend.uId) { result in
                
                switch result {
                case .success(let mumorys):
                    let friendMumorys = mumorys.filter { $0.isPublic == true }
                    if !friendMumorys.isEmpty, let firstMumory = friendMumorys.first {
                        self.firstMumory = firstMumory
                    }
                    self.mumorys = friendMumorys
                    
                    DispatchQueue.main.async {
                        mumoryDataViewModel.friendMumorys = friendMumorys
                        mumoryDataViewModel.isUpdating = false
                        friendDataViewModel.isMumoryLoading = false
                    }
                case .failure(let err):
                    print("ERROR: \(err)")
                }
            }
            
            Task {
                friendDataViewModel.friend = await MumoriUser(uId: friend.uId)
                friendDataViewModel.playlistArray = await friendDataViewModel.savePlaylist(uId: friend.uId)
                friendDataViewModel.isPlaylistLoading = false
            }
        }
    }
}


struct UnkownFriendPageView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @State var isPresentPopup: Bool = false
    @State var isRequested: Bool = false
    @State var myRequestList: [String] = []//이미 요청한 친구 uid배열
    @State var status: FriendRequestStatus = .normal
    let friend: MumoriUser
    let secretId: String
    let secretNickname: String
    init(friend: MumoriUser) {
        self.friend = friend
        secretId = friend.id.isEmpty ? "*******" : String(friend.id.prefix(2)) + String(repeating: "*", count: friend.id.count-2)
        secretNickname = friend.nickname.isEmpty ? "*******" : String(friend.nickname.prefix(2)) + String(repeating: "*", count: friend.nickname.count-2)
    }
    
    var body: some View {
        ZStack(alignment: .top){
            VStack(spacing: 0, content: {
                UnknownFriendInfoView
                UnknownFriendContentView
                    .padding(.top, getUIScreenBounds().height * 0.1)
            })
        }
        .onAppear{
            getMyRequestList()
        }
    }
    
    //상단 친구 인포메이션 - 배경사진, 프로필사진, 닉네임, 아이디 등
    var UnknownFriendInfoView: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0, content: {
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(width: getUIScreenBounds().width)
                    .frame(height: 165)
                    .foregroundStyle(ColorSet.darkGray)
                    .overlay {
                        LinearGradient(colors: [ColorSet.background.opacity(0.8), Color.clear], startPoint: .top, endPoint: .init(x: 0.5, y: 0.76))
                    }
                
                VStack(alignment: .leading, spacing: 4, content: {
                    Text(secretNickname)
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 24))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)
                    
                    Text("@\(secretId)")
                        .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 16))
                        .foregroundStyle(ColorSet.charSubGray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    //자기소개 안보이게
                    Text("")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundStyle(ColorSet.subGray)
                        .frame(height: 52, alignment: .bottom)
                        .padding(.bottom, 18)
                })
                .overlay {
                    friend.defaultProfileImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 90, height: 90)
                        .clipShape(Circle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .offset(y: -40)
                }
                .padding(.horizontal, 20)
                
                HStack(spacing: 4, content: {
                    
                    switch currentUserData.getFriendStatus(friend: friend) {
                    case .notFriend:
                        SharedAsset.addFriend.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                        
                        Text("친구 추가")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundStyle(ColorSet.background)
                        
                    case .alreadySendRequest:
                        SharedAsset.cancelFriendRequest.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                        
                        Text("요청취소")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundStyle(ColorSet.background)
                        
                    case .alreadyRecieveRequest:
                        SharedAsset.acceptFriend.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                        
                        Text("친구요청 수락")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundStyle(ColorSet.background)
                        
                    case .block:
                        SharedAsset.blockFriend.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                        
                        Text("차단 해제")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundStyle(ColorSet.background)
                        
                    default: EmptyView()
                    }
                    
                })
                .frame(maxWidth: .infinity)
                .frame(height: 45)
                .background(currentUserData.getFriendStatus(friend: friend) == .block ?
                            ColorSet.subGray : currentUserData.getFriendStatus(friend: friend) == .alreadySendRequest ?
                            ColorSet.charSubGray : ColorSet.mainPurpleColor)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
                .padding(.horizontal, 20)
                .padding(.bottom, 22)
                .onTapGesture {
                    UIView.setAnimationsEnabled(false)
                    isPresentPopup.toggle()
                    
                }
                
                Divider10()

            })

        }
        .disabled(status == .friendProcessLoading)
        .fullScreenCover(isPresented: $isPresentPopup, content: {
            PopupView
                .background(TransparentBackground())
        })
        .overlay {
            if status == .friendProcessLoading{
                LoadingAnimationView(isLoading: .constant(true))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, getUIScreenBounds().height * 0.5)
            }
        }

        
    }
    
    
    
    //친구가 아닌 사용자 컨텐츠 부분 안내
    var UnknownFriendContentView: some View{
        VStack(spacing: 0, content: {
            SharedAsset.lockBig.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 77, height: 77)
                .padding(.bottom, 30)
            
            Text("친구가 아닌 사용자입니다")
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                .foregroundStyle(Color.white)
                .padding(.bottom, 10)
            
            Text("친구인 사용자의 프로필만 볼 수 있습니다.")
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .foregroundStyle(ColorSet.subGray)
            
        })
    }
    
    //친구 요청, 삭제 팝업
    var PopupView: some View {
        VStack {
            
            switch currentUserData.getFriendStatus(friend: friend) {
            case .notFriend:
                TwoButtonPopupView(title: "친구 요청을 보내시겠습니까?", positiveButtonTitle: "친구요청") {
                    status = .friendProcessLoading
                    let functions = FBManager.shared.functions
                    Task {
                        guard let result = try? await functions.httpsCallable("friendRequest").call(["uId": self.friend.uId]) else {
                            print("network error")
                            status = .normal
                            return
                        }
                        status = .normal
                    }
                }
            case .alreadySendRequest:
                TwoButtonPopupView(title: "친구 요청을 취소하시겠습니까?", positiveButtonTitle: "요청취소") {
                    status = .friendProcessLoading
                    Task {
                        guard let result = await deleteFriendRequest(uId: currentUserData.uId, friendUId: friend.uId) else {
                            status = .normal
                            return
                        }
                        status = .normal
                    }
                }
            case .alreadyRecieveRequest:
                TwoButtonPopupView(title: "친구 요청을 수락하시겠습니까??", positiveButtonTitle: "요청수락") {
                    status = .friendProcessLoading
                    let functions = FBManager.shared.functions
                    Task {
                        guard let result = try? await functions.httpsCallable("friendAccept").call(["uId": self.friend.uId]) else {
                            print("network error")
                            status = .normal
                            return
                        }
                        status = .normal
                    }
                }
            case .block:
                TwoButtonPopupView(title: "차단을 해제 하시겠습니까?", positiveButtonTitle: "차단해제") {
                    status = .friendProcessLoading
                    Task{
                        let db = FBManager.shared.db
                        let query = db.collection("User").document(currentUserData.uId)
                        query.updateData(["blockFriends": FBManager.Fieldvalue.arrayRemove([self.friend.uId])])
                        status = .normal
                    }
                }
            default: EmptyView()
            }
        }
    }
    
    //내가 보낸 친구 요청 리스트 받아오기
    private func getMyRequestList(){
        let db = FBManager.shared.db
        let query = db.collection("User").document(currentUserData.uId).collection("Friend")
            .whereField("type", isEqualTo: "request")
        query.getDocuments { snapshot, error in
            Task {
                guard error == nil else {return}
                guard let snapshot = snapshot else {return}
                snapshot.documents.forEach { doc in
                    guard let uId = doc.data()["uId"] as? String else {return}
                    self.myRequestList.append(uId)
                    if uId == friend.uId {
                        self.isRequested = true
                    }
                }
            }
        }
    }
}


struct FriendInfoView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @State var isPresentBottomSheet: Bool = false
    @State var isPresentConfirmPopup: Bool = false
    
    let friend: MumoriUser
    init(friend: MumoriUser) {
        self.friend = friend
    }
    @Environment(\.dismiss) var dismiss
    var body: some View {
        
        VStack(spacing: 0, content: {
            AsyncImage(url: friend.backgroundImageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: getUIScreenBounds().width, height: 165)
                    .clipped()
            } placeholder: {
                Rectangle()
                    .frame(width: getUIScreenBounds().width, height: 165)
                    .foregroundStyle(ColorSet.darkGray)
            }
            .overlay {
                LinearGradient(colors: [ColorSet.background.opacity(0.8), Color.clear], startPoint: .top, endPoint: .init(x: 0.5, y: 0.76))
            }
            
            VStack(alignment: .leading, spacing: 4, content: {
                Text(friend.nickname)
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 24))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                
                Text("@\(friend.id)")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 16))
                    .foregroundStyle(ColorSet.charSubGray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(friend.bio)
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(ColorSet.subGray)
                    .frame(height: 52, alignment: .bottom)
                    .padding(.bottom, 18)
                
                
                
            })
            .overlay {
                AsyncImage(url: friend.profileImageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 90, height: 90)
                        .clipShape(Circle())
                } placeholder: {
                    friend.defaultProfileImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 90, height: 90)
                        .clipShape(Circle())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(y: -40)
                
            }
            .padding(.horizontal, 20)
            
            HStack(spacing: 4, content: {
                SharedAsset.friendPurple.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                
                Text("친구")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(ColorSet.mainPurpleColor)
                
                SharedAsset.downArrowPurple.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 19, height: 19)
                    .padding(.leading, 2)
                
                
            })
            .frame(maxWidth: .infinity)
            .frame(height: 45)
            .background(ColorSet.darkGray)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
            .padding(.horizontal, 20)
            .padding(.bottom, 22)
            .onTapGesture {
                UIView.setAnimationsEnabled(false)
                isPresentBottomSheet.toggle()
            }
            //바텀 애니메이션 뷰
            .fullScreenCover(isPresented: $isPresentBottomSheet, content: {
                BottomSheetDarkGrayWrapper(isPresent: $isPresentBottomSheet) {
                    DeleteFriendBottomSheetView(friend: friend, isPresentPopup: $isPresentConfirmPopup)
                }
                .background(TransparentBackground())
            })
            //친구 끊기 확인 팝업
            .fullScreenCover(isPresented: $isPresentConfirmPopup, content: {
                TwoButtonPopupView(title: "\(friend.nickname)님과 친구를 끊겠습니까?", positiveButtonTitle: "친구 끊기") {
                    deleteFriend(uId: currentUserData.uId, friendUId: friend.uId)
                }
                .background(TransparentBackground())
            })
        })
        .ignoresSafeArea()
    }
}

struct FriendPlaylistView: View {

    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var friendDataViewModel: FriendDataViewModel

    let db = FBManager.shared.db
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0, content: {
                //ooo의 플레이리스트
                HStack(spacing: 0, content: {
                    Text("\(friendDataViewModel.friend.nickname)의 플레이리스트")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                        .foregroundStyle(Color.white)
                    Spacer()
                    Text("\(friendDataViewModel.playlistArray.count)")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundStyle(ColorSet.charSubGray)
                        .padding(.trailing, 3)
                    
                    SharedAsset.next.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 17, height: 17)
                })
                .frame(height: 67)
                .padding(.horizontal, 20)
                .onTapGesture {
                    appCoordinator.rootPath.append(MumoryPage.friendPlaylistManage)
                }
                
                //플리 가로 스크롤뷰
                if friendDataViewModel.isPlaylistLoading {
                    ScrollView(.horizontal) {
                        HStack(alignment: .top, spacing: 10, content: {
                            ForEach(0...10, id: \.self) { index in
                                PlaylistSkeletonView(itemSize: getUIScreenBounds().width * 0.215)
                            }
                        })
                        .padding(.horizontal, 20)
                    }
                }else if friendDataViewModel.playlistArray.isEmpty {
                    Text("플레이리스트가 없습니다")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                        .foregroundColor(ColorSet.subGray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: getUIScreenBounds().width * 0.43 + 25, alignment: .center) //이후 수정하기
                } else {
                    ScrollView(.horizontal) {
                        HStack(alignment: .top, spacing: 10, content: {
                            ForEach(friendDataViewModel.playlistArray.indices, id: \.self) { index in
                                PlaylistItemTest(playlist: $friendDataViewModel.playlistArray[index], itemSize: getUIScreenBounds().width * 0.215)
                                    .onTapGesture {
                                        appCoordinator.rootPath.append(MumoryPage.friendPlaylist(playlistIndex: index))
                                    }
                            }
                            
                            
                            
                        })
                        .padding(.horizontal, 20)
                    }
                    .scrollIndicators(.hidden)
                }
            })
        }

    }

}



struct FriendPageCommonBottomSheetView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserData: CurrentUserData
    @Environment(\.dismiss) var dismiss
    let friend: MumoriUser
    @Binding var isPresentBlockConfirmPopup: Bool
    init(friend: MumoriUser, isPresentBlockConfirmPopup: Binding<Bool>) {
        self.friend = friend
        self._isPresentBlockConfirmPopup = isPresentBlockConfirmPopup
    }
    
    var body: some View {
        VStack(spacing: 0, content: {
            BottomSheetSubTitleItem(image: SharedAsset.blockFriendSocial.swiftUIImage, title: "\(friend.nickname)님 차단", subTitle: "회원님을 검색하거나 친구 추가를 할 수 없습니다.")
                .onTapGesture {
                    dismiss()
                    blockFriend(uId: currentUserData.uId, friendUId: friend.uId)
                }
            BottomSheetItem(image: SharedAsset.report.swiftUIImage, title: "신고")
                .onTapGesture {
                    dismiss()
                    appCoordinator.rootPath.append(MumoryPage.report)
                }
        })
    }
    
    
}

struct FriendDeleteBlockBottomSheetView: View {
    @Environment(\.dismiss) var dismiss
    let friend: MumoriUser
    @Binding var isPresentBlockConfirmPopup: Bool
    @Binding var isPresentDeleteConfirmPopup: Bool
    init(friend: MumoriUser, isPresentBlockConfirmPopup: Binding<Bool>, isPresentDeleteConfirmPopup: Binding<Bool>) {
        self.friend = friend
        self._isPresentBlockConfirmPopup = isPresentBlockConfirmPopup
        self._isPresentDeleteConfirmPopup = isPresentDeleteConfirmPopup
    }
    
    var body: some View {
        VStack(spacing: 0, content: {
            BottomSheetSubTitleItem(image: SharedAsset.blockFriendSocial.swiftUIImage, title: "\(friend.nickname)님 차단", subTitle: "회원님을 검색하거나 친구 추가를 할 수 없습니다.")
                .onTapGesture {
                    dismiss()
                    UIView.setAnimationsEnabled(false)
                    isPresentBlockConfirmPopup = true
                }
            
            
            BottomSheetSubTitleItem(image: SharedAsset.cutOffFriend.swiftUIImage, title: "\(friend.nickname)과 친구 끊기", subTitle: "\(friend.nickname)님과 친구 관계를 끊습니다.")
                .onTapGesture {
                    dismiss()
                    UIView.setAnimationsEnabled(false)
                    isPresentDeleteConfirmPopup = true
                }
        })
    }
}


public func blockFriend(uId: String, friendUId: String) {
    
    Task {
        let db = FBManager.shared.db
        let deleteDocQuery = db.collection("User").document(uId).collection("Friend")
            .whereField("uId", isEqualTo: friendUId)
        
        guard let snapshot = try? await deleteDocQuery.getDocuments() else {
            return
        }
        snapshot.documents.forEach { document in
            document.reference.delete()
        }
        
        let query = db.collection("User").document(uId)
        try await query.updateData(["friends": FBManager.Fieldvalue.arrayRemove([friendUId])])
        try await query.updateData(["blockFriends": FBManager.Fieldvalue.arrayUnion([friendUId])])
        
        //탈퇴한회원이라면...?ㅜㅜ
        let friendQuery = db.collection("User").document(friendUId)
        try await friendQuery.updateData(["friends": FBManager.Fieldvalue.arrayRemove([uId])])
    }
}

public func deleteFriend(uId: String, friendUId: String){
    let db = FBManager.shared.db
    
    let query = db.collection("User").document(uId)
    query.updateData(["friends": FBManager.Fieldvalue.arrayRemove([friendUId])])
    
    let friendQuery = db.collection("User").document(friendUId)
    friendQuery.updateData(["friends": FBManager.Fieldvalue.arrayRemove([uId])])
}

struct DeleteFriendBottomSheetView: View {
    @EnvironmentObject var currentUserDat: CurrentUserData
    @Environment(\.dismiss) var dismiss
    @Binding var isPresentPopup: Bool
    let friend: MumoriUser
    init(friend: MumoriUser, isPresentPopup: Binding<Bool>) {
        self.friend = friend
        self._isPresentPopup = isPresentPopup
    }
    var body: some View {
        BottomSheetSubTitleItem(image: SharedAsset.cutOffFriend.swiftUIImage, title: "\(friend.nickname)과 친구 끊기", subTitle: "\(friend.nickname)님과 친구 관계를 끊습니다.")
            .onTapGesture {
                dismiss()
                UIView.setAnimationsEnabled(false)
                isPresentPopup.toggle()
            }
    }
}


struct PlaylistItemTest: View {
    @Binding var playlist: MusicPlaylist
    var radius: CGFloat = 10
    var emptyGray = Color(red: 0.18, green: 0.18, blue: 0.18)
    let itemSize: CGFloat
    init(playlist: Binding<MusicPlaylist>,itemSize: CGFloat){
        self._playlist = playlist
        self.itemSize = itemSize
    }
    
    var body: some View {
        VStack(spacing: 0){
            VStack(spacing: 0, content: {
                HStack(spacing: 0, content: {
                    //1번째 이미지
                    if playlist.songs.count < 1 {
                        Rectangle()
                            .fill(emptyGray)
                            .frame(width: itemSize, height: itemSize)
                    }else{
                        AsyncImage(url: playlist.songs[0].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Rectangle()
                                .foregroundStyle(emptyGray)
                        }
                        .frame(width: itemSize, height: itemSize)
                        
                    }
                    
                    //세로줄(구분선)
                    Rectangle()
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                        .foregroundStyle(ColorSet.background)
                    
                    //2번째 이미지
                    if playlist.songs.count < 2{
                        Rectangle()
                            .fill(emptyGray)
                            .frame(width: itemSize, height: itemSize)
                    }else{
                        AsyncImage(url: playlist.songs[1].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Rectangle()
                                .foregroundStyle(emptyGray)
                        }
                        .frame(width: itemSize, height: itemSize)
                        
                    }
                    
                    
                })
                
                //가로줄(구분선)
                Rectangle()
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(ColorSet.background)
                
                HStack(spacing: 0,content: {
                    //3번째 이미지
                    if playlist.songs.count < 3 {
                        Rectangle()
                            .fill(emptyGray)
                            .frame(width: itemSize, height: itemSize)
                    }else{
                        AsyncImage(url: playlist.songs[2].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Rectangle()
                                .foregroundStyle(emptyGray)
                        }
                        .frame(width: itemSize, height: itemSize)
                        
                    }
                    
                    //세로줄 구분선
                    Rectangle()
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                        .foregroundStyle(ColorSet.background)
                    
                    //4번째 이미지
                    if playlist.songs.count <  4 {
                        Rectangle()
                            .fill(emptyGray)
                            .frame(width: itemSize, height: itemSize)
                    }else{
                        AsyncImage(url: playlist.songs[3].artwork?.url(width: 300, height: 300) ?? URL(string: "")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Rectangle()
                                .foregroundStyle(emptyGray)
                        }
                        .frame(width: itemSize, height: itemSize)
                        
                    }
                    
                })
            })
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
            .overlay {
                SharedAsset.bookmarkWhite.swiftUIImage
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .opacity(playlist.id == "favorite" ? 1 : 0)
                
                SharedAsset.lockPurple.swiftUIImage
                    .resizable()
                    .frame(width: 23, height: 23)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .opacity(playlist.id == "favorite" ? 0 : playlist.isPublic ? 0 : 1)
            }
            
            
            Text(playlist.title)
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.top, 10)
                .foregroundStyle(.white)
                .frame(width: itemSize * 2)
            
            Text("\(playlist.songIDs.count)곡")
                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(LibraryColorSet.lightGrayTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 5)
            
        }
    }
    
    private func fetchSongInfo(songIDs: [String]) async -> [Song]{
        var songs: [Song] = []
        var count: Int = 0
        for id in songIDs {
            if count > 3 {
                break
            }
            let musicItemID = MusicItemID(rawValue: id)
            var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
            request.properties = [.genres, .artists]
            let response = try? await request.response()
            guard let song = response?.items.first else {
                continue
            }
            songs.append(song)
            count += 1
        }
        return songs
    }
    
}

struct FriendMumoryView: View {
    @EnvironmentObject var friendDataViewModel: FriendDataViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator

    @Binding private var mumorys: [Mumory]
    
    init(mumorys: Binding<[Mumory]>) {
        self._mumorys = mumorys
    }
    var body: some View {
        VStack(spacing: 0, content: {
            HStack(spacing: 0, content: {
                Text("\(friendDataViewModel.friend.nickname)의 뮤모리")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                    .foregroundStyle(Color.white)
                
                Spacer()
                
                Text("\(mumorys.count)")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(ColorSet.charSubGray)
                    .padding(.trailing, 3)
                
                SharedAsset.next.swiftUIImage
                    .resizable()
                    .frame(width: 17, height: 17)
                    .scaledToFit()
            })
            .padding(.horizontal, 20)
            .frame(height: 67)
            .onTapGesture {
                self.appCoordinator.rootPath.append(MumoryView(type: .myMumoryView(friendDataViewModel.friend), mumoryAnnotation: Mumory()))
            }
            
            if friendDataViewModel.isMumoryLoading {
                ScrollView(.horizontal) {
                    HStack(spacing: getUIScreenBounds().width < 380 ? 8 : 12, content: {
                        MumorySkeletonView()
                    })
                    .padding(.horizontal, 20)
                }
                .frame(height: getUIScreenBounds().width * 0.43)
                .padding(.bottom, 40)
            } else {
                if mumorys.isEmpty {
                    Text("뮤모리 기록이 없습니다")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                        .foregroundStyle(ColorSet.subGray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: getUIScreenBounds().width * 0.43)
                        .padding(.bottom, 40)
                } else {
                    ScrollView(.horizontal) {
                        HStack(spacing: getUIScreenBounds().width < 380 ? 8 : 12, content: {
                            ForEach(mumorys.prefix(10), id: \.id) { mumory in
                                MyMumoryItem(mumory: mumory)
                                    .onTapGesture {
                                        appCoordinator.rootPath.append(MumoryView(type: .mumoryDetailView, mumoryAnnotation: mumory))
                                    }
                            }
                        })
                        .padding(.horizontal, 20)
                        
                    }
                    .frame(height: getUIScreenBounds().width * 0.43)
                    .scrollIndicators(.hidden)
                    .padding(.bottom, 40)
                }
            }
        })
        
    }
}


public func fetchSongToPlaylist(playlistArray: Binding<[MusicPlaylist]>) {
    for i in 0 ..< playlistArray.count {
        let songIDs = playlistArray.wrappedValue[i].songIDs
        for id in songIDs {
            Task {
                let musicItemID = MusicItemID(rawValue: id)
                let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
                let response = try? await request.response()
                guard let song = response?.items.first else {
                    return
                }
                DispatchQueue.main.async {
                    playlistArray.wrappedValue[i].songs.append(song)
                }
            }
        }
    }
}


