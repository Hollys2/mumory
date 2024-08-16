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


public struct MumoryDetailView: View {

    @State var mumory: Mumory
    @State var user: UserProfile = .init()
    @State var offsetY: Double = .zero
    @State var isLoading: Bool = false
    @State var isPopUpShown: Bool = true
    @State var playButtonOpacity: CGFloat = 1
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    public init(mumory: Mumory) {
        self._mumory = State(initialValue: mumory)
        UIScrollView.appearance().bounces = false
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color(red: 0.09, green: 0.09, blue: 0.09)
            
            self.artWorkView
            
            self.scrollView
            
            if self.isLoading {
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
                    appCoordinator.sheet = .mumoryDetailMenu(mumory: self.mumory, isOwn: self.mumory.uId == self.currentUserViewModel.user.uId)
                }, label: {
                    Image(uiImage: SharedAsset.menuButtonMumoryDatail.image)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 12)
                })
            }
            .padding(.top, getSafeAreaInsets().top)
            .background(appCoordinator.isNavigationBarColored ? Color(red: 0.09, green: 0.09, blue: 0.09) : .clear)
            
            if appCoordinator.isReactionBarShown {
                MumoryDetailReactionBarView(mumory: self.mumory, isOn: true)
            }
        } // ZStack
        .onAppear {
            print("FUCK MumoryDetailView onAppear")
            playerViewModel.setLibraryPlayerVisibility(isShown: false)

            Task {
                self.isLoading = true
                do {
                    self.mumory = try await FetchManager.shared.fetchMumory(documentID: self.mumory.id)
                    self.user = await FetchManager.shared.fetchUser(uId: self.mumory.uId)
                    for friend in self.currentUserViewModel.friendViewModel.friends {
                        Task {
                            await self.currentUserViewModel.mumoryViewModel.sameSongFriendMumory(friend: friend, songId: self.mumory.song.id, mumory: self.mumory)
                        }
                        Task {
                            await self.currentUserViewModel.mumoryViewModel.surroundingFriendMumory(friend: friend, mumory: self.mumory)
                        }
                    }
                } catch {
                    print("FUCK ERROR: \(error.localizedDescription)")
                }
                self.isLoading = false
            }
        }
        .onDisappear {
            print("FUCK MumoryDetailView onDisappear")
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea()
        .fullScreenCover(isPresented: self.$appCoordinator.isMumoryMapViewShown) {
            FriendMumoryMapView(mumorys: [self.mumory], user: self.user)
        }
        .popup(show: $appCoordinator.isDeleteMumoryPopUpViewShown, content: {
            PopUpView(isShown: $appCoordinator.isDeleteMumoryPopUpViewShown, type: .twoButton, title: "해당 뮤모리를 삭제하시겠습니까?", buttonTitle: "뮤모리 삭제", buttonAction: {
                self.currentUserViewModel.mumoryViewModel.deleteMumory(mumory) { result in
                    switch result {
                    case .success():
                        print("SUCCESS deleteMumory!")
                        appCoordinator.isDeleteMumoryPopUpViewShown = false
                        appCoordinator.rootPath.removeLast()
                        appCoordinator.isFirstSocialTabTapped = false
                    case .failure(let error):
                        print("ERROR deleteMumory: \(error)")
                    }
                }
            })
        })
    }
    
    private var artWorkView: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: mumory.song.artworkUrl, transaction: Transaction(animation: .easeInOut(duration: 0.1))) { phase in
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
                ColorSet.background.opacity((self.offsetY + getSafeAreaInsets().top) / (getUIScreenBounds().width - 150))
            }
            
            SharedAsset.albumFilterMumoryDetail.swiftUIImage
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                .offset(y: self.offsetY)
            
            VStack(spacing: 10) {
                Text("\(mumory.song.title)")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 24))
                    .lineLimit(3)
                    .foregroundColor(.white)
                    .frame(width: 301, alignment: .leading)

                Text("\(mumory.song.artist)")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 20))
                    .lineLimit(2)
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 301, alignment: .leading)
            }
            .padding(.leading, 20)
        } // ZStack
    }
    
    private var scrollView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ZStack(alignment: .bottomTrailing) {
                    Color.clear
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                    
                    Rectangle()
                        .foregroundColor(.clear)
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
                    
                    SharedAsset.playButtonMumoryDatail.swiftUIImage
                        .resizable()
                        .frame(width: 42, height: 42)
                        .offset(x: -20)
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .onChange(of: geometry.frame(in: .global).minY) { newValue in
                                        let threshold = 150 + getSafeAreaInsets().top
                                        let distance = newValue - threshold
                                        let maxDistance: CGFloat = 90
                                        let opacity = min(max(distance / maxDistance, 0), 1)
                                        
                                        self.playButtonOpacity = Double(opacity)
                                    }
                            }
                        )
                        .opacity(self.playButtonOpacity)
                        .onTapGesture {
                            Task {
                                guard let song = await FetchManager.shared.fetchSong(songId: self.mumory.song.id) else { return }
                                playerViewModel.playNewSongShowingPlayingView(song: song)
                                playerViewModel.userWantsShown = true
                                playerViewModel.isShownMiniPlayer = true
                            }
                        }
                    
                }
                
                VStack(spacing: 0) {
                    Group {
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
                                Task {
                                    if self.user.uId == currentUserViewModel.user.uId {
                                        appCoordinator.rootPath.append(MumoryPage.myPage)
                                    } else {
                                        let friend = await FetchManager.shared.fetchUser(uId: self.user.uId)
                                        appCoordinator.rootPath.append(MumoryPage.friend(friend: friend))
                                    }
                                }
                            }
                            
                            VStack(spacing: 0) {
                                
                                Text("\(self.user.nickname)")
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Spacer(minLength: 0)
                                
                                HStack(spacing: 0) {
                                    
                                    Text(DateManager.formattedDate(date: self.mumory.date, isPublic: self.mumory.isPublic))
                                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                        .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                                        .lineLimit(1)
                                        .fixedSize(horizontal: true, vertical: false)
                                    
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
                                        
                                        Text("\(self.mumory.location.locationTitle)")
                                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                            .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                                            .frame(maxWidth: getUIScreenBounds().width * 0.27)
                                            .frame(height: 11, alignment: .leading)
                                            .fixedSize(horizontal: true, vertical: false)
                                    }
                                    .onTapGesture {
                                        self.appCoordinator.isMumoryMapViewShown = true
                                    }
                                } // HStack
                            } // VStack
                            .frame(height: 38)
                        } // HStack
                        .frame(height: 38)
                        .padding(.top, 55)
                        .padding(.bottom, (self.mumory.tags ?? []).isEmpty && (self.mumory.content ?? "").isEmpty && (self.mumory.imageURLs ?? []).isEmpty ? 50 : 55 - 11)
                        
                        if let tags = self.mumory.tags, !tags.isEmpty {
                            HStack(spacing: 0) {
                                
                                ForEach(tags.indices, id: \.self) { index in
                                    
                                    TagView(text: "\(tags[index])")
                                    
                                    if index != 2 {
                                        Spacer().frame(width: 6)
                                    }
                                }
                                
                                Spacer(minLength: 0)
                            } // HStack
                            .padding(.bottom, 25)
                        }
                        
                        if let content = self.mumory.content, !content.isEmpty {
                            Text("\(content)")
                                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, 25)
                        }
                        
                        // MARK: Image
                        if let imageURLs = self.mumory.imageURLs, !imageURLs.isEmpty {
                            MumoryDetailImageScrollUIViewRepresentable(mumory: self.mumory)
                                .frame(width: UIScreen.main.bounds.width - 40 + 10, height: UIScreen.main.bounds.width - 40)
                                .padding(.bottom, 50 - 11)
                        }
                    }
                    
                    MumoryDetailReactionBarView(mumory: self.mumory, isOn: false)
                        .background(GeometryReader { geometry in
                            Color.clear
                                .onAppear(perform: {
                                    let isReactionBarShown = geometry.frame(in: .global).minY > UIScreen.main.bounds.height - 85
                                    
                                    if appCoordinator.isReactionBarShown != isReactionBarShown {
                                        appCoordinator.isReactionBarShown = isReactionBarShown
                                    }
                                })
                                .onChange(of: geometry.frame(in: .global).minY) { minY in
                                    let isReactionBarShown = minY > UIScreen.main.bounds.height - 85
                                    
                                    if appCoordinator.isReactionBarShown != isReactionBarShown {
                                        appCoordinator.isReactionBarShown = isReactionBarShown
                                    }
                                }
                        })
                        .overlay(
                            ZStack {
                                SharedAsset.starPopup.swiftUIImage
                                    .resizable()
                                    .frame(width: 235, height: 42)
                                    .offset(x: -15, y: 16)
                                    .opacity(UserDefaults.standard.value(forKey: "starPopUp2") == nil ? 1 : 0)
                                    .onTapGesture {
                                        self.isPopUpShown = false
                                        UserDefaults.standard.set(Date(), forKey: "starPopUp2")
                                    }
                            }
                                .opacity(self.isPopUpShown ? 1: 0)
                            
                            , alignment: .bottomTrailing
                        )
                    
                    Spacer().frame(height: 70)
                    
                    Group {
                        Text("같은 음악을 들은 친구 뮤모리")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 24)
                        
                        if self.currentUserViewModel.mumoryViewModel.sameSongFriendMumorys.count > 0 {
                            VStack(spacing: 0) {
                                
                                MumoryDetailFriendMumoryScrollUIViewRepresentable(mumory: self.mumory)
                                    .frame(width: UIScreen.main.bounds.width - 40 + 10, height: 212)
                                
                                Spacer().frame(height: 25)
                                
                                HStack(spacing: 10) {
                                    
                                    ProgressView(value: CGFloat(self.appCoordinator.page) / CGFloat(Array(self.currentUserViewModel.mumoryViewModel.sameSongFriendMumorys.prefix(min(3, self.currentUserViewModel.mumoryViewModel.sameSongFriendMumorys.count))).count))
                                        .accentColor(SharedAsset.mainColor.swiftUIColor)
                                        .background(Color(red: 0.165, green: 0.165, blue: 0.165))
                                        .frame(width: getUIScreenBounds().width * 0.44102, height: 3)
                                        .animation(.easeInOut(duration: 0.1), value: self.appCoordinator.page)
                                    
                                    Text("\(self.appCoordinator.page)")
                                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                                        .foregroundColor(SharedAsset.mainColor.swiftUIColor)
                                    + Text(" / \(Array(self.currentUserViewModel.mumoryViewModel.sameSongFriendMumorys.prefix(min(3, self.currentUserViewModel.mumoryViewModel.sameSongFriendMumorys.count))).count)")
                                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                                        .foregroundColor(Color(red: 0.475, green: 0.475, blue: 0.475))
                                }
                                .padding(.bottom, 65)
                                .opacity(self.currentUserViewModel.mumoryViewModel.sameSongFriendMumorys.count == 1 ? 0 : 1)
                            }
                        } else {
                            
                            VStack(spacing: 0) {
                                Text("아직 같은 음악을 들은 친구가 없습니다.")
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                    .foregroundColor(Color(red: 0.475, green: 0.475, blue: 0.475))
                            }
                            .frame(height: 334 - 25)
                            .offset(y: -25)
                        }
                        
                        Rectangle()
                            .fill(Color(red: 0.055, green: 0.055, blue: 0.055))
                            .frame(width: getUIScreenBounds().width, height: 10)
                            .padding(.bottom, 74)
                    }
                    
                    Group {
                        Text("주변에서 뮤모리된 음악")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 24)
                        
                        if self.currentUserViewModel.mumoryViewModel.surroundingMumorys.isEmpty {
                            VStack(spacing: 0) {
                                Text("주변에서 뮤모리된 음악이 없습니다.")
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                    .foregroundColor(Color(red: 0.475, green: 0.475, blue: 0.475))
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                            }
                            .frame(height: 334 - 25)
                            .offset(y: -25)
                        } else {
                            ForEach(self.currentUserViewModel.mumoryViewModel.surroundingMumorys.prefix(3), id: \.self) { mumory in
                                MumoryDetailSameLocationMusicView(mumory: mumory)
                            }
                        }
                        Spacer().frame(height: 100)
                    }
                } // VStack
                .frame(width: UIScreen.main.bounds.width - 40)
                .padding(.horizontal, 20)
                .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                
                Spacer()
            } // VStack
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onChange(of: geometry.frame(in: .global).minY) { newValue in
                            self.offsetY = newValue
                            
                            let isNavigationBarColored = -newValue >= UIScreen.main.bounds.width - (self.getSafeAreaInsets().top + 19 + 30 + 12) - 20
                            
                            DispatchQueue.main.async {
                                if self.appCoordinator.isNavigationBarColored != isNavigationBarColored {
                                    self.appCoordinator.isNavigationBarColored = isNavigationBarColored
                                }
                            }
                        }
                }
            )
        }
    }
}

struct TagView: View {
    var text: String

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Image(uiImage: SharedAsset.tagMumoryDatail.image)
                .resizable()
                .frame(width: 14, height: 14)

            Text(text)
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                .foregroundColor(.white)
        }
        .padding(.leading, 8)
        .padding(.trailing, 10)
        .padding(.vertical, 7)
        .background(.white.opacity(0.2))
        .cornerRadius(14)
    }
}

//struct MumoryDetailScrollViewRepresentable: UIViewRepresentable {
//
//    //    typealias UIViewType = UIScrollView
//
//    let mumory: Mumory
//
//    @Binding var contentOffsetY: Double
//
//    @EnvironmentObject var appCoordinator: AppCoordinator
//
//    @EnvironmentObject var currentUserViewModel: currentUserViewModel
//
//    func makeUIView(context: Context) -> UIScrollView {
//        let scrollView = UIScrollView()
//
//        scrollView.delegate = context.coordinator
//
//        scrollView.isScrollEnabled = true
//        scrollView.bounces = false
//        scrollView.showsVerticalScrollIndicator = false
//        scrollView.showsHorizontalScrollIndicator = false
//
//        let hostingController = UIHostingController(rootView: MumoryDetailScrollContentView(mumory: self.mumory)
//            .environmentObject(appCoordinator)
//            .environmentObject(mumoryDataViewModel)
//            .environmentObject(currentUserViewModel)
//        )
//
//        let contentHeight = hostingController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
//        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: contentHeight)
//        hostingController.view.frame = CGRect(x: 0, y: -getSafeAreaInsets().top, width: UIScreen.main.bounds.width, height: contentHeight)
//
//        scrollView.backgroundColor = .clear
//        hostingController.view.backgroundColor = .clear
//
//        scrollView.subviews.forEach { $0.removeFromSuperview() }
//        scrollView.addSubview(hostingController.view)
//
//        return scrollView
//    }
//
//
//    func updateUIView(_ uiView: UIScrollView, context: Context) {
//
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(parent: self)
//    }
//}
//
//extension MumoryDetailScrollViewRepresentable {
//
//    class Coordinator: NSObject {
//
//        let parent: MumoryDetailScrollViewRepresentable
//        var contentHeight: CGFloat = .zero
//        var hostingController: UIHostingController<MumoryDetailScrollContentView>?
//
//        init(parent: MumoryDetailScrollViewRepresentable) {
//            self.parent = parent
//            super.init()
//        }
//    }
//}
//
//extension MumoryDetailScrollViewRepresentable.Coordinator: UIScrollViewDelegate {
//
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y
//
//        DispatchQueue.main.async {
//            self.parent.contentOffsetY = offsetY
//        }
//
//        let isNavigationBarColored = offsetY >= UIScreen.main.bounds.width - (parent.getSafeAreaInsets().top + 19 + 30 + 12) - 20
//
//        DispatchQueue.main.async {
//            if self.parent.appCoordinator.isNavigationBarColored != isNavigationBarColored {
//                self.parent.appCoordinator.isNavigationBarColored = isNavigationBarColored
//            }
//        }
//        //        previousOffset = offsetY
//    }
//}

