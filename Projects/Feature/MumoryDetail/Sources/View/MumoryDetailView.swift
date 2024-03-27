//
//  MumoryDetailView.swift
//  Feature
//
//  Created by 다솔 on 2023/12/25.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import MapKit

import Shared

struct MumoryDetailScrollViewRepresentable: UIViewRepresentable {
    
    //    typealias UIViewType = UIScrollView
    
    let mumory: Mumory
    
    @Binding var contentOffsetY: Double
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        
        scrollView.delegate = context.coordinator
        
        scrollView.contentMode = .scaleToFill
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        let hostingController = UIHostingController(rootView: MumoryDetailScrollContentView(mumory: self.mumory)
            .environmentObject(appCoordinator)
            .environmentObject(mumoryDataViewModel)
            .environmentObject(currentUserData)
        )
        let x = hostingController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        hostingController.view.frame = CGRect(x: 0, y: -appCoordinator.safeAreaInsetsTop, width: UIScreen.main.bounds.width, height: x)
        
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: x)
        
        scrollView.backgroundColor = .clear
        hostingController.view.backgroundColor = .clear
        
        scrollView.addSubview(hostingController.view)
        
        return scrollView
    }
    
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        let hostingController = UIHostingController(rootView: MumoryDetailScrollContentView(mumory: self.mumory)
            .environmentObject(appCoordinator)
            .environmentObject(mumoryDataViewModel)
            .environmentObject(currentUserData)
        )
        let x = hostingController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        hostingController.view.frame = CGRect(x: 0, y: -appCoordinator.safeAreaInsetsTop, width: UIScreen.main.bounds.width, height: x)
        
        uiView.contentSize = CGSize(width: 0, height: x) // 수평 스크롤 차단을 위해 너비를 0으로 함
        hostingController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: x)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension MumoryDetailScrollViewRepresentable {
    
    class Coordinator: NSObject {
        
        let parent: MumoryDetailScrollViewRepresentable
        //        var previousOffset: CGFloat = 0.0
        
        init(parent: MumoryDetailScrollViewRepresentable) {
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

extension MumoryDetailScrollViewRepresentable.Coordinator: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        self.parent.contentOffsetY = offsetY
        
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
    

    @State var mumory: Mumory
    @State var user: MumoriUser = MumoriUser()
    @State var offsetY: Double = .zero
    @State var isMapSheetShown: Bool = false
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
    
    public var body: some View {
        
        ZStack(alignment: .top) {
            
            Color(red: 0.09, green: 0.09, blue: 0.09)
            
            MumoryCommentSheetView(isSheetShown: $appCoordinator.isMumoryDetailCommentSheetViewShown, offsetY: $appCoordinator.offsetY)
                .bottomSheet(isShown: $appCoordinator.isCommentBottomSheetShown, mumoryBottomSheet: MumoryBottomSheet(appCoordinator: appCoordinator, mumoryDataViewModel: mumoryDataViewModel, type: .mumoryCommentMyView(isMe: mumoryDataViewModel.selectedComment.userDocumentID == currentUserData.user.uId ? true : false), mumoryAnnotation: .constant(Mumory())))
            
            ZStack(alignment: .bottomLeading) {
                
                AsyncImage(url: mumory.musicModel.artworkUrl, transaction: Transaction(animation: .easeInOut(duration: 0.1))) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    default:
                        Color(red: 0.18, green: 0.18, blue: 0.18)
                    }
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                .overlay {
                    ColorSet.background.opacity((self.offsetY + appCoordinator.safeAreaInsetsTop) / (getUIScreenBounds().width - 150))
                }
                
                SharedAsset.albumFilterMumoryDetail.swiftUIImage
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                    .offset(y: -self.offsetY - appCoordinator.safeAreaInsetsTop)
                
                VStack(spacing: 10) {

                    Text("\(mumory.musicModel.title)")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 24))
                        .lineLimit(2)
                        .foregroundColor(.white)
                        .frame(width: 301, alignment: .leading)

                    Text("\(mumory.musicModel.artist)")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 20))
                        .lineLimit(1)
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 301, alignment: .leading)
                }
                .padding(.leading, 20)
            } // ZStack
            
            MumoryDetailScrollViewRepresentable(mumory: self.mumory, contentOffsetY: self.$offsetY)
            
            HStack {
                
                Button(action: {
                    if !appCoordinator.rootPath.isEmpty {
                        appCoordinator.rootPath.removeLast()
                    }
                }, label: {
                    Image(uiImage: SharedAsset.closeButtonMumoryDetail.image)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 12)
                })
                
                Spacer()
                
                Button(action: {
                    appCoordinator.isMumoryDetailMenuSheetShown = true
                }, label: {
                    Image(uiImage: SharedAsset.menuButtonMumoryDatail.image)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 12)
                })
            }
            .padding(.top, appCoordinator.safeAreaInsetsTop)
            .background(appCoordinator.isNavigationBarColored ? Color(red: 0.09, green: 0.09, blue: 0.09) : .clear)
            
            if appCoordinator.isReactionBarShown {
                MumoryDetailReactionBarView(mumory: self.mumory, isOn: true)
            }
            
            ZStack {
                Color.clear
                
                LoadingAnimationView(isLoading: self.$mumoryDataViewModel.isUpdating)
            }
        } // ZStack
        .onAppear {
            Task {
                self.mumory = await self.mumoryDataViewModel.fetchMumory(documentID: self.mumory.id)
                self.user = await MumoriUser(uId: self.mumory.uId)
                print("mumoryAnnotation in MumoryDetailView: \(mumory.id)")
            }
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea()
        .fullScreenCover(isPresented: self.$isMapSheetShown) {
            MumoryMapView(isShown: self.$isMapSheetShown, mumory: self.mumory, user: self.user)
        }
        .bottomSheet(isShown: $appCoordinator.isMumoryDetailMenuSheetShown, mumoryBottomSheet: MumoryBottomSheet(appCoordinator: appCoordinator, mumoryDataViewModel: mumoryDataViewModel, type: .mumoryDetailView, mumoryAnnotation: self.$mumory, isMapSheetShown: self.$isMapSheetShown))
        .popup(show: $appCoordinator.isDeleteMumoryPopUpViewShown, content: {
            PopUpView(isShown: $appCoordinator.isDeleteMumoryPopUpViewShown, type: .twoButton, title: "해당 뮤모리를 삭제하시겠습니까?", buttonTitle: "뮤모리 삭제", buttonAction: {
                mumoryDataViewModel.deleteMumory(mumory) {
                    print("뮤모리 삭제 성공")
                    appCoordinator.isDeleteMumoryPopUpViewShown = false
                    appCoordinator.rootPath.removeLast()
                }
            })
        })
    }
}
