//
//  SelectTimeRangeView.swift
//  Feature
//
//  Created by 제이콥 on 12/26/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
struct SelectTimeView: View {
    @EnvironmentObject var manager: CustomizationManageViewModel

    var body: some View {
        ZStack{
            ColorSet.background.ignoresSafeArea()
            
            ScrollView{
                VStack(spacing: 0, content: {
                    Text("음악을 주로 듣는\n시간대를 선택해주세요")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 24))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.top, 50)
                    
                    //서브멘트
                    VStack(spacing: 0, content: {
                        HStack(spacing: 0){
                            Text("시간대를 ")
                                .foregroundColor(.white)
                                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                            
                            Text("1가지")
                                .foregroundStyle(ColorSet.mainPurpleColor)
                                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                            
                            Text(" 선택해주세요.")
                                .foregroundColor(.white)
                                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.top, 45)
                        
                        Text("더 나은 음악 추천을 제공하는 데 도움이 되며,")
                            .foregroundColor(.white)
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                            .padding(.top, 3)
                        
                        Text("또한 알림이 가는 시간대에 영향이 있습니다!")
                            .foregroundColor(.white)
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                            .padding(.top, 3)
                    })
                    
                    Text("설정 > 알림에서 수정할 수 있어요")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(ColorSet.subGray)
                        .padding(.leading, 20)
                        .padding(.top, 7)

                    TimeItem(timeZone: .moring)
                        .environmentObject(manager)
                        .padding(.top, 42)
                        .onTapGesture {
                            manager.selectedTime = 1
                        }
                    
                    TimeItem(timeZone: .afternoon)
                        .environmentObject(manager)
                        .padding(.top, 14)
                        .onTapGesture {
                            manager.selectedTime = 2
                        }
                    
                    TimeItem(timeZone: .evening)
                        .environmentObject(manager)
                        .padding(.top, 14)
                        .onTapGesture {
                            manager.selectedTime = 3
                        }
                    
                    TimeItem(timeZone: .night)
                        .environmentObject(manager)
                        .padding(.top, 14)
                        .onTapGesture {
                            manager.selectedTime = 4
                        }
                    
                    TimeItem(timeZone: .auto)
                        .environmentObject(manager)
                        .padding(.top, 14)
                        .onTapGesture {
                            manager.selectedTime = 5
                        }
                    
                    Rectangle()
                        .fill(.clear)
                        .frame(height: 100)
                    
                })
                
            }
        }
    }
}

//#Preview {
//    SelectTimeView()
//}

struct TimeItem: View {
    enum time{
        case moring
        case afternoon
        case evening
        case night
        case auto
    }
    @EnvironmentObject var manager: CustomizationManageViewModel
    @State var timeZone: time = .moring
    @State var selectedTime: Int = 0
    var body: some View {
        switch(timeZone){
        case .moring:
            VStack(spacing: 0, content: {
                Text("아침")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(manager.selectedTime == 1 ? Color.black : ColorSet.lightGray)
                    .padding(.top, 9)
                
            
                Text("6:00AM ~ 11:00AM")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                    .foregroundStyle(manager.selectedTime == 1 ? Color.black : ColorSet.lightGray)
                    .padding(.top, 4)
                    .padding(.bottom, 9)

            })
            .frame(maxWidth: .infinity)
            .background(manager.selectedTime == 1 ? ColorSet.mainPurpleColor : ColorSet.deepGray)
            .overlay(content: {
                RoundedRectangle(cornerSize: CGSize(width: 50, height: 50), style: .circular)
                    .stroke(Color.white, lineWidth: manager.selectedTime == 1 ? 0 : 1)
            })
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 50, height: 50), style: .circular))
            .padding(.leading, 20)
            .padding(.trailing, 20)
            
        case .afternoon:
            VStack(spacing: 0, content: {
                Text("점심")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(manager.selectedTime == 2 ? Color.black : ColorSet.lightGray)
                    .padding(.top, 9)
                
            
                Text("11:00AM - 4:00PM")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                    .foregroundStyle(manager.selectedTime == 2 ? Color.black : ColorSet.lightGray)
                    .padding(.top, 4)
                    .padding(.bottom, 9)

            })
            .frame(maxWidth: .infinity)
            .background(manager.selectedTime == 2 ? ColorSet.mainPurpleColor : ColorSet.deepGray)
            .overlay(content: {
                RoundedRectangle(cornerSize: CGSize(width: 50, height: 50), style: .circular)
                    .stroke(Color.white, lineWidth: manager.selectedTime == 2 ? 0 : 1)
            })
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 50, height: 50), style: .circular))
            .padding(.leading, 20)
            .padding(.trailing, 20)
            
        case .evening:
            VStack(spacing: 0, content: {
                Text("저녁")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(manager.selectedTime == 3 ? Color.black : ColorSet.lightGray)
                    .padding(.top, 9)
                
            
                Text("4:00PM - 9:00PM")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                    .foregroundStyle(manager.selectedTime == 3 ? Color.black : ColorSet.lightGray)
                    .padding(.top, 4)
                    .padding(.bottom, 9)

            })
            .frame(maxWidth: .infinity)
            .background(manager.selectedTime == 3 ? ColorSet.mainPurpleColor : ColorSet.deepGray)
            .overlay(content: {
                RoundedRectangle(cornerSize: CGSize(width: 50, height: 50), style: .circular)
                    .stroke(Color.white, lineWidth: manager.selectedTime == 3 ? 0 : 1)
            })
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 50, height: 50), style: .circular))
            .padding(.leading, 20)
            .padding(.trailing, 20)
            
        case .night:
            VStack(spacing: 0, content: {
                Text("밤")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(manager.selectedTime == 4 ? Color.black : ColorSet.lightGray)
                    .padding(.top, 9)
                
            
                Text("9:00PM - 2:00AM")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                    .foregroundStyle(manager.selectedTime == 4 ? Color.black : ColorSet.lightGray)
                    .padding(.top, 4)
                    .padding(.bottom, 9)

            })
            .frame(maxWidth: .infinity)
            .background(manager.selectedTime == 4 ? ColorSet.mainPurpleColor : ColorSet.deepGray)
            .overlay(content: {
                RoundedRectangle(cornerSize: CGSize(width: 50, height: 50), style: .circular)
                    .stroke(Color.white, lineWidth: manager.selectedTime == 4 ? 0 : 1)
            })
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 50, height: 50), style: .circular))
            .padding(.leading, 20)
            .padding(.trailing, 20)
            
        case .auto:
            VStack(spacing: 0, content: {
                Text("이용 시간대를 분석해 자동으로 설정")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(manager.selectedTime == 5 ? Color.black : ColorSet.lightGray)
                    .padding(.top, 19)
                    .padding(.bottom, 19)

            })
            .frame(maxWidth: .infinity)
            .background(manager.selectedTime == 5 ? ColorSet.mainPurpleColor : ColorSet.deepGray)
            .overlay(content: {
                RoundedRectangle(cornerSize: CGSize(width: 50, height: 50), style: .circular)
                    .stroke(Color.white, lineWidth: manager.selectedTime == 5 ? 0 : 1)
            })
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 50, height: 50), style: .circular))
            .padding(.leading, 20)
            .padding(.trailing, 20)
            
        }
    }
}
