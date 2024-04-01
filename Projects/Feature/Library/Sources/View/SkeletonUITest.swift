//
//  SkeletonUITest.swift
//  Feature
//
//  Created by 제이콥 on 3/22/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct SkeletonUITest: View {
    @State var isShown: Bool = false
    var body: some View {
        ZStack(alignment: .top) {
            SharedAsset.skeletonUITest.swiftUIImage
                .ignoresSafeArea()
                .scaledToFill()
                .overlay {
                    Color.black.opacity(isShown ? 0 : 0.5)
                        .animation(Animation.linear(duration: 1.0).repeatForever(autoreverses: true), value: isShown)
                }
                .onAppear(perform: {
                    isShown.toggle()
                })
        }
        .ignoresSafeArea()

    }
}

