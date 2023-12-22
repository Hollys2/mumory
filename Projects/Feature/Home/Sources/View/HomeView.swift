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


@available(iOS 16.0, *)
struct MumoryCarousel: UIViewRepresentable {

//    typealias UIViewType = UIScrollView
    
    @Binding var annotationSelected: Bool
    
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    var width: CGFloat
    var height: CGFloat

    func makeUIView(context: Context) -> UIScrollView {
        let view = UIScrollView()
        view.isPagingEnabled = true
        
        let totalWidth = self.width * CGFloat(mumoryDataViewModel.mumoryAnnotations.count)

        view.contentSize = CGSize(width: totalWidth, height: self.height)
        view.bounces = true
        
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        
        let view1 = UIHostingController(rootView: MumoryList(annotationSelected: $annotationSelected, mumoryAnnotations: mumoryDataViewModel.mumoryAnnotations))
//        view.frame = CGRect(x: 0, y: 0, width: totalWidth, height: self.height)
        view1.view.frame = CGRect(x: 0, y: 0, width: totalWidth, height: 418)
        
        view.addSubview(view1.view)
        view.backgroundColor = .yellow

        return view
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {}
}

@available(iOS 16.0, *)
struct MumoryList: View {
    
    @Binding var annotationSelected: Bool
    
    @State var mumoryAnnotations: [MumoryAnnotation]
    
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach($mumoryAnnotations) { i in
                MumoryCard(mumoryAnnotation: i)
            }
            Spacer()
        }
        .background()
    }
}

struct MumoryCard: View {
    
    @Binding var mumoryAnnotation: MumoryAnnotation
    
    @State var date: String = ""
    
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 310, height: 310)
                        .background(
                            AsyncImage(url: mumoryAnnotation.musicModel.artworkUrl) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 310, height: 310)
                                default:
                                    Color.red
                                        .frame(width: 310, height: 310)
                                }
                            }
                        )
                        .cornerRadius(15)
                    Spacer()
                }
                
                VStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 310, height: 310)
                        .background(
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 0.64, green: 0.52, blue: 0.98).opacity(0), location: 0.35),
                                    Gradient.Stop(color: Color(red: 0.64, green: 0.52, blue: 0.98), location: 0.85),
                                ],
                                startPoint: UnitPoint(x: 0.5, y: 0.74),
                                endPoint: UnitPoint(x: 0.5, y: 1)
                            )
                        )
                        .cornerRadius(15)
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    
                    HStack(spacing: 5)  {
                        Text("\(date)")
                            .font(
                                Font.custom("Pretendard", size: 15)
                                    .weight(.semibold)
                            )
                            .foregroundColor(.white)
                            .onAppear {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy.MM.dd"
                                self.date = dateFormatter.string(from: mumoryAnnotation.date)
                            }
                        
                        Spacer()
                        
                        SharedAsset.locationMumoryPopup.swiftUIImage
                            .resizable()
                            .frame(width: 17, height: 17)
                        
                        Text("\(mumoryAnnotation.locationModel.locationTitle)")
                            .font(
                                Font.custom("Pretendard", size: 15)
                                    .weight(.medium)
                            )
                            .foregroundColor(.white)
                            .frame(width: 117, alignment: .leading)
                            .lineLimit(1)
                    } // HStack
                    .padding(.horizontal, 16)
                    
                    // MARK: - Underline
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 284, height: 0.5)
                        .background(.white.opacity(0.5))
                    
                    HStack {
                        VStack(spacing: 12) {
                            Text("\(mumoryAnnotation.musicModel.title)")
                                .font(
                                    Font.custom("Pretendard", size: 18)
                                        .weight(.bold)
                                )
                                .foregroundColor(.white)
                                .frame(width: 199, height: 13, alignment: .topLeading)
                                .lineLimit(1)
                            
                            Text("\(mumoryAnnotation.musicModel.artist)")
                                .font(Font.custom("Pretendard", size: 18))
                                .foregroundColor(.white)
                                .frame(width: 199, height: 13, alignment: .topLeading)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            
                        }, label: {
                            SharedAsset.nextButtonMumoryPopup.swiftUIImage
                                .resizable()
                                .frame(width: 48, height: 48)
                        })
                    } // HStack
                    .padding(.horizontal, 16)
                    .padding(.bottom, 22)
                } // VStack
            } // ZStack
            .frame(width: 310, height: 418)
            .background(Color(red: 0.64, green: 0.51, blue: 0.99))
            .cornerRadius(15)
        }
        .frame(width: UIScreen.main.bounds.width - 80)
        .background(.clear)
    }
}


@available(iOS 16.4, *)
public struct HomeView: View {

    @State private var selectedTab: Tab = .home
    @State private var annotationSelected = false
    @State private var offset: CGFloat = 16
    @State private var sheetOffset: CGFloat = .zero
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    public init() {}
    
    public var body: some View {
        if appCoordinator.isNavigationStackShown {
            NavigationStack {
                main
            }
        } else {
            main
        }
    }
    
    var main: some View {
        ZStack(alignment: .center) {
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
                ZStack(alignment: .center) {
                    Color.black.opacity(0.3).ignoresSafeArea()
                        .onTapGesture {
                            self.annotationSelected.toggle()
                        }
                    
                    MumoryCarousel(annotationSelected: $annotationSelected, width: UIScreen.main.bounds.width, height: 418)
                        .frame(height: 418)
                        
                    Button(action: {
                        self.annotationSelected = false
                    }, label: {
                        SharedAsset.closeButtonMumoryPopup.swiftUIImage
                            .resizable()
                            .frame(width: 26, height: 26)
                    })
                } // ZStack
                .ignoresSafeArea()
            }
        }
    }
    
    var homeView: some View {
        ZStack {
            HomeMapViewRepresentable(annotationSelected: $annotationSelected)
                .ignoresSafeArea()
                .onAppear {
                    Task {
                        await mumoryDataViewModel.loadMusics()
                    }
                }

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

