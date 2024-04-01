//
//  InitialSettingView.swift
//  Shared
//
//  Created by 제이콥 on 4/1/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI

public struct InitialSettingView: View {
    let title: String
    let buttonTitle: String
    var buttonAction: () -> Void
    public init(title: String, buttonTitle: String, buttonAction: @escaping () -> Void) {
        self.title = title
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                .foregroundStyle(ColorSet.subGray)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
            
            Text(buttonTitle)
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundStyle(ColorSet.mainPurpleColor)
                .frame(height: 30)
                .padding(.horizontal, 10)
                .background(ColorSet.darkGray)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .circular))
                .onTapGesture {
                    buttonAction()
                }
        }
    }
}
