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
import Core
import Shared

struct List: View {
    
    @State var annotationModels: [MumoryModel]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach($annotationModels) { i in
                
                GeometryReader { g in
                    Card(annotationModel: i, width: g.frame(in: .global).width)
                }
                
            }
        }
    }
}

struct Card: View {
    
    @Binding var annotationModel: MumoryModel

    var width: CGFloat
    
    var body: some View {
        VStack {
//            Image
//            Text(self.annotationModel.location)
//                .font(.title)
//                .fontWeight(.bold)
        }
    }
}


@available(iOS 16.4, *)
public struct HomeView: View {

    @State private var selectedTab: Tab = .home
    @State private var annotationSelected = false
    
    @EnvironmentObject var appCoordinator: AppCoordinator
//    @EnvironmentObject var locationManager: LocationManager
    
    @State private var offset: CGFloat = 16
    @State private var sheetOffset: CGFloat = .zero

    public init() {}
    
    public var body: some View {
        if appCoordinator.isNavigationStackShown {
            NavigationStack {
                main
            }
            //                .sheet(isPresented: $appCoordinator.isCreateMumorySheetShown) {
            //                    NavigationView {
            //                        CreateMumoryView()
            //                    }
            //                    .presentationDetents([.height(UIScreen.main.bounds.height - 41)])
            //                    .presentationDragIndicator(.visible)
            //                    //            .interactiveDismissDisabled()
            
        } else {
            main
        }
    }
    
    var main: some View {
        ZStack {
            VStack(spacing: 0) {
                switch selectedTab {
                case .home:
                    homeView
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
                HomeTabView(selectedTab: $selectedTab)
                    .frame(height: 89)
            }
            
            if appCoordinator.isCreateMumorySheetShown {
                Color.black.opacity(0.3).ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(Animation.easeOut(duration: 0.2)) {
                            appCoordinator.isCreateMumorySheetShown = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                appCoordinator.path.removeLast(appCoordinator.path.count)
                            }
                        }
                    }
                CreateMumoryBottomSheetView()
                    .transition(.move(edge: .bottom))
                    .zIndex(1) // 추가해서 사라질 때 에니메이션 적용됨
            }
            
            if self.annotationSelected {
                Color.black.opacity(0.3).ignoresSafeArea()
                    .onTapGesture {
                        self.annotationSelected.toggle()
                    }
                Color.pink
                    .frame(width: 300, height: 200)
            }
        }
    }
    
    var homeView: some View {
        ZStack {
            HomeMapViewRepresentable(annotationSelected: $annotationSelected)
                .ignoresSafeArea()
            
//            Map(coordinateRegion: .constant(MKCoordinateRegion(
//                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
//                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//            )), interactionModes: .all)
//            .ignoresSafeArea()
//            .onAppear {
//                MKMapView.appearance().mapType = .mutedStandard
//                MKMapView.appearance().isPitchEnabled = true
//            }
            
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

@available(iOS 16.4, *)
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

