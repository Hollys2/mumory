//
//  TestView.swift
//  Feature
//
//  Created by 제이콥 on 1/29/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI

struct TesttseView: View {
    @State var title = ""
    var body: some View {
        ZStack{
            Color.gray.ignoresSafeArea()
            VStack{
                TextField("title", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .background(.yellow)
            }
        }
    }
}

#Preview {
    TesttseView()
}
