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
    @EnvironmentObject var manager: LibraryManageModel
    @EnvironmentObject var playerManager: PlayerViewModel
    var body: some View {
        ZStack{
            ColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0, content: {
                MyRecentMusicView()
                    .environmentObject(manager)
                    .environmentObject(playerManager)
                
                MyPlaylistView()
                    .environmentObject(manager)
                    .environmentObject(playerManager)
                
                
            })
        }
    }
}

#Preview {
    MyMusicView()
}
