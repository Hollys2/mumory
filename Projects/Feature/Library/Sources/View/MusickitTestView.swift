//
//  MusickitTestView.swift
//  Feature
//
//  Created by 제이콥 on 2/3/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import MusicKit

struct MusickitTestView: View {
    var body: some View {
        Button {
            MusicTest()
        } label: {
            Text("Button")
        }

    }
    
    private func MusicTest(){
        
    }
}

#Preview {
    MusickitTestView()
}
