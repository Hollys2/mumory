//
//  SelectTimeRangeView.swift
//  Feature
//
//  Created by 제이콥 on 12/26/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared

enum TimeZone{
    case none
    case moring
    case afternoon
    case evening
    case night
    case auto
}

struct SelectTimeView: View {
    @EnvironmentObject var signUpViewModel: SignUpViewModel
    
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

                    TimeItem(timeZone: .moring, selectedTime: $signUpViewModel.notificationTime)

                    
                    TimeItem(timeZone: .afternoon, selectedTime: $signUpViewModel.notificationTime)
                       
                    
                    TimeItem(timeZone: .evening, selectedTime: $signUpViewModel.notificationTime)
                        
                    
                    TimeItem(timeZone: .night, selectedTime: $signUpViewModel.notificationTime)
                       
                    
                    TimeItem(timeZone: .auto, selectedTime: $signUpViewModel.notificationTime)
                     
                    
                    EmptyView()
                        .frame(height: 100)
                    
                })
                
            }
        }
    }
}

struct TimeItem: View {
    // MARK: - Object lifecycle
    init(timeZone: TimeZone, selectedTime: Binding<TimeZone>) {
        self.timeZone = timeZone
        self._selectedTimeZone = selectedTime

        switch timeZone {
        case .moring:
            self.title = "아침"
            self.subTitle = "6:00AM ~ 11:00AM"
        case .afternoon:
            self.title = "점심"
            self.subTitle = "11:00AM - 4:00PM"
        case .evening:
            self.title = "저녁"
            self.subTitle = "4:00PM - 9:00PM"
        case .night:
            self.title = "밤"
            self.subTitle = "9:00PM - 2:00AM"
        case .auto:
            self.title = "자동"
            self.subTitle = "이용 시간대를 분석해 자동으로 설정"
        case .none:
            self.title = ""
            self.subTitle = ""
        }

    }
    
    // MARK: - Propoerties
    @Binding var selectedTimeZone: TimeZone
    let timeZone: TimeZone
    let title: String
    let subTitle: String
    
    // MARK: - View
    var body: some View {
        VStack(spacing: 0, content: {
            Text(title)
                .font(timeZone == selectedTimeZone ? SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16) : SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .foregroundStyle(timeZone == selectedTimeZone ? Color.black : ColorSet.subGray)
                .padding(.top, 9)
            
        
            Text(subTitle)
                .font(timeZone == selectedTimeZone ? SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12) : SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                .foregroundStyle(timeZone == selectedTimeZone ? Color.black : ColorSet.subGray)
                .padding(.top, 4)
                .padding(.bottom, 9)

        })
        .frame(maxWidth: .infinity)
        .background(timeZone == selectedTimeZone ? ColorSet.mainPurpleColor : ColorSet.moreDeepGray)
        .clipShape(RoundedRectangle(cornerRadius: 50, style: .circular))
        .overlay(content: {
            RoundedRectangle(cornerRadius: 50, style: .circular)
                .stroke(ColorSet.subGray, lineWidth: timeZone == selectedTimeZone ? 0 : 1)
        })
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .onTapGesture {
            selectedTimeZone = self.timeZone
        }
    }
}
