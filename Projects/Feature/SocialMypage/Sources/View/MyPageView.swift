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

struct MyPageView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var currentUserData: CurrentUserData
    @StateObject var myPageCoordinator: MyPageCoordinator = MyPageCoordinator()
    @StateObject var withdrawManager: WithdrawViewModel = WithdrawViewModel()
    @StateObject var settingViewModel: SettingViewModel = SettingViewModel()
    
    @State var isPresentEditProfile: Bool = false
    
    let lineGray = Color(white: 0.37)
    var body: some View {
        
        NavigationStack(path: $myPageCoordinator.stack) {
            ZStack(alignment: .top){
                ColorSet.background
                ScrollView{
                    VStack(spacing: 0, content: {
                        UserInfoView()
                        
                        Divider()
                            .frame(maxWidth: .infinity)
                            .frame(height: 0.5)
                            .background(lineGray)
                        
                        FriendView()
                        
                        Divider()
                            .frame(maxWidth: .infinity)
                            .frame(height: 0.5)
                            .background(lineGray)
                        
                        MyMumori()
                    })
                }
                
                HStack{
                    SharedAsset.xGradient.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            dismiss()
                        }
                    
                    Spacer()
                    
                    SharedAsset.setGradient.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            myPageCoordinator.push(destination: .setting)
                        }
                }
                .padding(.horizontal, 20)
                .frame(height: 44)
                .padding(.top, currentUserData.topInset)
            }
            .ignoresSafeArea()
            .navigationDestination(for: MyPage.self) { myPage in
                myPageCoordinator.getView(destination: myPage)
                    .navigationBarBackButtonHidden()
                    .environmentObject(myPageCoordinator)
                    .environmentObject(withdrawManager)
                    .environmentObject(settingViewModel)
            }
            .onAppear {
                settingViewModel.uid = currentUserData.user.uid
            }
        }
        
    }
}

#Preview {
    MyPageView()
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
                    .frame(width: currentUserData.width, height: 150)
                    .clipped()
            } placeholder: {
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(width: currentUserData.width)
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

struct FriendView: View {
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
                    .frame(width: 17, height: 17)
                    .scaledToFit()
            })
            .padding(.horizontal, 20)
            .frame(height: 67)
            
            ScrollView(.horizontal) {
                HStack(spacing: 12, content: {
                    ForEach(friends, id: \.self) { friend in
                        FriendHorizontalItem(user: friend)
                    }
                })
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
            .padding(.bottom, 37)
        })
        .onAppear {
            let db = FirebaseManager.shared.db
            Task {
                guard let document = try? await db.collection("User").document(currentUserData.uid).getDocument() else {
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
                        await self.friends.append(MumoriUser(uid: id))
                    }
                }
            }
        }
    }
}

struct MyMumori: View {
    @State var list: [Int] = [1,2,3,4,5]
    var body: some View {
        VStack(spacing: 0, content: {
            HStack(spacing: 0, content: {
                Text("나의 뮤모리")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                    .foregroundStyle(Color.white)
                
                Spacer()
                
                Text("\(list.count)")
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
            
            ScrollView(.horizontal) {
                HStack(spacing: 11, content: {
                    ForEach(list, id: \.self) { index in
                        MyMumoriItem()
                            .id(UUID())
                    }
                })
                .padding(.horizontal, 20)

            }
            .scrollIndicators(.hidden)
            .padding(.bottom, 40)
        })
    }
}

