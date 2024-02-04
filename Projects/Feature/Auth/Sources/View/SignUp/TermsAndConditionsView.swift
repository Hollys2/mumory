//
//  SignUpFinishView.swift
//  Feature
//
//  Created by 제이콥 on 12/10/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct TermsAndConditionsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var manager: SignUpManageViewModel
//    @State var isSignUpSuccess: Bool = false
    @State var isEntireChecked: Bool = false
    @State var isCheckedFirstItem: Bool = false
    @State var isCheckedSecondItem: Bool = false
    @State var isCheckedThirdItem: Bool = false

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
                    
                    //동의항목 선택 여부에 따라 전체동의 아이콘 변경 및 동작
                    if isCheckedFirstItem&&isCheckedSecondItem&&isCheckedThirdItem {
                        SharedAsset.checkCircleFill.swiftUIImage
                            .onTapGesture {
                                isEntireChecked = 
                                !(isCheckedFirstItem&&isCheckedSecondItem&&isCheckedThirdItem)
                                
                                isCheckedFirstItem = isEntireChecked
                                isCheckedSecondItem = isEntireChecked
                                isCheckedThirdItem = isEntireChecked
                            }
                    }else {
                        SharedAsset.checkCircle.swiftUIImage
                            .onTapGesture {
                                isEntireChecked = 
                                !(isCheckedFirstItem&&isCheckedSecondItem&&isCheckedThirdItem)
                                
                                isCheckedFirstItem = isEntireChecked
                                isCheckedSecondItem = isEntireChecked
                                isCheckedThirdItem = isEntireChecked
                            }
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                
                SignUpConsentItem(type: .required, title: "이용약관 동의", isChecked: $isCheckedFirstItem)
                    .padding(.top, 48)
                    .onChange(of: isCheckedFirstItem, perform: { value in
                        //필수항목 2가지 모두 체크 되어있는지 확인
                        manager.isCheckedRequiredItems = isCheckedFirstItem && isCheckedSecondItem
                    })
                
                SignUpConsentItem(type: .required, title: "개인정보 수집 및 이용 동의", isChecked: $isCheckedSecondItem)
                    .padding(.top, 35)
                    .onChange(of: isCheckedSecondItem, perform: { value in
                        //필수항목 2가지 모두 isCheckedRequiredItems 되어있는지 확인
                        manager.isCheckedRequiredItems = isCheckedFirstItem && isCheckedSecondItem
                    })
                
                SignUpConsentItem(type: .select, title: "서비스 소식 수신 동의", isChecked: $isCheckedThirdItem)
                    .padding(.top, 35)
                    .onChange(of: isCheckedThirdItem, perform: { value in
                        manager.isCheckedServiceNewsNotification = value
                    })
            }
            
        }
    }
}

//#Preview {
//    TermsAndConditionsView()
//}
