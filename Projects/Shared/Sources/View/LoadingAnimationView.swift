//
//  LoadingAnimationView.swift
//  Shared
//
//  Created by 제이콥 on 2/27/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Lottie

public struct LoadingAnimationView: View {
    @Binding var isLoading: Bool
    
    public init(isLoading: Binding<Bool>) {
        self._isLoading = isLoading
    }
    
    public var body: some View {
        ZStack(alignment: .center){
            
            LottieView(animation: .named("loading", bundle: .module))
                .looping()
                .opacity(isLoading ? 1 : 0)
                .frame(width: getUIScreenBounds().width * 0.16, height: getUIScreenBounds().width * 0.16)
        }
        .ignoresSafeArea()
    }
}



//#Preview {
//    LoadingAnimationView(isLoading: .constant(true))
//}
