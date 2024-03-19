//
//  MyPageView.swift
//  Feature
//
//  Created by 제이콥 on 2/23/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core

public struct MyPageView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var withdrawManager: WithdrawViewModel
    @EnvironmentObject var settingViewModel: SettingViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    @State var isPresentEditProfile: Bool = false
    
    let lineGray = Color(white: 0.37)
    public var body: some View {
        
        ZStack(alignment: .top){
            ColorSet.background
            ScrollView{
                VStack(spacing: 0, content: {
                    UserInfoView()
                    
                    Divider()
                        .frame(maxWidth: .infinity)
                        .frame(height: 0.5)
                        .background(lineGray)
                    
                    SimpleFriendView()
                        .frame(height: 195, alignment: .top)
                    
                    
                    Divider()
                        .frame(maxWidth: .infinity)
                        .frame(height: 0.5)
                        .background(lineGray)
                    
                    MyMumori()
                        .frame(height: 283, alignment: .top)
                    
                    SubFunctionView()
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 200)
                })
            }
            
            HStack{
                SharedAsset.xGradient.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        appCoordinator.setBottomAnimationPage(page: .remove)
                    }
                
                Spacer()
                
                SharedAsset.setGradient.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        appCoordinator.rootPath.append(MyPage.setting)
                    }
            }
            .padding(.horizontal, 20)
            .frame(height: 44)
            .padding(.top, currentUserData.topInset)
        }
        .ignoresSafeArea()
        .onAppear {
            settingViewModel.uid = currentUserData.user.uId
        }
    }
}

struct UserInfoView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @State var isPresentEditView: Bool = false
    
    var body: some View {
        
        VStack(spacing: 0, content: {
            AsyncImage(url: currentUserData.user.backgroundImageURL) { image in
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
                Text(currentUserData.user.nickname)
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 24))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                
                Text("@\(currentUserData.user.id)")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 16))
                    .foregroundStyle(ColorSet.charSubGray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(currentUserData.user.bio)
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(ColorSet.subGray)
                    .frame(height: 52, alignment: .bottom)
                    .padding(.bottom, 18)
                
                
                
            })
            .overlay {
                AsyncImage(url: currentUserData.user.profileImageURL) { image in
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
            
            
            
            
            
            
            HStack(spacing: 8, content: {
                SharedAsset.editProfile.swiftUIImage
                
                Text("프로필 편집")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .foregroundStyle(ColorSet.D9Gray)
                
            })
            .frame(maxWidth: .infinity)
            .frame(height: 45)
            .background(ColorSet.darkGray)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
            .padding(.horizontal, 20)
            .padding(.bottom, 22)
            .onTapGesture {
                isPresentEditView = true
            }
            .fullScreenCover(isPresented: $isPresentEditView, content: {
                EditProfileView()
            })
        })
    }
}

struct SimpleFriendView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserData: CurrentUserData
    @State var friends: [MumoriUser] = []
    var body: some View {
        VStack(spacing: 0, content: {
            HStack(spacing: 0, content: {
                Text("친구")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                    .foregroundStyle(Color.white)
                
                Spacer()
                Text("\(friends.count)")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(ColorSet.charSubGray)
                    .padding(.trailing, 3)
                SharedAsset.next.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 17, height: 17)
            })
            .padding(.horizontal, 20)
            .frame(height: 67)
            .background(ColorSet.background)
            .onTapGesture {
                appCoordinator.rootPath.append(MyPage.friendList(friends: self.friends))
            }
            
            ScrollView(.horizontal) {
                HStack(spacing: 12, content: {
                    ForEach(friends, id: \.self) { friend in
                        FriendHorizontalItem(user: friend)
                            .onTapGesture {
                                appCoordinator.rootPath.append(MyPage.friendPage(friend: friend))
                            }
                    }
                })
                .fixedSize()
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
            .padding(.bottom, 37)
        })
        .onAppear {
            self.friends.removeAll()
            let db = FBManager.shared.db
            
            Task {
                guard let document = try? await db.collection("User").document(currentUserData.uId).getDocument() else {
                    print("error1")
                    return
                }
                guard let data = document.data() else {
                    print("error2")
                    return
                }
                let friendIDs = data["friends"] as? [String] ?? []
                
                friendIDs.forEach { id in
                    Task{
                        await self.friends.append(MumoriUser(uId: id))
                    }
                }
            }
        }
    }
}

struct MumorySample: Hashable{
    var id: String
    var date: Date
    var locationTitle: String
    var songID: String
    var isPublic: Bool
}

struct MyMumori: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    let Firebase = FBManager.shared

    var body: some View {
        VStack(spacing: 0, content: {
            
            HStack(spacing: 0, content: {
                
                Text("나의 뮤모리")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                    .foregroundStyle(Color.white)
                
                Spacer()
                
                Text("\(mumoryDataViewModel.myMumorys.count)")
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
                self.appCoordinator.rootPath.append(MumoryView(type: .myMumoryView, mumoryAnnotation: Mumory()))
            }
            
            ScrollView(.horizontal) {
                HStack(spacing: 11, content: {
                    ForEach(mumoryDataViewModel.myMumorys.prefix(10), id: \.id) { mumory in
                        MyMumoryItem(mumory: mumory)
                            .onTapGesture {
                                appCoordinator.rootPath.append(MumoryView(type: .mumoryDetailView, mumoryAnnotation: mumory))
                            }
                    }
                })
                .padding(.horizontal, 20)
                
            }
            .scrollIndicators(.hidden)
            .padding(.bottom, 40)
        })
    }
    
//    private func getMyMumory(){
//        let db = Firebase.db
//        let uid = currentUserData.uId
//        let query = db.collection("Mumory").order(by: "date", descending: true).whereField("uId", isEqualTo: uid)
//        
//        query.getDocuments { snapshot, error in
//            guard error == nil else {
//                return
//            }
//            guard let snapshot = snapshot else {
//                print("b")
//                return
//            }
//            snapshot.documents.forEach { doc in
//                print("c")
//                Task {
//                    let data = doc.data()
//                    
//                    guard let date = (data["date"] as? FBManager.TimeStamp)?.dateValue() else {
//                        print("d")
//                        return
//                    }
//                    guard let songID = data["songID"] as? String else {
//                        print("e")
//                        return
//                    }
//                    let locationTitle = data["locationTitle"] as? String ?? ""
//                    let isPublic = data["isPublic"] as? Bool ?? false
//                    let id = doc.documentID
//                    
//                    self.mumoryList.append(MumorySample(id: id, date: date, locationTitle: locationTitle, songID: songID, isPublic: isPublic))
//                }
//                
//            }
//        }
//        
//    }
}

struct SubFunctionView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    let lineGray = Color(white: 0.37)
    
    var body: some View {
        VStack(spacing: 0) {
            
            Divider()
                .frame(maxWidth: .infinity)
                .frame(height: 0.5)
                .background(lineGray)
            
            HStack(spacing: 0, content: {
                Text("리워드")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                    .foregroundStyle(Color.white)
                
                Spacer()
                
                SharedAsset.next.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 17, height: 17)
            })
            .padding(.horizontal, 20)
            .frame(height: 67)
            .background(ColorSet.background)
            
            
            Divider()
                .frame(maxWidth: .infinity)
                .frame(height: 0.5)
                .background(lineGray)
            
            HStack(spacing: 0, content: {
                Text("월간 통계")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                    .foregroundStyle(Color.white)
                
                Spacer()
                
                SharedAsset.next.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 17, height: 17)
            })
            .padding(.horizontal, 20)
            .frame(height: 67)
            .background(ColorSet.background)
            
            
            Divider()
                .frame(maxWidth: .infinity)
                .frame(height: 0.5)
                .background(lineGray)
            
            HStack(spacing: 0, content: {
                Text("활동 내역")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                    .foregroundStyle(Color.white)
                
                Text("좋아요, 댓글, 친구")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                    .foregroundStyle(ColorSet.charSubGray)
                    .padding(.leading, 8)
                
                Spacer()
                
                SharedAsset.next.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 17, height: 17)
            })
            .padding(.horizontal, 20)
            .frame(height: 67)
            .background(ColorSet.background)
            .onTapGesture {
                appCoordinator.rootPath.append(MyPage.activityList)
            }
        }
    }
}
