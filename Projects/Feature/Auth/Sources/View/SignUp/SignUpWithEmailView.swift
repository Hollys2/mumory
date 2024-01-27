//
//  SignUpViewEmailView.swift
//  Feature
//
//  Created by 제이콥 on 12/10/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared

public struct SignUpWithEmailView: View {
    @EnvironmentObject var signUpViewModel: SignUpViewModel
    @State var email: String = ""
    @State var isValidEmail: Bool = false
    
    public init(){}
    
    public var body: some View {
            VStack(spacing: 0, content: {
                //이메일 표시 텍스트
                Text("이메일")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 23)
                    .padding(.top, 43)
                
                //이메일 입력 텍스트 필드
                HStack(spacing: 0){
                    TextField("email", text: $email)
                        .frame(maxWidth: .infinity)
                        .padding(.leading, 25)
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                        .foregroundColor(.white)
                    
                    SharedAsset.xWhiteCircle.swiftUIImage
                        .frame(width: 23, height: 23)
                        .padding(.trailing, 17)
                        .padding(.leading, 5)
                        .onTapGesture {
                            email = ""
                        }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(Color(red: 0.24, green: 0.24, blue: 0.24))
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30)))
                .onChange(of: email, perform: { value in
                        isValidEmail = isValidEmailStyle(email: value)
                        signUpViewModel.isValidEmail = isValidEmail
                    })
                
                //이메일 형식 오류 텍스트
                Text("이메일 형식이 올바르지 않습니다 :(")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                    .foregroundColor(Color(red: 1, green: 0.34, blue: 0.34))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 40)
                    .padding(.top, 15)
                    .opacity(email.count < 1 ? 0 : isValidEmail ? 0 : 1)
                
                
            })
            .onDisappear(perform: {
                if isValidEmail{
                    signUpViewModel.email = email
                }
            })
        
    }
    func getPrompt() -> Text {
        return Text("ex) abcdefg@hhhhh.com")
            .foregroundColor(Color(red: 0.77, green: 0.77, blue: 0.77))
            .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 18))
    }
    
    private func isValidEmailStyle(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

#Preview {
    SignUpWithEmailView()
}
