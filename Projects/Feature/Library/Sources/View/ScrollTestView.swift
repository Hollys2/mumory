//
//  ScrollTestView.swift
//  Feature
//
//  Created by 제이콥 on 1/26/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI

struct ScrollTestView: View {
    var body: some View {
        ZStack{
            ScrollView {
                VStack{
                    Text("텍스트111")
                    Spacer()
                }
            }
            
            ScrollView {
                VStack{
                    Spacer()
                    Spacer()
                    Text("텍스트222")
                        
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    ScrollTestView()
}
