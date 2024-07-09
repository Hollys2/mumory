//
//  SignUpViewEmailView.swift
//  Feature
//
//  Created by 제이콥 on 12/10/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core

///유효성 검사 결과 타입 - 중복 에러 포함
public enum ValidationState {
    case none
    case valid
    case formatError
    case duplicationError
}

public struct EmailInputView: View {
    // MARK: - Object lifecycle
    init() {}
    
    // MARK: - Propoerties
    

    
    @EnvironmentObject var signUpViewModel: SignUpViewModel
    @State var previousEmail: String = ""
    @State var timer: Timer?
    @State private var validationStatus: ValidationState = .none
    @FocusState var isFocused: Bool
    
    // MARK: - View
    public var body: some View {
        VStack(spacing: 0, content: {
            
            TitleTextForSignUpField(title: "이메일", topPadding: 43)
                
            RoundedTextField(text: $signUpViewModel.email, placeHolder: "ex) abcdefg@hhhhh.com", fontSize: 16)
                .padding(.top, 14)
                .padding(.horizontal, 20)
                .focused($isFocused)
                .onChange(of: signUpViewModel.email, perform: { value in
                    setValidation(state: .none)
                    if !(timer?.isValid ?? false) {
                        setTimerFunctionedForCheckingEmailValidation()
                    }
                })
            
            FeedbackTextForSignUp(title: getFeedbackMsg(), isValid: signUpViewModel.isValidEmail)
        })
        .onAppear(perform: {
            setTimerFunctionedForCheckingEmailValidation()
        })
        .onDisappear(perform: {
            self.timer?.invalidate()
        })
    }
    
    // MARK: - Methods
    private func setTimerFunctionedForCheckingEmailValidation() {
        self.previousEmail = self.signUpViewModel.email
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { timer in
            signUpViewModel.isLoading = true
            guard !signUpViewModel.email.isEmpty else {
                setValidation(state: .none)
                return
            }
            
            let isEndEditing = (previousEmail == signUpViewModel.email)
            guard isEndEditing else {
                previousEmail = signUpViewModel.email
                return
            }
            
            guard isCorrectFormat() else {
                setValidation(state: .formatError)
                return
            }
            
            Task {
                if await isValidEmail() {
                    setValidation(state: .valid)
                    self.timer?.invalidate()
                } else {
                    setValidation(state: .duplicationError)
                }
            }
            
        }
    }
    
    private func isCorrectFormat() -> Bool{
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        
        return emailPredicate.evaluate(with: self.signUpViewModel.email)
    }
    
    private func isValidEmail() async -> Bool {
        let db = FirebaseManager.shared.db
        let query = db.collection("User").whereField("email", isEqualTo: signUpViewModel.email)
        guard let documents = try? await query.getDocuments() else {return false}
        
        return documents.isEmpty
    }
    
    private func getFeedbackMsg() -> String {
        switch self.validationStatus {
        case .valid:
            return "올바른 형식 입니다."
        case .formatError:
            return "이메일 형식이 올바르지 않습니다. :("
        case .duplicationError:
            return "이미 사용 중인 이메일입니다."
        default: return ""
        }
    }
    
    ///유효성 결과 설정 및 로딩 상태, 회원가입 뷰모델 내부 이메일 값 수정
    private func setValidation(state: ValidationState) {
        self.validationStatus = state
        signUpViewModel.isValidEmail = (validationStatus == .valid)
        signUpViewModel.isLoading = false
    }
}
