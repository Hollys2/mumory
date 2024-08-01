//
//  extension+View.swift
//  Shared
//
//  Created by 다솔 on 2024/03/28.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import Lottie

extension View {

    public func generateHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

extension View {
    
    public func bottomSheet(sheet: Binding<Sheet>, mumoryBottomSheet: MumoryBottomSheet) -> some View {
        self.modifier(BottomSheetViewModifier(sheet: sheet, mumoryBottomSheet: mumoryBottomSheet))
    }
    
    public func rewardBottomSheet(isShown: Binding<Bool>) -> some View {
        self.modifier(RewardBottomSheetViewModifier(isShown: isShown))
    }
}

extension View {
  public func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}

private struct LoadingLottie: ViewModifier {
    
    var isShown: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if self.isShown {
                LottieView(animation: .named("loading", bundle: .module))
                    .looping()
                    .frame(width: UIScreen.main.bounds.width * 0.16, height: UIScreen.main.bounds.width * 0.16)
            }

        }
        .ignoresSafeArea()
    }
}

//extension View {
//
//    public func loadingLottie(_ isShown: Bool) -> some View {
//        modifier(LoadingLottie(isShown: isShown))
//    }
//}
