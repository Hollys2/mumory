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
import FirebaseAuth

struct SignUpManageView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var manager: SignUpManageViewModel = SignUpManageViewModel()
    @State private var isSignUpCompleted = false
    @State private var isLoading = false
    
    var body: some View {
            ZStack{
                LibraryColorSet.background.ignoresSafeArea()
                GeometryReader(content: { geometry in

                VStack{
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
                                .padding(.trailing, setPadding(screen: geometry.size))
                    }
                    .padding(.top, 20)

                    //가입 절차 별 페이지
                    switch(manager.step){
                    case 0:
                        InputEmailView()
                            .environmentObject(manager)
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
                    case 1:
                        InputPWView()
                            .environmentObject(manager)
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    case 2:
                        TermsAndConditionsView()
                            .environmentObject(manager)
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    default:
                        EmptyView()
                    }

                    
                    Spacer()
                    
                    //다음 버튼
                    Button(action: {
                        //마지막 페이지에서 다음 버튼 클릭했을 때 실행
                        if manager.step == 2{
                            isLoading = true
                            createUser(email: manager.email, password: manager.password)
                        }
                        //절차 별 애니메이션 적용을 위한 조건 셋팅
                        withAnimation {
                            manager.step += 1
                        }
                    }, label: {
                        WhiteButton(title: manager.getButtonTitle(), isEnabled: manager.isButtonEnabled())
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                    })
                    .disabled(!manager.isButtonEnabled())
                }
                })
                
                //가장 마지막 뷰에서 회원가입 버튼을 누르고 대기할 때 보이는 뷰
                LottieView(animation: .named("loading", bundle: .module))
                    .opacity(isLoading ? 1 : 0)

            }
            .background(LibraryColorSet.background)
            .navigationBarBackButtonHidden()
            .toolbar(content: {
                //네비게이션 바 좌측 버튼
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        //뒤로 가기 눌렀을 때 실행되는 애니메이션을 위한 현재 페이지 조건 셋팅
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
                }
                
                //네비게이션 바 타이틀
                ToolbarItem(placement: .principal) {
                    Text(manager.getNavigationTitle())
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundColor(.white)
                }
            })
            //회원가입이 완료 되었을 때 다음 화면으로 이동
            .navigationDestination(isPresented: $isSignUpCompleted) {
                StartCostomizationView()
            }
        
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

    
    //스크린 별 다음 버튼 활성화 여부 설정
//    private func setButtonDisable(signUpModel: SignUpManageViewModel) -> Bool {
//        if isFirstStep{
//            return !signUpModel.isValidEmail
//        }else if isSecondStep{
//            return !(signUpModel.isValidPassword && signUpModel.isValidConfirmPassword)
//        }else if isThirdStep{
//            return !manager.isCheckedConsent
//        }
//        return true
//    }
    
    private func createUser(email: String, password: String){
        print("email: \(email), pw: \(password)")
        Auth.auth().createUser(withEmail: email, password: password) { data, error in
            if let error = error {
                print("create user error: \(error)")
                isSignUpCompleted = false
                //회원가입 실패시 실행시킬 코드 추가하기
            }else {
                print("create user success")
                guard let result = data else {return}
                let userDefault = UserDefaults.standard
                userDefault.setValue(result.user.uid, forKeyPath: "uid")
                isSignUpCompleted = true
            }
            
            isLoading = false
        }
    }
}

#Preview {
    SignUpManageView()
}
