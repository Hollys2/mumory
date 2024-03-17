//
//  MyMusicView.swift
//  Feature
//
//  Created by 제이콥 on 2/7/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct MyMusicView: View {
    @EnvironmentObject var playerManager: PlayerViewModel
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0, content: {
                MyRecentMusicView()
                    .frame(height: 250, alignment: .top)
                
                Divider()
                    .frame(maxWidth: .infinity)
                    .frame(height: 0.3)
                    .background(ColorSet.subGray)
                
                MyPlaylistView()
                    .padding(.top, 35)

                
            })
        }
    }
}

//#Preview {
//    MyMusicView()
//}
