//
//  LoginView.swift
//  Feature
//
//  Created by 제이콥 on 12/9/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import CryptoKit
import Shared
import Core
import KakaoSDKUser
import Lottie
import GoogleSignIn
import AuthenticationServices
import Firebase
import FirebaseFirestore

public struct LoginView: View {
    public init() {}
    @State fileprivate var currentNonce: String?
    @State var isLoginCompleted: Bool = false
    @State var isCustomizationNotDone: Bool = false
    @State var isLoading: Bool = false
    public var body: some View {
        NavigationStack {
            GeometryReader(content: { geometry in
            
            ZStack{
                LibraryColorSet.background.ignoresSafeArea()
                
                VStack(spacing: 0){
                    
                    SharedAsset.logo.swiftUIImage
                        .padding(.top, geometry.size.height > 700 ? 100 : 46)
                    
                    
                    //로그인 버튼. 이메일부터 시작 (이후에 끝 주석 있음)
                    //이메일 로그인 버튼
                    NavigationLink {
                        EmailLoginView()
                    } label: {
                        EmailLoginButton()
                            .padding(.top, geometry.size.height > 700 ? 100 : 74)
                    }
                    .buttonStyle(EmpeyActionStyle())
                    
                    //카카오 로그인 버튼
                    LoginButtonItem(type: .kakao, action: tapKakaoButton)
                    
                    //구글 로그인 버튼
                    LoginButtonItem(type: .google, action: tapGoogleButton)
                    
                    //애플 로그인 버튼 및 기능
                    SignInWithAppleButton(.continue) { request in
                        //애플 로그인 요청에 넣을 사항들
                        isLoading = true
                        let nonce = randomNonceString()
                        currentNonce = nonce
                        request.requestedScopes = [.email]
                        request.nonce = sha256(nonce)
                        
                    } onCompletion: { result in
                        //요청 결과 처리
                        switch(result){
                        case .success(let authResult):
                            print("apple sign in success")

                            guard let appleIDCredential = authResult.credential as? ASAuthorizationAppleIDCredential else {
                                print("credential error")
                                return}
                            
                            guard let nonce = currentNonce else {
                                print("nonce error")
                                return
                            }
                            
                            guard let appleIDToken = appleIDCredential.identityToken else {
                                print("id token error")
                                return
                            }
                            
                            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                                print("string convert error")
                                return
                            }
                            
                            
                            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                                           rawNonce: nonce,
                                                                           fullName: appleIDCredential.fullName)
                            
                            Auth.auth().signIn(with: credential, completion: { result, error in
                                if let error = error {
                                    //파이어베이스 로그인/회원가입 실패
                                    //유저에게 피드백 해주기
                                    print("fire sign in error: \(error)")
                                    
                                }else if let user = result?.user {
                                    //파이어베이스 로그인 성공
                                    print("firebase sign in success ")
                                    
                                    setLoginHistoryAndUID(uid: user.uid)//로그인기록 남기기
                                    
                                    checkOldUserAndCustomization(uid: user.uid, email: user.email, method: "Apple")
                                }
                            })
                            
                        case .failure(let error):
                            //애플로그인 실패 - 유저에게 피드백 해주기
                            print("apple sign in failure: \(error)")
                        }
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(maxWidth: .infinity, maxHeight: 60)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30), style: .circular))
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.top, 10)
                    //로그인 버튼 UI 및 기능 끝
                    
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
            .navigationDestination(isPresented: $isCustomizationNotDone, destination: {
                //커스텀 안 했을 시 커스텀 화면으로 이동
                StartCostomizationView()
            })
            .navigationDestination(isPresented: $isLoginCompleted) {
                //로그인 완료시 홈 화면으로 이동
                HomeView()
            }
                
            })
            
        }
        .navigationBarBackButtonHidden()
        
        
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
                    print("kakao acount login error: \(error)")
                }else if let authToken = authToken{
                    print("login successful with account")
                    createUserWithKakao()
                }
            }
        }
    }
    
    private func tapEmailButton(){
        print("tap email button")
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
                        setLoginHistoryAndUID(uid: user.uid)//로그인기록 남기기
                        checkOldUserAndCustomization(uid: user.uid, email: user.email, method: "Google")
                    }
                }
            }
        }
        
    }
    
    private func tapAppleButton(){
        print("tap apple button")
    }
    
    //카카오 로그인 관련 코드 - 비즈 전환 후 재테스트 해야함
    private func createUserWithKakao(){
        print("create user with kakao")
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

                //저장된 유저데이터에서 기존유저 판단 쿼리
                let checkOldUserQuery = db.collection("User")
                    .whereField("email", isEqualTo: email)
                    .whereField("method", isEqualTo: "Kakao")
                
                //쿼리 기반 데이터 가져오기
                checkOldUserQuery.getDocuments { snapShot, error in
                    if let error = error {
                        //에러발생
                        print("fire base query error: \(error)")
                    }else if let snapShot = snapShot {
                        //카카오 이메일과 동일한 회원 데이터가 있는지 확인
                        if snapShot.isEmpty {
                            //카카오 이메일이 동일한 회원이 없으니 회원가입
                            print("no user")
                            
                            //비밀번호 하드코딩한 거 수정하기
                            auth.createUser(withEmail: "kakao/\(email)", password: "kakao\(uid)"){result, error in
                                if let error = error{
                                    print("firebase sign up error: \(error)")
                                }else{
                                    guard let user = result?.user else {return}
                                    print("firebase sign up successful")
                                    setLoginHistoryAndUID(uid: user.uid)
                                    checkOldUserAndCustomization(uid: user.uid, email: email, method: "Kakao")
                                }
                                
                            }
                        }else {
                            //카카오 이메일이 동일한 회원 데이터가 존재하면 로그인
                            auth.signIn(withEmail: email, password: String(uid)) { result, error in
                                if let error = error {
                                    print("login error \(error)")
                                }else if let user = result?.user{
                                    print("success login")
                                    setLoginHistoryAndUID(uid: user.uid)
                                    checkOldUserAndCustomization(uid: user.uid, email: email, method: "Kakao")
                                }
                            }
                        }
                    }
                }
                
            }
            
        }
    }
    
    //애플 로그인 관련 코드
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    //로그인 이력 남기기
    private func setLoginHistoryAndUID(uid: String) {
        let userDefualt = UserDefaults.standard
        userDefualt.setValue(Date(), forKey: "loginHistory")
        userDefualt.setValue(uid, forKey: "uid")
    }
    
    private func checkOldUserAndCustomization(uid: String, email: String?, method: String){
        //기존 유저인지, 신규 유저인지, 커스텀 했는지 확인
        let db = Firestore.firestore().collection("User")
        let query = db.whereField("uid", isEqualTo: uid)
        
        query.getDocuments { snapshot, error in
            if let error = error {
                //업로드에러
                //사용자 피드백
                print("error")
            }else if let data = snapshot {
                print("data count: \(data.count)")
                if data.isEmpty{
                    print("기존유저X")
                    //기존 유저 X, 유저 정보 업로드 후 custom페이지 이동
                    let userData: [String: Any] = [
                        "uid": uid,
                        //이메일 없을 경우 - NOEMAIL유저아이디
                        "email": email ?? "NOEMAIL\(uid)",
                        "signin_method": method
                    ]
                    
                    db.addDocument(data: userData) { error in
                        if let error = error {
                            //업로드 에러 사용자 피드백
                            print("add document error: \(error)")
                        }else {
                            print("upload user data successful")
                            isCustomizationNotDone = true
                        }
                    }
                }else{
                    //기존 유저 O
                    print("기존유저O")
                    guard let userDocument = data.documents.first?.data() else{return}
                    
                    if let id = userDocument["id"]{
                        //기존유저O, 커스텀O -> 홈화면으로 이동
                        print("커스텀O")
                        isLoginCompleted = true
                    }else {
                        print("커스텀X")
                        //기존유저O, 커스텀X -> 커스텀 페이지로 이동
                        isCustomizationNotDone = true
                    }
                }
            }
        }
    }
    
}

//#Preview {
//    LoginView()
//}
