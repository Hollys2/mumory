//
//  NavigationTitle.swift
//  Shared
//
//  Created by Kane on 9/10/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI

public struct NavigationTitle: View {
    // MARK: - Object lifecycle
    public init(title: String) {
        self.title = title
    }
    
    // MARK: - Propoerties
    let title: String
    
    // MARK: - View
    public var body: some View {
        Text(title)
            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
            .foregroundStyle(.white)
    }
}
