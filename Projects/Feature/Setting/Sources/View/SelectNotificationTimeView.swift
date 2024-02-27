//
//  SelectNotificationTimeView.swift
//  Feature
//
//  Created by 제이콥 on 2/4/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

enum time{
    case morning
    case afternoon
    case evening
    case night
    case auto
}

struct SelectNotificationTimeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userManager: UserViewModel

    @State var selectIndex: Int = 0
    
    var body: some View {
        ZStack{
            ColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0, content: {
                SelectTimeItem(time: .morning, index: $manager.selectedNotificationTime)
                    .onTapGesture {
                        manager.selectedNotificationTime = 1
                    }
                
                SelectTimeItem(time: .afternoon, index: $manager.selectedNotificationTime)
                    .onTapGesture {
                        manager.selectedNotificationTime = 2
                    }
                SelectTimeItem(time: .evening, index: $manager.selectedNotificationTime)
                    .onTapGesture {
                        manager.selectedNotificationTime = 3
                    }
                SelectTimeItem(time: .night, index: $manager.selectedNotificationTime)
                    .onTapGesture {
                        manager.selectedNotificationTime = 4
                    }
                SelectTimeItem(time: .auto, index: $manager.selectedNotificationTime)
                    .onTapGesture {
                        manager.selectedNotificationTime = 5
                    }
                
                Spacer()
            })
            .padding(.top, 12)

        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    SharedAsset.back.swiftUIImage
                        .frame(width: 30, height: 30)
                }
                
            }
            
            ToolbarItem(placement: .principal) {
                Text("알림")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                    .foregroundColor(.white)
            }
        }
        .onDisappear(perform: {
            manager.setNotificationTime()
        })
    }
}

#Preview {
    SelectNotificationTimeView()
}

struct SelectTimeItem: View {
    @State var time: time = .morning
    @Binding var index: Int
    var body: some View {
        switch(time){
        case .morning:
            HStack(spacing: 0, content: {
                
                Text("아침")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(index == 1 ? ColorSet.mainPurpleColor : .white)
                
                Text("6:00AM ~ 11:00AM")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 15))
                    .foregroundStyle(ColorSet.subGray)
                    .padding(.leading, 9)
                
                
                Spacer()
                
                SharedAsset.checkFill.swiftUIImage
                    .frame(width: 23, height: 23)
                    .opacity(index == 1 ? 1 : 0)
                
            })
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 18)
            .padding(.bottom, 18)
            
        case .afternoon:
            HStack(spacing: 0, content: {
                Text("점심")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(index == 2 ? ColorSet.mainPurpleColor : .white)
                
                Text("11:00AM ~ 4:00PM")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 15))
                    .foregroundStyle(ColorSet.subGray)
                    .padding(.leading, 9)
                
                Spacer()
                
                SharedAsset.checkFill.swiftUIImage
                    .frame(width: 23, height: 23)
                    .opacity(index == 2 ? 1 : 0)
            })
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 18)
            .padding(.bottom, 18)
            
        case .evening:
            HStack(spacing: 0, content: {
                
                Text("저녁")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(index == 3 ? ColorSet.mainPurpleColor : .white)
                
                Text("4:00PM ~ 9:00PM")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 15))
                    .foregroundStyle(ColorSet.subGray)
                    .padding(.leading, 9)
                
                
                Spacer()
                
                SharedAsset.checkFill.swiftUIImage
                    .frame(width: 23, height: 23)
                    .opacity(index == 3 ? 1 : 0)
            })
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 18)
            .padding(.bottom, 18)
            
        case .night:
            HStack(spacing: 0, content: {
                
                Text("밤")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(index == 4 ? ColorSet.mainPurpleColor : .white)
                
                Text("9:00PM ~ 2:00AM")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 15))
                    .foregroundStyle(ColorSet.subGray)
                    .padding(.leading, 9)
                
                
                Spacer()
                
                SharedAsset.checkFill.swiftUIImage
                    .frame(width: 23, height: 23)
                    .opacity(index == 4 ? 1 : 0)
            })
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 18)
            .padding(.bottom, 18)
            
        case .auto:
            HStack(spacing: 0, content: {
                
                Text("이용 시간대를 분석해 자동으로 설정")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(index == 5 ? ColorSet.mainPurpleColor : .white)
                
                Spacer()
                
                SharedAsset.checkFill.swiftUIImage
                    .frame(width: 23, height: 23)
                    .opacity(index == 5 ? 1 : 0)
            })
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 18)
            .padding(.bottom, 18)
        }
        
    }
}
