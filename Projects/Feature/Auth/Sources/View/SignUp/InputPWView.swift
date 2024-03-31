//
//  InputPasswordView.swift
//  Feature
//
//  Created by 제이콥 on 12/10/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
enum Field {
    case password
    case confirm
}
struct InputPWView: View {
    @EnvironmentObject var manager: SignUpManageViewModel
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @FocusState private var focusedField: Field?
    
    @State var passwordTime = 0.0
    @State private var passwordTimer: Timer?

    @State var confirmTime = 0.0
    @State private var confirmTimer: Timer?
    var body: some View {
        VStack(spacing: 0){
            Text("비밀번호")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 23)
                .padding(.top, 43)
            
            AuthSecureFieldSmall(text: $password, prompt: "영문, 숫자, 특수기호로 모두 조합된 8~20자")
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.top, 14)
                .onChange(of: password, perform: { value in
                    passwordTime = 0
                    manager.isValidPassword = false
                })
                .onChange(of: passwordTime, perform: { value in
                    if passwordTime == 0.8 {
                        DispatchQueue.main.async {
                            isValidPassword(password: password)
                            isValidConfirmPassword(confirmPassword: confirmPassword)
                        }
                    }
                })
            
            Text(manager.isValidPassword ? "올바른 형식 입니다." : "영문, 숫자, 특수기호로 모두 조합된 8~20자")
                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                .foregroundColor(manager.isValidPassword ? ColorSet.validGreen : ColorSet.errorRed)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 40)
                .padding(.top, 15)
                .frame(height: password.count == 0 ? 0 : passwordTime < 0.8 ? 0 : nil)
                .opacity(password.count == 0 ? 0 : passwordTime < 0.8 ? 0 : 1)
            
            Text("비밀번호 확인")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 23)
                .padding(.top, 33)
            
            AuthSecureFieldSmall(text: $confirmPassword, prompt: "한 번 더 입력해 주세요!")
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.top, 11)
                .onChange(of: confirmPassword, perform: { value in
                    confirmTime = 0
                    manager.isValidConfirmPassword = false
                })
                .onChange(of: confirmTime, perform: { value in
                    if confirmTime == 0.8 {
                        DispatchQueue.main.async {
                            isValidConfirmPassword(confirmPassword: confirmPassword)
                        }
                    }
                })

            
            Text(manager.isValidConfirmPassword ? "비밀번호가 일치합니다." : "비밀번호가 다릅니다. 다시 한 번 확인해 주세요.")
                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                .foregroundColor(manager.isValidConfirmPassword ? ColorSet.validGreen : ColorSet.errorRed)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 40)
                .padding(.top, 15)
                .frame(height: confirmPassword.count == 0 ? 0 : confirmTime < 0.8 ? 0 : nil)
                .opacity(confirmPassword.count == 0 ? 0 : confirmTime < 0.8 ? 0 : 1)
        }
        .onAppear(perform: {
            //앞페이지에서 뒤로가기 했을 때 이전에 작성해놓은 비밀번호가 다시 보일 수 있도록 함
            manager.isLoading = false
            if manager.isValidPassword && manager.isValidConfirmPassword{
                password = manager.password
                confirmPassword = manager.password
            }
            self.passwordTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
                passwordTime += 0.2
            }
            self.confirmTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { timer in
                confirmTime += 0.2
            })
        })
        .onDisappear(perform: {
            if manager.isValidPassword && manager.isValidConfirmPassword{
                manager.password = password
            }
            self.passwordTimer?.invalidate()
            self.confirmTimer?.invalidate()
        })
    }
    
    public func isValidPassword(password: String) {
        let passwordRegex = "^(?=.*[a-zA-Z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,20}$"
        let passwordPredicate = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        manager.isValidPassword = passwordPredicate.evaluate(with: password)
    }
    
    public func isValidConfirmPassword(confirmPassword: String){
        manager.isValidConfirmPassword = (password == confirmPassword)
        
    }
}

//#Preview {
//    InputPWView()
//}

