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

struct FriendPageView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserData: CurrentUserData
    @State var isStranger: Bool = false
    @State var isPresentFriendBottomSheet: Bool = false
    @State var isPresentBlockConfirmPopup: Bool = false

    let friend: MumoriUser
    
    init(friend: MumoriUser) {
        self.friend = friend
    }
    
    init(uId: String) async {
        self.friend = await MumoriUser(uId: uId)
    }
    

    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background
            
            if isStranger{
                UnkownFriendPageView(friend: friend)
            }else {
                KnownFriendPageView(friend: friend)
            }
            
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
                        isPresentFriendBottomSheet = true
                    }
            }
            .padding(.horizontal, 20)
            .frame(height: 44)
            .padding(.top, currentUserData.topInset)
        }
        .ignoresSafeArea()
        .onAppear {
            isStranger = !currentUserData.friends.contains(friend.uId)
        }
        .fullScreenCover(isPresented: $isPresentFriendBottomSheet, content: {
            BottomSheetDarkGrayWrapper(isPresent: $isPresentFriendBottomSheet) {
                FriendPageCommonBottomSheetView(friend: self.friend, isPresentBlockConfirmPopup: $isPresentBlockConfirmPopup)
            }
            .background(TransparentBackground())
        })
    }
}

struct KnownFriendPageView: View {
    let friend: MumoriUser
    let lineGray = Color(white: 0.37)

    init(friend: MumoriUser) {
        self.friend = friend
    }
    var body: some View {
        ScrollView{
            VStack(spacing: 0, content: {
                FriendInfoView(friend: friend)
                
                Divider05()
                
                //맵뷰 들어갈 공간
                Rectangle()
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity)
                    .frame(height: 187)
                                        
                Divider05()
                
                FriendPlaylistView(friend: friend)
            })
        }
    }
}


struct UnkownFriendPageView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @State var isPresentPopup: Bool = false
    @State var isRequested: Bool = false
    @State var myRequestList: [String] = []//이미 요청한 친구 uid배열
    
    let friend: MumoriUser
    let secretId: String
    init(friend: MumoriUser) {
        self.friend = friend
        secretId = String(friend.id.prefix(2)) + String(repeating: "*", count: friend.id.count-2)
    }
    
    var body: some View {
        ZStack(alignment: .top){
            VStack(spacing: 0, content: {
                UnknownFriendInfoView
                Divider10()
                UnknownFriendContentView
                    .padding(.top, 90)
            })
        }
        .onAppear{
            getMyRequestList()
        }
    }
    
    //상단 친구 인포메이션 - 배경사진, 프로필사진, 닉네임, 아이디 등
    var UnknownFriendInfoView: some View {
        VStack(spacing: 0, content: {
 
            
            Rectangle()
                .frame(maxWidth: .infinity)
                .frame(width: getUIScreenBounds().width)
<<<<<<< HEAD
                .frame(height: 165)
=======
                .frame(height: 150)
>>>>>>> 5e1e803 (edit playlist view)
                .foregroundStyle(ColorSet.darkGray)
                .overlay {
                    LinearGradient(colors: [ColorSet.background.opacity(0.8), Color.clear], startPoint: .top, endPoint: .init(x: 0.5, y: 0.76))
                }
            
            VStack(alignment: .leading, spacing: 4, content: {
                Text(friend.nickname)
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
                SharedAsset.profileRed.swiftUIImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 90, height: 90)
                    .clipShape(Circle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
<<<<<<< HEAD
                    .offset(y: -40)
=======
                    .offset(y: -50)
>>>>>>> 5e1e803 (edit playlist view)
            }
            .padding(.horizontal, 20)

                HStack(spacing: 4, content: {
                    if isRequested {
                        SharedAsset.cancelAddFriend.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    }else {
                        SharedAsset.friendIconSocial.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    }
                    
                    Text(isRequested ? "요청 취소" : "친구 추가")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                        .foregroundStyle(Color.black)
                    
                })
                .frame(maxWidth: .infinity)
                .frame(height: 45)
                .background(isRequested ? ColorSet.charSubGray : ColorSet.mainPurpleColor)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
                .padding(.horizontal, 20)
                .padding(.bottom, 22)
                .onTapGesture {
                    UIView.setAnimationsEnabled(false)
                    isPresentPopup = true
                }
               
        })
        .fullScreenCover(isPresented: $isPresentPopup, content: {
            PopupView
                .background(TransparentBackground())
        })

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
            if isRequested {
                TwoButtonPopupView(title: "친구 요청을 취소하시겠습니까?", positiveButtonTitle: "요청취소") {
                    Task{
                        guard let result = await deleteFriendRequest(uId: currentUserData.uId, friendUId: self.friend.uId) else {
                            return
                        }
                        isRequested = false
                    }
                }
            } else {
                TwoButtonPopupView(title: "친구 요청을 보내시겠습니까?", positiveButtonTitle: "친구요청") {
                    let functions = FBManager.shared.functions
                    Task {
                        guard let result = try? await functions.httpsCallable("friendRequest").call(["uId": self.friend.uId]) else {
                            print("network error")
                            return
                        }
                        isRequested = true
                    }
                }
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
                    .frame(width: getUIScreenBounds().width, height: 150)
                    .clipped()
            } placeholder: {
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(width: getUIScreenBounds().width)
                    .frame(height: 150)
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
                        Circle()
                            .fill(Color.black)
                            .frame(width: 90, height: 90)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .offset(y: -50)

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
                isPresentBottomSheet = true
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
    }
}

struct FriendPlaylistView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    let friend: MumoriUser
    init(friend: MumoriUser) {
        self.friend = friend
    }
    
    let db = FBManager.shared.db
    @State var playlists: [MusicPlaylist] = []
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0, content: {
                HStack(spacing: 0, content: {
                    Text("\(friend.nickname)의 플레이리스트")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                        .foregroundStyle(Color.white)
                    Spacer()
                    Text("\(playlists.count)")
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
                    appCoordinator.rootPath.append(MumoryPage.friendPlaylistManage(friend: self.friend, playlist: $playlists))
                }
                
                ScrollView(.horizontal) {
<<<<<<< HEAD
                    HStack(alignment: .top, spacing: 10, content: {
=======
                    HStack(alignment: .top,spacing: 10, content: {
>>>>>>> 5e1e803 (edit playlist view)
                        ForEach( 0 ..< playlists.count, id: \.self) { index in
                            PlaylistItemTest(playlist: $playlists[index], itemSize: 85)
                                .onTapGesture {
                                    appCoordinator.rootPath.append(MumoryPage.friendPlaylist(playlist: $playlists[index]))
                                }
                        }
                        .padding(.horizontal, 20)
                    })
                }
            })
        }
        .onAppear {
            if self.playlists.isEmpty {
                Task {
                    await getPlaylist()
                    fetchSongToPlaylist(playlistArray: $playlists)
                }
            }
        }
    }
    private func getPlaylist() async {
        self.playlists.removeAll()
        guard let snapshot = try? await db.collection("User").document(friend.uId).collection("Playlist").getDocuments() else {
            print("error")
            return
        }
        for document in snapshot.documents {
            let data = document.data()
            guard let isPublic = data["isPublic"] as? Bool else {
                return
            }
            if !isPublic {continue}
            guard let title = data["title"] as? String else {
                return
            }
            guard let songIdentifiers = data["songIds"] as? [String] else {
                return
            }
            let id = document.documentID
            self.playlists.append(MusicPlaylist(id: id, title: title, songIDs: songIdentifiers, isPublic: isPublic))
        }
        
    }
    private func fetchSongInfo(songIdentifiers: [String]) async -> [Song] {
 
        var songs: [Song] = []
        for id in songIdentifiers {
            let musicItemID = MusicItemID(rawValue: id)
            let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
            let response = try? await request.response()
            guard let song = response?.items.first else {
                continue
            }
            songs.append(song)
        }
        return songs
    }
}



struct FriendPageCommonBottomSheetView: View {
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
            Divider05()
            BottomSheetItem(image: SharedAsset.report.swiftUIImage, title: "신고")
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
            
            Divider05()
            
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
    let db = FBManager.shared.db
    let query = db.collection("User").document(uId)
    query.updateData(["friends": FBManager.Fieldvalue.arrayRemove([friendUId])])
    query.updateData(["blockFriends": FBManager.Fieldvalue.arrayUnion([friendUId])])
    
    let friendQuery = db.collection("User").document(friendUId)
    friendQuery.updateData(["friends": FBManager.Fieldvalue.arrayRemove([uId])])
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
                isPresentPopup = true
            }
    }
}


struct PlaylistItemTest: View {
    @Binding var playlist: MusicPlaylist
//    @State var songs: [Song] = []
    
    var radius: CGFloat = 10
    var emptyGray = Color(red: 0.18, green: 0.18, blue: 0.18)
    let itemSize: CGFloat
    
    init(playlist: Binding<MusicPlaylist>,itemSize: CGFloat){
        self._playlist = playlist
        self.itemSize = itemSize
    }
    
    var body: some View {
        ZStack(alignment: .top){
            
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
                
                Text("\(playlist.songIDs.count)곡")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(LibraryColorSet.lightGrayTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 5)
                
            }
            
        }
//        .onAppear(perform: {
//            Task{
//                self.songs = await fetchSongInfo(songIDs: playlist.songIDs)
//            }
//        })
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
