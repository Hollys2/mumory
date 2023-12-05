//
//  HomeView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/08.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import MapKit
import MusicKit
import CoreLocation
import CoreLocationUI

import Core
import Shared


struct Location: Identifiable {
    //    let id: ObjectIdentifier
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

public struct HomeView: View {
    
    //    @State private var tappedLocation: CLLocationCoordinate2D?
    @State private var selectedTab: Tab = .home
    @State private var isBottomSheetShown = false
    @State private var isSheetAnimating = false
    
    @StateObject private var viewModel = HomeViewModel()

    
    public init(){
        
    }
    
    public var body: some View {

        ZStack {
            VStack(spacing: 0) {
                switch selectedTab {
                case .home:
                    ZStack {
                        HomeMapView(tappedLocation: .constant(nil))
                            .ignoresSafeArea()
                        
                        VStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(maxWidth: .infinity)
                                .frame(height: 95)
                                .background(
                                    LinearGradient(
                                        stops: [
                                            Gradient.Stop(color: Color(red: 0.64, green: 0.51, blue: 0.99).opacity(0.6), location: 0.08),
                                            Gradient.Stop(color: Color(red: 0.64, green: 0.51, blue: 0.99).opacity(0), location: 1.00),
                                        ],
                                        startPoint: UnitPoint(x: 0.5, y: 0),
                                        endPoint: UnitPoint(x: 0.5, y: 1)
                                    )
                                )
                                .allowsHitTesting(false)
                            Spacer()
                        }
                        
                        VStack {
                            Spacer()
                            Rectangle()
                              .foregroundColor(.clear)
                              .frame(maxWidth: .infinity)
                              .frame(height: 159.99997)
                              .background(
                                LinearGradient(
                                  stops: [
                                    Gradient.Stop(color: Color(red: 0.64, green: 0.51, blue: 0.99), location: 0.36),
                                    Gradient.Stop(color: Color(red: 0.64, green: 0.51, blue: 0.99).opacity(0), location: 0.83),
                                  ],
                                  startPoint: UnitPoint(x: 0.5, y: 1),
                                  endPoint: UnitPoint(x: 0.5, y: 0)
                                )
                              )
                              .offset(y: 90)
                              .allowsHitTesting(false)
                        }
                        
                        VStack {
                            PlayingMusicBarView() // 추후 HomeMapView의 MapCoordinator에서 작성할 것
                                .offset(y: 16)
                            Spacer()
                        }
                    }
                case .social:
                    Text("The Second Tab")
                case .library:
                    Text("The Third Tab")
                case .notification:
                    VStack(spacing: 0){
                        Color.red
                        Color.blue
                    }
                        .ignoresSafeArea()
                }
                Spacer(minLength: 0) // 추후 수정
                HomeTabView(selectedTab: $selectedTab, isBottomSheetShown: $isBottomSheetShown)
                    .frame(height: 89)
            }
            
            
            if isBottomSheetShown || isSheetAnimating {
                    Color.black.opacity(isBottomSheetShown ? 0.5 : 0)
                        .ignoresSafeArea(.all)
                        .onAppear {
                            withAnimation {
                                isSheetAnimating = true
                            }
                        }
                        .onDisappear {
                            withAnimation {
                                isSheetAnimating = false
                            }
                        }
                }

        }
        .sheet(isPresented: $isBottomSheetShown) {
            if #available(iOS 16.0, *) {
                NavigationView {
                    MakeMumoryView(isShown: $isBottomSheetShown)
                }
                .presentationDetents([.fraction(0.985)])
                .presentationDragIndicator(.visible)
            } else {
                // Fallback on earlier versions
            }
        }
        .onChange(of: isBottomSheetShown) { newValue in
//            withAnimation(.easeInOut) {  // 애니메이션과 함께
//                    isBottomSheetShown = newValue  // isBottomSheetShown 변수 업데이트
//                }


        }
    }
}


//        Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: )
//                .onAppear {
//                    let manager = CLLocationManager()
//                    manager.requestWhenInUseAuthorization()
//                    manager.startUpdatingLocation()
//
//                }
//            LocationButton(.currentLocation) {
//                // Fetch location with Core Location.
////                viewModel.requestAllowOnceLocationPermission()
//
//            }



//        Map(coordinateRegion: $viewModel.region, annotationItems: locations) { location in
//            MapMarker(coordinate: location.coordinate)
//        }


//        Map(coordinateRegion: $region)
//        VStack {
//            MapView(tappedLocation: $tappedLocation)
//            if tappedLocation != nil {
//                LookAroundView(tappedLocation: $tappedLocation, showView: $showLookAround)
//                    .cornerRadius(20)
//                    .opacity(showLookAround ? 1 : 0)
//            }
//        }
//        .ignoresSafeArea()

//        Map(coordinateRegion: $region, annotationItems: [region.center]) { location in
//            MapMarker(coordinate: location, tint: .red)
//        }
//            .accentColor(Color(.systemPink))
//            .onAppear() {
//                viewModel.checkIfLocationServiceIsEnabled()
//            }

//    let db = Firestore.firestore()
//    let db = FirebaseManager.shared.db
//    
//    
//    private func saveMusic() {
//        let musicIDs = ["hello", "1487778081", "1712044358", "1590067123", "1651802560", "1534525138",
//                        "1436905366", "1441164589", "1441164738"]
//        
//        db.collection("favorite").document("musicIDs").setData(["IDs": musicIDs]) { error in
//            if let error = error {
//                print("파베 에러: \(error)")
//            } else {
//                print("파베 성공")
//            }
//        }
//    }
//    
//    private func loadSongs() {
//        db.collection("favorite").document("musicIDs").getDocument { (document, error) in
//            if let error = error {
//                print("Error getting document: \(error)")
//            } else if let document = document, document.exists {
//                if let musicIDs = document.data()?["IDs"] as? [String] {
//                    print("Music IDs: \(musicIDs)")
//                } else {
//                    print("No Music IDs")
//                }
//            } else {
//                print("Document does not exist")
//            }
//        }
//    }


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

