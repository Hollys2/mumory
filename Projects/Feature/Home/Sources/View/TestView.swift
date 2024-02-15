//
//  TestView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/27.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import PhotosUI
import Core
import Shared
import MapKit


@available(iOS 16.0, *)
public struct TestView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    @GestureState var dragAmount = CGSize.zero
    @State private var translation: CGSize = CGSize(width: 0, height: 0)
    
    public init() {}
    
    var dragGesture: some Gesture {
        DragGesture()
            .updating($dragAmount) { value, state, _ in
                print("updating: \(value.translation.height)")
                if value.translation.height > 0 {
                    DispatchQueue.main.async {
                        self.translation.height = value.translation.height
                    }
                }
                
            }
            .onEnded { value in
                print("onEnded: \(value.translation.height)")
                withAnimation(Animation.easeInOut(duration: 0.2)) {
                    if value.translation.height > 50 {
                        appCoordinator.isMumoryDetailMenuSheetShown = false
                    }
                    self.translation.height = 0
                }
            }
    }
    
    public var body: some View {
//        VStack(spacing: 0) {
        NavigationStack{
            VStack(spacing: 0) {
                Image(uiImage: SharedAsset.dragIndicator.image)
                    .frame(maxWidth: .infinity)
                    .frame(height: 22)
                    .background(.pink)
                    .gesture(dragGesture)
                
                Group {
                    Button(action: {
                        
                    }, label: {
                        HStack(spacing: 0) {
                            Spacer().frame(width: 24)
                            SharedAsset.editMumoryDetailMenu.swiftUIImage
                                .frame(width: 22, height: 22)
                            
                            Spacer().frame(width: 14)
                            
                            Text("뮤모리 수정")
                                .font(
                                    Font.custom("Pretendard", size: 16)
                                        .weight(.medium)
                                )
                                .foregroundColor(.white)
                                .frame(height: 55)
                            
                            Spacer()
                        }
                    })
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 0.3)
                        .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.4))
                    
                    Button(action: {
                    }, label: {
                        HStack(spacing: 0) {
                            Spacer().frame(width: 24)
                            SharedAsset.lockMumoryDetailMenu.swiftUIImage
                                .frame(width: 22, height: 22)
                            
                            Spacer().frame(width: 14)
                            
                            Text("나만 보기")
                                .font(
                                    Font.custom("Pretendard", size: 16)
                                        .weight(.medium)
                                )
                                .foregroundColor(.white)
                                .frame(height: 55)
                            
                            Spacer()
                        }
                    })
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 0.3)
                        .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.4))
                    
                    Button(action: {
                        
                    }, label: {
                        HStack(spacing: 0) {
                            Spacer().frame(width: 24)
                            SharedAsset.mapMumoryDetailMenu.swiftUIImage
                                .frame(width: 22, height: 22)
                            
                            Spacer().frame(width: 14)
                            
                            Text("지도에서 보기")
                                .font(
                                    Font.custom("Pretendard", size: 16)
                                        .weight(.medium)
                                )
                                .foregroundColor(.white)
                                .frame(height: 55)
                            
                            Spacer()
                        }
                    })
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 0.3)
                        .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.4))
                }
                
                //                Rectangle()
                //                    .foregroundColor(.clear)
                //                    .frame(height: 0.3)
                //                    .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.4))
                
                Group {
                    Button(action: {
                        
                    }, label: {
                        HStack(spacing: 0) {
                            Spacer().frame(width: 24)
                            SharedAsset.deleteMumoryDetailMenu.swiftUIImage
                                .frame(width: 22, height: 22)
                            
                            Spacer().frame(width: 14)
                            
                            Text("뮤모리 삭제")
                                .font(
                                    Font.custom("Pretendard", size: 16)
                                        .weight(.medium)
                                )
                                .foregroundColor(Color(red: 1, green: 0.25, blue: 0.25))
                                .frame(height: 55)
                            
                            Spacer()
                        }
                    })
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 0.3)
                        .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.4))
                    
                    Button(action: {
                        
                    }, label: {
                        HStack(spacing: 0) {
                            Spacer().frame(width: 24)
                            SharedAsset.shareMumoryDetailMenu.swiftUIImage
                                .frame(width: 22, height: 22)
                            
                            Spacer().frame(width: 14)
                            
                            Text("공유하기")
                                .font(
                                    Font.custom("Pretendard", size: 16)
                                        .weight(.medium)
                                )
                                .foregroundColor(.white)
                                .frame(height: 55)
                            
                            Spacer()
                        }
                    })
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 0.3)
                        .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.4))
                    
                    Button(action: {
                        
                    }, label: {
                        HStack(spacing: 0) {
                            Spacer().frame(width: 24)
                            SharedAsset.complainMumoryDetailMenu.swiftUIImage
                                .frame(width: 22, height: 22)
                            
                            Spacer().frame(width: 14)
                            
                            Text("신고")
                                .font(
                                    Font.custom("Pretendard", size: 16)
                                        .weight(.medium)
                                )
                                .foregroundColor(.white)
                                .frame(height: 55)
                            
                            Spacer()
                        }
                    })
                }
                
            }
            .frame(width: UIScreen.main.bounds.width - 14 - 18, height: 330)
            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
            .cornerRadius(15)
            
            Spacer().frame(height: 9)
        } // VStack
        .frame(width: UIScreen.main.bounds.width - 14)
        .background(.yellow)
        .cornerRadius(15)
        .offset(y: self.translation.height)
//        .ignoresSafeArea()
        //        .offset(y: self.translation.height + UIScreen.main.bounds.height - appCoordinator.safeAreaInsetsTop - appCoordinator.safeAreaInsetsBottom - 361)
        //        .offset(y: self.translation.height + appCoordinator.safeAreaInsetsTop + 16) // withAnimation과 연관 있음
        //        .offset(y: self.dragAmount + UIScreen.main.bounds.height - 361 - appCoordinator.safeAreaInsetsBottom) // withAnimation과 연관 있음
    }
}
//        .cornerRadius(23, corners: [.topLeft, .topRight])


//Button("SearchLocationView") {
//    appCoordinator.isNavigationStackShown = false
//    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//        appCoordinator.isSearchLocationViewShown = true
//    }
//}
//
//Button("SearchLocationMapView") {
//    appCoordinator.isNavigationStackShown = true
//
//    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//        withAnimation(Animation.easeInOut(duration: 0.2)) {
//            appCoordinator.isCreateMumorySheetShown = false
//        }
//    }
//
//    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//        appCoordinator.isSearchLocationMapViewShown = true
//    }
//}

//@available(iOS 16.0, *)
//struct CreateMumoryBottomSheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        let appCoordinator = AppCoordinator()
//        CreateMumoryBottomSheetView(isShown: .constant(false))
//            .environmentObject(appCoordinator)
//    }
//}


class SwipeBackHostingController<Content: View>: UIHostingController<Content> {
    override init(rootView: Content) {
        super.init(rootView: rootView)
        print("@@SwipeBackHostingController")
        
        // 백 스와이프를 처리하는 GestureRecognizer 추가
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        gesture.direction = .right
        view.addGestureRecognizer(gesture)
    }
    
    @objc private func handleSwipeGesture() {
        // 백 스와이프가 감지되면 뷰를 닫음
        presentationController?.presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
