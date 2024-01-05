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
    
    @Binding var mumoryAnnotations: [MumoryAnnotation]
    //    @Binding var annotationSelected: Bool
    
    //    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        
        scrollView.delegate = context.coordinator
        
        let totalWidth = (310 + 20) * CGFloat(mumoryAnnotations.count)
        scrollView.contentSize = CGSize(width: totalWidth, height: 1)
        
        scrollView.isPagingEnabled = true
        scrollView.contentMode = .scaleToFill
        scrollView.clipsToBounds = false
        scrollView.bounces = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        let hostingController = UIHostingController(rootView: MumoryList(mumoryAnnotations: $mumoryAnnotations))
        hostingController.view.frame = CGRect(x: 0, y: 0, width: totalWidth, height: 418)
        
        scrollView.addSubview(hostingController.view)
        //        view.backgroundColor = .red
        hostingController.view.backgroundColor = .clear
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension MumoryCarousel {
    
    class Coordinator: NSObject {
        
        let parent: MumoryCarousel
        
        init(parent: MumoryCarousel) {
            self.parent = parent
            super.init()
        }
    }
}

extension MumoryCarousel.Coordinator: UIScrollViewDelegate {
    //    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    //           let pageWidth: CGFloat = 330.0 // 페이지의 너비
    //
    //           // 사용자가 놓은 스크롤의 최종 위치를 페이지 단위로 계산하여 목표 위치(targetContentOffset)를 조정
    //           let targetX = targetContentOffset.pointee.x
    //           let contentWidth = scrollView.contentSize.width
    //           let newPage = round(targetX / pageWidth)
    //           let xOffset = min(newPage * pageWidth, contentWidth - scrollView.bounds.width) // 너무 많이 이동하지 않도록 bounds 체크
    //
    //           targetContentOffset.pointee = CGPoint(x: xOffset, y: 0)
    //       }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //        print(scrollView.contentOffset.x)
    }
    
}

@available(iOS 16.0, *)
struct MumoryList: View {
    
    @Binding var mumoryAnnotations: [MumoryAnnotation]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(mumoryAnnotations.indices, id: \.self) { index in
                MumoryCard(mumoryAnnotation: $mumoryAnnotations[index], selectedIndex: index)
                    .padding(.horizontal, 10)
            }
        }
    }
}

struct MumoryCard: View {
    
    @Binding var mumoryAnnotation: MumoryAnnotation
    //    @Binding var annotationSelected: bool
    
    let selectedIndex: Int
    
    @State var date: String = ""
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
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
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 310, height: 310)
                                    .background(Color(red: 0.25, green: 0.25, blue: 0.25))
                                    .overlay(
                                        Rectangle()
                                            .inset(by: 0.5)
                                            .stroke(.white, lineWidth: 1)
                                    )
                                    .overlay(
                                        SharedAsset.defaultArtwork.swiftUIImage
                                            .frame(width: 103, height: 124)
                                            .background(Color(red: 0.47, green: 0.47, blue: 0.47))
                                    )
                                
                                //                                Color.red
                                //                                    .frame(width: 310, height: 310)
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
                        //                        withAnimation(Animation.easeInOut(duration: 0.2)) {
                        //                            appCoordinator.isMumoryDetailShown = true
                        //                        }
                        appCoordinator.mumoryPopUpZIndex = 0
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            appCoordinator.mumoryPopUpZIndex = 2
                        }
                        appCoordinator.rootPath.append(0)
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
}


public struct HomeView: View {
    
    @State private var selectedTab: Tab = .home
    
    @State private var translation: CGSize = .zero
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    public init() {}
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                print("onChanged: \(value.translation.height)")
                if value.translation.height > 0 {
                    DispatchQueue.main.async {
                        translation.height = value.translation.height                        
                    }
                }
            }
            .onEnded { value in
                print("onEnded: \(value.translation.height)")
                
                withAnimation(Animation.easeInOut(duration: 0.2)) {
//                    if value.translation.height > 130 {
//                        appCoordinator.isCreateMumorySheetShown = false
//
//                        mumoryDataViewModel.choosedMusicModel = nil
//                        mumoryDataViewModel.choosedLocationModel = nil
//                    }
                        translation.height = 0
                }
            }
    }

    public var body: some View {
        NavigationStack(path: $appCoordinator.rootPath) {
            ZStack(alignment: .bottom) { // 바텀시트를 위해 정렬
                VStack(spacing: 0) {
                    switch selectedTab {
                    case .home:
                        homeView
                    case .social:
                        SocialView()
                    case .library:
                        Text("The Third Tab")
                    case .notification:
                        VStack(spacing: 0){
                            Color.red
                            Color.blue
                        }
                    }
                    
                    HomeTabView(selectedTab: $selectedTab)
                        .frame(height: 89 + appCoordinator.safeAreaInsetsBottom)
                }
                
                if appCoordinator.isCreateMumorySheetShown {
                    Color.black.opacity(0.6)
                        .onTapGesture {
                            withAnimation(Animation.easeOut(duration: 0.2)) {
                                appCoordinator.isCreateMumorySheetShown = false
                            }
                        }
                    
                    CreateMumoryBottomSheetView()
                        .offset(y: translation.height)
                        .gesture(dragGesture)
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                }
                
                //            if self.annotationSelected {
                if self.appCoordinator.isMumoryPopUpShown {
                    //                ZStack { // 부모 ZStack의 정렬 무시
                    Color.black.opacity(0.6)
                        .onTapGesture {
                            //                            self.annotationSelected.toggle()
                            self.appCoordinator.isMumoryPopUpShown = false
                        }
                    
                    MumoryCarousel(mumoryAnnotations: $mumoryDataViewModel.mumoryAnnotations)
                        .frame(height: 418)
                        .padding(.horizontal, (UIScreen.main.bounds.width - 310) / 2 - 10)
                    
                    Button(action: {
                        //                        self.annotationSelected = false
                        self.appCoordinator.isMumoryPopUpShown = false
                    }, label: {
                        SharedAsset.closeButtonMumoryPopup.swiftUIImage
                            .resizable()
                            .frame(width: 26, height: 26)
                    })
                    .offset(y: 209 + 13 + 25)
                    //                }
                    //                .background(.orange)
                    .frame(width: 100, height: 100)
                    .padding()
                    .foregroundColor(.purple)
                    
                }
                
                if self.appCoordinator.isSocialMenuSheetViewShown {
                    Color.black.opacity(0.3).ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(Animation.easeOut(duration: 0.2)) {
                                self.appCoordinator.isSocialMenuSheetViewShown = false
                            }
                        }
                    
                    SocialMenuSheetView(translation: $translation)
                        .frame(width: UIScreen.main.bounds.width - 14)
                        .offset(y: self.translation.height)
                        .simultaneousGesture(dragGesture)
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                }
                
                if appCoordinator.isMumoryDetailMenuSheetShown {
                    Color.black.opacity(0.5).ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(Animation.easeInOut(duration: 0.2)) {
                                appCoordinator.isMumoryDetailMenuSheetShown = false
                            }
                        }
                    
                    MumoryDetailMenuSheetView(translation: $translation)
                        .frame(width: UIScreen.main.bounds.width - 14)
                        .offset(y: self.translation.height)
                        .simultaneousGesture(dragGesture)
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                }
                
                if appCoordinator.isMumoryDetailCommentSheetViewShown {
                    Color.black.opacity(0.5).ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(Animation.easeInOut(duration: 0.2)) {
                                appCoordinator.isMumoryDetailCommentSheetViewShown = false
                            }
                        }
                    
                    MumoryDetailCommentSheetView() // 스크롤뷰만 제스처 추가해서 드래그 막음
                        .offset(y: self.translation.height)
                        .gesture(dragGesture)
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                }
            } // ZStack
            .ignoresSafeArea()
            .navigationDestination(for: Int.self) { i in
                if i == 0 {
                    MumoryDetailView(mumoryAnnotation: mumoryDataViewModel.mumoryAnnotations[2])
                        .navigationBarBackButtonHidden(true)
                } else if i == 1 {
                    MumoryDetailEditView()
                } else if i == 2 {
                    SearchMusicView()
                } else if i == 3 {
                    SearchLocationView()
                } else {
                    Color.pink
                }
            }
            .navigationDestination(for: String.self, destination: { i in
                if i == "music" {
                    SearchMusicView()
                } else if i == "location" {
                    SearchLocationView()
                } else if i == "map" {
                    SearchLocationMapView()
                } else {
                    Color.gray
                }
            })
        } // NavigationStack
    }
    
    var homeView: some View {
        ZStack {
            HomeMapViewRepresentable(annotationSelected: $appCoordinator.isMumoryPopUpShown)
                .onAppear {
                    Task {
                        await mumoryDataViewModel.loadMusics()
                    }
                }
            
            VStack(spacing: 0) {
                Rectangle()
                  .foregroundColor(.clear)
                  .frame(height: 95)
                  .background(
                    LinearGradient(
                      stops: [
                        Gradient.Stop(color: Color(red: 0.64, green: 0.51, blue: 0.99).opacity(0.9), location: 0.08),
                        Gradient.Stop(color: Color(red: 0.64, green: 0.51, blue: 0.99).opacity(0), location: 1.00),
                      ],
                      startPoint: UnitPoint(x: 0.5, y: 0),
                      endPoint: UnitPoint(x: 0.5, y: 1)
                    )
                  )
                
                Spacer()
                
                Rectangle()
                  .foregroundColor(.clear)
                  .frame(height: 159.99997)
                  .background(
                    LinearGradient(
                      stops: [
                        Gradient.Stop(color: Color(red: 0.64, green: 0.51, blue: 0.99), location: 0.36),
                        Gradient.Stop(color: Color(red: 0.64, green: 0.51, blue: 0.99).opacity(0), location: 0.83),
                      ],
                      startPoint: UnitPoint(x: 0.5, y: 0),
                      endPoint: UnitPoint(x: 0.5, y: 1)
                    )
                  )
                  .allowsHitTesting(false)
            }
            
            VStack {
                PlayingMusicBarView()
                    .offset(y: appCoordinator.safeAreaInsetsTop + 16)
                Spacer()
            }
        }
    }
}

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
