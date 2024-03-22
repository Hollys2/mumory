//
//  MumoryDetailMapView.swift
//  Feature
//
//  Created by 다솔 on 2024/03/21.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import MapKit

import Shared


struct MumoryDetailMapView: View {
    
    @Binding private var isShown: Bool
    let mumory: Mumory
    let user: MumoriUser
    @State private var region: MKCoordinateRegion = MapConstant.defaultRegion
    
    @EnvironmentObject private var appCoordinator: AppCoordinator
    
    init(isShown: Binding<Bool>, mumory: Mumory, user: MumoriUser) {
        self._isShown = isShown
        self.mumory = mumory
        self.user = user
        self._region = State(initialValue: MKCoordinateRegion(center: mumory.coordinate, span: MapConstant.defaultSpan))
    }
    
    var body: some View {
        ZStack(alignment: .top) {

            Map(coordinateRegion: .constant(region), annotationItems: [mumory]) { m in

                MapAnnotation(coordinate: m.locationModel.coordinate) {
                    ZStack(alignment: .topLeading) {
                        SharedAsset.musicPin.swiftUIImage
                            .resizable()
                            .frame(width: 74, height: 81)
                        
                        AsyncImage(url: m.musicModel.artworkUrl) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                            default:
                                Color.clear
                            }
                        }
                        .frame(width: 60.65238, height: 60.65238)
                        .cornerRadius(12)
                        .offset(x: 6.74, y: 6.74)
                    }
                }
            }
            .preferredColorScheme(.light)
            .onAppear {
                MKMapView.appearance().mapType = .mutedStandard
            }
            
            HStack {
                
                Color.clear
                    .frame(width: 30, height: 30)
                
                Spacer()
                
                Text("\(self.user.nickname)님의 뮤모리")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button {
                    self.isShown = false
                } label: {
                    SharedAsset.closeButtonMumoryDetailMap.swiftUIImage
                        .resizable()
                        .frame(width: 30, height: 30)
                }

            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .padding(.top, self.appCoordinator.safeAreaInsetsTop)
            .padding(.horizontal, 20)
            .background(Color(red: 0.09, green: 0.09, blue: 0.09, opacity: 0.898))
        }
        .ignoresSafeArea()
    }
}
