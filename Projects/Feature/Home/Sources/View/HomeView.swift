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
    
    @StateObject private var playerManager = PlayerViewModel()
    @State private var translation: CGSize = .zero
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    let customDetent = UISheetPresentationController.Detent.custom(identifier: nil) { context in
        let statusBarHeight = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.statusBarManager?.statusBarFrame.height }
            .first ?? 0
        let safeAreaInsetsTop = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first?.safeAreaInsets.top }
            .first ?? 0
        return UIScreen.main.bounds.height - 100
    }
       
    
    public init() {}
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height > 0 {
                    DispatchQueue.main.async {
                        translation.height = value.translation.height                        
                    }
                }
            }
            .onEnded { value in
                
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
                        LibraryManageView()
                            .environmentObject(playerManager)
                    case .notification:
                        VStack(spacing: 0){
                            Color.red
                            Color.blue
                        }
                    }
                    
                    HomeTabView(selectedTab: $selectedTab)
                }
                
                    MiniPlayerView()
                        .environmentObject(playerManager)
                        .padding(.bottom, 89 + appCoordinator.safeAreaInsetsBottom)
                        .opacity(appCoordinator.isHiddenTabBar ? 0 : 1)
            
                
                if appCoordinator.isCreateMumorySheetShown {
                    Color.black.opacity(0.6)
                        .onTapGesture {
                            withAnimation(Animation.easeInOut(duration: 0.2)) { // 사라질 때 애니메이션 적용
                                appCoordinator.isCreateMumorySheetShown = false
                                //                                mumoryDataViewModel.choosedMusicModel = nil
                                //                                mumoryDataViewModel.choosedLocationModel = nil
                            }}
                    
                    CreateMumoryBottomSheetView()
                        .offset(y: translation.height)
                        .gesture(dragGesture)
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                }
                
//                ZStack(alignment: .center) {
//
//                    Color.black.opacity(0.5)
//
//                    RewardPopUpView()
//                }
                    
                
                if self.appCoordinator.isMumoryPopUpShown {
                    ZStack { // 부모 ZStack의 정렬 무시
                        Color.black.opacity(0.6)
                            .onTapGesture {
                                self.appCoordinator.isMumoryPopUpShown = false
                            }
                        
                        MumoryCarousel(mumoryAnnotations: $mumoryDataViewModel.mumoryAnnotations)
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
                
            } // ZStack
            .ignoresSafeArea()            
            .navigationBarBackButtonHidden()
            .navigationDestination(for: Int.self) { i in
                switch i {
                case 0:
                    MumoryDetailView(mumoryAnnotation: mumoryDataViewModel.mumoryAnnotations[2])
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
                      startPoint: UnitPoint(x: 0.5, y: 1),
                      endPoint: UnitPoint(x: 0.5, y: 0)
                    )
                  )
                  .offset(y: 89 + appCoordinator.safeAreaInsetsBottom)
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
            print("FUCK")
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
