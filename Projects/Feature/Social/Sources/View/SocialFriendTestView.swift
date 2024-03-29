//
//  SocialFriendTestView.swift
//  Feature
//
//  Created by 제이콥 on 3/15/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

//뷰 내역
//메인 뷰
//아이템: 친구 추가, 요청/수락, 요청취소, 차단해제
//바텀시트,
public enum FriendRequestStatus {
    case loading
    case valid
    case alreadyFriend
    case alreadyRequest
    case alreadyRecieve
}
struct SocialFriendTestView: View {

    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserData: CurrentUserData
    @State private var itemSelection = 0
    @State private var searchText = ""
    
    @State private var friendSearchResult: MumoriUser?
    @State private var isPresentFriendBottomSheet: Bool = false
    @State private var friendRequestStatus: FriendRequestStatus = .valid
 
    
    let db = FBManager.shared.db
    var body: some View {
        ZStack(alignment: .top) {
            ColorSet.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0, content: {
                //상단바
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.appCoordinator.isAddFriendViewShown = false
                        }
                    }, label: {
                        SharedAsset.closeButtonSearchFriend.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    })
                    
                    Spacer()
                    
                    Text("친구 찾기")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        UIView.setAnimationsEnabled(false)
                        isPresentFriendBottomSheet = true
                    }, label: {
                        SharedAsset.menuButtonSearchFriend.swiftUIImage
                            .resizable()
                            .frame(width: 30, height: 30)
                    })
                }
                .padding(.horizontal, 20)
                .frame(height: 63)       
                
                HStack(spacing: 6, content: {
                    Text("친구 추가")
                        .font(itemSelection == 0 ? SharedFontFamily.Pretendard.bold.swiftUIFont(size: 13) : SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                        .foregroundStyle(itemSelection == 0 ? Color.black : ColorSet.D0Gray)
                        .padding(.horizontal, 16)
                        .frame(height: 33)
                        .background(itemSelection == 0 ? ColorSet.mainPurpleColor : ColorSet.darkGray)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
                        .onTapGesture {
                            self.itemSelection = 0
                        }
                    
                    Text("친구 요청")
                        .font(itemSelection == 1 ? SharedFontFamily.Pretendard.bold.swiftUIFont(size: 13) : SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))                       
                        .foregroundStyle(itemSelection == 1 ? Color.black : ColorSet.D0Gray)
                        .padding(.horizontal, 16)
                        .frame(height: 33)
                        .background(itemSelection == 1 ? ColorSet.mainPurpleColor : ColorSet.darkGray)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
                        .onTapGesture {
                            self.itemSelection = 1
                        }
                       
                })
                .padding(.leading, 20)
                .padding(.bottom, 31)
                .padding(.top, 20)

                Divider05()
                
                if itemSelection == 0 {
                    //친구 추가 - selection: 0
                    SearchFriendTextField(text: $searchText, prompt: "ID검색")
                        .submitLabel(.search)
                        .padding(.top, 22)
                        .onSubmit {
                            searchFriend()
                        }
                        .onChange(of: searchText) { newValue in
                            if searchText.isEmpty {
                                self.friendSearchResult = nil
                            }
                        }
                    
                    if let friend = self.friendSearchResult {
                        VStack(spacing: 0) {
                            
                            switch currentUserData.getFriendStatus(friend: friend) {
                            case .friend:
                                AlreadFriendItem(friend: friend)
                            case .notFriend:
                                FriendAddItem(friend: friend)
                            case .alreadySendRequest:
                                MyRequestFriendItem(friend: friend)
                            case .alreadyRecieveRequest:
                                RecievedRequestItem(friend: friend)
                            default: EmptyView()
                            }
                 
                        }
                        .padding(.top, 15)
                    }
                    
                }else {
                    //친구 요청 - selection: 1
                    ScrollView {
                        LazyVStack(spacing: 0, content: {
                            ForEach(currentUserData.recievedRequests, id: \.self) { friend in
                                RecievedRequestItem(friend: friend)
                            }
                        })
                    }
                    .onAppear {
                        currentUserData.recievedNewFriends = false
                    }
              
                }
                
            })
       
        }
        .padding(.top, appCoordinator.safeAreaInsetsTop)
        .fullScreenCover(isPresented: $isPresentFriendBottomSheet, content: {
            BottomSheetDarkGrayWrapper(isPresent: $isPresentFriendBottomSheet) {
                SocialFriendBottomSheet()
            }
            .background(TransparentBackground())
        })

    }
    
    private func searchFriend(){
        friendRequestStatus = .loading
        Task {
            let query = db.collection("User")
                .whereField("id", isEqualTo: searchText)
            
            guard let snapshot = try? await query.getDocuments() else {return}
            guard let doc = snapshot.documents.first else {return}
            let blockFriends = (doc.data()["blockFriends"] as? [String]) ?? []
            if blockFriends.contains(currentUserData.uId){return}
            guard let friendUID = doc.data()["uid"] as? String else {return}
            
            if currentUserData.friends.contains(where: {$0.uId == friendUID}) {
                friendRequestStatus = .alreadyFriend
            }else if currentUserData.recievedRequests.contains(where: {$0.uId == friendUID}) {
                friendRequestStatus = .alreadyRecieve
            }else if currentUserData.friendRequests.contains(where: {$0.uId == friendUID}) {
                friendRequestStatus = .alreadyRequest
            }else {
                friendRequestStatus = .valid
            }
            
            self.friendSearchResult = await MumoriUser(uId: friendUID)
        }
    }

//
//    private func getMyRequestFriendList(){
//        let query = db.collection("User").document(currentUserData.uId).collection("Friend")
//            .whereField("type", isEqualTo: "request")
//        Task {
//            guard let snapshot = try? await query.getDocuments() else {
//                return
//            }
//            snapshot.documents.forEach { document in
//                guard let uid = document.data()["uId"] as? String else {
//                    return
//                }
//                Task {
//                    myRequestFriendList.append(await MumoriUser(uId: uid))
//                }
//            }
//        }
//    }
//    
//    private func getFriendRequest(){
//        self.friendRequestList.removeAll()
//        Task{
//            let query = db.collection("User").document(currentUserData.uId).collection("Friend")
//                .whereField("type", isEqualTo: "recieve")
//        
//            guard let docs = try? await query.getDocuments() else {
//                return
//            }
//            docs.documents.forEach { doc in
//                guard let uid = doc.data()["uId"] as? String else {
//                    return
//                }
//                Task {
//                    friendRequestList.append(await MumoriUser(uId: uid))
//                }
//            }
//        }
//    }
}

struct FindFriendSelectItem: View {
    let type: ActivityType
    let title: String
    @Binding var selection: ActivityType
    
    init(type: ActivityType, title: String, selection: Binding<ActivityType>) {
        self.title = title
        self._selection = selection
        self.type = type
    }
    var body: some View {
        Text(title)
            .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 13))
            .foregroundStyle(selection == type ? Color.black : Color.white)
            .padding(.horizontal, 16)
            .frame(height: 33)
            .background(selection == type ? ColorSet.mainPurpleColor : ColorSet.darkGray)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
            .onTapGesture {
                self.selection = self.type
            }
        
    }
}

struct SearchFriendTextField: View {
    @Binding var text: String
    var prompt: String = ""
    
    var body: some View {
        HStack(spacing: 0){
            TextField("", text: $text, prompt: getPrompt())
                .frame(maxWidth: .infinity)
                .padding(.leading, 25)
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .foregroundColor(.white)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            
            
            SharedAsset.xWhiteCircle.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 23, height: 23)
                .padding(.trailing, 17)
                .padding(.leading, 5)
                .opacity(text.count > 0 ? 1 : 0)
                .onTapGesture {
                    text = ""
                }
            
        }
        .frame(maxWidth: .infinity)
        .frame(height: 45)
        .background(Color(red: 0.24, green: 0.24, blue: 0.24))
        .clipShape(RoundedRectangle(cornerRadius: 35, style: .circular))
        .padding(.horizontal, 20)
    }
    
    func getPrompt() -> Text {
        return Text(prompt)
            .foregroundColor(ColorSet.subGray)
            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
    }
}

struct AlreadFriendItem: View {
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
                    .lineLimit(1)
                
                Text("@\(friend.id)")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                    .foregroundStyle(ColorSet.charSubGray)
                    .lineLimit(1)
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.trailing, 37)
            Text("이미 등록된 친구입니다.")
                .fixedSize()
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                .foregroundStyle(Color.white)
        })
        .padding(.horizontal, 20)
        .background(ColorSet.background)
        .frame(height: 84)
    }
}

struct FriendAddItem: View {
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
                    .frame(width: 50)
            }
            
            VStack(alignment: .leading, spacing: 1, content: {
                Text(friend.nickname)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                
                Text("@\(friend.id)")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                    .foregroundStyle(ColorSet.charSubGray)
                    .lineLimit(1)
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 1) {
                SharedAsset.friendIconSocial.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                
                Text("친구추가")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 16)
            .frame(height: 33)
            .background(ColorSet.mainPurpleColor)
            .clipShape(RoundedRectangle(cornerRadius: 16.5, style: .circular))
            .onTapGesture {
                UIView.setAnimationsEnabled(false)
                isPresentRequestPopup = true
            }
        })
        .padding(.horizontal, 20)
        .background(ColorSet.background)
        .frame(height: 84)
        .fullScreenCover(isPresented: $isPresentRequestPopup) {
            TwoButtonPopupView(title: "친구 요청을 보내시겠습니까?", positiveButtonTitle: "친구요청") {
                request()
            }
            .background(TransparentBackground())
        }
    }
    
    private func request(){
        let functions = Firebase.functions
        Task {
            guard let result = try? await functions.httpsCallable("friendRequest").call(["uId": self.friend.uId]) else {
                print("network error")
                return
            }
        }
    }
}

struct RecievedRequestItem: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    var friend: MumoriUser
    var uId: String = ""
    init(friend: MumoriUser) {
        self.friend = friend
    }
    @State var isPresentDeletePopup: Bool = false
    @State var isPresentAcceptPopup: Bool = false
    let db = FBManager.shared.db
    
    var body: some View {
        HStack(spacing: 0, content: {
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
            .padding(.trailing, 13)
            
            VStack(alignment: .leading, spacing: 1, content: {
                Text(friend.nickname)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text("@\(friend.id)")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                    .foregroundStyle(ColorSet.charSubGray)
                    .lineLimit(1)
                    .truncationMode(.tail)
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.trailing, 13)
            
           Text("수락")
                .fixedSize()
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundStyle(Color.black)
                .padding(.horizontal, 27)
                .frame(height: 33)
                .background(ColorSet.mainPurpleColor)
                .clipShape(RoundedRectangle(cornerRadius: 16.5, style: .circular))
                .padding(.trailing, 6)
                .onTapGesture {
                    UIView.setAnimationsEnabled(false)
                    isPresentAcceptPopup = true
                }
            
            
            Text("삭제")
                .fixedSize()
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundStyle(Color.black)
                .padding(.horizontal, 27)
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
            TwoButtonPopupView(title: "친구 요청을 삭제하시겠습니까?", positiveButtonTitle: "요청삭제") {
                deleteRequest()
            }
            .background(TransparentBackground())
        }
        .fullScreenCover(isPresented: $isPresentAcceptPopup) {
            TwoButtonPopupView(title: "친구 요청을 수락하시겠습니까?", positiveButtonTitle: "요청수락") {
                acceptRequest()
            }
            .background(TransparentBackground())
        }
    }
    
    private func deleteRequest() {
        let query = db.collection("User").document(currentUserData.uId).collection("Friend")
            .whereField("uId", isEqualTo: friend.uId)
            .whereField("type", isEqualTo: "recieve")
        Task {
            guard let snapshot = try? await query.getDocuments() else {
                return
            }
            guard let result = try? await snapshot.documents.first?.reference.delete() else {
                return
            }
            currentUserData.recievedRequests.removeAll(where: {$0.uId == friend.uId})
        }
    }
    
    private func acceptRequest(){
        let functions = FBManager.shared.functions

        Task {
            guard let result = try? await functions.httpsCallable("friendAccept").call(["uId": self.friend.uId]) else {
                print("network error")
                return
            }
            currentUserData.recievedRequests.removeAll(where: {$0.uId == friend.uId})
            currentUserData.friends.append(friend)
        }
    }
}

struct SocialFriendBottomSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
        VStack(spacing: 0) {
            BottomSheetItem(image: SharedAsset.requestFriendSocial.swiftUIImage, title: "내가 보낸 요청")
                .onTapGesture {
                    dismiss()
                    appCoordinator.rootPath.append(MumoryPage.requestFriend)
                }
            
            Divider05()
            
            BottomSheetItem(image: SharedAsset.blockFriendSocial.swiftUIImage, title: "차단친구 관리")
                .onTapGesture {
                    dismiss()
                    appCoordinator.rootPath.append(MumoryPage.blockFriend)
                }
        }

    }
}
