//
//  SignUpView.swift
//  Feature
//
//  Created by 제이콥 on 12/10/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var signUpViewModel: SignUpViewModel = SignUpViewModel()
    
    //app coordinator 역할을 할 조건들
    @State private var isFirstStep = true
    @State private var isSecondStep = false
    @State private var isThirdStep = false
    @State private var isAllDone = false
    
    @State private var isProgressViewHidden = true
    
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
                    if isFirstStep{
                        SignUpWithEmailView()
                            .environmentObject(signUpViewModel)
                    }else if isSecondStep{
                        InputPWView()
                            .environmentObject(signUpViewModel)
                            .transition(AnyTransition.move(edge: .trailing))

                    }else if isThirdStep{
                        SignUpFinishView()
                            .environmentObject(signUpViewModel)
                            .transition(AnyTransition.move(edge: .trailing))

                    }
                        
                    
                    Spacer()
                    
                    //다음 버튼
                    WhiteButton(title: isThirdStep ? "회원가입" : "다음", isEnabled: !setButtonDisable(signUpModel: signUpViewModel))
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                        .onTapGesture {
                            //마지막 페이지에서 다음 버튼 클릭했을 때 실행
                            if isThirdStep{
                                isProgressViewHidden = false
                                createUser(email: signUpViewModel.email, password: signUpViewModel.password)
                            }
                            
                            //절차 별 애니메이션 적용을 위한 조건 셋팅
                            withAnimation {
                                if isFirstStep {
                                    isFirstStep = false
                                    isSecondStep = true
                                } else if isSecondStep {
                                    isSecondStep = false
                                    isThirdStep = true
                                } else if isAllDone {
                                    isThirdStep = false
                                }
                            }
                            
                        }
                    //이메일 형식 만족, 비밀번호와 비밀번호 확인 모두 만족. 둘 중 하나 만족시 활성화
                        .disabled(setButtonDisable(signUpModel: signUpViewModel))
                        
                
                }
                })
                
                //가장 마지막 뷰에서 회원가입 버튼을 누르고 대기할 때 보이는 뷰
                ProgressView()
                    .opacity(isProgressViewHidden ? 0 : 1)

            }
            .background(LibraryColorSet.background)
            .navigationBarBackButtonHidden()
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    SharedAsset.back.swiftUIImage
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            //뒤로 가기 눌렀을 때 실행되는 애니메이션을 위한 현재 페이지 조건 셋팅
                            withAnimation {
                                if isFirstStep {
                                    dismiss()
                                } else if isSecondStep {
                                    isSecondStep = false
                                    isFirstStep = true
                                } else if isThirdStep {
                                    isThirdStep = false
                                    isSecondStep = true
                                }
                            }
                        }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(setTitle())
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundColor(.white)
                }
            })
        //회원가입이 완료 되었을 때 다음 화면으로 이동
            .navigationDestination(isPresented: $isAllDone) {
                StartCostomizationView()
            }
        
    }
    
    //스크린 별 상단 라인 너비 조절(스텝 별 길이 상이)
    private func setPadding(screen: CGSize) -> CGFloat {
        if isFirstStep {
            return screen.width * (3/4)
        } else if isSecondStep {
            return screen.width * (2/4)
        } else if isThirdStep {
            return screen.width * (1/4)
        } else if isAllDone {
            return 0
        }
        return 0
    }
    
    //스크린 별 네이베이션 바 타이틀 텍스트
    private func setTitle() -> String {
        if isFirstStep{
            return "이메일로 가입하기"
        }else if isSecondStep{
            return "비밀번호 입력하기"
        }else if isThirdStep{
            return ""
        }
        return ""
    }
    
    //스크린 별 다음 버튼 활성화 여부 설정
    private func setButtonDisable(signUpModel: SignUpViewModel) -> Bool {
        if isFirstStep{
            return !signUpModel.isValidEmail
        }else if isSecondStep{
            return !(signUpModel.isValidPassword && signUpModel.isValidConfirmPassword)
        }else if isThirdStep{
            return !signUpViewModel.isCheckedConsent
        }
        return true
    }
    
    private func createUser(email: String, password: String){
        print("email: \(email), pw: \(password)")
        let Auth = AuthManager.shared.firebaseAuth
        Auth.createUser(withEmail: email, password: password) { data, error in
            if let error = error {
                print("create user error: \(error)")
                isAllDone = false
                isProgressViewHidden = true
                //회원가입 실패시 실행시킬 코드 추가하기
            }else {
                print("create user success")
                guard let result = data else {return}
                let userDefault = UserDefaults.standard
                userDefault.setValue(result.user.uid, forKeyPath: "uid")
                isProgressViewHidden = false
                isAllDone = true
                
            }
        }
    }
}

#Preview {
    SignUpView()
}
