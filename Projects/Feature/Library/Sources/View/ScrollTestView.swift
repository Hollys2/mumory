//
//  ScrollTestView.swift
//  Feature
//
//  Created by 제이콥 on 1/26/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI

struct ScrollTestView: View {
    @State private var contentOffset: CGPoint = .zero
    @State private var scrollViewHeight: CGFloat = .zero
    @State private var scrollViewVisibleHeight: CGFloat = .zero
    
    var body: some View {
        ZStack{
            Color.yellow
            ScrollViewWrapper(contentOffset: $contentOffset, scrollViewHeight: $scrollViewHeight, visibleHeight: $scrollViewVisibleHeight) {
                
                ForEach(0...100, id: \.self){index in
                    Rectangle()
                        .foregroundStyle(.yellow)
                }
                .background(.yellow)
                
            }
            .background(.yellow)
        }
    }
}

#Preview {
    ScrollTestView()
}
