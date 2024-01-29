//
//  SignUpManageViewModel.swift
//  Feature
//
//  Created by 제이콥 on 1/30/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation

enum page {
    case email
    case password
    case condition
}

public class SignUpManageViewModel: ObservableObject{
    public init(){}
    @Published var step: Int = 0
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var isCheckedRequiredItems: Bool = false
    @Published var isCheckedMarketingNotification: Bool = false
    @Published var isCheckedEventNotification: Bool = false

    

    public func getNavigationTitle() -> String {
        switch(step){
        case 0: return "이메일로 가입하기"
        case 1: return "비밀번호 입력하기"
        default: return ""
        }
    }
    
    public func getButtonTitle() -> String {
        switch(step){
        case 0, 1: return "다음"
        case 2: return "회원가입"
        default: return ""
        }
    }
    
    public func isButtonEnabled() -> Bool {
        switch(step){
        case 0: return isValidEmail()
        case 1: return isValidPassword() && isValidConfirmPassword()
        default: return false
        }
    }
    
    public func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    public func isValidPassword() -> Bool {
        let passwordRegex = "^(?=.*[a-zA-Z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
        let passwordPredicate = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    public func isValidConfirmPassword() -> Bool {
        return (password == confirmPassword)
    }
}
