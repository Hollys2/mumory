//
//  AnimationWrapper.swift
//  Feature
//
//  Created by 제이콥 on 3/20/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MapKit

struct AnimationWrapper: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @Environment(\.dismiss) var dismiss
    @State var backgroundOpacity = 0.0
    @State var isPresentBottomSheet: Bool = true
    @State private var region: MKCoordinateRegion?

    var body: some View {
        ZStack(alignment: .bottom) {
//            Color.black.opacity(backgroundOpacity).ignoresSafeArea()
//                .onTapGesture {
//                    backgroundOpacity = 0
//                    dismiss()
//                }
            
            CreateMumoryBottomSheetView(isSheetShown: $appCoordinator.isCreateMumorySheetShown, offsetY: $appCoordinator.offsetY, newRegion: self.$region)
                .onChange(of: appCoordinator.isCreateMumorySheetShown) { newValue in
                    if !newValue {
                        dismiss()
                    }
                }
        }
        .onAppear {
            UIView.setAnimationsEnabled(true)
            Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { timer in
                withAnimation(.easeOut(duration: 0.13)) {
                    isPresentBottomSheet = true
                }
            }
        }
    }
}

#Preview {
    AnimationWrapper()
}
