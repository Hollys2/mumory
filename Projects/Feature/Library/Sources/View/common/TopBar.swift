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
    let leftButton: Image
    let title: String
    let rightButton: Image
    let leftButtonAction: () -> Void
    let rightButtonAction: () -> Void
    var body: some View {
        HStack{
            leftButton
                .frame(width: 30, height: 30)
                .onTapGesture {
                    leftButtonAction()
                }
            Spacer()
            Text(title)
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                .foregroundStyle(.white)
            Spacer()
            rightButton
                .frame(width: 30, height: 30)
                .onTapGesture {
                    rightButtonAction()
                }

        }
        .padding(.leading, 20)
        .padding(.trailing, 20)

    }
}

//#Preview {
//    TopBar()
//}
