//
//  EmailLoginView.swift
//  Feature
//
//  Created by 제이콥 on 12/9/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core
import Lottie

struct EmailLoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userManager: UserViewModel
    
    @StateObject var customManager: CustomizationManageViewModel = CustomizationManageViewModel()

    @State var email: String = ""
    @State var password: String = ""
    @State var isLoginError: Bool = false
    @State var isLoading: Bool = false
    @State var isCustomizationNotDone: Bool = false
    @State var isLoginSuccess: Bool = false
    @State var isPresent: Bool = false

    
    var body: some View {
        GeometryReader(content: { geometry in
            NavigationStack{
                ZStack{
                    LibraryColorSet.background.ignoresSafeArea()
                    
                    VStack(spacing: 0, content: {
                        //상단 타이틀
                        Text("이메일로 로그인 하기")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 22))
                            .foregroundColor(.white)
                            .padding(.top, 30)
                        
                        //이메일 텍스트 필드(재사용)
                        AuthTextField(text: $email, prompt: "이메일")
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .padding(.top, 55)
                        
                        //비밀번호 보안 텍스트 필드(재사용)
                        AuthSecureTextField(text: $password, prompt: "비밀번호")
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .padding(.top, 11)
                        
                        //로그인 오류 텍스트
                        Text("•  이메일 또는 비밀번호가 일치하지 않습니다.")
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                            .foregroundColor(Color(red: 1, green: 0.34, blue: 0.34))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 40)
                            .padding(.top, 18)
                            .opacity(isLoginError ? 1 : 0)
                            .frame(height: isLoginError ? nil : 0)
                        
                        //로그인 버튼(재사용)
                        WhiteButton(title: "로그인 하기", isEnabled: email.count > 0 && password.count > 0)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .padding(.top, 20)
                            .onTapGesture {
                                tapLoginButton(email: email, password: password) { isError in
                                    isLoginError = isError
                                }
                            }
                            .disabled(!(email.count > 0 && password.count > 0))
                        
                        
                        //비밀번호 찾기 네비게이션 링크 텍스트
                        NavigationLink {
                            FindPWView()
                        } label: {
                            Text("비밀번호 찾기")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                                .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                                .padding(.top, 80)
                        }
                        
                        Spacer()
                    })
                    
                    
                    LottieView(animation: .named("loading", bundle: .module))
                        .looping()
                        .opacity(isLoading ? 1 : 0)
                        .frame(width: geometry.size.width * 0.2, height: geometry.size.width * 0.2)
                }
                .navigationDestination(isPresented: $isCustomizationNotDone, destination: {
                    StartCostomizationView()
                        .environmentObject(customManager)
                })
                .navigationDestination(isPresented: $isLoginSuccess, destination: {
                    HomeView()
                })
                .frame(width: geometry.size.width + 1)
                .background(LibraryColorSet.background)
                .navigationBarBackButtonHidden()
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        SharedAsset.xWhite.swiftUIImage
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                dismiss()
                            }
                    }
                })
                .onTapGesture {
                    self.hideKeyboard()
                }
            }
        })
    }
    
    func tapLoginButton(email: String, password: String, completion: @escaping (Bool) -> Void){
        //Core에 정의해둔 FirebaseAuth
        isLoading = true
        let Firebase = FirebaseManager.shared
        let Auth = Firebase.auth
        let db = Firebase.db
        
        Auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("로그인 실패, \(error)")
                completion(true) //isLoginError = true -> 오류발생
            }else if let result = result{
                print("login success")
                db.collection("User").document(result.user.uid).getDocument { snapshot, error in
                    if let error = error {
                        
                    }else if let snapshot = snapshot {
                        guard let data = snapshot.data() else {
                            print("no data")
                            return
                        }
                        
                        userManager.uid = result.user.uid
                        userManager.id = data["id"] as? String ?? ""
                        userManager.nickname = data["nickname"] as? String ?? ""
                        userManager.email = data["email"] as? String ?? ""
                        userManager.signInMethod = data["signin_method"] as? String ?? ""
                        userManager.selectedNotificationTime = data["selected_notification_time"] as? Int ?? 0
                        userManager.isCheckedSocialNotification = data["is_checked_social_notification"] as? Bool ?? nil
                        userManager.isCheckedServiceNewsNotification = data["is_checked_service_news_notification"] as? Bool ?? nil
                        userManager.favoriteGenres = data["favorite_genres"] as? [Int] ?? []
                        
                        isCustomizationNotDone = userManager.id == ""
                        isLoginSuccess = userManager.id != ""
                        completion(false) //isLoginError = false -> 오류 미발생
                    }
                }
            }
            isLoading = false
        }
    }
}

#Preview {
    EmailLoginView()
}