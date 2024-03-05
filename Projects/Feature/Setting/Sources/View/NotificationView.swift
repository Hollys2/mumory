//
//  NotificationView.swift
//  Feature
//
//  Created by 제이콥 on 2/4/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core

enum notificationCategory {
    case social
    case service
}

struct NotificationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userManager: UserViewModel
    @EnvironmentObject var myPageCoordinator: MyPageCoordinator

    @State var isEntireButtonOn: Bool = false
    @State var isEntireOn: Bool = false
    @State var isSocialOn: Bool = false
    @State var isServiceOn: Bool = false

    var body: some View {
        ZStack{
            ColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0, content: {
                //상단바
                HStack {
                    SharedAsset.back.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            myPageCoordinator.pop()
                        }
                    Spacer()
                    Text("알림")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundStyle(Color.white)
                    Spacer()
                    SharedAsset.home.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            dismiss()
                        }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .frame(height: 65)
                .padding(.bottom, 7)
                
                
                NotificationItem(title: "전체 알림", isOn: $isEntireButtonOn)
                    .padding(.top, 12)
                    .onChange(of: isEntireButtonOn, perform: { value in
                        if value {
                            withAnimation {
                                isSocialOn = value
                                isServiceOn = value
                            }
                        }else {
                            if isEntireOn {
                                withAnimation {
                                    isSocialOn = value
                                    isServiceOn = value
                                }
                            }
                        }
                    })
                    .onChange(of: isEntireOn, perform: { value in
                        withAnimation {
                            isEntireButtonOn = value
                        }
                    })
           
                    
                
                NotificationItem(title: "소셜 알림", isOn: $isSocialOn)
                    .onChange(of: isSocialOn, perform: { value in
                        withAnimation {
                            isEntireOn = isSocialOn && isServiceOn
                        }
                        subscribeSocial(isOn: value)
                    })
                
                NotificationItem(title: "서비스 소식 알림", isOn: $isServiceOn)
                    .onChange(of: isServiceOn, perform: { value in
                        withAnimation {
                            isEntireOn = isSocialOn && isServiceOn
                        }
                        subscribeService(isOn: value)
                        
                    })
                

                Divider()
                    .frame(maxWidth: .infinity)
                    .frame(height: 0.5)
                    .background(ColorSet.subGray)
                    .padding(.top, 7)
                    .padding(.bottom, 7)
                
                
                HStack(spacing: 0, content: {
                    Text("알림 시각")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                        .foregroundStyle(.white)
                    Spacer()
                    Text(getNotificationTimeText(timeRage: userManager.selectedNotificationTime))
                        .foregroundStyle(ColorSet.mainPurpleColor)
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                })
                .padding(20)
                .background(ColorSet.background)
                .onTapGesture {
                    myPageCoordinator.push(destination: .selectNotificationTime)
                }
     
                Spacer()
            })
            
        }
        .onAppear(perform: {
            isSocialOn = userManager.isCheckedSocialNotification
            isServiceOn = userManager.isCheckedServiceNewsNotification
        })
    }
    
    public func getNotificationTimeText(timeRage: Int) -> String {
        switch(timeRage){
        case 1: return "아침  6:00AM ~ 11:00AM"
        case 2: return "점심  11:00AM ~ 4:00PM"
        case 3: return "저녁  4:00PM ~ 9:00PM"
        case 4: return "밤  9:00PM ~ 2:00AM"
        case 5: return "이용 시간대를 분석해 자동으로 설정"
        default : return "시간을 설정해주세요"
        }
    }
    
    public func subscribeSocial(isOn: Bool) {
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        let messaging = Firebase.messaging
        
        if isOn{
            messaging.subscribe(toTopic: "SOCIAL")
        }else {
            messaging.unsubscribe(fromTopic: "SOCIAL")
        }
        let userData = [
            "is_checked_social_notification" : isOn
        ]
        db.collection("User").document(userManager.uid).setData(userData, merge: true)
        userManager.isCheckedSocialNotification = isOn
    }
    
    public func subscribeService(isOn: Bool) {
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        let messaging = Firebase.messaging
        
        if isOn{
            messaging.subscribe(toTopic: "SERVICE")
        }else {
            messaging.unsubscribe(fromTopic: "SERVICE")
        }
        let userData = [
            "is_checked_service_news_notification" : isOn
        ]
        db.collection("User").document(userManager.uid).setData(userData, merge: true)
        userManager.isCheckedServiceNewsNotification = isOn
    }
    
}

#Preview {
    NotificationView()
}

struct NotificationItem: View {
    @State var title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 0, content: {
            Text(title)
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                .foregroundStyle(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(CustomToggleStyle())
                
        })
        .padding(20)

    }
}

//커스텀한 스위치 스타일 - onColor, offColor: on/off 배경색깔, thumbColor: 스위치 원형 색
struct CustomToggleStyle: ToggleStyle {

    var onColor: Color = ColorSet.mainPurpleColor
    var offColor: Color = ColorSet.lightGray
    var thumbColor: Color = ColorSet.darkGray

    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: 16, style: .circular)
                .fill(configuration.isOn ? onColor : offColor)
                .frame(width: 50, height: 30)
                .overlay(content: {
                    Circle()
                        .fill(thumbColor)
                        .padding(2)
                        .offset(x: configuration.isOn ? 10 : -10)
                })
                .onTapGesture {
                    withAnimation(.smooth(duration: 0.2)) {
                        configuration.isOn.toggle()
                    }
                }
               
        }
    }
}
