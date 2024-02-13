//
//  TopBar.swift
//  Feature
//
//  Created by 제이콥 on 1/26/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct TopBar: View {
    let leftButton: Image?
    let title: String
    let rightButton: Image?
    let leftButtonAction: (() -> Void)?
    let rightButtonAction: (() -> Void)?
    var body: some View {
        HStack(){
            if leftButton != nil {
                leftButton
                    .onTapGesture {
                        leftButtonAction!()
                    }
            }else {
                Rectangle()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.clear)
            }
            
            Spacer()
            
            Text(title)
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                .foregroundStyle(.white)
            
            Spacer()
            
            if rightButton != nil {
                rightButton
                    .onTapGesture {
                        rightButtonAction!()
                    }
            }else {
                Rectangle()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.clear)
            }

        }
        .padding(.horizontal, 20)
        .frame(height: 50)

    }
}

//#Preview {
//    TopBar()
//}
