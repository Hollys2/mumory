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
    @EnvironmentObject var playerViewModel: PlayerViewModel

    @State var isTapBackButton: Bool = false
    @State var isPresentEditProfile: Bool = false
    let lineGray = Color(white: 0.37)
    public var body: some View {
        
        ZStack(alignment: .top){
            ColorSet.background
            ScrollView{
                VStack(spacing: 0, content: {
                    UserInfoView()
                    
                    Divider05()
                    
                    SimpleFriendView()
                        .frame(height: 195, alignment: .top)
                    
                    Divider05()
                    
                    MyMumori()
                    
                    SubFunctionView()
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 200)
                })
            }
            .scrollIndicators(.hidden)
            
            //상단바
            HStack{
                SharedAsset.xGradient.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        isTapBackButton = true
                        if appCoordinator.bottomAnimationViewStatus == .myPage {
                            appCoordinator.setBottomAnimationPage(page: .remove)
                            if appCoordinator.selectedTab == .social {
                                Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { timer in
                                    playerViewModel.setPlayerVisibilityWithoutAnimation(isShown: true)
                                }
                            }
                        }else {
                            appCoordinator.rootPath.removeLast()
                        }
                    }
                    .disabled(isTapBackButton)
                
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
            .frame(height: 63)
            .padding(.top, currentUserData.topInset)
        }
        .ignoresSafeArea()
        .onAppear {
            settingViewModel.uid = currentUserData.uId
            AnalyticsManager.shared.setScreenLog(screenTitle: "MyPageView")
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

                } placeholder: {
                    currentUserData.user.defaultProfileImage
                        .resizable()

                }
                .scaledToFill()
                .frame(width: 90, height: 90)
                .clipShape(Circle())
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(y: -40)
            }
            .padding(.horizontal, 20)
            
            HStack(spacing: 8, content: {
                SharedAsset.editProfile.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                
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
    var body: some View {
        VStack(spacing: 0, content: {
            HStack(spacing: 0, content: {
                Text("친구")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                    .foregroundStyle(Color.white)
                
                Spacer()
                Text("\(currentUserData.friends.count)")
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
                appCoordinator.rootPath.append(MyPage.friendList)
            }
            
            if currentUserData.friends.isEmpty {
                InitialSettingView(title: "서로의 일상과 음악 취향을\n공유하고 싶은 친구들을 초대해보세요", buttonTitle: "친구 초대하러 가기") {
                    appCoordinator.rootPath.append(MumoryPage.searchFriend)
                }
            }else {
                ScrollView(.horizontal) {
                    HStack(spacing: 12, content: {
                        ForEach(currentUserData.friends, id: \.self) { friend in
                            FriendHorizontalItem(user: friend)
                                .onTapGesture {
                                    if friend.nickname == "탈퇴계정" {return}
                                    appCoordinator.rootPath.append(MyPage.friendPage(friend: friend))
                                }
                        }
                    })
                    .fixedSize()
                    .padding(.horizontal, 20)
                }
                .scrollIndicators(.hidden)
                .padding(.bottom, 37)
            }
        })
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
    @EnvironmentObject var playerViewModel: PlayerViewModel
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
                self.appCoordinator.rootPath.append(MumoryView(type: .myMumoryView(currentUserData.user), mumoryAnnotation: Mumory()))

            }
            
            if mumoryDataViewModel.myMumorys.isEmpty {
                
                InitialSettingView(title: "음악과 일상 기록을 통해\n나만의 뮤모리를 채워보세요", buttonTitle: "뮤모리 기록하러 가기") {
                    appCoordinator.setBottomAnimationPage(page: .remove)
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
                        withAnimation(Animation.easeInOut(duration: 0.1)) {
                            appCoordinator.isCreateMumorySheetShown = true
                            appCoordinator.offsetY = CGFloat.zero
                            playerViewModel.setPlayerVisibility(isShown: false)
                        }
                    }
                }
                .frame(height: getUIScreenBounds().width * 0.43)
                .padding(.bottom, 40)


            }else {
                ScrollView(.horizontal) {
                    HStack(spacing: getUIScreenBounds().width < 380 ? 8 : 12, content: {
                        ForEach(mumoryDataViewModel.myMumorys.prefix(10), id: \.id) { mumory in
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
        })

    }
}

struct SubFunctionView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    let lineGray = Color(white: 0.37)
    
    var body: some View {
        VStack(spacing: 0) {
            Divider05()
            
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
            .onTapGesture {
                appCoordinator.rootPath.append(MyPage.reward)
            }
            
            Divider05()
            
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
            .onTapGesture {
                appCoordinator.rootPath.append(MyPage.monthlyStat)
            }
            
            Divider05()
            
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
            
            Divider05()
        }
    }
}
