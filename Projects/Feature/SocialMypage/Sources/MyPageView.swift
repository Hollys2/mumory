////
////  MyPageView.swift
////  Feature
////
////  Created by 제이콥 on 2/23/24.
////  Copyright © 2024 hollys. All rights reserved.
////
//
//import SwiftUI
//import Shared
//
//struct MyPageView: View {
//    let lineGray = Color(white: 0.37)
//    @State var isPresentSettingPage: Bool = false
//    var body: some View {
//        ZStack(alignment: .top){
//            ColorSet.background.ignoresSafeArea()
//            ScrollView{
//                VStack(spacing: 0, content: {
//                    UserInfoView()
//                    
//                    Divider()
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 0.5)
//                        .background(lineGray)
//                    
//                    FriendView()
//                    
//                    Divider()
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 0.5)
//                        .background(lineGray)
//                    
//                    MyMumori()
//                    
//                    
//                    
//                })
//            }
//            .ignoresSafeArea()
//            
//            HStack{
//                SharedAsset.xWhite.swiftUIImage
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 30, height: 30)
//                Spacer()
//                SharedAsset.set.swiftUIImage
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 30, height: 30)
//                    .onTapGesture {
//                        isPresentSettingPage = true
//                    }
//                    .fullScreenCover(isPresented: $isPresentSettingPage, content: {
//                        SettingView()
//                    })
//                
//            }
//            .padding(.horizontal, 20)
//
//
//        }
//        
//    }
//}
//
//#Preview {
//    MyPageView()
//}
//
//struct UserInfoView: View {
//    let nickname = "가라가라기리고"
//    let id = "garagaragigi"
//    
//    var body: some View {
//        
//        VStack(spacing: 0, content: {
//            AsyncImage(url: URL(string: "https://s.pacn.ws/1/p/173/chiikawa-jigaw-puzzle-500-piece-500540-muchauma-gourmet-775601.1.jpg?v=s299ky")) { image in
//                image
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 393, height: 150)
//                    .clipped()
//
//
//            } placeholder: {
//                Rectangle()
//                    .frame(maxWidth: .infinity)
//                    .foregroundStyle(Color.gray)
//                    .frame(width: 393)
//                    .frame(height: 150)
//
//            }
//            
//            HStack(alignment: .top, spacing: 0, content: {
//                VStack(spacing: 4, content: {
//                    Text("가라가라기리고")
//                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 24))
//                        .foregroundStyle(Color.white)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//
//                    Text("@\(id)")
//                        .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 16))
//                        .foregroundStyle(ColorSet.charSubGray)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//
//                })
//                .padding(.top, 20)
//
//                Spacer()
//                AsyncImage(url: URL(string: "https://newsimg.hankookilbo.com/2019/10/04/201910042106092399_1.jpg")) { image in
//                    image
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 90, height: 90)
//                        .clipShape(Circle())
//                } placeholder: {
//                    SharedAsset.profileRed.swiftUIImage
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 90, height: 90)
//                        .clipShape(Circle())
//                }
//                .offset(y: -50)
//            })
//            .padding(.horizontal, 20)
//
//            Text("안뇽하세요 저는 치키카와를 좋아하는 천우희랄까나,")
//                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
//                .foregroundStyle(ColorSet.subGray)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(20)
//                .lineLimit(2)
//            
//            HStack(spacing: 8, content: {
//                SharedAsset.editProfile.swiftUIImage
//                
//                Text("프로필 편집")
//                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
//                    .foregroundStyle(ColorSet.D9Gray)
//            })
//            .frame(maxWidth: .infinity)
//            .frame(height: 45)
//            .background(ColorSet.darkGray)
//            .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
//            .padding(.horizontal, 20)
//            .padding(.bottom, 22)
//            
//           
//        })
//    }
//}
//
//struct FriendView: View {
//    let friendArray: [Int] = [1,1]
//    var body: some View {
//        VStack(spacing: 0, content: {
//            HStack(spacing: 0, content: {
//                Text("친구")
//                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
//                    .foregroundStyle(Color.white)
//                
//                Spacer()
//                Text("\(friendArray.count)")
//                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
//                    .foregroundStyle(ColorSet.charSubGray)
//                    .padding(.trailing, 3)
//                SharedAsset.next.swiftUIImage
//                    .resizable()
//                    .frame(width: 17, height: 17)
//                    .scaledToFit()
//            })
//            .padding(.horizontal, 20)
//            .frame(height: 67)
//            
//            ScrollView(.horizontal) {
//                HStack(spacing: 12, content: {
//                    ForEach(0 ..< 10, id: \.self) { int in
//                        FriendHorizontalItem()
//                    }
//                })
//                .padding(.horizontal, 20)
//            }
//            .scrollIndicators(.hidden)
//            .padding(.bottom, 37)
//        })
//    }
//}
//
//struct MyMumori: View {
//    @State var list: [Int] = [1,1,1,1,1]
//    var body: some View {
//        VStack(spacing: 0, content: {
//            HStack(spacing: 0, content: {
//                Text("나의 뮤모리")
//                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
//                    .foregroundStyle(Color.white)
//                
//                Spacer()
//                
//                Text("\(list.count)")
//                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
//                    .foregroundStyle(ColorSet.charSubGray)
//                    .padding(.trailing, 3)
//                
//                SharedAsset.next.swiftUIImage
//                    .resizable()
//                    .frame(width: 17, height: 17)
//                    .scaledToFit()
//            })
//            .padding(.horizontal, 20)
//            .frame(height: 67)
//            
//            ScrollView(.horizontal) {
//                HStack(spacing: 11, content: {
//                    ForEach(list, id: \.self) { index in
//                        MyMumoriItem()
//                    }
//                })
//                .padding(.horizontal, 20)
//
//            }
//            .scrollIndicators(.hidden)
//            .padding(.bottom, 40)
//        })
//    }
//}
