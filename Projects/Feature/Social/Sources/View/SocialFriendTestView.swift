//
//  SocialFriendTestView.swift
//  Feature
//
//  Created by 제이콥 on 3/15/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct SocialFriendTestView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserData: CurrentUserData
    @State private var itemSelection = 0
    @State private var searchText = ""
    
    @State private var friendSearchResult: MumoriUser?
    @State private var friendRequestList: [MumoriUser] = []
    
    let db = FBManager.shared.db
    var body: some View {
        ZStack(alignment: .top) {
            ColorSet.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0, content: {
                //상단바
                HStack(spacing: 0) {
                    Button(action: {
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
                        .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 13))
                        .foregroundStyle(itemSelection == 0 ? Color.black : Color.white)
                        .padding(.horizontal, 16)
                        .frame(height: 33)
                        .background(itemSelection == 0 ? ColorSet.mainPurpleColor : ColorSet.darkGray)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
                        .onTapGesture {
                            self.itemSelection = 0
                        }
                        .padding(.leading, 20)
                    
                    Text("친구 요청")
                        .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 13))
                        .foregroundStyle(itemSelection == 1 ? Color.black : Color.white)
                        .padding(.horizontal, 16)
                        .frame(height: 33)
                        .background(itemSelection == 1 ? ColorSet.mainPurpleColor : ColorSet.darkGray)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
                        .onTapGesture {
                            self.itemSelection = 1
                        }
                })
                .padding(.bottom, 31)

                Divider()
                    .frame(height: 0.5)
                    .frame(maxWidth: .infinity)
                    .background(ColorSet.subGray)
                
                if itemSelection == 0 {
                    
                    SearchFriendTextField(text: $searchText, prompt: "ID검색")
                        .padding(.top, 22)
                        .onSubmit {
                            Task {
                                guard let snapshot = try? await db.collection("User").whereField("id", isEqualTo: searchText).getDocuments() else {
                                    return
                                }
                                guard let doc = snapshot.documents.first else {
                                    return
                                }
                                guard let friendUID = doc.data()["uid"] as? String else {
                                    return
                                }
                                self.friendSearchResult = await MumoriUser(uid: friendUID)
                            }
                        }
                    
                    if let friend = self.friendSearchResult {
                        FriendAddItem(friend: friend)
                            .padding(.top, 15)
                    }
                    
                }else {
                    ScrollView {
                        LazyVStack(spacing: 0, content: {
                            ForEach(friendRequestList, id: \.self) { friend in
                                FriendRequestItem(friend: friend)
                            }
                        })
                    }
                    .onAppear {
                        Task{
                            let query = db.collection("User").document(currentUserData.uid).collection("Friend")
                                .whereField("type", isEqualTo: "recieve")
                        
                            
                            guard let docs = try? await query.getDocuments() else {
                                return
                            }
                            docs.documents.forEach { doc in
                                guard let uid = doc.data()["uId"] as? String else {
                                    return
                                }
                                Task {
                                    friendRequestList.append(await MumoriUser(uid: uid))
                                }
                            }
                        }
                    }
                    
                }
            })
       
        }
        .padding(.top, appCoordinator.safeAreaInsetsTop)

    }
}

#Preview {
    SocialFriendTestView()
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

            
            Button(action: {
                text = ""
            }, label: {
                SharedAsset.xWhiteCircle.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 23, height: 23)
                    .padding(.trailing, 17)
                    .padding(.leading, 5)
                    .opacity(text.count > 0 ? 1 : 0)
            })
            
        }
        .frame(maxWidth: .infinity)
        .frame(height: 45)
        .background(Color(red: 0.24, green: 0.24, blue: 0.24))
        .clipShape(RoundedRectangle(cornerRadius: 35, style: .circular))
        .padding(.horizontal, 20)
    }
    
    func getPrompt() -> Text {
        return Text(prompt)
            .foregroundColor(Color(red: 0.77, green: 0.77, blue: 0.77))
            .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 16))
    }
}

struct FriendAddItem: View {
    let friend: MumoriUser
    init(friend: MumoriUser) {
        self.friend = friend
    }
    let Firebase = FBManager.shared
    
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
                print("tap")
                let functions = Firebase.functions
                Task {
                    guard let result = try? await functions.httpsCallable("friendRequestNotificationTest").call(["uId": self.friend.uid]) else {
                        print("network error")
                        return
                    }
                }
            }
        })
        .padding(.horizontal, 20)
        .background(ColorSet.background)
        .frame(height: 84)
    }
}

struct FriendRequestItem: View {
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
            
           Text("수락")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundStyle(Color.black)
                .padding(.horizontal, 27)
                .frame(height: 33)
                .background(ColorSet.mainPurpleColor)
                .clipShape(RoundedRectangle(cornerRadius: 16.5, style: .circular))
                .padding(.trailing, 6)
                .onTapGesture {
                    Task {
                        print("tap")
                        let functions = FBManager.shared.functions
                        guard let result = try? await functions.httpsCallable("friendAcceptNotificationTest").call(["uId": self.friend.uid]) else {
                            print("network error")
                            return
                        }
                    }
                }

            
            Text("삭제")
                 .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                 .foregroundStyle(Color.black)
                 .padding(.horizontal, 27)
                 .frame(height: 33)
                 .background(ColorSet.subGray)
                 .clipShape(RoundedRectangle(cornerRadius: 16.5, style: .circular))

        })
        .padding(.horizontal, 20)
        .background(ColorSet.background)
        .frame(height: 84)
    }
}
