//
//  AnimationWrapper.swift
//  Feature
//
//  Created by 제이콥 on 3/20/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MapKit

struct CreateMumoryViewWrapper: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @Environment(\.dismiss) var dismiss
    @State var backgroundOpacity = 0.0
    @State var isPresentBottomSheet: Bool = true
    @State private var region: MKCoordinateRegion?
    
    var body: some View {
//        NavigationStack {
            ZStack(alignment: .bottom) {
           
               
            }
            .ignoresSafeArea()
            .onAppear {
                UIView.setAnimationsEnabled(true)
                Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { timer in
                    withAnimation(.easeOut(duration: 0.13)) {
                        isPresentBottomSheet = true
                    }
                }
            }
            .navigationDestination(for: String.self, destination: { i in
                if i == "music" {
                    SearchMusicViewInCreateMumory()
                } else if i == "location" {
                    SearchLocationView()
                } else if i == "map" {
                    SearchLocationMapView()
                } else {
                    Color.gray
                }
            })
//        }
        
        
    }
}

