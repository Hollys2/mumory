//
//  PlayQueueView.swift
//  Feature
//
//  Created by 제이콥 on 2/20/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct PlayQueueView: View {
    @State var offset: CGPoint = .zero
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            VStack{
                SharedAsset.xWhite.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 20)
                    .padding(.vertical, 15)
                
                HStack{
                    Text("재생목록")
                    SharedAsset.downArrow.swiftUIImage
                        .resizable()
                        .frame(width: 18, height: 18)
                }
                
                
                SimpleScrollView(contentOffset: $offset) {
                    
                }
                
                
            }
        }
    }
}
