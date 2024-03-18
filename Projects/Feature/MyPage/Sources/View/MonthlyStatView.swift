//
//  MonthlyStatView.swift
//  Feature
//
//  Created by 다솔 on 2024/01/30.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import Shared


public struct MonthlyStatView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    public init() {}
    
    public var body: some View {
        
        VStack(spacing: 0) {
            
            TopBarView(title: "월간 통계", rightBarButtonNavigationPath: nil, paddingBottom: 28)
            
            ZStack(alignment: .top) {
                
                ScrollView(showsIndicators: false) {
                    
                    ContentView()
                        .frame(height: 1000)
                }
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(SharedAsset.backgroundColor.swiftUIColor.opacity(0.9))
                    
                    HStack(spacing: 6) {
                        Text("\(DateManager.formattedDate(date: Date(), dateFormat: "YYYY"))년 \(DateManager.formattedDate(date: Date(), dateFormat: "M"))월")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                            .foregroundColor(.white)
                        
                        SharedAsset.dateButtonMypage.swiftUIImage
                            .resizable()
                            .frame(width: 15, height: 15)
                    }
                    .padding(.leading, 12)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
//                            self.isDatePickerShown = true
                        }
                    }
                }
            }
        }
        .background(SharedAsset.backgroundColor.swiftUIColor)
        .preferredColorScheme(.dark)
    }
}

struct ContentView: View {
    
    @State var bottomPadding: CGFloat = 0
    @State var isPopUpViewShown: Bool = false
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            ZStack(alignment: .topLeading) {
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: getUIScreenBounds().width - 40, height: 108)
                    .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                    .cornerRadius(15)
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("사용자이름이름님의 이달의 관심 음악 장르는")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                        .foregroundColor(.white)
                    
                    Group {
                        Text("POP")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 24))
                            .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                        
                        + Text("  입니다")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                
                SharedAsset.infoIconMonthlyStat.swiftUIImage
                    .resizable()
                    .frame(width: 15, height: 15)
                    .offset(x: getUIScreenBounds().width - 40 - 15 - 11, y: 108 - 15 - 11)
            }
            
            ZStack(alignment: .topLeading) {
                
                VStack(spacing: 0) {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("10월 뮤모리 작성")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                            .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                        
                        HStack(spacing: 0) {
                            
                            Text("9개")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                                .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                            
                            Spacer()
                            
                            Text("10월 10일, 오늘")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                        }
                        .padding(.top, 13)
                    }
                    .padding(.top, 22)
                    .padding(.horizontal, 20)
                    
                    ScrollViewReader { proxy in
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            
                            HStack(spacing: 10) {
                                
                                ForEach(0..<2) { _ in
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 42, height: 66)
                                        .background(Color(red: 0.47, green: 0.47, blue: 0.47))
                                        .cornerRadius(30)
                                        .overlay(
                                            Text("10")
                                                .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 15))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(Color(red: 0.21, green: 0.21, blue: 0.21))
                                                .frame(height: 11)
                                                .offset(y: -33 + 5.5 + 11)
                                        )
                                        .overlay(
                                            Circle()
                                                .fill(Color(red: 0.76, green: 0.76, blue: 0.76))
                                                .frame(width: 32, height: 32)
                                                .overlay(
                                                    Text("+1")
                                                        .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 14))
                                                        .multilineTextAlignment(.center)
                                                        .foregroundColor(.black)
                                                )
                                                .offset(y: 12)
                                        )
                                }
                                
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 42, height: 66)
                                    .background(Color(red: 0.89, green: 0.89, blue: 0.89))
                                    .cornerRadius(30)
                                    .overlay(
                                        Text("10")
                                            .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 15))
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.black)
                                            .frame(height: 11)
                                            .offset(y: -33 + 5.5 + 11)
                                    )
                                    .overlay(
                                        Circle()
                                            .fill(Color(red: 0.64, green: 0.51, blue: 0.99))
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Text("+1")
                                                    .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 14))
                                                    .multilineTextAlignment(.center)
                                                    .foregroundColor(.black)
                                            )
                                            .offset(y: 12)
                                    )
                                    .id(0)
                            }
                            .padding(.horizontal, 20)
                        }
                        .onAppear {
                            proxy.scrollTo(0)
                        }
                        .padding(.top, 25)
                    }
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: getUIScreenBounds().width * 0.82, height: 0.5)
                        .background(Color(red: 0.28, green: 0.28, blue: 0.28))
                        .padding(.top, 27)
        
                    HStack(spacing: 0) {
                        
                        ZStack(alignment: .leading) {
                            
                            VStack(alignment: .leading, spacing: 7.5) {
                                Text("받은 좋아요")
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                    .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                
                                Text("6개")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                    .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                            }
                            
                            VStack(alignment: .leading, spacing: 7.5) {
                                Text("받은 댓글")
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                    .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                
                                Text("5개")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                    .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                            }
                            .offset(x: (getUIScreenBounds().width - 40) / 2)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 21)
                    .padding(.horizontal, 20)
                }
                .frame(width: getUIScreenBounds().width - 40)
                .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                .cornerRadius(15)
                .frame(width: getUIScreenBounds().width)
                
                
                if self.isPopUpViewShown {
                    MonthlyStatPopUpView()
                        .offset(x: getUIScreenBounds().width - 270 - 20 + 5, y: -20)
                }
            }
            .padding(.top, 15)
            
            Text("뮤모리된 지역")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 15)
                .padding(.leading, 20)
            
            HStack(spacing: 10) {
                
                ForEach(1..<4) { index in
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: getUIScreenBounds().width * 0.28, height: getUIScreenBounds().width * 0.28)
                        .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                        .cornerRadius(15)
                        .overlay(
                            VStack(spacing: 0) {
                                HStack(alignment: .center, spacing: 10) {
                                    Text("TOP \(index)")
                                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.white)
                                        .frame(height: 8)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, getUIScreenBounds().width * 0.015)
                                .background(Color(red: 0.32, green: 0.32, blue: 0.32))
                                .cornerRadius(30)
                                .padding(.top, getUIScreenBounds().width * 0.28 * 0.1)
                                
                                Spacer()
                                
                                Text("서울특별시")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("6개")
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                                    .frame(height: 15)
                                    .padding(.bottom, getUIScreenBounds().width * 0.28 * 0.12)
                            }
                                .frame(height: getUIScreenBounds().width * 0.28)
                        )
                }
            }
            .padding(.top, 15)
            .padding(.horizontal, 20)
            
            Text("음악 활동")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 30)
                .padding(.leading, 20)
            
            HStack(spacing: 10) {
                
                ForEach(0..<2) { i in
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: getUIScreenBounds().width * 0.435, height: 108)
                        .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                        .cornerRadius(15)
                        .overlay(
                            VStack(alignment: .leading) {
                                Text("새 플레이리스트")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                                    .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                
                                Spacer()
                                
                                Text("3개")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                                    .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                            }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(20)
                        )
                }
            }
            .padding(.top, 15)
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.top, 65)
    }
}

struct MonthlyStatPopUpView: View {
    
    var body: some View {
        
        VStack(alignment: .trailing, spacing: 0) {
            
            SharedAsset.popupUnionMonthlyStat.swiftUIImage
                .resizable()
                .frame(width: 12.12436, height: 9.75)
                .offset(x: -16.94, y: 1)
            
            HStack(alignment: .bottom, spacing: 6) {
                
                Text("뮤모리 기록, 재생 / 즐겨찾기 / 플레이리스트\n바탕으로 수집된 데이터 기반으로 나오는 결과입니다")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 11))
                    .foregroundColor(.black)
                    .frame(alignment: .topLeading)
                    .lineLimit(2)
                    .lineSpacing(5)
                    .fixedSize(horizontal: true, vertical: false)
                
                SharedAsset.closeButtonPopup.swiftUIImage
                    .resizable()
                    .frame(width: 13, height: 13)
            }
            .padding(.leading, 17)
            .padding(.vertical, 13)
            .frame(width: 270, alignment: .leading)
            .background(Color(red: 0.64, green: 0.51, blue: 0.99))
            .cornerRadius(17)
        }
    }
}


struct MonthlyStatView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyStatView()
    }
}
