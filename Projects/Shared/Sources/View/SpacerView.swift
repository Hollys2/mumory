//
//  SpacerView.swift
//  Shared
//
//  Created by Kane on 9/10/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI

public struct SpacerView: View {
    public init(height: CGFloat) {
        self.height = height
    }
    let height: CGFloat
    
    public var body: some View {
        Rectangle()
            .foregroundStyle(.clear)
            .frame(height: height)
    }
}
