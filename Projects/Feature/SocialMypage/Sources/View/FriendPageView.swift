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
    let friend: MumoriUser
    init(friend: MumoriUser) {
        self.friend = friend
    }
    init(uId: String) async {
        self.friend = await MumoriUser(uid: uId)
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
            }
            .padding(.horizontal, 20)
            .frame(height: 44)
            .padding(.top, currentUserData.topInset)
        }
        .ignoresSafeArea()
        .onAppear {
            isStranger = true
//            isStranger = currentUserData.friends.contains(friend.uid)
        }
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
                
                Divider()
                    .frame(maxWidth: .infinity)
                    .frame(height: 0.5)
                    .background(lineGray)
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity)
                    .frame(height: 187)
                                        
                Divider()
                    .frame(maxWidth: .infinity)
                    .frame(height: 0.5)
                    .background(lineGray)
                
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
                line
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

                Text("@\(secretId)")
                        .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 16))
                        .foregroundStyle(ColorSet.charSubGray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                 
                //자기소개
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
                        SharedAsset.profileRed.swiftUIImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .offset(y: -50)

                }
                .padding(.horizontal, 20)

                HStack(spacing: 4, content: {
                    if isRequested {
                        SharedAsset.friendIconSocial.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    }else {
                        SharedAsset.cancelAddFriend.swiftUIImage
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
                    isPresentPopup = true
                }
               
        })
        .fullScreenCover(isPresented: $isPresentPopup, content: {
            PopupView
        })

    }
    
    //구분선
    var line: some View {
        Divider()
            .frame(maxWidth: .infinity)
            .frame(height: 1)
            .background(ColorSet.subGray)
    }
    
    //친구가 아닌 사용자 컨텐츠 부분 안내
    var UnknownFriendContentView: some View{
        VStack(spacing: 0, content: {
            SharedAsset.lock.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 77, height: 77)
                .padding(.bottom, 30)
            
            Text("친구가 아닌 사용자입니다")
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                .foregroundStyle(Color.white)
                .padding(.bottom, 20)
            
            Text("친구인 사용자의 프로필만 볼 수 있습니다.")
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .foregroundStyle(ColorSet.subGray)

        })
    }
    
    //친구 요청, 삭제 팝업
    var PopupView: some View {
        if isRequested {
            TwoButtonPopupView(title: "친구 요청을 취소하시겠습니까?", positiveButtonTitle: "요청 취소") {
                Task{
                    guard let result = await deleteFriendRequest(uId: currentUserData.uid, friendUId: self.friend.uid) else {
                        return
                    }
                    isRequested = false
                }
            }
        }else {
            TwoButtonPopupView(title: "친구 요청을 보내시겠습니까?", positiveButtonTitle: "친구 요청") {
                let functions = FBManager.shared.functions
                Task {
                    guard let result = try? await functions.httpsCallable("friendRequest").call(["uId": self.friend.uid]) else {
                        print("network error")
                        return
                    }
                    isRequested = true
                }
            }
        }
    }
    
    //내가 보낸 친구 요청 리스트 받아오기
    private func getMyRequestList(){
        let db = FBManager.shared.db
        let query = db.collection("User").document(currentUserData.uid).collection("Friend")
            .whereField("type", isEqualTo: "request")
        query.getDocuments { snapshot, error in
            Task {
                guard error == nil else {return}
                guard let snapshot = snapshot else {return}
                snapshot.documents.forEach { doc in
                    guard let uId = doc.data()["uId"] as? String else {return}
                    self.myRequestList.append(uId)
                    if uId == friend.uid {
                        self.isRequested = true
                    }
                }
            }
        }
    }
    
}


struct FriendInfoView: View {
    @State var isPresentBottomSheet: Bool = false
    let friend: MumoriUser
    init(friend: MumoriUser) {
        self.friend = friend
    }
    
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
                isPresentBottomSheet = true
            }
            .fullScreenCover(isPresented: $isPresentBottomSheet, content: {
                
            })
        })
    }
}

struct FriendPlaylistView: View {
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
                
                ScrollView(.horizontal) {
                    HStack(alignment: .top,spacing: 10, content: {
                        ForEach(playlists, id: \.id) { playlist in
                            PlaylistItem(playlist: playlist, itemSize: 85)
                        }
                        .padding(.horizontal, 20)
                    })
                }
            })
        }
        .onAppear {
            Task {
                guard let snapshot = try? await db.collection("User").document(friend.uid).collection("Playlist").getDocuments() else {
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



//#Preview {
//    UnkownFriendPageView()
//}


//struct UnknownFriendInfo: View {
//    @State var isPresentBottomSheet: Bool = false
//    let friend: MumoriUser
//    let secretId: String
//    init(friend: MumoriUser) {
//        self.friend = friend
//        secretId = String(friend.id.prefix(2)) + String(repeating: "*", count: friend.id.count-2)
//    }
//    
//    var body: some View {
//        
//        VStack(spacing: 0, content: {
// 
//            AsyncImage(url: friend.backgroundImageURL) { image in
//                image
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: getUIScreenBounds().width, height: 150)
//                    .clipped()
//            } placeholder: {
//                Rectangle()
//                    .frame(maxWidth: .infinity)
//                    .frame(width: getUIScreenBounds().width)
//                    .frame(height: 150)
//                    .foregroundStyle(ColorSet.darkGray)
//            }
//            .overlay {
//                LinearGradient(colors: [ColorSet.background.opacity(0.8), Color.clear], startPoint: .top, endPoint: .init(x: 0.5, y: 0.76))
//            }
//            
//            VStack(alignment: .leading, spacing: 4, content: {
//                Text(friend.nickname)
//                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 24))
//                        .foregroundStyle(Color.white)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.top, 20)
//
//                Text("@\(secretId)")
//                        .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 16))
//                        .foregroundStyle(ColorSet.charSubGray)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                 
//                //자기소개
//                Text(friend.bio)
//                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
//                        .foregroundStyle(ColorSet.subGray)
//                        .frame(height: 52, alignment: .bottom)
//                        .padding(.bottom, 18)
//                })
//                .overlay {
//                    AsyncImage(url: friend.profileImageURL) { image in
//                        image
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 90, height: 90)
//                            .clipShape(Circle())
//                    } placeholder: {
//                        SharedAsset.profileRed.swiftUIImage
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 90, height: 90)
//                            .clipShape(Circle())
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
//                    .offset(y: -50)
//
//                }
//                .padding(.horizontal, 20)
//
//            HStack(spacing: 4, content: {
//                SharedAsset.friendIconSocial.swiftUIImage
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 22, height: 22)
//                
//                Text("친구 추가")
//                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
//                    .foregroundStyle(Color.black)
//                  
//            })
//            .frame(maxWidth: .infinity)
//            .frame(height: 45)
//            .background(ColorSet.mainPurpleColor)
//            .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
//            .padding(.horizontal, 20)
//            .padding(.bottom, 22)
//            .onTapGesture {
//                isPresentBottomSheet = true
//            }
//            .fullScreenCover(isPresented: $isPresentBottomSheet, content: {
//                
//            })
//        })
//    }
//}
