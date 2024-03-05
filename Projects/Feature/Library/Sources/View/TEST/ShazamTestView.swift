//
//  ShazamTestView.swift
//  Feature
//
//  Created by 제이콥 on 2/14/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import ShazamKit
import AVFAudio

public struct ShazamTestView: View {
    public init(){}
//    @State var matcher: MatcherViewModel = MatcherViewModel()
    private var session: SHSession?
    private let audioEngine = AVAudioEngine()
    
    public var body: some View {
        ZStack(alignment: .center){
            Color.gray.ignoresSafeArea()
            VStack(alignment: .center){
                Button(action: {
//                    matcher.startOrEndListening()
                    
                }, label: {
                    Text("Button")
                })
            }
        }
 
    }
    
    private func shazam() {
        
    }
}

//#Preview {
//    ShazamTestView()
//}
