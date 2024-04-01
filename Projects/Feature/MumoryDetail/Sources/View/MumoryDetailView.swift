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
        
        scrollView.isScrollEnabled = true
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        let hostingController = UIHostingController(rootView: MumoryDetailScrollContentView(mumory: self.mumory)
            .environmentObject(appCoordinator)
            .environmentObject(mumoryDataViewModel)
            .environmentObject(currentUserData)
        )
        
        let contentHeight = hostingController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: contentHeight)
        hostingController.view.frame = CGRect(x: 0, y: -appCoordinator.safeAreaInsetsTop, width: UIScreen.main.bounds.width, height: contentHeight)
        
        scrollView.backgroundColor = .clear
        hostingController.view.backgroundColor = .clear
        
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        scrollView.addSubview(hostingController.view)
        
        return scrollView
    }
    
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        let hostingController = UIHostingController(rootView: MumoryDetailScrollContentView(mumory: self.mumory)
            .environmentObject(appCoordinator)
            .environmentObject(mumoryDataViewModel)
            .environmentObject(currentUserData)
        )
        let contentHeight = hostingController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height

        
        if context.coordinator.contentHeight != contentHeight {
           
            uiView.contentSize = CGSize(width: 0, height: contentHeight) // 수평 스크롤 차단을 위해 너비를 0으로 함
            hostingController.view.frame = CGRect(x: 0, y: -appCoordinator.safeAreaInsetsTop, width: UIScreen.main.bounds.width, height: contentHeight)
            
            uiView.backgroundColor = .clear
            hostingController.view.backgroundColor = .clear

            uiView.subviews.forEach { $0.removeFromSuperview() }
            uiView.addSubview(hostingController.view)

            context.coordinator.contentHeight = contentHeight
        }
    

//        hostingController.view.setNeedsLayout()
//        hostingController.view.layoutIfNeeded()

//        let contentSize = hostingController.view.sizeThatFits(
//             CGSize(width: UIScreen.main.bounds.width, height: CGFloat.infinity)
//         )
//
//        uiView.contentSize = CGSize(width: 0, height: contentSize.height) // 수평 스크롤 차단을 위해 너비를 0으로 함
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension MumoryDetailScrollViewRepresentable {
    
    class Coordinator: NSObject {
        
        let parent: MumoryDetailScrollViewRepresentable
        var contentHeight: CGFloat = .zero
        //        var previousOffset: CGFloat = 0.0
        
        init(parent: MumoryDetailScrollViewRepresentable) {
            self.parent = parent
            super.init()
        }
    }
}

extension MumoryDetailScrollViewRepresentable.Coordinator: UIScrollViewDelegate {
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        DispatchQueue.main.async {
            self.parent.contentOffsetY = offsetY
        }
        
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
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    
    public var body: some View {
        
        ZStack(alignment: .top) {
            
            Color(red: 0.09, green: 0.09, blue: 0.09)
                        
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
            
            if mumoryDataViewModel.isUpdating {
                MumoryDetailLoadingView()
            }
            
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
            
            MumoryCommentSheetView(isSheetShown: $appCoordinator.isMumoryDetailCommentSheetViewShown, offsetY: $appCoordinator.offsetY)
                .bottomSheet(isShown: $appCoordinator.isCommentBottomSheetShown, mumoryBottomSheet: MumoryBottomSheet(appCoordinator: appCoordinator, mumoryDataViewModel: mumoryDataViewModel, type: .mumoryCommentMyView(isMe: mumoryDataViewModel.selectedComment.uId == currentUserData.user.uId ? true : false), mumoryAnnotation: .constant(Mumory())))
            
            ZStack {
                Color.clear
                    .ignoresSafeArea()
                
                LoadingAnimationView(isLoading: self.$mumoryDataViewModel.isUpdating)
            }
        } // ZStack
        .background(Color(red: 0.09, green: 0.09, blue: 0.09))
        .onAppear {
            playerViewModel.setPlayerVisibility(isShown: false)
            
            Task {
                self.mumory = await self.mumoryDataViewModel.fetchMumory(documentID: self.mumory.id)
                self.user = await MumoriUser(uId: self.mumory.uId)
                print("mumoryAnnotation in MumoryDetailView: \(mumory.id)")
                
                for friend in self.currentUserData.friends {
                    await mumoryDataViewModel.sameSongFriendMumory(friend: friend, songId: self.mumory.musicModel.songID.rawValue)
                    await mumoryDataViewModel.surroundingFriendMumory(friend: friend, mumory: self.mumory)
                    print("친구뮤모리: \(mumoryDataViewModel.sameSongFriendMumorys)")
                    print("주변뮤모리: \(mumoryDataViewModel.surroundingMumorys)")
                }
            }
            
            Task {
                for friend in self.currentUserData.friends {
                    await mumoryDataViewModel.sameSongFriendMumory(friend: friend, songId: self.mumory.musicModel.songID.rawValue)
                    await mumoryDataViewModel.surroundingFriendMumory(friend: friend, mumory: self.mumory)
                    print("친구뮤모리: \(mumoryDataViewModel.sameSongFriendMumorys)")
                    print("주변뮤모리: \(mumoryDataViewModel.surroundingMumorys)")
                }
            }
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea()
        .fullScreenCover(isPresented: self.$isMapSheetShown) {
            MumoryMapView(isShown: self.$isMapSheetShown, mumory: self.mumory, user: self.user)
        }
        .bottomSheet(isShown: $appCoordinator.isMumoryDetailMenuSheetShown, mumoryBottomSheet: MumoryBottomSheet(appCoordinator: appCoordinator, mumoryDataViewModel: mumoryDataViewModel, type: self.mumory.uId == currentUserData.user.uId ? .mumoryDetailView : .mumoryCommentFriendView, mumoryAnnotation: self.$mumory, isMapSheetShown: self.$isMapSheetShown))
        .popup(show: $appCoordinator.isDeleteMumoryPopUpViewShown, content: {
            PopUpView(isShown: $appCoordinator.isDeleteMumoryPopUpViewShown, type: .twoButton, title: "해당 뮤모리를 삭제하시겠습니까?", buttonTitle: "뮤모리 삭제", buttonAction: {
                mumoryDataViewModel.deleteMumory(mumory) {
                    print("뮤모리 삭제 성공")
                    appCoordinator.isDeleteMumoryPopUpViewShown = false
                    appCoordinator.rootPath.removeLast()
                    appCoordinator.isFirstTabSelected = false
                }
            })
        })
    }
}

public struct MumoryDetailLoadingView: View {
    
    @State var startAnimation: Bool = true
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    public var body: some View {
        ScrollView {
            
            ZStack(alignment: .top) {
                
                Color(red: 0.184, green: 0.184, blue: 0.184)
                    .frame(width: getUIScreenBounds().width, height: getUIScreenBounds().height)
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    ZStack(alignment: .bottomLeading) {
                        
                        SharedAsset.albumFilterMumoryDetail.swiftUIImage
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                            .offset(y: -appCoordinator.safeAreaInsetsTop)
                        
                        Rectangle()
                            .fill(SharedAsset.backgroundColor.swiftUIColor)
                            .frame(width: UIScreen.main.bounds.width, height: 64)
                            .background(
                                LinearGradient(
                                    stops: [
                                        Gradient.Stop(color: Color(red: 0.09, green: 0.09, blue: 0.09), location: 0.38),
                                        Gradient.Stop(color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0), location: 0.59),
                                    ],
                                    startPoint: UnitPoint(x: 0.5, y: 1.28),
                                    endPoint: UnitPoint(x: 0.5, y: 0.56)
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 10) {
                            RoundedRectangle(cornerRadius: 5, style: .circular)
                                .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                .frame(width: 255, height: 23)
                            
                            RoundedRectangle(cornerRadius: 5, style: .circular)
                                .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                .frame(width: 86, height: 18)
                        }
                        .padding(.leading, 20)
                    } // ZStack
                    
                    SharedAsset.backgroundColor.swiftUIColor
                    
                    HStack(spacing: 0) {
                        Circle()
                            .fill(self.startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                            .frame(width: 38, height: 38)
                        
                        Spacer().frame(width: 8)
                        
                        VStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 5, style: .circular)
                                .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                .frame(width: 95, height: 14)
                            
                            HStack {
                                RoundedRectangle(cornerRadius: 5, style: .circular)
                                    .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                    .frame(width: 60, height: 14)
                                
                                Spacer()
                                
                                RoundedRectangle(cornerRadius: 5, style: .circular)
                                    .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                    .frame(width: 124, height: 14)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 68)
                    .background(SharedAsset.backgroundColor.swiftUIColor)
                    
                    HStack(spacing: 8) {
                        ForEach(0..<3) { _ in
                            RoundedRectangle(cornerRadius: 40, style: .circular)
                                .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                .frame(width: 75, height: 28)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 55)
                    .background(SharedAsset.backgroundColor.swiftUIColor)
                    
                    
                    VStack(alignment: .leading, spacing: 0) {
                        RoundedRectangle(cornerRadius: 40, style: .circular)
                            .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                            .frame(width: getUIScreenBounds().width - 40, height: 15)
                        
                        RoundedRectangle(cornerRadius: 40, style: .circular)
                            .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                            .frame(width: 313, height: 15)
                            .padding(.top, 13)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
                    .background(SharedAsset.backgroundColor.swiftUIColor)
                    
                    
                    Rectangle()
                        .fill(self.startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                        .frame(width: getUIScreenBounds().width - 40, height: getUIScreenBounds().width - 40)
                        .padding(.horizontal, 20)
                        .padding(.top, 21)
                        .background(SharedAsset.backgroundColor.swiftUIColor)
                        .clipped()
                }
            }
        }
        .frame(width: getUIScreenBounds().width, height: getUIScreenBounds().height)
        .scrollDisabled(true)
        .ignoresSafeArea()
        .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: self.startAnimation)
        .onAppear {
            startAnimation.toggle()
        }
    }
}

public struct SocialLoadingView: View {
    
    @State var startAnimation: Bool = true
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    public var body: some View {
        ScrollView {
            
            ZStack(alignment: .top) {
                
                SharedAsset.backgroundColor.swiftUIColor
                    .frame(width: getUIScreenBounds().width, height: getUIScreenBounds().height)
                
                VStack(spacing: 0) {
                    
                    Rectangle()
                        .fill(SharedAsset.backgroundColor.swiftUIColor)
                        .frame(height: 68)
                        .padding(.top, appCoordinator.safeAreaInsetsTop)
                    
                    Group {
                        HStack(spacing: 0) {
                            Circle()
                                .fill(self.startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                                .frame(width: 38, height: 38)
                            
                            Spacer().frame(width: 8)
                            
                            VStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 5, style: .circular)
                                    .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                    .frame(width: 95, height: 14)
                                
                                HStack {
                                    RoundedRectangle(cornerRadius: 5, style: .circular)
                                        .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                        .frame(width: 60, height: 14)
                                    
                                    Spacer()
                                    
                                    RoundedRectangle(cornerRadius: 5, style: .circular)
                                        .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                        .frame(width: 124, height: 14)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 15, style: .circular)
                                .fill(self.startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                                .frame(width: getUIScreenBounds().width - 20, height: getUIScreenBounds().width - 20)
                            
                            VStack(spacing: 0) {
                                RoundedRectangle(cornerRadius: 5, style: .circular)
                                    .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                    .frame(width: 139, height: 12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 22)
                                    .padding(.horizontal, 20)
                                
                                Spacer()
                                
                                HStack(alignment: .bottom, spacing: 0) {
                                    
                                    VStack(alignment: .leading, spacing: 12) {
                                        
                                        HStack(spacing: 8) {
                                            
                                            ForEach(0..<2) { _ in
                                                RoundedRectangle(cornerRadius: 40, style: .circular)
                                                    .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                                    .frame(width: 75, height: 28)
                                            }
                                            Spacer()
                                        }
                                        
                                        RoundedRectangle(cornerRadius: 5, style: .circular)
                                            .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                            .frame(width: 258, height: 12)
                                    }
                                    
                                    VStack(spacing: 12) {
                                        Circle()
                                            .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                            .frame(width: 42, height: 42)
                                        
                                        Circle()
                                            .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                            .frame(width: 42, height: 42)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 27)
                            }
                            .frame(width: getUIScreenBounds().width - 20, height: getUIScreenBounds().width - 20)
                        }
                        .padding(.top, 14)
                    }
                    
                    Group {
                        HStack(spacing: 0) {
                            Circle()
                                .fill(self.startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                                .frame(width: 38, height: 38)
                            
                            Spacer().frame(width: 8)
                            
                            VStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 5, style: .circular)
                                    .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                    .frame(width: 95, height: 14)
                                
                                HStack {
                                    RoundedRectangle(cornerRadius: 5, style: .circular)
                                        .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                        .frame(width: 60, height: 14)
                                    
                                    Spacer()
                                    
                                    RoundedRectangle(cornerRadius: 5, style: .circular)
                                        .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                        .frame(width: 124, height: 14)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 40)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 15, style: .circular)
                                .fill(self.startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                                .frame(width: getUIScreenBounds().width - 20, height: getUIScreenBounds().width - 20)
                            
                            VStack(spacing: 0) {
                                RoundedRectangle(cornerRadius: 5, style: .circular)
                                    .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                    .frame(width: 139, height: 12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 22)
                                    .padding(.horizontal, 20)
                                
                                Spacer()
                                
                                HStack(alignment: .bottom, spacing: 0) {
                                    
                                    VStack(alignment: .leading, spacing: 12) {
                                        
                                        HStack(spacing: 8) {
                                            
                                            ForEach(0..<2) { _ in
                                                RoundedRectangle(cornerRadius: 40, style: .circular)
                                                    .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                                    .frame(width: 75, height: 28)
                                            }
                                            Spacer()
                                        }
                                        
                                        RoundedRectangle(cornerRadius: 5, style: .circular)
                                            .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                            .frame(width: 258, height: 12)
                                    }
                                    
                                    VStack(spacing: 12) {
                                        Circle()
                                            .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                            .frame(width: 42, height: 42)
                                        
                                        Circle()
                                            .fill(self.startAnimation ? ColorSet.skeleton02 : ColorSet.skeleton03)
                                            .frame(width: 42, height: 42)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 27)
                            }
                            .frame(width: getUIScreenBounds().width - 20, height: getUIScreenBounds().width - 20)
                        }
                        .padding(.top, 14)
                    }
                }
                .padding(.top, 25)
            }
        }
        .scrollDisabled(true)
        .ignoresSafeArea()
        .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: self.startAnimation)
        .onAppear {
            startAnimation.toggle()
        }
    }
}

