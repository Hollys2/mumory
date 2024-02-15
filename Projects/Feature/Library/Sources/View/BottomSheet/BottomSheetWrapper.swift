//
//  MusickitTestView.swift
//  Feature
//
//  Created by 제이콥 on 2/3/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

public struct BottomSheetWrapper: View {
    @Environment(\.dismiss) private var dismiss
    @State var backgroundOpacity = 0.0
    @State var yOffset: CGFloat = 0
    @Binding var isPresent: Bool
    var content: () -> any View
    
    public init(isPresent: Binding<Bool>, @ViewBuilder content: @escaping () -> any View) {
        self._isPresent = isPresent
        self.content = content
    }
    
    public var body: some View {
            
            ZStack(alignment: .bottom, content: {
                Color.black.opacity(backgroundOpacity).ignoresSafeArea()
                    .onTapGesture {
                        backgroundOpacity = 0
                        dismiss()
                    }
                VStack(spacing: 0, content: {
                    SharedAsset.dragIndicator.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 47)
                        .padding(.top, 11)
                        .padding(.bottom, 4)
                    AnyView(content())
                    
                    
                })
                .frame(maxWidth: .infinity)
                .background(ColorSet.background)
                .cornerRadius(15, corners: [.allCorners])
                .padding(.horizontal, 7)
                .offset(y: yOffset)
                .gesture(drag)
                
            })
            .onAppear(perform: {
                withAnimation(.easeIn(duration: 0.5)){
                    backgroundOpacity = 0.7
                }
            })
            .onChange(of: isPresent, perform: { value in
                if !isPresent {
                    backgroundOpacity = 0.0
                }
            })
        
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged({ drag in
                yOffset = drag.location.y >= 0 ? drag.location.y : 0
            })
            .onEnded({ drag in
                if drag.location.y - drag.startLocation.y < 65  {
                    withAnimation(.linear(duration: 0.2)) {
                        yOffset = 0
                    }
                }else {
                    backgroundOpacity = 0
                    dismiss()
                }
                
            })
        
    }
}
