//
//  SignUpFinishView.swift
//  Feature
//
//  Created by 제이콥 on 12/10/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct SignUpFinishView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var signUpViewModel: SignUpViewModel
//    @State var isSignUpSuccess: Bool = false
    @State var isEntireChecked: Bool = false
    @State var isFirstStepChecked: Bool = false
    @State var isSecondStepChecked: Bool = false
    @State var isThirdStepChecked: Bool = false
    @State var isFourthStepChecked: Bool = false
    

    var body: some View {
        ZStack{
            LibraryColorSet.background.ignoresSafeArea()
            VStack(spacing: 0){
                
                Text("서비스 이용약관에\n동의해주세요")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 43)
                    .padding(.leading, 29)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 24))
                    .lineSpacing(7)
                
                Spacer()
                
                HStack{
                    Text("전체 동의")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if isFirstStepChecked&&isSecondStepChecked&&isThirdStepChecked&&isFourthStepChecked {
                        SharedAsset.checkCircleFill.swiftUIImage
                            .onTapGesture {
                                isEntireChecked = !(isFirstStepChecked&&isSecondStepChecked&&isThirdStepChecked&&isFourthStepChecked)
                                isFirstStepChecked = isEntireChecked
                                isSecondStepChecked = isEntireChecked
                                isThirdStepChecked = isEntireChecked
                                isFourthStepChecked = isEntireChecked
                            }
                    }else {
                        SharedAsset.checkCircle.swiftUIImage
                            .onTapGesture {
                                isEntireChecked = !(isFirstStepChecked&&isSecondStepChecked&&isThirdStepChecked&&isFourthStepChecked)
                                isFirstStepChecked = isEntireChecked
                                isSecondStepChecked = isEntireChecked
                                isThirdStepChecked = isEntireChecked
                                isFourthStepChecked = isEntireChecked
                            }
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                
                SignUpConsentItem(type: .required, title: "이용약관 동의", isChecked: $isFirstStepChecked)
                    .padding(.top, 48)
                    .onChange(of: isFirstStepChecked, perform: { value in
                        print("tap 1")
                        signUpViewModel.isCheckedConsent = isFirstStepChecked && isSecondStepChecked
                        print("result: \(signUpViewModel.isCheckedConsent)")

                    })
                
                SignUpConsentItem(type: .required, title: "개인정보 수집 및 이용 동의", isChecked: $isSecondStepChecked)
                    .padding(.top, 35)
                    .onChange(of: isSecondStepChecked, perform: { value in
                        print("tap 2")
                        signUpViewModel.isCheckedConsent = isFirstStepChecked && isSecondStepChecked
                        print("result: \(signUpViewModel.isCheckedConsent)")
                    })
                
                SignUpConsentItem(type: .select, title: "마케팅 정보 수신 동의", isChecked: $isThirdStepChecked)
                    .padding(.top, 35)

                
                SignUpConsentItem(type: .select, title: "이벤트 앱 푸시 수신 동의", isChecked: $isFourthStepChecked)
                    .padding(.top, 35)
                    .padding(.bottom, 64)
            }
        }
    }
}

#Preview {
    SignUpFinishView()
}
