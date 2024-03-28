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
            
            TopBarView(title: "리워드", rightBarButtonNavigationPath: nil, paddingBottom: 28)
            
            ZStack(alignment: .top) {
                
                ScrollView(showsIndicators: false) {
                    
                    RewardContentView()
                }
            }
        }
        .background(SharedAsset.backgroundColor.swiftUIColor)
        .preferredColorScheme(.dark)
    }
}

struct RewardContentView: View {
    
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
                
                + Text("  5개")
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
                        VStack(spacing: 0) {
                        
                            VStack(alignment: .leading, spacing: 8) {
                                switch i {
                                case 0:
                                    Text("출석 리워드")
                                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                        .foregroundColor(.white)
                                    
                                    Text("꾸준히 출석해서 리워드를 받아보세요!")
                                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                        .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                case 1:
                                    Text("뮤모리 기록")
                                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                        .foregroundColor(.white)
                                    
                                    Text("뮤모리를 꾸준히 작성하고 리워드를 받아보세요!")
                                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                        .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                case 2:
                                    Text("새로운 지역 도장깨기")
                                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                        .foregroundColor(.white)
                                    
                                    Text("새로운 지역에서 뮤모리를 작성하고 리워드를 받으세요!")
                                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                        .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                case 3:
                                    Text("친구 게시물에 좋아요 누르기")
                                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                        .foregroundColor(.white)
                                    
                                    Text("친구들 게시물에 좋아요를 누르고 리워드를 받으세요!")
                                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                        .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                case 4:
                                    Text("친구 게시물에 댓글 쓰기")
                                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                        .foregroundColor(.white)
                                    
                                    Text("친구들 게시물에 댓글을 쓰고 리워드를 받으세요!")
                                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                        .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                default:
                                    EmptyView()
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                            
                            Spacer().frame(height: 16)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                
                                HStack(spacing: getUIScreenBounds().width * 0.025) {
                                    
                                    ForEach(0..<5) { index in
                                        
                                        VStack(spacing: 13) {
                                            
                                            ZStack {
                                                switch i {
                                                case 0:
                                                    attendanceRewards[index]
                                                        .resizable()
                                                        .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                                                        .blur(radius: 0)
                                                        .mask(
                                                            Rectangle()
                                                                .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                                                                .cornerRadius(10)
                                                        )
                                                case 1:
                                                    recordRewards[index]
                                                        .resizable()
                                                        .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                                                        .blur(radius: 3)
                                                        .mask(
                                                            Rectangle()
                                                                .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                                                                .cornerRadius(10)
                                                        )
                                                    
                                                    Rectangle()
                                                      .foregroundColor(.clear)
                                                      .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                                                      .background(Color(red: 0.24, green: 0.24, blue: 0.24).opacity(0.6))
                                                      .cornerRadius(10)

                                                    
                                                    SharedAsset.lockReward.swiftUIImage
                                                        .resizable()
                                                        .frame(width: getUIScreenBounds().width * 0.082, height: getUIScreenBounds().width * 0.082)
                                                case 2:
                                                    recordRewards[index]
                                                        .resizable()
                                                        .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                                                        .blur(radius: 3)
                                                        .mask(
                                                            Rectangle()
                                                                .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                                                                .cornerRadius(10)
                                                        )
                                                    
                                                    Rectangle()
                                                      .foregroundColor(.clear)
                                                      .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                                                      .background(Color(red: 0.24, green: 0.24, blue: 0.24).opacity(0.6))
                                                      .cornerRadius(10)

                                                    
                                                    SharedAsset.lockReward.swiftUIImage
                                                        .resizable()
                                                        .frame(width: getUIScreenBounds().width * 0.082, height: getUIScreenBounds().width * 0.082)
                                                case 3:
                                                    recordRewards[index]
                                                        .resizable()
                                                        .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                                                        .blur(radius: 3)
                                                        .mask(
                                                            Rectangle()
                                                                .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                                                                .cornerRadius(10)
                                                        )
                                                    
                                                    Rectangle()
                                                      .foregroundColor(.clear)
                                                      .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                                                      .background(Color(red: 0.24, green: 0.24, blue: 0.24).opacity(0.6))
                                                      .cornerRadius(10)

                                                    
                                                    SharedAsset.lockReward.swiftUIImage
                                                        .resizable()
                                                        .frame(width: getUIScreenBounds().width * 0.082, height: getUIScreenBounds().width * 0.082)
                                                case 4:
                                                    recordRewards[index]
                                                        .resizable()
                                                        .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                                                        .blur(radius: 3)
                                                        .mask(
                                                            Rectangle()
                                                                .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                                                                .cornerRadius(10)
                                                        )
                                                    
                                                    Rectangle()
                                                      .foregroundColor(.clear)
                                                      .frame(width: getUIScreenBounds().width * 0.179, height: getUIScreenBounds().width * 0.179)
                                                      .background(Color(red: 0.24, green: 0.24, blue: 0.24).opacity(0.6))
                                                      .cornerRadius(10)

                                                    
                                                    SharedAsset.lockReward.swiftUIImage
                                                        .resizable()
                                                        .frame(width: getUIScreenBounds().width * 0.082, height: getUIScreenBounds().width * 0.082)
                                                    
                                                    
                                                default:
                                                    EmptyView()
                                                }
                                            }
                                            
                                            Text("첫 출석")
                                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            
                        }
                    )
            }
            
            Spacer(minLength: 100)
        }
        
    }
}

struct RewardView_Previews: PreviewProvider {
    static var previews: some View {
        RewardView()
    }
}
