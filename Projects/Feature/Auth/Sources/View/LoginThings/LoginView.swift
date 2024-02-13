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
import Lottie
import GoogleSignIn
import Firebase

public struct LoginView: View {
    @StateObject var signInWithAppleManager: SignInWithAppleManager = SignInWithAppleManager()
    @EnvironmentObject var userManager: UserViewModel

    @State var isLoginCompleted: Bool = false
    @State var isCustomizationNotDone: Bool = false
    @State var isLoading: Bool = false
    @State var isEmailLoginTapped = false
    
    let Firebase = FirebaseManager.shared
    
    public init() {}

    public var body: some View {
        GeometryReader(content: { geometry in
            
            ZStack{
                LibraryColorSet.background.ignoresSafeArea()
                
                VStack(spacing: 0){
                    
                    SharedAsset.logo.swiftUIImage
                        .padding(.top, geometry.size.height > 700 ? 127 : 71)
                    
                    //이메일 로그인 버튼
                    EmailLoginButton()
                        .padding(.top, geometry.size.height > 700 ? 116 : 90)
                        .onTapGesture {
                            isEmailLoginTapped = true
                        }
                        .fullScreenCover(isPresented: $isEmailLoginTapped, content: {
                            EmailLoginView()
                        })
                    
                    //카카오 로그인 버튼
                    LoginButtonItem(type: .kakao, action: tapKakaoButton)
                    
                    //구글 로그인 버튼
                    LoginButtonItem(type: .google, action: tapGoogleButton)
                    
                    //애플 로그인 버튼
                    LoginButtonItem(type: .apple, action: tapAppleButton)
                        .onChange(of: signInWithAppleManager.isUserAuthenticated) { isUserAuthenticated in
                            if isUserAuthenticated{
                                if let currentUser = Firebase.auth.currentUser {
                                    checkInitialSetting(uid: currentUser.uid, email: currentUser.email, method: "Apple")
                                }
                            }
                        }
                    
                    NavigationLink {
                        SignUpManageView()
                    } label: {
                        VStack(spacing: 0){
                            Text("뮤모리 계정이 없으시다면?")
                                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                                .padding(.top, geometry.size.height > 700 ? 68 : 51)
                            
                            Text("이메일로 가입하기")
                                .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                                .padding(.top, 8)
                            
                            Spacer()
                            
                        }
                    }
                    .buttonStyle(EmpeyActionStyle()) //터치 애니메이션 삭제
                    
                }
                
                
                //로딩 로티 애니메이션 - Z스택 최상단
                LottieView(animation: .named("loading", bundle: .module))
                    .looping()
                    .opacity(isLoading ? 1 : 0)
                    .frame(width: geometry.size.width * 0.2, height: geometry.size.width * 0.2)
                
            }
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $isCustomizationNotDone, destination: {
                TermsOfServiceForSocialView() //커스텀 안 했을 시 커스텀 화면으로 이동
            })
            .navigationDestination(isPresented: $isLoginCompleted) {
                HomeView() //로그인 완료시 홈 화면으로 이동
            }
            .onDisappear(perform: {
                isLoading = false
                
                //애플 로그인 하고서 커스텀에서 다시 로그인으로 왔을 때, 애플로그인이 다시 안 되는 에러가 있어서 인증 여부를 해제함
                signInWithAppleManager.isUserAuthenticated = false
            })
            
        })
    }
    
    
    //카카오 로그인은 비즈 전환 후 다시 테스트해봐야함
    private func tapKakaoButton(){
        isLoading = true
        if UserApi.isKakaoTalkLoginAvailable(){
            //카카오톡 어플 사용이 가능하다면
            UserApi.shared.loginWithKakaoTalk { authToken, error in
                //앱로그인
                if let error = error{
                    //카카오 로그인 실패
                    print("kakao login error: \(error)")
                }else if authToken != nil {
                    //카카오 로그인 성공
                    print("login successful with app")
                    signInWithKakao()
                }
            }
        }else{
            //카카오톡 어플 사용이 불가하다면
            UserApi.shared.loginWithKakaoAccount { authToken, error in
                //계정로그인
                if let error = error{
                    print("kakao acount login error: \(error)")
                }else if authToken != nil{
                    print("login successful with account")
                    signInWithKakao()
                }
            }
        }
    }
    
    //구글 로그인 기능
    private func tapGoogleButton(){
        isLoading = true
        
        guard let id = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: id)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let presentingVC = window.rootViewController else {
            print("No root view controller")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { result, error in
            if let error = error{
                print("google error: \(error)")
            }else{
                print("google login success")
                guard let idToken = result?.user.idToken?.tokenString else {print("no idToken");return}
                guard let accessToken = result?.user.accessToken.tokenString else {print("no accessToken");return}
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                
                Auth.auth().signIn(with: credential){(result, error) in
                    if let error = error {
                        print("create user error: \(error)")
                    }else if let user = result?.user{
                        print("success creating or login user ")
                        checkInitialSetting(uid: user.uid, email: user.email, method: "Google")
                    }
                }
            }
        }
        
    }
    
    private func tapAppleButton(){
        print("tap apple button")
        signInWithAppleManager.performSignIn()
        isLoading = true
    }
    
    //카카오 로그인 관련 코드 - 비즈 전환 후 재테스트 해야함
    private func signInWithKakao(){
        print("create user with kakao")
        //기존에 존재하는 유저인지 판단 후 회원가입 혹은 로그인 진행
        
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
                
                //저장된 유저데이터에서 기존유저 판단 쿼리
                let checkOldUserQuery = Firebase.db.collection("User")
                    .whereField("email", isEqualTo: email)
                    .whereField("signin_method", isEqualTo: "Kakao")
                
                //쿼리 기반 데이터 가져오기
                checkOldUserQuery.getDocuments { snapShot, error in
                    if let error = error {
                        print("fire base query error: \(error)")
                    }else if let snapShot = snapShot {
                        //카카오 이메일과 동일한 회원 데이터가 있는지 확인
                        if snapShot.isEmpty {
                            //이메일이 동일한 카카오 로그인 회원이 없으니 회원가입
                            print("no user")
                            
                            //비밀번호 하드코딩한 거 수정하기
                            Firebase.auth.createUser(withEmail: "kakao/\(email)", password: "kakao/\(uid)"){result, error in
                                if let error = error{
                                    print("firebase sign up error: \(error)")
                                }else{
                                    guard let user = result?.user else {return}
                                    print("firebase sign up successful")
                                    checkInitialSetting(uid: user.uid, email: email, method: "Kakao")
                                }
                                
                            }
                        }else {
                            //카카오 이메일이 동일한 회원 데이터가 존재하면 로그인
                            Firebase.auth.signIn(withEmail: "kakao/\(email)", password: "kakao/\(uid)") { result, error in
                                if let error = error {
                                    print("login error \(error)")
                                }else if let user = result?.user{
                                    print("success login")
                                    checkInitialSetting(uid: user.uid, email: email, method: "Kakao")
                                }
                            }
                        }
                    }
                }
                
            }
            
        }
    }
        
    private func checkInitialSetting(uid: String, email: String?, method: String){
        //로그인 기록 및 uid 셋팅
        let userDefualt = UserDefaults.standard
        userDefualt.setValue(Date(), forKey: "loginHistory")
        
        //기존 유저인지, 신규 유저인지, 커스텀 했는지 확인
        let query = Firebase.db.collection("User").document(uid)
        
        query.getDocument { snapshot, error in
            if let error = error {
                //업로드에러
                //사용자 피드백
                print("get document error: \(error)")
            }else if let snapshot = snapshot {
                if snapshot.exists {
                    guard let data = snapshot.data() else {
                        print("no data")
                        return
                    }
                    userManager.uid = data["uid"] as? String ?? ""
                    userManager.id = data["id"] as? String ?? ""
                    userManager.nickname = data["nickname"] as? String ?? ""
                    userManager.email = data["email"] as? String ?? ""
                    userManager.signInMethod = data["signin_method"] as? String ?? ""
                    userManager.selectedNotificationTime = data["selected_notification_time"] as? Int ?? 0
                    userManager.favoriteGenres = data["favorite_genres"] as? [Int] ?? []
                    userManager.isCheckedSocialNotification = data["is_checked_social_notification"] as? Bool ?? nil
                    userManager.isCheckedServiceNewsNotification = data["is_checked_service_news_notification"] as? Bool ?? nil

                    isCustomizationNotDone = userManager.id == "" //저장된 아이디가 없으면 커스텀부터 시작
                    isLoginCompleted = userManager.id != "" //저장된 아이디가 있으면 홈으로 이동
                }else{
                    print("기존유저X")
                    
                    let userData: [String: Any] = [
                        "uid": uid,
                        "email": email ?? "NOEMAIL\(uid)", //이메일 없을 경우 - NOEMAIL유저아이디
                        "signin_method": method
                    ]
                    
                    snapshot.reference.setData(userData) { error in
                        if let error = error {
                            //업로드 에러 사용자 피드백
                            print("add document error: \(error)")
                        }else {
                            print("upload user data successful")
                            isCustomizationNotDone = true
                        }
                    }
                }
                
                
//                if snapshot.exists{
//                    //기존 유저 O
//                    print("기존유저O")
//                    guard let userData = snapshot.data() else {
//                        print("no data")
//                        return
//                    }
//                    
//                    //이용약관 동의 했는지 확인
//                    if let isCheckedServiceNewsNotification = userData["is_checked_service_news_notification"]{
//                        //이용약관 동의 O
//                        
//                        //커스텀 할 때 기입한 id 존재 유무 확인
//                        if let id = userData["id"]{
//                            //기존유저O, 이용약관동의O, 커스텀O -> 홈화면으로 이동
//                            print("커스텀O")
//                            isLoginCompleted = true
//                        }else {
//                            print("커스텀X")
//                            //기존유저O, 커스텀X -> 커스텀 페이지로 이동
//                            isCustomizationNotDone = true
//                        }
//                    }else {
//                        //이용약관 동의X -> 이용약관 동의 페이지
//                        isTermsOfServiceNotDone = true
//                    }
//                    
//                }else{
//                    //기존 유저 X, 유저 정보 업로드 후 custom페이지 이동
//                    print("기존유저X")
//                    
//                    let userData: [String: Any] = [
//                        "uid": uid,
//                        "email": email ?? "NOEMAIL\(uid)", //이메일 없을 경우 - NOEMAIL유저아이디
//                        "signin_method": method
//                    ]
//                    
//                    snapshot.reference.setData(userData) { error in
//                        if let error = error {
//                            //업로드 에러 사용자 피드백
//                            print("add document error: \(error)")
//                        }else {
//                            print("upload user data successful")
//                            isCustomizationNotDone = true
//                        }
//                    }
//                }
            }
        }
        
        
        //        query.getDocuments { snapshot, error in
        //            if let error = error {
        //                //업로드에러
        //                //사용자 피드백
        //                print("error")
        //            }else if let data = snapshot {
        //                print("data count: \(data.count)")
        //                if data.isEmpty{
        //
        //                }else{
        //
        //                }
        //            }
        //        }
    }
    
}

#Preview {
    LoginView()
}
