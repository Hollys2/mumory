//
//  PopupAlertModifier.swift
//  Shared
//
//  Created by Kane on 9/8/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI

struct PopupAlertModifier: ViewModifier {
    @Binding var isPresent: Bool
    let alertView: any View
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresent, content: {
                ZStack(content: {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    AnyView(alertView)
                })
                .background(TransparentBackground())
            })
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
    }
}
