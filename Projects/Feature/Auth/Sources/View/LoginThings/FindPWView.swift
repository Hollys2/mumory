//
//  FindPWView.swift
//  Feature
//
//  Created by 제이콥 on 12/10/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core
import Lottie

struct FindPWView: View {
    @Environment(\.dismiss) private var dismiss
    @State var email: String = ""
    @State var errorText: String = ""
    @State var isError: Bool = false
    @State var isValidEmail: Bool = false
    @State var infoText = "•  가입하신 이메일 주소를 입력하시면 비밀번호 재설정 지침을\n    보내드립니다."
    @State var isLoading = false
    var body: some View {
        ZStack{
            LibraryColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0, content: {
                HStack{
                    SharedAsset.back.swiftUIImage
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            dismiss()
                        }
                    Spacer()
                }
                .padding(.horizontal)
                .frame(height: 63)
                
                //상단 타이틀
                Text("비밀번호 재설정")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 22))
                    .foregroundColor(.white)
                    .padding(.top, 30)
                
                //이메일 텍스트 필드(재사용)
                AuthTextField(text: $email, prompt: "가입한 이메일을 입력해주세요")
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.top, 55)
                    
                    Text(infoText)
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                        .foregroundStyle(isValidEmail ? ColorSet.mainPurpleColor : ColorSet.lightGray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 40)
                        .padding(.trailing, 40)
                        .padding(.top, 15)
                        .lineSpacing(4)
                
                Text(errorText)
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                    .foregroundStyle(ColorSet.errorRed)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 40)
                    .padding(.trailing, 40)
                    .padding(.top, 10)
                    .lineSpacing(4)
                    .opacity(isError ? 1 : 0)
                    .frame(height: isError ? nil : 0)
                                     
                
                
                //로그인 버튼(재사용)
                WhiteButton(title: "비밀번호 찾기", isEnabled: true)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.top, 30)
                    .onTapGesture {
                        if email.count == 0 {
                            withAnimation {
                                errorText = "•  이메일을 입력하세요."
                                isError = true
                                isValidEmail = false
                            }
                            
                        }else {
                            checkValidEmail(email: email)
                        }
                    }
                
                Spacer()
            })
            
            LoadingAnimationView(isLoading: $isLoading)
            
        }
        .background(LibraryColorSet.background)
        .navigationBarBackButtonHidden()
        .onTapGesture {
            self.hideKeyboard()
        }
    }

    
    private func checkValidEmail(email: String) {
        isLoading = true
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        let auth = Firebase.auth
        
        let query = db.collection("User")
            .whereField("email", isEqualTo: email)
            .whereField("signInMethod", isEqualTo: "Email")
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("get document error: \(error)")
                isLoading = false
                //다시시도
            }else if let snapshot = snapshot{
                print("docs count: \(snapshot.documents.count)")
                print("isempty:\(snapshot.documents.isEmpty)")
                if snapshot.documents.isEmpty{
                    isLoading = false
                    withAnimation {
                        errorText = "•  해당 이메일 주소가 존재하지 않습니다. 다시 한 번 \n    확인해 주세요."
                        isError = true
                        isValidEmail = false
                    }
                }else {
                    auth.sendPasswordReset(withEmail: email) { error in
                        if error == nil {
                            isLoading = false
                            withAnimation {
                                infoText = "•  비밀번호 재설정 지침서가 전송되었습니다. 입력하신 이메일\n    주소 보관함을 확인해보세요."
                                isError = false
                                isValidEmail = true
                            }
                        }
                    }
        
                }
            }
        }
        
    }
    
}

//#Preview {
//    FindPWView()
//}
