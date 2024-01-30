//
//  MyPageSearchView.swift
//  Feature
//
//  Created by 다솔 on 2024/01/30.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import Shared

public struct MyPageSearchView: View {
    
    @State private var searchText: String = ""
    @State private var currentTabSelection: Int = 0
    @State private var isRecentSearch: Bool = false
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: self.appCoordinator.safeAreaInsetsTop + 12)
            
            HStack(spacing: 8) {
                ZStack(alignment: .leading) {
                    TextField("", text: $searchText,
                              prompt: Text("나의 뮤모리 검색").font(Font.custom("Pretendard", size: 16))
                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47)))
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .padding(.horizontal, 15 + 23 + 7)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color(red: 0.24, green: 0.24, blue: 0.24))
                    )
                    .foregroundColor(.white)
                    
                    Image(systemName: "magnifyingglass")
                        .frame(width: 23, height: 23)
                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                        .padding(.leading, 15)
                    
                    if !self.searchText.isEmpty {
                        Button(action: {
                            self.searchText = ""
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white)
                            }
                            .padding(.trailing, 17)
                        }
                    }
                }
                
                Text("취소")
                    .font(
                        SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16)
                        //                        Font.custom("Pretendard", size: 16)
                        //                            .weight(.medium)
                    )
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text("검색 결과 00건")
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                            .foregroundColor(Color(red: 0.65, green: 0.65, blue: 0.65))
                        
                        Spacer()
                    }
                    .padding(.top, 17)
                    .padding(.bottom, 25)
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 0) {
                        
                        ForEach(0..<3) { _ in
                            
                            VStack(spacing: 0) {
                                Spacer().frame(height: 15)
                                
                                HStack(alignment: .center, spacing: 0) {
                                    Image(uiImage: SharedAsset.profileMumoryDetail.image)
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    
                                    Spacer().frame(width: 7)
                                    
                                    Text("이르음음음음음")
                                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                                        .foregroundColor(.white)
                                        .frame(width: 75, height: 10, alignment: .leading)
                                    
                                    Text(" ・ 10월 2일")
                                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                                        .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                                    
                                    Spacer()
                                    
                                    Image(uiImage: SharedAsset.locationMumoryDatail.image)
                                        .frame(width: 15, height: 15)
                                    
                                    Spacer().frame(width: 4)
                                    
                                    Text("반포한강공원반포한강공원")
                                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                                        .lineLimit(1)
                                        .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                                        .frame(width: 99, height: 12, alignment: .leading)
                                } // HStack
                                
                                Spacer().frame(height: 15)
                                
                                HStack(spacing: 0) {
                                    
                                    VStack(alignment: .leading, spacing: 0) {
                                        
                                        Text("내용내 용내 용내용옹내 용일 상일 상일상내용내용내용 내용옹내용일상 일상일상 내용내용내용 내용옹 내용 일상내용 내용옹내용 일상일상일상내용내용내용")
                                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                        
//                                        Spacer()
                                        
                                        HStack(spacing: 10) {
                                            Text("#태그태그태그")
                                                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                                                .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                                .fixedSize(horizontal: true, vertical: false)

                                            Text("#태그태그태그")
                                                .font(Font.custom("Pretendard", size: 13))
                                                .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                                .fixedSize(horizontal: true, vertical: false)

                                            Text("#태그태그태그")
                                                .font(Font.custom("Pretendard", size: 13))
                                                .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading) // HStack 정렬
                                        .padding(.vertical, 5)
                                        
                                        HStack(spacing: 0) {
                                            Image(uiImage: SharedAsset.musicIconMumoryDetail.image)
                                                .frame(width: 14, height: 14)
                                            
                                            Group {
//                                                Text("  What Was I Made For? [From The Motion Picture \"Barbie\"]")
                                                Text("  Super Shy")
                                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                                                + Text("  NewJeans")
                                                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                                            }
//                                            .frame(width: getUIScreenBounds().width * 0.48, alignment: .leading)
//                                            .frame(width: getUIScreenBounds().width * 0.71, alignment: .leading)
                                            .frame(alignment: .leading)
                                            .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                                            .lineLimit(1)
//                                            .fixedSize(horizontal: true, vertical: false)

                                            Spacer(minLength: 1)
                                        }
                                    } // VStack
                                    
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 75, height: 75)
                                        .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                                        .cornerRadius(5)
                                        .padding(.leading, 20)
                                        .overlay(
                                            ZStack {
                                                Circle()
                                                    .foregroundColor(Color(red: 0.16, green: 0.16, blue: 0.16).opacity(0.6))
                                                    .frame(width: 19, height: 19)

                                                Text("2")
                                                    .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 10))
                                                    .multilineTextAlignment(.center)
                                                    .foregroundColor(.white)
                                            }
                                                .offset(x: -5, y: -5)
                                            , alignment: .bottomTrailing
                                        )
                                } // HStack
                                
                                Spacer().frame(height: 17)
                            } // VStack
                            .frame(height: 148)
                            .padding(.horizontal, 17)
                            .overlay(
                                Rectangle()
                                    .frame(height: 0.3)
                                    .foregroundColor(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                                , alignment: .top
                            )
                        }
                    }
                    .frame(height: 148 * 3 + 30)
                    .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                    .cornerRadius(15)
                    .padding(.horizontal, 20)
                    .overlay(
                        Rectangle()
                            .frame(width: getUIScreenBounds().width - 40, height: 0.3)
                            .foregroundColor(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                            .offset(y: -15)
                        , alignment: .bottom
                    )
                    .padding(.bottom, 100)
                }
            }
        }
        .background(Color(red: 0.09, green: 0.09, blue: 0.09))
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
    }
}

struct MyPageSearchView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageSearchView()
    }
}
