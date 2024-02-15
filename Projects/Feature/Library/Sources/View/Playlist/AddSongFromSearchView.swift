//
//  AddSongFromSearchView.swift
//  Feature
//
//  Created by 제이콥 on 2/14/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct AddSongFromSearchView: View {
    var body: some View {
        ZStack{
            ColorSet.background.ignoresSafeArea()
            VStack(spacing: 0, content: {
                Text("Placeholder")
                    .foregroundStyle(.white)
                Text("Hello, World! favorite")
                    .foregroundStyle(.white)

            })
        }
    }
}

#Preview {
    AddSongFromSearchView()
}
