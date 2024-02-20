//
//  MumoryDetailView.swift
//  Feature
//
//  Created by 다솔 on 2023/12/25.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Shared

struct MumoryDetailScrollView: UIViewRepresentable {
    
    //    typealias UIViewType = UIScrollView
    
    @State var mumoryAnnotation: MumoryAnnotation
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        
        scrollView.delegate = context.coordinator
        
        scrollView.contentMode = .scaleToFill
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        let hostingController = UIHostingController(rootView: MumoryDetailScrollContentView(mumoryAnnotation: self.mumoryAnnotation).environmentObject(appCoordinator))
        let x = hostingController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        hostingController.view.frame = CGRect(x: 0, y: -appCoordinator.safeAreaInsetsTop, width: UIScreen.main.bounds.width, height: 2300)
        
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 2300)
        
        scrollView.backgroundColor = .clear
        hostingController.view.backgroundColor = .clear
        
        scrollView.addSubview(hostingController.view)
        
        return scrollView
    }
    
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension MumoryDetailScrollView {
    
    class Coordinator: NSObject {
        
        let parent: MumoryDetailScrollView
        //        var previousOffset: CGFloat = 0.0
        
        init(parent: MumoryDetailScrollView) {
            self.parent = parent
            super.init()
        }
        
        func handleScrollDirection(_ direction: ScrollDirection) {
            switch direction {
            case .up:
                withAnimation(Animation.easeInOut(duration: 0.2)) {
                    parent.appCoordinator.isNavigationBarShown = true
                }
            case .down:
                withAnimation(Animation.easeInOut(duration: 0.2)) {
                    parent.appCoordinator.isNavigationBarShown = false
                }
            }
        }
        
        func handleScrollBoundary(_ view: ScrollBoundary) {
            switch view {
            case .above:
                parent.appCoordinator.isNavigationBarColored = false
            case .below:
                parent.appCoordinator.isNavigationBarColored = true
            }
        }
    }
}

enum ScrollDirection {
    case up
    case down
}

enum ScrollBoundary {
    case above
    case below
}

extension MumoryDetailScrollView.Coordinator: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        //        print("offsetY: \(offsetY)")
        
        //        let scrollDirection: ScrollDirection = (offsetY < previousOffset) ? .up : .down
        //        let scrollBoundary: ScrollBoundary = (offsetY < UIScreen.main.bounds.width - (parent.appCoordinator.safeAreaInsetsTop + 19 + 30 + 12) - 20) ? .above : .below
        
        //        DispatchQueue.main.async {
        //            self.handleScrollDirection(scrollDirection)
        //            self.handleScrollBoundary(scrollBoundary)
        //        }
        
        let isNavigationBarColored = offsetY >= UIScreen.main.bounds.width - (parent.appCoordinator.safeAreaInsetsTop + 19 + 30 + 12) - 20
        
        DispatchQueue.main.async {
            if self.parent.appCoordinator.isNavigationBarColored != isNavigationBarColored {
                self.parent.appCoordinator.isNavigationBarColored = isNavigationBarColored
            }
        }
        //        previousOffset = offsetY
    }
}

public struct MumoryDetailView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var mumoryAnnotation: MumoryAnnotation
    @State private var isPublic: Bool = false
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    @GestureState var dragAmount = CGSize.zero
    @State private var translation: CGSize = .zero
    
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
        
        ZStack(alignment: .top) {
            
            Color(red: 0.09, green: 0.09, blue: 0.09)
            
            ZStack(alignment: .bottomLeading) {
                
                AsyncImage(url: mumoryAnnotation.musicModel.artworkUrl, transaction: Transaction(animation: .easeInOut(duration: 0.1))) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
//                            .transition(.move(edge: .trailing))
                    default:
                        Color(red: 0.18, green: 0.18, blue: 0.18)
                    }
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                
                VStack(spacing: 23) {
                    
                    Text("\(mumoryAnnotation.musicModel.title)")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 24))
                        .lineLimit(2)
                        .foregroundColor(.white)
                        .frame(width: 301, alignment: .leading)
                    
                    Text("\(mumoryAnnotation.musicModel.artist)")
                        .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 20))
                        .lineLimit(1)
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 301, alignment: .leading)
                }
                .offset(y: -4)
                .padding(.leading, 20)
            } // ZStack
            
            MumoryDetailScrollView(mumoryAnnotation: self.mumoryAnnotation)
            
            HStack {
                Button(action: {
                    if !appCoordinator.rootPath.isEmpty {
                        appCoordinator.rootPath.removeLast()
                    }
                }, label: {
                    Image(uiImage: SharedAsset.closeButtonMumoryDetail.image)
                        .resizable()
                        .frame(width: 30, height: 30)
                })
                
                Spacer()
                
                Button(action: {
                    withAnimation(Animation.easeInOut(duration: 0.2)) {
                        appCoordinator.isMumoryDetailMenuSheetShown = true
                    }
                }, label: {
                    Image(uiImage: SharedAsset.menuButtonMumoryDatail.image)
                        .resizable()
                        .frame(width: 30, height: 30)
                })
            }
            .frame(width: UIScreen.main.bounds.width - 40)
            .padding(.top, appCoordinator.safeAreaInsetsTop + 19)
            .padding(.bottom, 12)
            .padding(.horizontal, 20)
            .background(appCoordinator.isNavigationBarColored ? Color(red: 0.09, green: 0.09, blue: 0.09) : .clear)
            
            if appCoordinator.isReactionBarShown {
                MumoryDetailReactionBarView(isOn: true)
                //                    .transition(.move(edge: .bottom))
            }
            
//            if appCoordinator.isMumoryDetailMenuSheetShown {
//                Color.black.opacity(0.5).ignoresSafeArea()
//                    .onTapGesture {
//                        withAnimation(Animation.easeInOut(duration: 0.2)) {
//                            appCoordinator.isMumoryDetailMenuSheetShown = false
//                        }
//                    }
//
//                MumoryDetailMenuSheetView(mumoryAnnotation: self.mumoryAnnotation, translation: $translation)
//                    .offset(y: self.translation.height + UIScreen.main.bounds.height - 361 - appCoordinator.safeAreaInsetsBottom)
//                    .simultaneousGesture(dragGesture)
//                    .transition(.move(edge: .bottom))
//                    .zIndex(3)
//            }
            
//            if appCoordinator.isMumoryDetailCommentSheetViewShown {
//                Color.black.opacity(0.5).ignoresSafeArea()
//                    .onTapGesture {
//                        withAnimation(Animation.easeInOut(duration: 0.2)) {
//                            appCoordinator.isMumoryDetailCommentSheetViewShown = false
//                        }
//                    }
//
//                MumoryDetailCommentSheetView() // 스크롤뷰만 제스처 추가해서 드래그 막음
//                    .offset(y: self.translation.height + UIScreen.main.bounds.height - (UIScreen.main.bounds.height * 0.84) - appCoordinator.safeAreaInsetsBottom)
//                    .gesture(dragGesture)
//                    .transition(.move(edge: .bottom))
//                    .zIndex(1)
//            }
        } // ZStack
        .navigationBarBackButtonHidden(true)
        .bottomSheet(isShown: $appCoordinator.isMumoryDetailMenuSheetShown, mumoryBottomSheet: MumoryBottomSheet(appCoordinator: appCoordinator, type: .mumoryDetailView, songID: self.mumoryAnnotation.musicModel.songID, isPublic: self.$isPublic))
        .ignoresSafeArea()
    }
}

//struct MumoryDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        let mumoryAnnotation = MumoryAnnotation()
//        MumoryDetailView(mumoryAnnotation: mumoryAnnotation)
//    }
//}
