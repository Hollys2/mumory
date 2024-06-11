//
//  SocialView.swift
//  Feature
//
//  Created by 다솔 on 2024/01/03.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import FirebaseFunctions

import Shared


struct SocialScrollViewRepresentable<Content: View>: UIViewRepresentable {
    
    var content: () -> Content
    @State var isFirst: Bool = true
    //    var onRefresh: () -> Void
    
    @Binding var shouldUpdate: Bool
    @Binding var contentOffsetY: CGFloat
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var currentUserData: CurrentUserViewModel
    
    init(shouldUpdate: Binding<Bool>, contentOffsetY: Binding<CGFloat>, @ViewBuilder content: @escaping () -> Content) {
        self._shouldUpdate = shouldUpdate
        self._contentOffsetY = contentOffsetY
        //        self.onRefresh = onRefresh
        self.content = content
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        print("FUCK makeUIView")
        let scrollView = UIScrollView()
        
        scrollView.delegate = context.coordinator
        
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        //        scrollView.contentInsetAdjustmentBehavior = .never // Disable automatic adjustment
        scrollView.backgroundColor = UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1)
        scrollView.bounces = true
        
        scrollView.contentInset.top = 68
        scrollView.contentOffset = CGPoint(x: 0, y: -68)
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        print("FUCK updateUIView")
        
        let hostingController = UIHostingController(rootView: self.content()
            .environmentObject(self.mumoryDataViewModel)
            .environmentObject(self.currentUserData))
        
        hostingController.view.backgroundColor = UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1)
        
        let contentHeight = hostingController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        print("FUCK contentHeight: \(contentHeight)")
        
        hostingController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: contentHeight)
        
        uiView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: contentHeight)
        
        if context.coordinator.contentHeight != contentHeight {
            print("FUCKYOU")
            uiView.subviews.forEach { $0.removeFromSuperview() }
            uiView.addSubview(hostingController.view)
        }
        
        context.coordinator.contentHeight = contentHeight
        
        let refreshControl = UIRefreshControl()

        refreshControl.tintColor = UIColor(white: 0.47, alpha: 1)
        uiView.refreshControl = refreshControl
        uiView.refreshControl?.addTarget(context.coordinator, action: #selector(Coordinator.handleRefreshControl), for: .valueChanged)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension SocialScrollViewRepresentable {
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        
        let parent: SocialScrollViewRepresentable
        
        var preOffsetY: CGFloat = 0.0
        var topBarOffsetY: CGFloat = 0.0
        var contentHeight: CGFloat = .zero
        var oldMumoryAnnotations: [Mumory] = [] // immutatable if it is declared in SocialScrollViewRepresentable
        
        var isRefreshing = false
        
        init(parent: SocialScrollViewRepresentable) {
            self.parent = parent
            //            super.init()
        }
        
        @objc func handleRefreshControl(sender: UIRefreshControl) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
            
            self.parent.mumoryDataViewModel.fetchSocialMumory(friends: self.parent.currentUserData.friends, me: self.parent.currentUserData.user, isRefreshing: true) { _ in
                DispatchQueue.main.async {
                    sender.endRefreshing()
                }
            }
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offsetY = scrollView.contentOffset.y
            let topAnchor = self.parent.appCoordinator.safeAreaInsetsTop + 68
            
            let deltaY = offsetY - preOffsetY
            
            if deltaY > 0 { // Scrolling down
                topBarOffsetY = min(topBarOffsetY + deltaY, topAnchor)
            } else { // Scrolling up
                topBarOffsetY = max(topBarOffsetY + deltaY, 0)
            }
            
            DispatchQueue.main.async {
                self.parent.contentOffsetY = self.topBarOffsetY
            }
            
            preOffsetY = offsetY
            
            //            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let scrollViewHeight = scrollView.bounds.height
            //            let topAnchor = self.parent.appCoordinator.safeAreaInsetsTop + 68
            //
            //            print("SSS offsetY: \(offsetY)")
            //            print("SSS preOffsetY: \(preOffsetY)")
            //
            //            topBarOffsetY += (offsetY - preOffsetY)
            //
            //            if topBarOffsetY < .zero || offsetY <= .zero {
            //                topBarOffsetY = .zero
            //                print("SSS zero")
            //            } else if topBarOffsetY > topAnchor || offsetY >= contentHeight - scrollViewHeight {
            //                topBarOffsetY = topAnchor
            //                print("SSS limitHeight")
            //            }
            //
            //            DispatchQueue.main.async {
            //                self.parent.contentOffsetY = self.topBarOffsetY
            //            }
            //
            //            preOffsetY = offsetY
            
            
            if offsetY >=  (contentHeight - scrollViewHeight - 100) {
                print("SSS onRefresh")
                
                if !isRefreshing {
                    isRefreshing = true
                    //                    parent.onRefresh()
                    //                onRefresh: {
                    //                    self.mumoryDataViewModel.fetchEveryMumory(friends: currentUserData.friends, me: currentUserData.user) { _ in
                    
                    //                    }
                    //                    self.generateHapticFeedback(style: .medium)
                    //                }
                }
//                else {
//                    isRefreshing = false
//                }
            }
        }
    }
}

struct SocialScrollCotentView: View {
    
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject private var currentUserData: CurrentUserViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            
            ForEach(Array(Set(self.mumoryDataViewModel.socialMumorys)).sorted(by: { $0.date > $1.date }), id: \.uuid) { i in
                SocialItemView(mumory: i)
            }
            
            Spacer(minLength: 0)
        }
        .frame(width: UIScreen.main.bounds.width - 20)
        .padding(.top, 25)
        .padding(.bottom, 90)
    }
}

struct SocialItemView: View {
    
    @State private var isMapViewShown: Bool = false
    @State private var isTruncated: Bool = false
    @State private var isLocationTitleTruncated: Bool = false
    @State private var isButtonDisabled: Bool = false
    @State var user: UserProfile = UserProfile()
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject private var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject private var currentUserData: CurrentUserViewModel
    @EnvironmentObject private var playerViewModel: PlayerViewModel
    
    let mumory: Mumory
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack(spacing: 8) {
                
                AsyncImage(url: self.user.profileImageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                    default:
                        self.user.defaultProfileImage
                            .resizable()
                    }
                }
                .scaledToFill()
                .frame(width: 38, height: 38)
                .mask {Circle()}
                .onTapGesture {
                    if self.user.uId == self.currentUserData.user.uId {
                        appCoordinator.rootPath.append(MumoryPage.myPage)
                    } else {
                        Task {
                            let friend = await FetchManager.shared.fetchUser(uId: self.user.uId)
                            appCoordinator.rootPath.append(MumoryPage.friend(friend: friend))
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text("\(self.user.nickname)")
                        .font((SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14)))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: true, vertical: false)
                    
                    Spacer(minLength: 0)
                    
                    HStack(spacing: 0) {
                        
                        Text(DateManager.formattedDate(date: self.mumory.date, isPublic: self.mumory.isPublic))
                            .font((SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14)))
                            .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                        
                        if !self.mumory.isPublic {
                            Image(uiImage: SharedAsset.lockMumoryDatail.image)
                                .resizable()
                                .frame(width: 18, height: 18)
                        }
                        
                        Spacer()
                        
                        Group {
                            Image(uiImage: SharedAsset.locationMumoryDatail.image)
                                .resizable()
                                .frame(width: 17, height: 17)
                            
                            Spacer().frame(width: 5)
                            
                            Text(self.mumory.locationModel.locationTitle)
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                                .frame(maxWidth: getUIScreenBounds().width * 0.33589)
                                .frame(height: 11, alignment: .leading)
                                .fixedSize(horizontal: true, vertical: false)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onAppear {
                                            let size = self.mumory.locationModel.locationTitle.size(withAttributes: [.font: SharedFontFamily.Pretendard.medium.font(size: 14)])
                                            
                                            if size.width > proxy.size.width {
                                                self.isLocationTitleTruncated = true
                                            } else {
                                                self.isLocationTitleTruncated = false
                                            }
                                        }
                                    }
                                )
                                .offset(x: self.isLocationTitleTruncated ? -3 : 0)
                        }
                        .onTapGesture {
                            self.isMapViewShown = true
                        }
                    } // HStack
                } // VStack
                .frame(height: 38)
            } // HStack
            .frame(height: 38)
            
            Spacer().frame(height: 13)
            
            ZStack(alignment: .topLeading) {
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.width - 20)
                    .background(
                        AsyncImage(url: self.mumory.musicModel.artworkUrl, transaction: Transaction(animation: .easeInOut(duration: 0.1))) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            case .failure:
                                Text("Failed to load image")
                            case .empty:
                                ProgressView()
                            default:
                                Color(red: 0.18, green: 0.18, blue: 0.18)
                            }
                        }
                            .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.width - 20)
                            .clipped()
                    )
                    .cornerRadius(15)
                
                
                SharedAsset.artworkFilterSocial.swiftUIImage
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.width - 20)
                    .cornerRadius(15)
                    .gesture(
                        TapGesture(count: 1)
                            .onEnded {
                                mumoryDataViewModel.selectedMumoryAnnotation = mumory
                                self.appCoordinator.rootPath.append(MumoryView(type: .mumoryDetailView, mumoryAnnotation: self.mumory))
                            }
                    )
                
                // MARK: Title & Menu
                HStack(spacing: 0) {
                    
                    //                    Button {
                    //                        Task {
                    //                            guard let song = await fetchSong(songID: mumory.musicModel.songID.rawValue) else {return}
                    //                            playerViewModel.playNewSong(song: song, isPlayerShown: false)
                    //                            withAnimation {
                    //                                playerViewModel.userWantsShown = true
                    //                                playerViewModel.isShownMiniPlayer = true
                    //                                playerViewModel.miniPlayerMoveToBottom = false
                    //                            }
                    //                        }
                    //                    } label: {
                    //                        HStack(spacing: 0) {
                    //                            SharedAsset.musicIconSocial.swiftUIImage
                    //                                .resizable()
                    //                                .frame(width: 14, height: 14)
                    //
                    //                            Spacer().frame(width: 6)
                    //
                    //                            Text(self.mumory.musicModel.title)
                    //                                .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 14))
                    //                                .multilineTextAlignment(.trailing)
                    //                                .foregroundColor(.white)
                    //                                .lineLimit(1)
                    //
                    //                            Spacer().frame(width: 8)
                    //
                    //                            Text(self.mumory.musicModel.artist)
                    //                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                    //                                .foregroundColor(.white)
                    //                                .lineLimit(1)
                    //                        }
                    //                        .padding(.vertical, 10)
                    //                    }
                    
                    HStack(spacing: 0) {
                        SharedAsset.musicIconSocial.swiftUIImage
                            .resizable()
                            .frame(width: 14, height: 14)
                        
                        Spacer().frame(width: 6)
                        
                        Text(self.mumory.musicModel.title)
                            .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 14))
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Spacer().frame(width: 8)
                        
                        Text(self.mumory.musicModel.artist)
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task {
                            guard let song = await fetchSong(songID: mumory.musicModel.songID.rawValue) else {return}
                            playerViewModel.playNewSong(song: song, isPlayerShown: false)
                            withAnimation {
                                playerViewModel.userWantsShown = true
                                playerViewModel.isShownMiniPlayer = true
                                playerViewModel.miniPlayerMoveToBottom = false
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.appCoordinator.choosedMumoryAnnotation = self.mumory
                        appCoordinator.bottomSheet = .socialMenu
                    }, label: {
                        SharedAsset.menuButtonSocial.swiftUIImage
                            .resizable()
                            .frame(width: 22, height: 22)
                            .padding()
                    })
                    
                } // HStack
                .padding(.top, 1)
                .padding(.leading, 20)
                .padding(.trailing, 1)
                
                VStack(spacing: 0) {
                    
                    Spacer(minLength: 0)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        
                        HStack(spacing: 8) {
                            
                            // MARK: Image Counter
                            if let imageURLs = self.mumory.imageURLs, !imageURLs.isEmpty {
                                
                                HStack(spacing: 4) {
                                    
                                    SharedAsset.imageCountSocial.swiftUIImage
                                        .resizable()
                                        .frame(width: 14, height: 14)
                                    
                                    Text("\(imageURLs.count)")
                                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.white)
                                }
                                .frame(width: 48, height: 28)
                                .background(
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 48, height: 28)
                                        .background(Color(red: 0.16, green: 0.16, blue: 0.16).opacity(0.7))
                                        .cornerRadius(15)
                                )
                            }
                            
                            // MARK: Tag
                            if let tags = self.mumory.tags {
                                ForEach(tags, id: \.self) { tag in
                                    
                                    HStack(alignment: .center, spacing: 5) {
                                        
                                        SharedAsset.tagMumoryDatail.swiftUIImage
                                            .resizable()
                                            .frame(width: 14, height: 14)
                                        
                                        Text(tag)
                                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                    }
                                    .padding(.leading, 8)
                                    .padding(.trailing, 10)
                                    .padding(.vertical, 7)
                                    .background(.white.opacity(0.25))
                                    .cornerRadius(14)
                                }
                                
                                Spacer()
                            }
                        } // HStack
                        
                    } // ScrollView
                    .mask(
                        Rectangle()
                            .frame(width: (UIScreen.main.bounds.width - 20) * 0.66, height: 44)
                            .blur(radius: 3)
                    )
                    
                    // MARK: Content
                    if let content = self.mumory.content, !content.isEmpty {
                        
                        HStack(spacing: 0) {
                            
                            Text(content.replacingOccurrences(of: "\n", with: " "))
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .frame(maxWidth: (UIScreen.main.bounds.width - 20) * 0.66 * 0.87, alignment: .leading)
                                .fixedSize(horizontal: true, vertical: false)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onAppear {
                                            let size = content.replacingOccurrences(of: "\n", with: " ").size(withAttributes: [.font: SharedFontFamily.Pretendard.medium.font(size: 13)])
                                            
                                            if size.width > proxy.size.width {
                                                self.isTruncated = true
                                            } else {
                                                self.isTruncated = false
                                            }
                                        }
                                    }
                                )
                            
                            Spacer(minLength: 0)
                            
                            if self.isTruncated {
                                Text("더보기")
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 11))
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.white.opacity(0.7))
                                    .lineLimit(1)
                                    .frame(alignment: .leading)
                            }
                        }
                        .padding(.top, 14)
                    }
                } // VStack
                .frame(width: (getUIScreenBounds().width - 20) * 0.66)
                .frame(height: getUIScreenBounds().height * 0.08776)
                .padding(.leading, 22)
                .offset(y: UIScreen.main.bounds.width - 20 - getUIScreenBounds().height * 0.08776 - 22)
                
                
                // MARK: Heart & Comment
                VStack(spacing: 0) {
                    
                    Button(action: {
                        self.generateHapticFeedback(style: .medium)
                        isButtonDisabled = true
                        _ = self.mumory.likes
                        
                        Task {
                            await mumoryDataViewModel.likeMumory(mumoryAnnotation: self.mumory, uId: currentUserData.user.uId) { likes in
                                print("likeMumory successfully")
                                self.mumory.likes = likes
                                isButtonDisabled = false
                                
                                lazy var functions = Functions.functions()
                                functions.httpsCallable("like").call(["mumoryId": mumory.id]) { result, error in
                                    if let error = error {
                                        //                                        self.mumory.likes = originLikes
                                        print("Error Functions \(error.localizedDescription)")
                                    } else {
                                        //                                        self.mumory.likes = likes
                                        print("라이크 함수 성공: \(mumory.likes.count)")
                                    }
                                }
                            }
                        }
                    }, label: {
                        mumory.likes.contains(currentUserData.user.uId) ?
                        SharedAsset.heartOnButtonMumoryDetail.swiftUIImage
                            .resizable()
                            .frame(width: 42, height: 42)
                            .background(
                                .white.opacity(0.1)
                            )
                            .mask {Circle()}
                        : SharedAsset.heartOffButtonSocial.swiftUIImage
                            .resizable()
                            .frame(width: 42, height: 42)
                            .background(
                                .white.opacity(0.1)
                            )
                            .mask {Circle()}
                    })
                    .disabled(isButtonDisabled)
                    .padding(.bottom, mumory.likes.isEmpty ? 12 : 0)
                    
                    if mumory.likes.count != 0 {
                        Text("\(mumory.likes.count)")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.top, 6)
                            .padding(.bottom, 8)
                    }
                    
                    Button(action: {
                        self.mumoryDataViewModel.selectedMumoryAnnotation = self.mumory
                        withAnimation(Animation.easeInOut(duration: 0.1)) {
                            //                            self.appCoordinator.isSocialCommentSheetViewShown = true
                            self.appCoordinator.sheet = .comment
                            appCoordinator.offsetY = CGFloat.zero
                        }
                    }, label: {
                        SharedAsset.commentButtonSocial.swiftUIImage
                            .resizable()
                            .frame(width: 42, height: 42)
                            .background(
                                .white.opacity(0.1)
                            )
                            .mask {Circle()}
                    })
                    
                    if mumory.commentCount != 0 {
                        Text("\(mumory.commentCount)")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.top, 6)
                    }
                }
                .offset(x: UIScreen.main.bounds.width - 20 - 42 - 17)
                .alignmentGuide(VerticalAlignment.top) { d in
                    d[.bottom] - (UIScreen.main.bounds.width - 20) + 23
                }
            } // ZStack
            
            Spacer().frame(height: 40)
        } // VStack
        .frame(height: getUIScreenBounds().width + 71)
        .onAppear {
            Task {
                self.user = await FetchManager.shared.fetchUser(uId: self.mumory.uId)
            }
        }
        .fullScreenCover(isPresented: self.$isMapViewShown) {
            FriendMumoryMapView(isShown: self.$isMapViewShown, mumorys: [self.mumory], user: self.user)
        }
    }
}

public struct SocialView: View {
    
    @Binding private var isSocialSearchViewShown: Bool
    
    @State private var shouldUpdate = true
    
    @State private var offsetY: CGFloat = 0
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var currentUserData: CurrentUserViewModel
    
    public init(isShown: Binding<Bool>) {
        UIScrollView.appearance().bounces = true
        self._isSocialSearchViewShown = isShown
    }
    
    public var body: some View {
        
        ZStack(alignment: .top) {
            //            Color(red: 0.09, green: 0.09, blue: 0.09)
            //                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            SocialScrollViewRepresentable(shouldUpdate: self.$shouldUpdate, contentOffsetY: self.$offsetY) {
                if self.mumoryDataViewModel.socialMumorys.isEmpty {
                    noMumoryView
                } else {
                    SocialScrollCotentView()
                }
            }
            
            if mumoryDataViewModel.isUpdating, !mumoryDataViewModel.isFirstSocialLoad {
                SocialLoadingView()
            }
            
            HStack(alignment: .top, spacing: 0) {
                
                Text("소셜")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 24))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    self.isSocialSearchViewShown = true
                }) {
                    SharedAsset.searchButtonSocial.swiftUIImage
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                
                Spacer().frame(width: 12)
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.appCoordinator.isAddFriendViewShown = true
                    }
                }) {
                    (currentUserData.recievedRequests.isEmpty ? SharedAsset.addFriendOffSocial.swiftUIImage : SharedAsset.addFriendOnSocial.swiftUIImage)
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                
                Spacer().frame(width: 12)
                
                Button(action: {
                    appCoordinator.setBottomAnimationPage(page: .myPage)
                }) {
                    AsyncImage(url: currentUserData.user.profileImageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                        default:
                            currentUserData.user.defaultProfileImage
                                .resizable()
                        }
                    }
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                }
            } // HStack
            .frame(height: 68)
            .padding(.horizontal, 20)
            .padding(.top, appCoordinator.safeAreaInsetsTop)
            //            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
            .background(.brown)
            .offset(y: -self.offsetY)
        }
        .onAppear {
            playerViewModel.setPlayerVisibilityWithoutAnimation(isShown: true, moveToBottom: false)
            playerViewModel.isShownMiniPlayerInLibrary = false
            
            if !self.appCoordinator.isFirstTabSelected {
                self.mumoryDataViewModel.fetchSocialMumory(friends: currentUserData.friends, me: currentUserData.user, isRefreshing: false) { _ in
                    print("FUCK fetchSocialMumory")
                }
                self.appCoordinator.isFirstTabSelected = true
            }
            
            FirebaseManager.shared.observeFriendRequests()
            print("FUCK SocialView onAppear")
        }
        .onDisappear {
            print("FUCK SocialView onDisappear")
        }
    }
    
    private var noMumoryView: some View {
        VStack(spacing: 0) {
            
            SharedAsset.socialInitIcon.swiftUIImage
                .resizable()
                .frame(width: 96.74, height: 57)
                .padding(.bottom, 39)
            
            Text("아직 뮤모리가 기록되지 않았어요")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 21)
            
            Text("친구들을 초대해서 나만의 좋은 음악과")
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                .foregroundColor(Color(red: 0.761, green: 0.761, blue: 0.761))
                .fixedSize(horizontal: true, vertical: true)
                .padding(.bottom, 3)
            
            Text("특별한 순간을 공유해보세요!")
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                .foregroundColor(Color(red: 0.761, green: 0.761, blue: 0.761))
                .fixedSize(horizontal: true, vertical: true)
        }
        .frame(width: getUIScreenBounds().width, height: getUIScreenBounds().height - 89 - appCoordinator.safeAreaInsetsTop - 68)
    }
}
