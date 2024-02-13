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
import PhotosUI

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
                    Text("\(self.date)")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                        .foregroundColor(.white)
                        .onAppear {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy.MM.dd"
                            self.date = dateFormatter.string(from: mumoryAnnotation.date)
                        }
                    
                    
                    Spacer(minLength: 59)
                    
                    SharedAsset.locationMumoryPopup.swiftUIImage
                        .resizable()
                        .frame(width: 17, height: 17)
                    
                    Text("\(mumoryAnnotation.locationModel.locationTitle)")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                        .foregroundColor(.white)
//                        .frame(maxWidth: getUIScreenBounds().width * 0.3, alignment: .leading)
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
//                        //                            appCoordinator.isMumoryDetailShown = true
//                        //                        }
//                        appCoordinator.mumoryPopUpZIndex = 0
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                            appCoordinator.mumoryPopUpZIndex = 2
//                        }
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
    
    @State private var showDatePicker: Bool = false
    
    @State private var translation: CGSize = .zero
    @State private var offsetY: CGFloat = .zero
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
       
    public init() {}
    
    private func lerp(_ v0: CGFloat, _ v1: CGFloat, _ t: CGFloat) -> CGFloat {
        return (1 - t) * v0 + t * v1
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
//                print("onChanged: \(value.translation.height)")
                if value.translation.height > 0 {
//                    translation.height = value.translation.height
                    let targetHeight = value.translation.height
                    translation.height = lerp(translation.height, targetHeight, 1)

                }
            }
            .onEnded { value in
//                print("onEnded: \(value.translation.height)")
                withAnimation(Animation.easeInOut(duration: 0.1)) {
                    if value.translation.height > 130 {
                        appCoordinator.isCreateMumorySheetShown = false
                        mumoryDataViewModel.choosedMusicModel = nil
                        mumoryDataViewModel.choosedLocationModel = nil
                    }
                    translation.height = .zero
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
                }
                
                TestBottomSheetView(isSheetShown: $appCoordinator.isCreateMumorySheetShown, offsetY: $appCoordinator.offsetY)
                
//                if appCoordinator.isCreateMumorySheetShown {
//                    Color.black.opacity(0.6)
//                        .onTapGesture {
//                            withAnimation(Animation.easeInOut(duration: 0.1)) { // 사라질 때 애니메이션 적용
//                                appCoordinator.isCreateMumorySheetShown = false
//
//                                mumoryDataViewModel.choosedMusicModel = nil
//                                mumoryDataViewModel.choosedLocationModel = nil
//                            }}
//
//                    CreateMumoryBottomSheetView(showDatePicker: $showDatePicker)
//                        .offset(y: translation.height)
//                        .gesture(self.dragGesture)
//                        .transition(.move(edge: .bottom))
//                        .zIndex(1)
//                }
                    
                if self.appCoordinator.isMumoryPopUpShown {
                    ZStack { // 부모 ZStack의 정렬 무시
                        Color.black.opacity(0.6)
                            .onTapGesture {
                                self.appCoordinator.isMumoryPopUpShown = false
                            }
                        
                        MumoryCarousel(mumoryAnnotations: $mumoryDataViewModel.mumoryCarouselAnnotations)
                            .frame(height: 418)
                            .padding(.horizontal, (UIScreen.main.bounds.width - 310) / 2 - 10)
                        
                        Button(action: {
                            self.appCoordinator.isMumoryPopUpShown = false
                        }, label: {
                            SharedAsset.closeButtonMumoryPopup.swiftUIImage
                                .resizable()
                                .frame(width: 26, height: 26)
                        })
                        .offset(y: 209 + 13 + 25)
                    }
                }
                
                if self.appCoordinator.isSocialMenuSheetViewShown {
                    Color.black.opacity(0.5).ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(Animation.easeOut(duration: 0.2)) {
                                self.appCoordinator.isSocialMenuSheetViewShown = false
                            }
                        }
                    
                    SocialMenuSheetView(translation: $translation)
                        .offset(y: self.translation.height - appCoordinator.safeAreaInsetsBottom)
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
                        .offset(y: self.translation.height - appCoordinator.safeAreaInsetsBottom)
                        .gesture(dragGesture)
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                }
                
                if self.appCoordinator.isAddFriendViewShown {
                    SocialFriendView()
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                }
                
//                id self.appCoordinator.
                
            } // ZStack
            .ignoresSafeArea()
            .navigationDestination(for: Int.self) { i in
                switch i {
                case 0:
                    MumoryDetailView(mumoryAnnotation: mumoryDataViewModel.mumoryAnnotations[0])
                case 1:
                    MumoryDetailEditView()
                case 2:
                    SearchMusicView()
                case 3:
                    SearchLocationView()
                case 4:
                    SocialSearchView()
                default:
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
            .navigationDestination(for: SearchFriendType.self, destination: { type in
                switch type {
                case .cancelRequestFriend:
                    FriendMenuView(type: .cancelRequestFriend)
                case .unblockFriend:
                    FriendMenuView(type: .unblockFriend)
                default:
                    Color.pink
                }
            })
//            .sheetWithDetents(
//                isPresented: $appCoordinator.isCreateMumorySheetShown,
//                detents: [UISheetPresentationController.Detent.custom(
//                    identifier: UISheetPresentationController.Detent.Identifier("FUCK"),
//                    resolver: { dimension in
//                        // Set your custom height here
//                        return UIScreen.main.bounds.height - 200
//                    }
//                )]) {
//                        print("The sheet has been dismissed")
//                } content: {
//                    VStack(spacing: 0) {
//                        Color.red
//                            .onTapGesture {
//                                appCoordinator.createMumoryPath.append(0.1)
//                            }
//                        Color.blue
//                            .onTapGesture {
//                                appCoordinator.createMumoryPath.append(1.1)
//                            }
//                    }
//                    .navigationDestination(for: Double.self, destination: { i in
//                        switch i {
//                        case 0.1:
//                            Color.orange
//                                .navigationBarBackButtonHidden(true)
//                        default:
//                            Color.pink
//                        }
//                    })
//                }

//            .sheet(isPresented: $appCoordinator.isCreateMumorySheetShown) {
//                NavigationStack(path: $appCoordinator.createMumoryPath) {
//                    VStack(spacing: 0) {
//                        Color.red
//                            .onTapGesture {
//                                appCoordinator.createMumoryPath.append(0.1)
//                            }
//                        Color.blue
//                            .onTapGesture {
//                                appCoordinator.createMumoryPath.append(3.3)
//                            }
//                            .navigationDestination(for: Double.self, destination: { i in
//                                switch i {
//                                case 0.1:
//                                    Color.orange
//                                        .navigationBarBackButtonHidden(true)
//                                default:
//                                    Color.pink
//                                }
//                            })
//                    }
//
//
//                }
//                .presentationDetents([.height(getUIScreenBounds().height - appCoordinator.safeAreaInsetsTop - 36)])
//                //                .presentationCornerRadius(23)
//            }
        } // NavigationStack
        .onAppear {
            print("HomeMapViewRepresentable onAppear")
//                    Task {
                self.mumoryDataViewModel.fetchData()
//                        await mumoryDataViewModel.loadMusics()
//                    }
        
        }
        
    }
    
    var homeView: some View {
        
        ZStack {
            
            HomeMapViewRepresentable(annotationSelected: $appCoordinator.isMumoryPopUpShown)
            
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
                      startPoint: UnitPoint(x: 0.5, y: 1),
                      endPoint: UnitPoint(x: 0.5, y: 0)
                    )
                  )
                  .offset(y: 89)
            }
            .allowsHitTesting(false)
            
            VStack {
                PlayingMusicBarView()
                    .offset(y: appCoordinator.safeAreaInsetsTop + 16)
                
                Spacer()
            }
        }
    }
}


struct SheetPresentationForSwiftUI<Content>: UIViewRepresentable where Content: View {
    
    @Binding var isPresented: Bool
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    let detents: [UISheetPresentationController.Detent]
    let content: Content

    init(
        _ isPresented: Binding<Bool>,
        detents: [UISheetPresentationController.Detent],
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.detents = detents
        self.content = content()
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
        // Create the UIViewController that will be presented by the UIButton
        let viewController = UIViewController()
        viewController.modalPresentationStyle = .formSheet

        // Create the UIHostingController that will embed the SwiftUI View
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = .brown
        
        // Add the UIHostingController to the UIViewController
        viewController.addChild(hostingController)
        viewController.view.addSubview(hostingController.view)
        
        // Set constraints
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor).isActive = true
        //            hostingController.view.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor).isActive = true
//        hostingController.view.topAnchor.constraint(equalTo: viewController.view.topAnchor).isActive = true
        
        hostingController.view.widthAnchor.constraint(equalToConstant: getUIScreenBounds().width).isActive = true  // Set the width as needed
        hostingController.view.heightAnchor.constraint(equalToConstant: getUIScreenBounds().height - 100).isActive = true  // Set the height as needed
        hostingController.didMove(toParent: viewController)
        
        // Set the presentationController as a UISheetPresentationController
        if let sheetController = viewController.presentationController as? UISheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom(
                identifier: UISheetPresentationController.Detent.Identifier("FUCK"),
                resolver: { dimension in
                    // Set your custom height here
                    return UIScreen.main.bounds.height - 200
                }
            )
            sheetController.detents = [customDetent]
            sheetController.largestUndimmedDetentIdentifier = customDetent.identifier
            
            sheetController.prefersGrabberVisible = false
            sheetController.prefersScrollingExpandsWhenScrolledToEdge = true
            sheetController.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheetController.preferredCornerRadius = 23
            
        }

        viewController.presentationController?.delegate = context.coordinator
        viewController.transitioningDelegate = context.coordinator
        
        
        if isPresented {
            if uiView.window?.rootViewController?.presentedViewController == nil {
                uiView.window?.rootViewController?.present(viewController, animated: true)
            }
        } else {
            uiView.window?.rootViewController?.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UISheetPresentationControllerDelegate, UIViewControllerTransitioningDelegate {
        
        let parent: SheetPresentationForSwiftUI
        
        init(parent: SheetPresentationForSwiftUI) {
            self.parent = parent
            super.init()
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            parent.appCoordinator.isCreateMumorySheetShown = false
//            withAnimation(.easeInOut(duration: 0.2)) {
//            }
//            if let onDismiss = onDismiss {
//                onDismiss()
//            }
        }
        
//        func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//            return CustomPresentationAnimator(duration: 0.3)
//          }
//
//        func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//            return CustomPresentationAnimator(duration: 0.3)
//        }
    }
}

struct sheetWithDetentsViewModifier<SwiftUIContent>: ViewModifier where SwiftUIContent: View {
    
    @Binding var isPresented: Bool
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    let onDismiss: (() -> Void)?
    let detents: [UISheetPresentationController.Detent]
    let swiftUIContent: SwiftUIContent
    
    init(isPresented: Binding<Bool>, detents: [UISheetPresentationController.Detent] = [.medium()] , onDismiss: (() -> Void)? = nil, content: () -> SwiftUIContent) {
        self._isPresented = isPresented
        self.onDismiss = onDismiss
        self.swiftUIContent = content()
        self.detents = detents
    }
    
    func body(content: Content) -> some View {
        ZStack {
            SheetPresentationForSwiftUI($isPresented, detents: detents) {
                swiftUIContent
            }
            //            .fixedSize()
            
            content
        }
        .ignoresSafeArea()
    }
}

extension View {
    
    func sheetWithDetents<Content>(
        isPresented: Binding<Bool>,
        detents: [UISheetPresentationController.Detent],
        onDismiss: (() -> Void)?,
        content: @escaping () -> Content) -> some View where Content : View {
            modifier(
                    sheetWithDetentsViewModifier(
                        isPresented: isPresented,
                        detents: detents,
                        onDismiss: onDismiss,
                        content: content)
                    )
        }
    
}

class CustomPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval
    
    init(duration: TimeInterval) {
        self.duration = duration
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
           guard let toViewController = transitionContext.viewController(forKey: .to) else { return }

           let finalFrame = transitionContext.finalFrame(for: toViewController)
           let containerView = transitionContext.containerView

           let initialFrame = finalFrame.offsetBy(dx: 0, dy: containerView.bounds.height)
           toViewController.view.frame = initialFrame

           containerView.addSubview(toViewController.view)

           UIView.animate(withDuration: duration, animations: {
               toViewController.view.frame = finalFrame
           }) { _ in
               transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
           }
       }
}



struct SheetViewController<Content>: UIViewControllerRepresentable where Content: View {
    @Binding var isPresented: Bool
    var content: Content
    var cornerRadius: CGFloat
    
    init(
        _ isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content,
        cornerRadius: CGFloat
    ) {
        self._isPresented = isPresented
        self.content = content()
        self.cornerRadius = cornerRadius
    }

    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            let sheetController = UIHostingController(rootView: content)

            let viewController = uiViewController
            viewController.view.addSubview(sheetController.view)
            viewController.modalPresentationStyle = .formSheet
            viewController.presentationController?.delegate = context.coordinator

            context.coordinator.sheetController = sheetController

            uiViewController.present(viewController, animated: true)
        } else {
            uiViewController.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    class Coordinator: NSObject, UISheetPresentationControllerDelegate {
        var parent: SheetViewController
        var sheetController: UIHostingController<Content>?

        init(parent: SheetViewController) {
            self.parent = parent
        }

        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            parent.isPresented = false
        }
    }
}

struct SheetWithCornerRadius<Content>: View where Content: View {
    @Binding var isPresented: Bool
    var content: () -> Content
    var cornerRadius: CGFloat

    var body: some View {
        SheetViewController($isPresented, content: content, cornerRadius: cornerRadius)
    }
}

extension View {
    func sheetWithCornerRadius<Content: View>(isPresented: Binding<Bool>, cornerRadius: CGFloat, @ViewBuilder content: @escaping () -> Content) -> some View {
        SheetWithCornerRadius(isPresented: isPresented, content: content, cornerRadius: cornerRadius)
    }
}





struct TestBottomSheetView: View {
    
    @Binding var isSheetShown: Bool
    @Binding var offsetY: CGFloat
    
    @State private var showDatePicker: Bool = false
    @State private var isPublishPopUpShown: Bool = false
    @State private var isPublishErrorPopUpShown: Bool = false
    @State private var isTagErrorPopUpShown: Bool = false
    @State private var isDeletePopUpShown: Bool = false
    
    @GestureState private var dragState = DragState.inactive
//    @State var offsetY = CGFloat(0)
    
    @State private var contentText: String = ""
    @State private var isPublic: Bool = true
    @State private var calendarYOffset: CGFloat = .zero
    @State private var scrollViewOffset: CGFloat = 0
    @State private var tagContainerViewFrame: CGRect = .zero

    @State var date: Date = Date()
    
    @StateObject private var photoPickerViewModel: PhotoPickerViewModel = .init()
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject private var dateManager: DateManager
    
    init(isSheetShown: Binding<Bool>, offsetY: Binding<CGFloat>) {
        self._isSheetShown = isSheetShown
        self._offsetY = offsetY
    }
    
    let maxHeight = CGFloat(16)
    
    var body: some View {
        
        let drag = DragGesture()
            .updating($dragState) { drag, state, transaction in
                var newTranslation = drag.translation
                if self.offsetY + newTranslation.height < -maxHeight {  // 최대치를 넘지 않도록 제한
                    newTranslation.height = -maxHeight - self.offsetY
                }
                state = .dragging(translation: newTranslation)
                //                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)
        
        return ZStack(alignment: .bottom) {
            
            if isSheetShown {
                
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        self.isDeletePopUpShown = true
                    }
                
                VStack(spacing: 0) {
                    
                    // MARK: -Top bar
                    ZStack {
                        
                        HStack {
                            Image(uiImage: SharedAsset.closeCreateMumory.image)
                                .resizable()
                                .frame(width: 25, height: 25)
                                .gesture(TapGesture(count: 1).onEnded {
                                    
                                    self.isDeletePopUpShown = true
                                    
//                                    withAnimation(Animation.easeInOut(duration: 0.1)) { // 사라질 때 애니메이션 적용
//                                        appCoordinator.isCreateMumorySheetShown = false
//
//                                        mumoryDataViewModel.choosedMusicModel = nil
//                                        mumoryDataViewModel.choosedLocationModel = nil
//                                    }
                                })
                            
                            Spacer()
                            
                            Button(action: {
                                if (self.mumoryDataViewModel.choosedMusicModel != nil) && (self.mumoryDataViewModel.choosedLocationModel != nil) {
                                    self.isPublishPopUpShown = true
                                } else {
                                    self.isPublishErrorPopUpShown = true
                                }
//                                self.isTagErrorPopUpShown = true
//                                if let choosedMusicModel = mumoryDataViewModel.choosedMusicModel, let choosedLocationModel = mumoryDataViewModel.choosedLocationModel {
//                                    let newMumoryAnnotation = MumoryAnnotation(date: self.date, musicModel: choosedMusicModel, locationModel: choosedLocationModel)
//
//                                    mumoryDataViewModel.createMumory(newMumoryAnnotation)
//                                }
//
//                                withAnimation(Animation.easeInOut(duration: 0.1)) { // 사라질 때 애니메이션 적용
//                                    appCoordinator.isCreateMumorySheetShown = false
//                                }
//
//                                mumoryDataViewModel.choosedMusicModel = nil
//                                mumoryDataViewModel.choosedLocationModel = nil
                                
                            }) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 46, height: 30)
                                    .background((self.mumoryDataViewModel.choosedMusicModel != nil) && (self.mumoryDataViewModel.choosedLocationModel != nil) ? SharedAsset.mainColor.swiftUIColor : Color(red: 0.47, green: 0.47, blue: 0.47))
                                    .cornerRadius(31.5)
                                    .overlay(
                                        Text("게시")
                                            .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 13))
                                            .foregroundColor(.black)
                                    )
                                    .allowsHitTesting(true)
                            }
//                            .disabled(!((self.mumoryDataViewModel.choosedMusicModel != nil) && (self.mumoryDataViewModel.choosedLocationModel != nil)))
                        } // HStack
                        
                        Text("뮤모리 만들기")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                            .foregroundColor(.white)
                    } // ZStack
                    .padding(.top, 26)
                    .padding(.bottom, 11)
                    .padding(.horizontal, 20)
                    
                    ScrollView(showsIndicators: false) {
        
                            VStack(spacing: 0) {
        
                                VStack(spacing: 16) {
        
                                    NavigationLink(value: "music") {
                                        ContainerView(title: "음악 추가하기", image: SharedAsset.musicIconCreateMumory.swiftUIImage)
                                    }
        
                                    NavigationLink(value: "location") {
                                        ContainerView(title: "위치 추가하기", image: SharedAsset.locationIconCreateMumory.swiftUIImage)
                                    }
        
                                    CalendarContainerView(title: "\(dateManager.formattedDate(date: self.date, dateFormat: "yyyy. MM. dd. EEEE"))")
                                        .onTapGesture {
                                            withAnimation(.easeInOut(duration: 0.1)) {
                                                self.showDatePicker.toggle()
                                            }
                                        }
                                        .background {
                                            GeometryReader { geometry in
        
                                                Color.clear
                                                    .onAppear {
                                                        self.calendarYOffset = geometry.frame(in: .global).maxY
                                                    }
                                                    .onChange(of: geometry.frame(in: .global).maxY) { newOffset in
                                                        // Update calendarYOffset when the offset changes
                                                        self.calendarYOffset = newOffset
                                                    }
                                            }
                                        }
        
                                }
                                .padding(.horizontal, 20)
        
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(height: 6)
                                    .background(.black)
                                    .padding(.vertical, 18)
        
                                VStack(spacing: 16) {
        
                                    TagContainerView(title: "#때끄")
                                        .background(GeometryReader { geometry -> Color in
                                            DispatchQueue.main.async {
                                                self.tagContainerViewFrame = geometry.frame(in: .global)
                                            }
                                            return Color.clear
                                        })
                                    //                            .onAppear {
                                    //                                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
                                    //                                    guard let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                                    //                                    let keyboardHeight = keyboardSize.height
                                    //
                                    //                                    withAnimation {
                                    //                                        scrollViewOffset = tagContainerViewFrame.maxY - (getUIScreenBounds().height - keyboardHeight) + 16
                                    //                                    }
                                    //                                }
                                    //
                                    //                                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
                                    //                                    withAnimation {
                                    //                                         scrollViewOffset = 0
                                    //                                    }
                                    //                                }
                                    //                            }
        
                                    ContentContainerView(contentText: "하이")
        
                                    HStack(spacing: 11) {
                                        PhotosPicker(selection: $photoPickerViewModel.imageSelections,
                                                     maxSelectionCount: 3,
                                                     matching: .images) {
        
                                            Rectangle()
                                                .foregroundColor(.clear)
                                                .frame(width: 75, height: 75)
                                                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                                .cornerRadius(10)
                                                .overlay(
                                                    VStack(spacing: 0) {
                                                        (photoPickerViewModel.imageSelectionCount == 3 ?  SharedAsset.photoFullIconCreateMumory.swiftUIImage : SharedAsset.photoIconCreateMumory.swiftUIImage)
                                                            .resizable()
                                                            .frame(width: 25, height: 25)
        
                                                        HStack(spacing: 0) {
                                                            Text("\(photoPickerViewModel.imageSelectionCount)")
                                                                .font(Font.custom("Pretendard", size: 14).weight(.medium))
                                                                .foregroundColor(photoPickerViewModel.imageSelectionCount >= 1 ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.47, green: 0.47, blue: 0.47))
                                                            Text(" / 3")
                                                                .font(Font.custom("Pretendard", size: 14).weight(.medium))
                                                                .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                                        }
                                                        .multilineTextAlignment(.center)
                                                        .padding(.top, 10)
                                                    }
                                                )
                                        }
        
                                        if !photoPickerViewModel.selectedImages.isEmpty {
        
                                            ForEach(photoPickerViewModel.selectedImages, id: \.self) { image in
        
                                                ZStack {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .frame(width: 75, height: 75)
                                                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                                        .cornerRadius(10)
        
                                                    Button(action: {
                                                        photoPickerViewModel.removeImage(image)
                                                    }) {
                                                        SharedAsset.closeButtonCreateMumory.swiftUIImage
                                                            .resizable()
                                                            .frame(width: 27, height: 27)
                                                    }
                                                    .offset(x: -51 + 57 + 27, y: -(-51 + 57 + 27))
                                                }
                                            }
                                        }
                                    }
                                    .onChange(of: photoPickerViewModel.imageSelections) { _ in
                                        photoPickerViewModel.convertDataToImage()
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 50)
        
                            } // VStack
                            .padding(.top, 20)
                            .padding(.bottom, 50)
        
                    } // ScrollView
                    .simultaneousGesture(DragGesture().onChanged { i in
                        // 스크롤할 때 바텀시트 움직이는 것 방지?
                        print("simultaneousGesture DragGesture")
        
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    })
                    

                    ZStack(alignment: .topLeading) {
                        Rectangle()
                            .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.12))
                            .frame(height: 72 + appCoordinator.safeAreaInsetsBottom)
                            .overlay(
                                Rectangle()
                                    .inset(by: 0.15)
                                    .fill(Color(red: 0.65, green: 0.65, blue: 0.65))
                                    .frame(height: 0.5)
                                , alignment: .top
                            )
                        
                        
                            HStack(spacing: 0) {

                                Group {
                                    Text("전체공개")
                                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                                        .foregroundColor(self.isPublic ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.76, green: 0.76, blue: 0.76))
                                    
                                    Spacer().frame(width: 7)
                                    
                                    Image(uiImage: self.isPublic ? SharedAsset.publicOnCreateMumory.image : SharedAsset.publicOffCreateMumory.image)
                                        .frame(width: 17, height: 17)
                                    
                                    Spacer()
                                }
                                .onTapGesture {
                                    self.isPublic.toggle()
                                }
                                
                                SharedAsset.keyboardButtonCreateMumory.swiftUIImage
//                                    .resizable()
                                    .frame(width: 26, height: 26)
                            }
                            .padding(.top, 18)
                            .padding(.horizontal, 20)
                    } // ZStack
                    .offset(y: getUIScreenBounds().height == 667 || getUIScreenBounds().height == 736 ? -33  : -getSafeAreaInsets().bottom - 16)
                    .highPriorityGesture(TapGesture())
                    
                } // VStack
                .background(SharedAsset.backgroundColor.swiftUIColor)
                .cornerRadius(23, corners: [.topLeft, .topRight])
                .padding(.top, appCoordinator.safeAreaInsetsTop + 16)
                .padding(.bottom, -appCoordinator.safeAreaInsetsTop - 16)
                .offset(y: self.offsetY + self.dragState.translation.height)
                .gesture(drag)
                .transition(.move(edge: .bottom))
                .zIndex(1)
                .calendarPopup(show: self.$showDatePicker, yOffset: self.calendarYOffset) {

                    DatePicker("", selection: self.$date, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .accentColor(SharedAsset.mainColor.swiftUIColor)
                        .background(SharedAsset.backgroundColor.swiftUIColor)
                        .preferredColorScheme(.dark)
//                        .onChange(of: self.date) { _ in
//                            withAnimation(.easeInOut(duration: 0.1)) {
//                                self.showDatePicker = false
//                            }
//                        }
                }
                .popup(show: self.$isPublishPopUpShown, content: {
                    PopUpView(isShown: self.$isPublishPopUpShown, type: .twoButton, title: "게시하기겠습니까?", buttonTitle: "게시", buttonAction: {
                        if let choosedMusicModel = mumoryDataViewModel.choosedMusicModel, let choosedLocationModel = mumoryDataViewModel.choosedLocationModel {
                            let newMumoryAnnotation = MumoryAnnotation(date: self.date, musicModel: choosedMusicModel, locationModel: choosedLocationModel)
                            
                            mumoryDataViewModel.createMumory(newMumoryAnnotation)
                        }
                        
                        withAnimation(Animation.easeInOut(duration: 0.2)) { // 사라질 때 애니메이션 적용
                            appCoordinator.isCreateMumorySheetShown = false
                        }
                        
                        mumoryDataViewModel.choosedMusicModel = nil
                        mumoryDataViewModel.choosedLocationModel = nil
                    })
                })
                .popup(show: self.$isPublishErrorPopUpShown, content: {
                    PopUpView(isShown: self.$isPublishErrorPopUpShown, type: .oneButton, title: "음악, 위치, 날짜를 입력해주세요.", subTitle: "뮤모리를 남기시려면\n해당 조건을 필수로 입력해주세요!", buttonTitle: "확인", buttonAction: {
                        self.isPublishErrorPopUpShown = false
                    })
                    
                })
                .popup(show: self.$isTagErrorPopUpShown, content: {
                    PopUpView(isShown: self.$isTagErrorPopUpShown, type: .oneButton, title: "태그는 최대 3개까지 입력할 수 있습니다.", buttonTitle: "확인", buttonAction: {
                        self.isTagErrorPopUpShown = false
                    })
                })
                .popup(show: self.$isDeletePopUpShown, content: {
                    PopUpView(isShown: self.$isDeletePopUpShown, type: .delete, title: "해당 기록을 삭제하시겠습니까?", subTitle: "지금 이 페이지를 나가면 작성하던\n기록이 삭제됩니다.", buttonTitle: "계속 작성하기", buttonAction: {
                        self.isDeletePopUpShown = false
                    })
                    
                })
            }
        }
    }
    
    private func onDragEnded(drag: DragGesture.Value) {
//        print("drag.translation.height: \(drag.translation.height)")
        //        let verticalDirection = drag.predictedEndLocation.y - drag.location.y
        let cardDismiss = drag.translation.height > 100
        let offset = cardDismiss ? drag.translation.height : 0
        
        self.offsetY = CGFloat(offset)
        
        if cardDismiss {
            withAnimation(.spring(response: 0.1)) {
                self.isSheetShown = false
            }
        }
    }
}

enum DragState {
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    
    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}
