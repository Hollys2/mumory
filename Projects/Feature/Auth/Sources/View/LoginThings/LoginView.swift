//
//  LoginView.swift
//  Feature
//
//  Created by 제이콥 on 12/9/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core
import KakaoSDKUser


public struct LoginView: View {
    public init() {}
    @State var isLoginCompleted: Bool = false
    public var body: some View {
        NavigationStack {
            ZStack{
                LibraryColorSet.background.ignoresSafeArea()
                
                VStack(spacing: 0){
                    
                    SharedAsset.logo.swiftUIImage
                        .padding(.top, 127)
                    
                    NavigationLink {
                        EmailLoginView()
                    } label: {
                        LoginButtonItem(type: .email)
                            .padding(.top, 150)
                    }
                    
                    LoginButtonItem(type: .kakao)
                    
                    LoginButtonItem(type: .google)
                    
                    LoginButtonItem(type: .apple)
                    
                    NavigationLink {
                        SignUpView()
                    } label: {
                        VStack(spacing: 0){
                            Text("뮤모리 계정이 없으시다면?")
                                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                                .padding(.top, 40)
                            
                            Text("이메일로 가입하기")
                                .underline()
                                .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                                .padding(.top, 8)
                                .padding(.bottom, 50)
                            
                        }
                    }
                    
                }
                
            }
            .navigationDestination(isPresented: $isLoginCompleted) {
                HomeView()
            }
        }
        .navigationBarBackButtonHidden()
        
    }
    
    private func tapKakaoButton(){
 
        if UserApi.isKakaoTalkLoginAvailable(){
            //카카오톡 어플 사용이 가능하다면
            UserApi.shared.loginWithKakaoTalk { authToken, error in
                //앱로그인
                if let error = error{
                    //카카오 로그인 실패
                    print("kakao login error: \(error)")
                }else if let authToken = authToken {
                    //카카오 로그인 성공
                    print("login successful with app")
                    createUserWithKakao()
                }
            }
        }else{
            //카카오톡 어플 사용이 불가하다면
            UserApi.shared.loginWithKakaoAccount { authToken, error in
                //계정로그인
                if let error = error{
                    print(error)
                }else{
                    print("login successful with account")
                    createUserWithKakao()
                }
            }
        }
    }
    private func tapEmailButton(){
        print("tap email button")
    }
    private func tapGoogleButton(){
        print("tap google button")
    }
    private func tapAppleButton(){
        print("tap apple button")
    }
    private func createUserWithKakao(){
        let auth = FirebaseManager.shared.auth
        let db = FirebaseManager.shared.db
        
        //유저 정보 접근
        UserApi.shared.me { user, error in
            if let error = error {
                //유저 정보 접근 에러
                print("error in getting user info \(error)")
            }else if let user = user{
                //유저 정보 접근 성공
                //동의,비동의 항목에 따라 가지고 올 수 있는 데이터가 다름
                guard let email = user.kakaoAccount?.email else {return}
                guard let uid = user.id else {return} //카카오 uid
                
                print("email: \(email)") //이메일 필수 체크할 수 있도록 해야함
                print("uid: \(uid)")
                
                //저장된 유저데이터에서 기존유저 판단 쿼리
                let validUserCheckQuery = db.collection("User").whereField("email", isEqualTo: email)
                
                //쿼리 기반 데이터 가져오기
                validUserCheckQuery.getDocuments { snapShot, error in
                    if let error = error {
                        //에러발생
                        print("fire base query error: \(error)")
                    }else if let snapShot = snapShot {
                        //카카오 이메일과 동일한 회원 데이터가 있는지 확인
                        if snapShot.isEmpty {
                            //카카오 이메일이 동일한 회원이 없으니 회원가입
                            print("no user")
                            auth.createUser(withEmail: email, password: String(uid)){result, error in
                                if let error = error{
                                    print("firebase sign up error: \(error)")
                                }else{
                                    guard let userResult = result?.user else {return}
                                    print("uid: \(userResult.uid)")
                                    isLoginCompleted = true
                                    print("firebase sign up successful")
                                }
                                
                            }
                        }else {
                            //카카오 이메일이 동일한 회원 데이터가 존재하면 로그인
                            auth.signIn(withEmail: email, password: String(uid)) { authDataResult, error in
                                if let error = error {
                                    print("login error \(error)")
                                }else {
                                    print("success login")
                                    isLoginCompleted = true
                                }
                            }
                        }
                    }
                }
                
            }
            
        }
    }
}

//#Preview {
//    LoginView()
//}
