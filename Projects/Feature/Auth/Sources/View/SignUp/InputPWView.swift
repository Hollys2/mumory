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
                    manager.password = value
                })
            
            Text("영문, 숫자, 특수기호로 모두 조합된 8~20자")
                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                .foregroundColor(Color(red: 1, green: 0.34, blue: 0.34))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 40)
                .padding(.top, 15)
                .opacity(password.count < 1 ? 0 : manager.isValidPassword() ? 0 : 1)
                .frame(height: password.count < 1 ? 0 : manager.isValidPassword() ? 0 : nil)
            
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
                    manager.confirmPassword = value
                })

            
            Text("비밀번호가 다릅니다. 다시 한 번 확인해 주세요.")
                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                .foregroundColor(Color(red: 1, green: 0.34, blue: 0.34))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 40)
                .padding(.top, 15)
                .opacity(confirmPassword.count < 1 ? 0 : (password == confirmPassword) ? 0 : 1)
                .frame(height: confirmPassword.count < 1 ? 0 : (password == confirmPassword) ? 0 : nil)
        }
        .onAppear(perform: {
            //앞페이지에서 뒤로가기 했을 때 이전에 작성해놓은 비밀번호가 다시 보일 수 있도록 함
            if manager.isValidPassword() && manager.isValidConfirmPassword(){
                password = manager.password
                confirmPassword = manager.confirmPassword
            }
        })
    }
}

//#Preview {
//    InputPWView()
//}

