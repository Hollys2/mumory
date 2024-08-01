//
//  SocialView.swift
//  Feature
//
//  Created by 다솔 on 2024/01/03.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import Combine
import FirebaseFunctions
import Shared

class SocialItemCollectionViewCell: UICollectionViewCell {
    
    private var hostingController: UIHostingController<SocialItemView>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHostingController()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupHostingController()
    }

    private func setupHostingController() {
        hostingController = UIHostingController(rootView: SocialItemView(mumory: Mumory()))
        
        guard let hostingController = hostingController else { return }
        
        hostingController.view.frame.size = CGSize(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.width - 20 + 51)
        hostingController.view.backgroundColor = UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1)
        
        contentView.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func configure(mumory: Mumory) {
        hostingController?.rootView = SocialItemView(mumory: mumory)
    }
}


struct CollectionViewRepresentable: UIViewRepresentable {

    private let scrollPublisher = PassthroughSubject<UIScrollView, Never>()

    @Binding var topBarOffsetY: CGFloat
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    
    func makeUIView(context: Context) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset.top = getSafeAreaInsets().top + 68 + 25
        collectionView.contentInset.bottom = 89 + 90
        collectionView.register(SocialItemCollectionViewCell.self, forCellWithReuseIdentifier: "SocialItemCell")
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(white: 0.47, alpha: 1)
        collectionView.refreshControl = refreshControl
        collectionView.refreshControl?.addTarget(context.coordinator, action: #selector(Coordinator.handleRefreshControl), for: .valueChanged)
        
        context.coordinator.collectionView = collectionView
//        context.coordinator.cancellable = self.scrollPublisher
//            .sink { scrollView in
//                let contentOffsetY = scrollView.contentOffset.y
//                let contentHeight = scrollView.contentSize.height
//                let scrollViewHeight = scrollView.frame.size.height
//                let limitHeight = self.getSafeAreaInsets().top + 68
//                let deltaY = contentOffsetY - self.previousOffsetY
//
////                self.topBarOffsetY += (contentOffsetY - self.previousOffsetY)
////                if self.topBarOffsetY < .zero || contentOffsetY <= .zero {
////                    self.topBarOffsetY = .zero
////                } else if self.topBarOffsetY > limitHeight || contentOffsetY >= contentHeight - scrollViewHeight {
////                    self.topBarOffsetY = limitHeight
////                }
////
////                self.previousOffsetY = contentOffsetY
//            }
        //            .store(in: &context.coordinator.cancellables)
        
        DispatchQueue.main.async {
            self.appCoordinator.isSocialLoading = true
            self.currentUserViewModel.mumoryViewModel.fetchSocialMumory(currentUserViewModel: self.currentUserViewModel) { result in
                switch result {
                case .success(_):
                    print("FUCK SUCCESS fetchSocialMumory onAppear")
                case .failure(let error):
                    print("FUCK FAILURE fetchSocialMumory onAppear: \(error.localizedDescription)")
                }
                collectionView.reloadData()
                self.appCoordinator.isSocialLoading = false
            }
        }
        
        return collectionView
    }

    func updateUIView(_ uiView: UICollectionView, context: Context) {
        if self.appCoordinator.isScrollToTop {
            uiView.setContentOffset(CGPoint(x: 0, y: -(getSafeAreaInsets().top + 68 + 25)), animated: true)
            DispatchQueue.main.async {
                self.appCoordinator.isScrollToTop = false
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        let parent: CollectionViewRepresentable
        weak var collectionView: UICollectionView?
        var previousOffsetY: CGFloat = .zero
        var isFetched: Bool = false
        
        var cancellable: AnyCancellable?

        init(parent: CollectionViewRepresentable) {
            self.parent = parent
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.parent.currentUserViewModel.mumoryViewModel.socialMumorys.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard indexPath.item < self.parent.currentUserViewModel.mumoryViewModel.socialMumorys.count else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SocialItemCell", for: indexPath)
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SocialItemCell", for: indexPath) as! SocialItemCollectionViewCell
            let mumory = self.parent.currentUserViewModel.mumoryViewModel.socialMumorys[indexPath.item]
            cell.configure(mumory: mumory)
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.width - 20 + 51)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
              return 40 // 세로 셀 간의 간격
          }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 0 // 가로 셀 간의 간격
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            self.parent.scrollPublisher.send(scrollView)
            
            let contentOffsetY = scrollView.contentOffset.y + self.parent.getSafeAreaInsets().top + 68 + 25
            let contentHeight = scrollView.contentSize.height
            let scrollViewHeight = scrollView.frame.size.height
            let limitHeight = self.parent.getSafeAreaInsets().top + 68
            let deltaY = contentOffsetY - self.previousOffsetY
            
            if !self.isFetched {
                if deltaY > 0 {
                    if contentOffsetY >= contentHeight - scrollViewHeight - self.parent.getUIScreenBounds().width - 161 {
                        self.isFetched = true
                        
                        self.parent.currentUserViewModel.mumoryViewModel.fetchSocialMumory(currentUserViewModel: self.parent.currentUserViewModel) { result in
                            switch result {
                            case .success(let count):
                                if count != 0 {
                                    print("FUCK SUCCESS fetchSocialMumory 더 가져오기")
                                    self.collectionView?.reloadData()
                                }
                            case .failure(let error):
                                print("FUCK FAILURE fetchSocialMumory 더 가져오기 \(error.localizedDescription)")
                            }
                            self.isFetched = false
                        }
                    }
                }
            }
            
            self.parent.topBarOffsetY += (contentOffsetY - self.previousOffsetY)
            
            if self.parent.topBarOffsetY < .zero || contentOffsetY <= .zero {
                self.parent.topBarOffsetY = .zero
            } else if self.parent.topBarOffsetY > limitHeight || contentOffsetY - (self.parent.getSafeAreaInsets().top + 68 + 25) - 89 - 90  >= contentHeight - scrollViewHeight {
                self.parent.topBarOffsetY = limitHeight
            }
            
            self.previousOffsetY = contentOffsetY
        }
        
        @objc func handleRefreshControl(sender: UIRefreshControl) {
            print("FUCK handleRefreshControl")
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
                        
            self.parent.currentUserViewModel.mumoryViewModel.fetchSocialMumory(currentUserViewModel: self.parent.currentUserViewModel, isRefreshControl: true) { result in
                switch result {
                case .success(let count):
                    print("FUCK SUCCESS fetchSocialMumory handlreRefreshControl!")
                    if count != 0 {
                        self.collectionView?.reloadData()
                    }
                case .failure(let error):
                    print("FUCK FAILURE fetchSocialMumory handlreRefreshControl: \(error.localizedDescription)")
                }

                DispatchQueue.main.async {
                    sender.endRefreshing()
                }
            }
        }
    }
}

private struct SocialItemView: View {
    
    @State private var isMapViewShown: Bool = false
    @State private var isTruncated: Bool = false
    @State private var isLocationTitleTruncated: Bool = false
    @State private var isButtonDisabled: Bool = false
    @State var user: UserProfile = UserProfile()
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject private var currentUserViewModel: CurrentUserViewModel
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
                    if self.user.uId == self.currentUserViewModel.user.uId {
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
                            
                            Text(self.mumory.location.locationTitle)
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                                .frame(maxWidth: getUIScreenBounds().width * 0.33589)
                                .frame(height: 11, alignment: .leading)
                                .fixedSize(horizontal: true, vertical: false)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onAppear {
                                            let size = self.mumory.location.locationTitle.size(withAttributes: [.font: SharedFontFamily.Pretendard.medium.font(size: 14)])
                                            
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
            .padding(.bottom, 13)
            
//            Spacer().frame(height: 13)
            
            ZStack(alignment: .topLeading) {
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.width - 20)
                    .background(
                        AsyncImage(url: self.mumory.song.artworkUrl, transaction: Transaction(animation: .easeInOut(duration: 0.1))) { phase in
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
//                                mumoryDataViewModel.selectedMumoryAnnotation = mumory
                                self.appCoordinator.selectedMumory = mumory
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
                        
                        Text(self.mumory.song.title)
                            .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 14))
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Spacer().frame(width: 8)
                        
                        Text(self.mumory.song.artist)
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task {
                            guard let song = await fetchSong(songID: mumory.song.id) else {return}
                            playerViewModel.playNewSong(song: song, isPlayerShown: false)
                            withAnimation {
                                playerViewModel.userWantsShown = true
                                playerViewModel.isShownMiniPlayer = true
                                playerViewModel.miniPlayerMoveToBottom = false
                            }
                        }
                    }
                    
                    Spacer()
                  
                    
                    SharedAsset.menuButtonSocial.swiftUIImage
                        .resizable()
                        .frame(width: 22, height: 22)
                        .padding()
                        .onTapGesture {
                            self.appCoordinator.selectedMumory = self.mumory
                            self.appCoordinator.sheet = .socialMenu
                        }
                    
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
                            await self.currentUserViewModel.mumoryViewModel.likeMumory(mumoryAnnotation: self.mumory, uId: currentUserViewModel.user.uId) { result in
                                
                                switch result {
                                case .success(let likes):
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
                                            print("라이크 함수 성공: \((mumory.likes ?? []).count)")
                                        }
                                    }
                                    
                                case .failure(let error):
                                    print("ERROR likeMumory: \(error)")
                                }
                            }
                        }
                    }, label: {
                        (mumory.likes ?? []).contains(currentUserViewModel.user.uId) ?
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
                    .padding(.bottom, (mumory.likes ?? []).isEmpty ? 12 : 0)
                    
                    if (mumory.likes ?? []).count != 0 {
                        Text("\((mumory.likes ?? []).count)")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.top, 6)
                            .padding(.bottom, 8)
                    }
                    
                    Button(action: {
//                        self.mumoryDataViewModel.selectedMumoryAnnotation = self.mumory
                        self.appCoordinator.selectedMumory = self.mumory
                        
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
        } // VStack
        .frame(width: getUIScreenBounds().width - 20, height: getUIScreenBounds().width - 20 + 51)
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
    
    @State private var offsetY: CGFloat = 0
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    public init(isSocialSearchViewShown: Binding<Bool>) {
        UIScrollView.appearance().bounces = true
        self._isSocialSearchViewShown = isSocialSearchViewShown
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            
            Color(red: 0.09, green: 0.09, blue: 0.09)
            
            CollectionViewRepresentable(topBarOffsetY: self.$offsetY)

            if self.appCoordinator.isSocialLoading {
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
                    (currentUserViewModel.friendViewModel.recievedRequests.isEmpty ? SharedAsset.addFriendOffSocial.swiftUIImage : SharedAsset.addFriendOnSocial.swiftUIImage)
                        .resizable()
                        .frame(width: 30, height: 30)
                }

                Spacer().frame(width: 12)

                Button(action: {
                    appCoordinator.isMyPageViewShown = true
                }) {
                    AsyncImage(url: currentUserViewModel.user.profileImageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                        default:
                            currentUserViewModel.user.defaultProfileImage
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
            .padding(.top, getSafeAreaInsets().top)
            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
            .offset(y: -self.offsetY)
        }
        .onAppear {
            playerViewModel.setPlayerVisibilityWithoutAnimation(isShown: true, moveToBottom: false)
            playerViewModel.isShownMiniPlayerInLibrary = false
            
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
        .frame(width: getUIScreenBounds().width, height: getUIScreenBounds().height - 89)
    }
}
