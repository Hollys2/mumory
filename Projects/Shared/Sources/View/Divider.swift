//
//  Divider.swift
//  Shared
//
//  Created by 제이콥 on 3/20/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI

public struct Divider05: View {
    public init(){}
    public var body: some View {
        Divider()
            .frame(maxWidth: .infinity)
            .frame(height: 0.5)
            .background(ColorSet.skeleton02)
    }
}

public struct Divider10: View {
    public init(){}
    public var body: some View {
        Divider()
            .frame(maxWidth: .infinity)
            .frame(height: 1)
            .background(ColorSet.skeleton02)
    }
}


public struct Divider03: View {
    public init(){}
    public var body: some View {
        Divider()
            .frame(maxWidth: .infinity)
            .frame(height: 0.3)
            .background(ColorSet.skeleton02)
    }
}
