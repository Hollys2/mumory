//
//  SignUpView.swift
//  Feature
//
//  Created by 제이콥 on 12/10/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Lottie
import Core


struct SignUpManageView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var appCoordinator: AppCoordinator

    @StateObject var manager: SignUpManageViewModel = SignUpManageViewModel()

    @State private var isSignUpCompleted = false
    @State private var isSignUpErrorShowing: Bool = false
    @State private var isTapBackButton: Bool = false
    
    var body: some View {
            ZStack{
                LibraryColorSet.background.ignoresSafeArea()
                
                VStack{
                    HStack{
                        Button(action: {
                            //뒤로 가기 눌렀을 때 실행되는 애니메이션을 위한 현재 페이지 조건 셋팅
                            isTapBackButton = true
                            if manager.step == 0 {
                                dismiss()
                            }else{
                                withAnimation {
                                    manager.step -= 1
                                }
                            }
                            
                        }, label: {
                            SharedAsset.back.swiftUIImage
                                .frame(width: 30, height: 30)
                        })
                        
                        Spacer()
                        
                        Text(manager.getNavigationTitle())
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                            .foregroundColor(.white)
                        
                        Spacer()

                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 30, height: 30)
                        
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 65)
                    //가입 절차 인디케이터(회색, 흰색 라인)
                    ZStack{
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .foregroundColor(Color(red: 0.37, green: 0.37, blue: 0.37))
                        
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .foregroundColor(.white)
                            .padding(.trailing, setPadding(screen: CGSize(width: getUIScreenBounds().width, height: getUIScreenBounds().height)))
                    }
                    
                    //가입 절차 별 페이지
                    switch(manager.step){
                    case 0:
                        InputEmailView()
                            .environmentObject(manager)
                            .transition(.asymmetric(insertion: .move(edge: isTapBackButton ? .leading : .trailing), removal: .move(edge: isTapBackButton ? .trailing : .leading)))
                            .onAppear(perform: {
                                isTapBackButton = false
                            })
                    case 1:
                        ScrollView {
                            InputPWView()
                                .environmentObject(manager)
                                .transition(.asymmetric(insertion: .move(edge: isTapBackButton ? .leading : .trailing), removal: .move(edge: isTapBackButton ? .trailing : .leading)))
                                .onAppear(perform: {
                                    isTapBackButton = false
                                })
                        }
               
                    case 2:
                        TermsOfServiceView()
                            .environmentObject(manager)
                            .transition(.asymmetric(insertion: .move(edge: isTapBackButton ? .leading : .trailing), removal: .move(edge: isTapBackButton ? .trailing : .leading)))
                            .onAppear(perform: {
                                isTapBackButton = false
                            })
                    default:
                        EmptyView()
                    }
                    
                    
                    Spacer()
                    
                    //다음 버튼
                    Button(action: {
                        //마지막 페이지에서 다음 버튼 클릭했을 때 실행
                        if manager.step == 2{
                            manager.isLoading = true
                            createUser(email: manager.email, password: manager.password)
                        }else{
                            withAnimation {
                                manager.step += 1
                            }
                        }
                        
                    }, label: {
                        MumoryLoadingButton(title: manager.getButtonTitle(), isEnabled: manager.isButtonEnabled(), isLoading: $manager.isLoading)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                    })
                    .disabled(manager.isLoading || !manager.isButtonEnabled())
                }
                
            }
            .background(LibraryColorSet.background)
            .navigationBarBackButtonHidden()
            .gesture(DragGesture().onEnded({ gesture in
                if gesture.location.x - gesture.startLocation.x > 80 {
                    isTapBackButton = true
                    if manager.step == 0 {
                        dismiss()
                    }else{
                        withAnimation {
                            manager.step -= 1
                        }
                    }
                    
                }
            }))
            .onTapGesture {
                self.hideKeyboard()
            }
            .disabled(manager.isLoading)
            .fullScreenCover(isPresented: $isSignUpErrorShowing, content: {
                OneButtonOnlyConfirmPopupView(title: "알 수 없는 오류가 발생했습니다.")
                    .background(TransparentBackground())
            })

    }
    
    //스크린 별 상단 라인 너비 조절(스텝 별 길이 상이)
    private func setPadding(screen: CGSize) -> CGFloat {
        switch(manager.step){
        case 0: return screen.width * (3/4)
        case 1: return screen.width * (2/4)
        case 2: return screen.width * (1/4)
        default: return screen.width
        }
    }
    
    private func createUser(email: String, password: String){
        let auth = FBManager.shared.auth
        auth.createUser(withEmail: email, password: password) { data, error in
            if let error = error {
                print("create user error: \(error)")
                manager.isLoading = false
                UIView.setAnimationsEnabled(false)
                isSignUpErrorShowing = true
            }else {
                print("create user success")
                guard let result = data else {return}
                
                let userDefault = UserDefaults.standard
                userDefault.setValue(result.user.uid, forKeyPath: "uid")
                
                uploadUserData(uid: result.user.uid)
            }
        }
    }
    
    private func uploadUserData(uid: String){
        let Firebase = FBManager.shared
        let db = Firebase.db
        let messaging = Firebase.messaging
        let query = db.collection("User").document(uid)
        
        //유저데이터 업로드
        let userData: [String : Any] = [
            "uid": uid,
            "email": manager.email,
            "signInMethod": "Email",
            "isSubscribedToService": manager.isCheckedServiceNewsNotification,
            "isSubscribedToSocial": true,
            "fcmToken": messaging.fcmToken ?? "",
            "signUpDate": Date()
        ]
        
        if manager.isCheckedServiceNewsNotification {
            messaging.subscribe(toTopic: "Service")
        }
        
        messaging.subscribe(toTopic: "Social")
        
        
        query.setData(userData) { error in
            if let error = error {
                print("firestore error \(error)")
                isSignUpErrorShowing = true
                manager.isLoading = false
            }else {
                print("firestore upload user data successful")
                manager.isLoading = false
                isSignUpCompleted = true
                appCoordinator.rootPath.append(MumoryPage.startCustomization)
            }
        }

    }
}

//#Preview {
//    SignUpManageView()
//}
