//
//  SettingView.swift
//  Feature
//
//  Created by 제이콥 on 2/3/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var manager: SettingViewModel = SettingViewModel()
    var body: some View {
        //테스트때문에 navigationStack 추가함. 이후 삭제하기
        ZStack{
            ColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0){
                //설정 버튼들
                NavigationLink{
                    AccountManageView()
                        .environmentObject(manager)
                }label: {
                    SettingItem(title: "계정 정보 / 보안")
                }
                
                NavigationLink {
                    NotificationView()
                        .environmentObject(manager)

                } label: {
                    SettingItem(title: "알림")
                }
                
                NavigationLink {
                    QuestionView()
                        .environmentObject(manager)
                } label: {
                    SettingItem(title: "1:1 문의")

                }

                SettingItem(title: "앱 리뷰 남기기")
                
                
                Spacer()
                Button {
                    //로그아웃
                    UserDefaults.standard.removeObject(forKey: "uid")
                    try? FirebaseManager.shared.auth.signOut()
                    
                } label: {
                    Text("로그아웃")
                        .foregroundColor(.white)
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .padding(.top, 15)
                        .padding(.bottom, 15)
                        .padding(.trailing, 58)
                        .padding(.leading, 58)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color(red: 0.65, green: 0.65, blue: 0.65), lineWidth: 1)
                        )
                }
                
                Text("계정 탈퇴")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(ColorSet.subGray)
                    .underline()
                    .padding(.bottom, 70)
                    .padding(.top, 67)
                
            }
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
            
            ToolbarItem(placement: .navigationBarTrailing) {
                
                NavigationLink {
                    HomeView()
                } label: {
                    SharedAsset.home.swiftUIImage
                        .frame(width: 30, height: 30)
                }
                
            }
            
            ToolbarItem(placement: .principal) {
                Text("설정")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                    .foregroundColor(.white)
            }
        }
        .onAppear(perform: {
            getUserInfo()
        })
        
    }
    
    private func getUserInfo(){
        let db = FirebaseManager.shared.db
        if let uid = UserDefaults.standard.string(forKey: "uid") {
            let query = db.collection("User").whereField("uid", isEqualTo: uid)
            query.getDocuments { snapshot, error in
                if let error = error {
                    print("firestore error: \(error)")
                }else if let snapshot = snapshot {
                    guard let documentData = snapshot.documents.first?.data() else {
                        print("no document")
                        return
                    }
                    
                    guard let email = documentData["email"] as? String else {
                        print("no email")
                        return
                    }
                    self.manager.email = email

                    guard let method = documentData["signin_method"] as? String else {
                        print("no method")
                        return
                    }
                    self.manager.signinMethod = method
                    
                    guard let selectedTime = documentData["selected_notification_time"] as? Int else {
                        print("no time")
                        return
                    }                    
                    self.manager.selectedNotificationTime = selectedTime

                    guard let isCheckdServiceNewsNotification = documentData["is_checked_service_news_notification"] as? Bool else {
                        print("no service notification")
                        return
                    }
                    self.manager.isCheckedServiceNewsNotification = isCheckdServiceNewsNotification
                    
                    guard let isCheckdSocialNotification = documentData["is_checked_social_notification"] as? Bool else {
                        print("no social notification")
                        return
                    }
                    self.manager.isCheckedSocialNotification = isCheckdSocialNotification
                    
                    guard let nickname = documentData["nickname"] as? String else {
                        print("no nickname")
                        return
                    }
                    self.manager.nickname = nickname

                    
                    
                }
            }

        }else {
            //재로그인
        }
    }

}

#Preview {
    SettingView()
}

struct SettingItem: View {
    @State var title: String
    var body: some View {
        HStack{
            Text(title)
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                .foregroundStyle(.white)
            
            Spacer()
            
            SharedAsset.nextSetting.swiftUIImage
                .frame(width: 25, height: 25)
        }
        .padding(20)
    }
}
