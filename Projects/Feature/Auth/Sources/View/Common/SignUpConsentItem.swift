//
//  SignUpConsentItem.swift
//  Feature
//
//  Created by 제이콥 on 12/10/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared

enum ChoiceType{
    case required
    case select
}

struct SignUpConsentItem: View {
    var type: ChoiceType
    var title: String
    @Binding var isChecked: Bool
    var body: some View {
        HStack(spacing: 5){
            
            //필수, 선택 머리말
            switch(type){
            case .required:
                Text("(필수)")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                    .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
            case .select:
                Text("(선택)")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
            }
            
            //동의 항목 타이틀
            Text(title)
                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
            
            //타입 별 보기 여부
            switch(type){
            case .required:
                Text("보기")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                    .padding(.leading, 5)
                    .underline()
                
            case .select:
                EmptyView()
            }
            
            Spacer()
            
            if isChecked{
                SharedAsset.checkFill.swiftUIImage
                    .onTapGesture {
                        isChecked.toggle()
                    }
            }else {
                SharedAsset.check.swiftUIImage
                    .onTapGesture {
                        isChecked.toggle()
                    }
            }
            
            
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 20)
        .padding(.trailing, 24)
    }
}

//#Preview {
//    SignUpConsentItem(type: .required, title: "이용약관 동의")
//}
