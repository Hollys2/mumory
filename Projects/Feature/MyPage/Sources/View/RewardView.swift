//
//  RewardView.swift
//  Feature
//
//  Created by 다솔 on 2024/01/30.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import Shared


public struct RewardView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            TopBarView(title: "리워드", rightBarButtonNavigationPath: nil, paddingBottom: 16)
            
            ZStack(alignment: .top) {
                ScrollView(showsIndicators: false) {
                    RewardContentView()
                }
            }
        }
        .navigationBarBackButtonHidden()
        .background(SharedAsset.backgroundColor.swiftUIColor)
    }
}

struct RewardContentView: View {
    
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    
    let attendanceRewards: [Reward] = (0...4).flatMap { index in
        [ Reward(type: .attendance(num: index))]
    }
    let recordRewards: [Reward] = (0...4).flatMap { index in
        [ Reward(type: .record(index))]
    }
    let locationRewards: [Reward] = (0...4).flatMap { index in
        [ Reward(type: .location(index))]
    }
    let likeRewards: [Reward] = (0...4).flatMap { index in
        [ Reward(type: .like(index))]
    }
    let commentRewards: [Reward] = (0...4).flatMap { index in
        [ Reward(type: .comment(index))]
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Rectangle()
              .foregroundColor(.clear)
              .frame(width: getUIScreenBounds().width - 40, height: 60)
              .background(Color(red: 0.16, green: 0.16, blue: 0.16))
              .cornerRadius(15)
              .overlay(
                Text("획득한 리워드")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                    .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                
                + Text("  \(self.currentUserViewModel.rewardViewModel.myRewards.count)개")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
              )
              .padding(.top, 15)
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: getUIScreenBounds().width - 40, height: 186)
                .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                .cornerRadius(15)
                .overlay(
                    RewardRowContent(rewards: self.attendanceRewards)
                )
                       
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: getUIScreenBounds().width - 40, height: 186)
                .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                .cornerRadius(15)
                .overlay(
                    RewardRowContent(rewards: self.recordRewards)
                )
                       
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: getUIScreenBounds().width - 40, height: 186)
                .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                .cornerRadius(15)
                .overlay(
                    RewardRowContent(rewards: self.locationRewards)
                )
                      
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: getUIScreenBounds().width - 40, height: 186)
                .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                .cornerRadius(15)
                .overlay(
                    RewardRowContent(rewards: self.likeRewards)
                )
                        
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: getUIScreenBounds().width - 40, height: 186)
                .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                .cornerRadius(15)
                .overlay(
                    RewardRowContent(rewards: self.commentRewards)
                )
            
            Spacer(minLength: 100)
        }
    }
}

struct RewardRowContent: View {

    let rewards: [Reward]

    public init(rewards: [Reward]) {
        self.rewards = rewards
    }

    var body: some View {
        VStack(spacing: 0) {
            Group {
                VStack(alignment: .leading, spacing: 8) {
                    if self.rewards[0].type == .attendance(num: 0) {
                        Group {
                            Text("출석 리워드")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                .foregroundColor(.white)
                            
                            Text("꾸준히 출석해서 리워드를 받아보세요!")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                        }
                    } else if self.rewards[0].type == .record(0) {
                        Group {
                            Text("뮤모리 기록")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                .foregroundColor(.white)
                            
                            Text("뮤모리를 꾸준히 작성하고 리워드를 받아보세요!")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                        }
                    } else if self.rewards[0].type == .location(0) {
                        Group {
                            Text("새로운 지역 도장깨기")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                .foregroundColor(.white)
                            
                            Text("새로운 지역에서 뮤모리를 작성하고 리워드를 받으세요!")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                        }
                    } else if self.rewards[0].type == .like(0) {
                        Group {
                            Text("친구 게시물에 좋아요 누르기")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                .foregroundColor(.white)
                            
                            Text("친구들 게시물에 좋아요를 누르고 리워드를 받으세요!")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                        }
                    } else if self.rewards[0].type == .comment(0) {
                        Group {
                            Text("친구 게시물에 댓글 쓰기")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                .foregroundColor(.white)
                            
                            Text("친구들 게시물에 댓글을 쓰고 리워드를 받으세요!")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)

                Spacer().frame(height: 16)
            }
            .onAppear {
                print("self.rewards[0]: \(self.rewards[0])")
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: getUIScreenBounds().width * 0.025) {
                    ForEach(self.rewards, id: \.id) { reward in
                        RewardItem(reward: reward)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct RewardItem: View {
    
    let reward: Reward
    
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    
    public init(reward: Reward) {
        self.reward = reward
    }
    
    var body: some View {
        VStack(spacing: 13) {
            ZStack {
                self.reward.image
                    .resizable()
                    .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                    .blur(radius: !self.currentUserViewModel.rewardViewModel.myRewards.contains { $0 == self.reward } ? 3 : 0)
                    .mask(
                        Rectangle()
                            .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                            .cornerRadius(10)
                    )


                if !self.currentUserViewModel.rewardViewModel.myRewards.contains { $0 == self.reward } {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                        .background(Color(red: 0.24, green: 0.24, blue: 0.24).opacity(0.6))
                        .cornerRadius(10)
                    
                    SharedAsset.lockReward.swiftUIImage
                        .resizable()
                        .frame(width: getUIScreenBounds().width * 0.082, height: getUIScreenBounds().width * 0.082)
                }
            }

            Text(self.reward.subTitle)
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
    }
}
