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
import FirebaseAuth
import Firebase
import GoogleSignIn
import KakaoSDKAuth
import KakaoSDKUser
import Lottie

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var myPageCoordinator: MyPageCoordinator
    @EnvironmentObject var withdrawManager: WithdrawViewModel
    @EnvironmentObject var settingViewModel: SettingViewModel
    
    @State var isShowingWithdrawPopup = false
    @State var isLoading: Bool = false
    
    var body: some View {
        //테스트때문에 navigationStack 추가함. 이후 삭제하기
        
        ZStack{
            ColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0){
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
                    Text("설정")
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
                
                
                SettingItem(title: "계정 정보 / 보안")
                    .onTapGesture {
                        myPageCoordinator.push(destination: .account)
                    }
                
                SettingItem(title: "알림")
                    .onTapGesture {
                        myPageCoordinator.push(destination: .notification)
                    }
                
                SettingItem(title: "1:1 문의")
                    .onTapGesture {
                        myPageCoordinator.push(destination: .question)
                    }
                
                SettingItem(title: "앱 리뷰 남기기")
                
                
                Spacer()
                
                
                LogoutButton()
                    .onTapGesture {
                        let Firebase = FBManager.shared
                        do {
                            try Firebase.auth.signOut()
                            print("로그아웃 완료")
                            myPageCoordinator.push(destination: .login)
                            
                        }catch {
                            print("signout error: \(error)")
                        }
                        
                        Firebase.messaging.deleteToken { error in
                            print(error?.localizedDescription)
                        }
                    }
                
            
                WithdrawButton()
                    .onChange(of: withdrawManager.isAppleUserAuthenticated, perform: { value in
                        if value{
                            //계정 탈퇴를 위한 애플 로그인 성공시
                            deleteAppleUser()
                        }
                    })
                    .onTapGesture {
                        UIView.setAnimationsEnabled(false)
                        isShowingWithdrawPopup = true
                    }
                    .fullScreenCover(isPresented: $isShowingWithdrawPopup) {
                        TwoButtonPopupView(title: "계정을 탈퇴하시겠습니까?", subTitle: "탈퇴하신 계정은 복구가 불가능합니다.", positiveButtonTitle: "탈퇴하기") {
                            //탈퇴(확인)버튼 클릭 action - 회원가입 방식에 따라 재 로그인 진행
                            withdraw(method: settingViewModel.signinMethod)
                        }
                        .background(TransparentBackground())
                    }
                
            }
            .onDisappear(perform: {
                isLoading = false
            })
            
            LoadingAnimationView(isLoading: $isLoading)
            
        }
        
    }
    
    func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
      guard let viewController = viewController else {
        return nil
      }
   
      if let navigationController = viewController as? UINavigationController {
        return navigationController
      }
   
      for childViewController in viewController.children {
        return findNavigationController(viewController: childViewController)
      }
   
      return nil
    }
    private func deleteAppleUser(){
        print("in delete apple user")
        let Firebase = FBManager.shared
        let db = Firebase.db
        let auth = Firebase.auth
        
        guard let currentUser = auth.currentUser else {
            print("no current user")
            return
        }
        
        currentUser.delete { error in
            if let error = error{
                print("delete user error: \(error)")
                //에러처리
            }else {
                print("delete user successful")
                db.collection("User").document(currentUser.uid).delete { error in
                    if let error = error {
                        print("delete document error: \(error)")
                    }else {
                        print("delete docs successful")
                        myPageCoordinator.resetPath(destination: .login)
                    }
                }
            }
            
        }
    }
    private func withdraw(method: String){
        isLoading = true
        if method == "Apple" {
            withdrawManager.AppleLogin()
        }else if method == "Google" {
            withdrawManager.GoogleLogin(originalEmail: settingViewModel.email) { isSuccessful in
                deleteUser(isSuccessful: isSuccessful)
            }
        }else if method == "Kakao" {
            withdrawManager.KakaoLogin(originalEmail: settingViewModel.email) { isSuccessful in
                deleteUser(isSuccessful: isSuccessful)
            }
        }else if method == "Email" {
            myPageCoordinator.push(destination: .emailVerification)
        }
    }
    
    private func deleteUser(isSuccessful: Bool){
        if isSuccessful {
            let Firebase = FBManager.shared
            let db = Firebase.db
            let auth = Firebase.auth
            
            guard let currentUser = auth.currentUser else {
                print("no current user")
                return
            }
            
            currentUser.delete { error in
                if let error = error{
                    print("delete user error: \(error)")
                }else {
                    db.collection("User").document(currentUser.uid).delete { error in
                        if let error = error {
                            print("delete document error: \(error)")
                        }else {
                            myPageCoordinator.resetPath(destination: .login)
                        }
                    }
                }
            }
            
        }
    }
}

//#Preview {
//    SettingView()
//}

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

private struct WithdrawButton: View {
    var body: some View {
        Text("계정 탈퇴")
            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
            .foregroundStyle(ColorSet.subGray)
            .underline()
            .padding(.bottom, 70)
            .padding(.top, 67)
    }
}

private struct LogoutButton: View {
    var body: some View {
        Text("로그아웃")
            .foregroundColor(.white)
            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
            .padding(.top, 15)
            .padding(.bottom, 15)
            .padding(.trailing, 62)
            .padding(.leading, 62)
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .circular)
                    .stroke(Color(red: 0.65, green: 0.65, blue: 0.65), lineWidth: 1)
            )
    }
}
