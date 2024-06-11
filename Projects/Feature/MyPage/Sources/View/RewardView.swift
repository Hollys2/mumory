//
//  RewardView.swift
//  Feature
//
//  Created by 다솔 on 2024/01/30.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import Shared

let attendanceRewards: [Image] = [
    SharedAsset._1AttendanceReward.swiftUIImage,
    SharedAsset._3AttendanceReward.swiftUIImage,
    SharedAsset._7AttendanceReward.swiftUIImage,
    SharedAsset._14AttendanceReward.swiftUIImage,
    SharedAsset._30AttendanceReward.swiftUIImage
]

let recordRewards: [Image] = [
    SharedAsset._1RecordReward.swiftUIImage,
    SharedAsset._3RecordReward.swiftUIImage,
    SharedAsset._7RecordReward.swiftUIImage,
    SharedAsset._14RecordReward.swiftUIImage,
    SharedAsset._30RecordReward.swiftUIImage
]

let locationRewards: [Image] = [
    SharedAsset._1LocationReward.swiftUIImage,
    SharedAsset._3LocationReward.swiftUIImage,
    SharedAsset._7LocationReward.swiftUIImage,
    SharedAsset._14LocationReward.swiftUIImage,
    SharedAsset._30LocationReward.swiftUIImage
]

let likeRewards: [Image] = [
    SharedAsset._1LikeReward.swiftUIImage,
    SharedAsset._3LikeReward.swiftUIImage,
    SharedAsset._7LikeReward.swiftUIImage,
    SharedAsset._14LikeReward.swiftUIImage,
    SharedAsset._30LikeReward.swiftUIImage
]

let commentRewards: [Image] = [
    SharedAsset._1CommentReward.swiftUIImage,
    SharedAsset._3CommentReward.swiftUIImage,
    SharedAsset._7CommentReward.swiftUIImage,
    SharedAsset._14CommentReward.swiftUIImage,
    SharedAsset._30CommentReward.swiftUIImage
]

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
        .background(SharedAsset.backgroundColor.swiftUIColor)
    }
}

struct RewardContentView: View {
    
    var rewards: [Reward] = [.attendance(0), .record(0), .location(0), .like(0), .comment(0)]
    
    @State var count: Int = 0
    
    @EnvironmentObject var currentUserData: CurrentUserViewModel
    
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
                
                + Text("  \(count)개")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
              )
              .padding(.top, 15)
            
            ForEach(0..<5) { i in
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: getUIScreenBounds().width - 40, height: 186)
                    .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                    .cornerRadius(15)
                    .overlay(
                        RewardRowContent(index: i)
                    )
            }
            
            Spacer(minLength: 100)
        }
        .onAppear {
            Task {
                self.count = await MumoryDataViewModel.fetchRewardCount(user: currentUserData.user)
            }
        }
    }
}

struct RewardRowContent: View {

    let i: Int
    var rewards: [Reward] = [.attendance(0), .record(0), .location(0), .like(0), .comment(0)]

    public init(index: Int) {
        self.i = index
    }

    var body: some View {

        VStack(spacing: 0) {
            RewardContent2(index: i)

            ScrollView(.horizontal, showsIndicators: false) {

                HStack(spacing: getUIScreenBounds().width * 0.025) {

                    ForEach(0..<5) { index in
                        RewardContent3(index: i, index2: index)
                    }
                }
                .padding(.horizontal, 20)
            }

        }
    }
}

struct RewardContent2: View {
    
    let i: Int
    
    public init(index: Int) {
        self.i = index
    }
    
    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 8) {
                switch i {
                case 0:
                    Group {
                        Text("출석 리워드")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundColor(.white)

                        Text("꾸준히 출석해서 리워드를 받아보세요!")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                            .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                    }
                case 1:
                    Group {
                        Text("뮤모리 기록")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundColor(.white)

                        Text("뮤모리를 꾸준히 작성하고 리워드를 받아보세요!")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                            .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                    }
                case 2:
                    Group {
                        Text("새로운 지역 도장깨기")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundColor(.white)

                        Text("새로운 지역에서 뮤모리를 작성하고 리워드를 받으세요!")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                            .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                    }
                case 3:
                    Group {
                        Text("친구 게시물에 좋아요 누르기")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundColor(.white)

                        Text("친구들 게시물에 좋아요를 누르고 리워드를 받으세요!")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                            .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                    }
                case 4:
                    Group {
                        Text("친구 게시물에 댓글 쓰기")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundColor(.white)

                        Text("친구들 게시물에 댓글을 쓰고 리워드를 받으세요!")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                            .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                    }
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)

            Spacer().frame(height: 16)
        }
    }
}

struct RewardContent3: View {
    
    let i: Int
    let index: Int
    var rewards: [Reward] = [.attendance(0), .record(0), .location(0), .like(0), .comment(0)]
    
    @State private var myRewards: [String] = []
    
    @EnvironmentObject var currentUserData: CurrentUserViewModel
    
    public init(index: Int, index2: Int) {
        self.i = index
        self.index = index2
    }
    
    var body: some View {
        VStack(spacing: 13) {

            ZStack {
                switch i {
                case 0:
                    Group {
                        attendanceRewards[index]
                            .resizable()
                            .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                            .blur(radius: !myRewards.contains { $0 == "attendance\(index)"} ? 3 : 0)
                            .mask(
                                Rectangle()
                                    .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                                    .cornerRadius(10)
                            )


                        if !myRewards.contains { $0 == "attendance\(index)"} {
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

                case 1:
                    Group {
                        recordRewards[index]
                            .resizable()
                            .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                            .blur(radius: !myRewards.contains { $0 == "record\(index)"} ? 3 : 0)
                            .mask(
                                Rectangle()
                                    .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                                    .cornerRadius(10)
                            )


                        if !myRewards.contains { $0 == "record\(index)"} {
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
                case 2:
                    Group {
                        locationRewards[index]
                            .resizable()
                            .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                            .blur(radius: !myRewards.contains { $0 == "location\(index)"} ? 3 : 0)
                            .mask(
                                Rectangle()
                                    .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                                    .cornerRadius(10)
                            )


                        if !myRewards.contains { $0 == "location\(index)"} {
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
                case 3:
                    Group {
                        likeRewards[index]
                            .resizable()
                            .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                            .blur(radius: !myRewards.contains { $0 == "like\(index)"} ? 3 : 0)
                            .mask(
                                Rectangle()
                                    .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                                    .cornerRadius(10)
                            )


                        if !myRewards.contains { $0 == "like\(index)"} {
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
                case 4:
                    Group {
                        commentRewards[index]
                            .resizable()
                            .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                            .blur(radius: !myRewards.contains { $0 == "comment\(index)"} ? 3 : 0)
                            .mask(
                                Rectangle()
                                    .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                                    .cornerRadius(10)
                            )


                        if !myRewards.contains { $0 == "comment\(index)"} {
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
                default:
                    EmptyView()
                }
            }

            Text(rewards[i].subTitles[index])
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
        .onAppear {
            Task {
                self.myRewards = await MumoryDataViewModel.fetchReward(user: currentUserData.user)
            }
        }
    }
}

struct RewardView_Previews: PreviewProvider {
    static var previews: some View {
        RewardView()
    }
}
