//
//  HomeView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/08.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import MapKit

import Core
import Shared

import Firebase


public struct HomeView: View {
    
    @State private var selectedTab: Tab = .home
    @State private var region: MKCoordinateRegion?
    @State private var listener: ListenerRegistration?

    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var keyboardResponder: KeyboardResponder
    @EnvironmentObject var settingViewModel: SettingViewModel
    @EnvironmentObject var withdrawViewModel: WithdrawViewModel
    
    
    @State var myPageStack: [MyPage] = []
    
    public init() {}
    
    public var body: some View {
        
            
            ZStack(alignment: .bottom) {
                
                VStack(spacing: 0) {
                    switch selectedTab {
                    case .home:
                        mapView
                    case .social:
                        SocialView()
                    case .library:
                        LibraryView()
                    case .notification:
                        NotifyView()
                    }
                }
                .padding(.bottom, 89)
                
                //마이페이지
                MyPageBottomAnimationView()
                
                MumoryTabView(selectedTab: $selectedTab)
                
                
                MiniPlayerView()
                    .padding(.bottom, 89)
                    .opacity(appCoordinator.isHiddenTabBar ? 0 : 1)
                
            
                CreateMumoryBottomSheetView(isSheetShown: $appCoordinator.isCreateMumorySheetShown, offsetY: $appCoordinator.offsetY, newRegion: self.$region)
                
                MumoryCommentSheetView(isSheetShown: $appCoordinator.isMumoryDetailCommentSheetViewShown, offsetY: $appCoordinator.offsetY, mumoryAnnotation: mumoryDataViewModel.selectedMumoryAnnotation ?? Mumory())
                    .bottomSheet(isShown: $appCoordinator.isCommentBottomSheetShown, mumoryBottomSheet: MumoryBottomSheet(appCoordinator: appCoordinator, mumoryDataViewModel: mumoryDataViewModel, type: .mumoryCommentMyView, mumoryAnnotation: Mumory()))
                    .popup(show: $appCoordinator.isDeleteCommentPopUpViewShown) {
                        PopUpView(isShown: $appCoordinator.isDeleteCommentPopUpViewShown, type: .twoButton, title: "나의 댓글을 삭제하시겠습니까?", buttonTitle: "댓글 삭제", buttonAction: {
            //                self.mumoryDataViewModel.deleteMumory(self.mumoryAnnotation)
                            appCoordinator.isDeleteCommentPopUpViewShown = false
                        })
                    }
                
                if self.appCoordinator.isMumoryPopUpShown {
                    
                    ZStack {
                        
                        Color.black.opacity(0.6)
                            .onTapGesture {
                                self.appCoordinator.isMumoryPopUpShown = false
                            }
                        
                        MumoryCarouselUIViewRepresentable(mumoryAnnotations: $mumoryDataViewModel.mumoryCarouselAnnotations)
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
                
                if self.appCoordinator.isAddFriendViewShown {
                    SocialFriendTestView()
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                }
                
            } // ZStack
            .ignoresSafeArea()
            .navigationBarBackButtonHidden()
            .onAppear {
                playerViewModel.isShownMiniPlayer = false
            }
    }
    
    var mapView: some View {
        
        ZStack {
            
            HomeMapViewRepresentable(annotationSelected: $appCoordinator.isMumoryPopUpShown, region: $region)
                .onAppear {
                    Task {
                        print("HomeMapViewRepresentable onAppear")
                    }
//                    self.mumoryDataViewModel.fetchMyMumory(userDocumentID: self.appCoordinator.currentUser.documentID)
                    self.listener = self.mumoryDataViewModel.fetchMyMumoryListener(userDocumentID: self.appCoordinator.currentUser.documentID)
                }
                .onDisappear {
                    print("HomeMapViewRepresentable onDisappear")
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
    
    @ViewBuilder
    private func MyPageBottomAnimationView() -> some View{
        VStack {
            if appCoordinator.bottomAnimationViewStatus == .myPage {
                MyPageView()
                    .environmentObject(withdrawViewModel)
                    .environmentObject(settingViewModel)
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
                    
            }
        }

    }
    @ViewBuilder
    private func PlayBottomAnimationView() -> some View {
        VStack {
            if appCoordinator.bottomAnimationViewStatus == .play {
                NowPlayingView()
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
            }
        }
    }

}
