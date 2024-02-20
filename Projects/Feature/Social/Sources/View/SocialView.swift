//
//  SocialView.swift
//  Feature
//
//  Created by 다솔 on 2024/01/03.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import Shared


struct SocialScrollViewRepresentable<Content: View>: UIViewRepresentable {
    
    //    typealias UIViewType = UIScrollView
    
    var content: () -> Content
    var onRefresh: () -> Void
    let refreshControl = UIRefreshControl()

    @Binding var offsetY: CGFloat
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    
    init(offsetY: Binding<CGFloat>, onRefresh: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self._offsetY = offsetY
        self.onRefresh = onRefresh
        self.content = content
    }
    
    
    func makeUIView(context: Context) -> UIScrollView {
        
        let scrollView = UIScrollView()

        scrollView.delegate = context.coordinator

        scrollView.refreshControl = refreshControl
        scrollView.refreshControl?.addTarget(context.coordinator, action: #selector(Coordinator.handleRefreshControl), for: .valueChanged)
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        let hostingController = UIHostingController(rootView: self.content().environmentObject(self.mumoryDataViewModel))
        let x = hostingController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        scrollView.contentSize = CGSize(width: 0, height: x) // 수평 스크롤 차단을 위해 너비를 0으로 함
        hostingController.view.frame = CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width - 20, height: x)
        scrollView.addSubview(hostingController.view)
        
        context.coordinator.scrollView = scrollView
        
        return scrollView
    }
    
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        print("updateUIView")
//        let hostingController = UIHostingController(rootView: content().environmentObject(mumoryDataViewModel))
//        let x = hostingController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
//        hostingController.view.frame = CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width - 20, height: x)
//        uiView.contentSize = CGSize(width: 0, height: x)
        
//        uiView.subviews.forEach { $0.removeFromSuperview() }
//        uiView.addSubview(hostingController.view)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension SocialScrollViewRepresentable {
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        
        let parent: SocialScrollViewRepresentable
        var scrollView: UIScrollView?
        var preOffsetY: CGFloat = 0.0
        var topBarOffsetY: CGFloat = 0.0
        
        init(parent: SocialScrollViewRepresentable) {
            self.parent = parent
            super.init()
        }
        
        @objc func handleRefreshControl(sender: UIRefreshControl) {
            print("handleRefreshControl")

            let hostingController = UIHostingController(rootView: parent.content().environmentObject(parent.mumoryDataViewModel))
            let x = hostingController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            hostingController.view.frame = CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width - 20, height: x)
            scrollView?.contentSize = CGSize(width: 0, height: x)
            
            scrollView?.subviews.forEach { $0.removeFromSuperview() }
            scrollView?.addSubview(hostingController.view)
            
            let newRefreshControl = UIRefreshControl()
            newRefreshControl.addTarget(self, action: #selector(Coordinator.handleRefreshControl), for: .valueChanged)
            scrollView?.refreshControl = newRefreshControl
            
            if newRefreshControl.isRefreshing {
                newRefreshControl.endRefreshing()
            }
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            
            if let refreshControl = scrollView.refreshControl, refreshControl.isRefreshing {
                  print("새로고침이 시작되었습니다.")
              }
            
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let scrollViewHeight = scrollView.bounds.height
            let limitHeight = self.parent.appCoordinator.safeAreaInsetsTop + 64
            
            topBarOffsetY += (offsetY - preOffsetY)

            if topBarOffsetY < .zero || offsetY <= .zero {
                topBarOffsetY = .zero
            } else if topBarOffsetY > limitHeight || offsetY >= contentHeight - scrollViewHeight {
                topBarOffsetY = limitHeight
            }

            parent.offsetY = topBarOffsetY

            preOffsetY = offsetY
        }
    }
}

struct SocialScrollCotentView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject private var mumoryDataViewModel: MumoryDataViewModel
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            Spacer().frame(height: 100)
            
            LazyVStack(spacing: 0) {
                
                ForEach(self.mumoryDataViewModel.mumoryAnnotations, id: \.self) { i in
                    SocialItemView(mumoryAnnotation: i)
                }
            }
            .frame(width: UIScreen.main.bounds.width - 20)
        } // VStack
        .background(Color(red: 0.09, green: 0.09, blue: 0.09))
    }
}

struct SocialItemView: View {
    
    @State private var isTruncated: Bool = false
    
    @StateObject private var dateManager: DateManager = DateManager()
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    let mumoryAnnotation: MumoryAnnotation
    
    var body: some View {
        
        VStack(spacing: 0) {
            // MARK: Profile
            HStack(spacing: 8) {
                
                Image(uiImage: SharedAsset.profileMumoryDetail.image)
                    .resizable()
                    .frame(width: 38, height: 38)
                
                VStack(alignment: .leading, spacing: 5.25) {
                    
                    Text("이르음음음음음")
                        .font((SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16)))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: true, vertical: false)
                    
                    HStack(spacing: 0) {
                        
                        Text(DateManager.formattedDate(date: self.mumoryAnnotation.date, isPublic: self.mumoryAnnotation.isPublic))
                            .font((SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15)))
                            .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                        
                        if !self.mumoryAnnotation.isPublic {
                            Image(uiImage: SharedAsset.lockMumoryDatail.image)
                                .resizable()
                                .frame(width: 18, height: 18)
                        }
                        
                        Spacer()
                        
                        Image(uiImage: SharedAsset.locationMumoryDatail.image)
                            .resizable()
                            .frame(width: 17, height: 17)
                        
                        Spacer().frame(width: 4)
                        
                        Text(self.mumoryAnnotation.locationModel.locationTitle)
                            .font((SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15)))
                            .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                            .frame(maxWidth: 106)
                            .frame(height: 11, alignment: .leading)
                            .fixedSize(horizontal: true, vertical: false)
                    } // HStack
                } // VStack
            } // HStack
            
            Spacer().frame(height: 13)
            
            ZStack(alignment: .topLeading) {
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.width - 20)
                    .background(
                        AsyncImage(url: self.mumoryAnnotation.musicModel.artworkUrl, transaction: Transaction(animation: .easeInOut(duration: 0.1))) { phase in
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
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.width - 20)
                    .background(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: .black.opacity(0.4), location: 0.00),
                                Gradient.Stop(color: .black.opacity(0), location: 0.26),
                                Gradient.Stop(color: .black.opacity(0), location: 0.63),
                                Gradient.Stop(color: .black.opacity(0.4), location: 0.96),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0),
                            endPoint: UnitPoint(x: 0.5, y: 1)
                        )
                    )
                    .cornerRadius(15)
                    .gesture(
                        TapGesture(count: 1)
                            .onEnded {
                                self.appCoordinator.rootPath.append(MumoryView(type: .mumoryDetailView, musicItemID: self.mumoryAnnotation.musicModel.songID))
                            }
                    )
                
                // MARK: Title & Menu
                HStack(spacing: 0) {
                    
                    SharedAsset.musicIconSocial.swiftUIImage
                        .resizable()
                        .frame(width: 14, height: 14)
                    
                    Spacer().frame(width: 6)
                    
                    Text(self.mumoryAnnotation.musicModel.title)
                        .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 14))
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.white)
                    
                    Spacer().frame(width: 8)
                    
                    Text(self.mumoryAnnotation.musicModel.artist)
                        .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 14))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        self.appCoordinator.choosedSongID = self.mumoryAnnotation.musicModel.songID
                        self.appCoordinator.isSocialMenuSheetViewShown = true
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
                            if let imageURLs = self.mumoryAnnotation.imageURLs, !imageURLs.isEmpty {
                                
                                HStack(spacing: 4) {
                                    
                                    SharedAsset.imageCountSocial.swiftUIImage
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                    
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
                                        .background(Color(red: 0.16, green: 0.16, blue: 0.16).opacity(0.6))
                                        .cornerRadius(15)
                                )
                            }
                            
                            // MARK: Tag
                            if let tags = self.mumoryAnnotation.tags {
                                
                                ForEach(tags, id: \.self) { i in
                                    
                                    HStack(alignment: .center, spacing: 5) {
                                    
                                        SharedAsset.tagMumoryDatail.swiftUIImage
                                            .resizable()
                                            .frame(width: 14, height: 14)
                                        
                                        Text(i)
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
                    if let content = self.mumoryAnnotation.content, !content.isEmpty {
                        
                        HStack(spacing: 0) {
                        
                            Text(content)
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .frame(maxWidth: (UIScreen.main.bounds.width - 20) * 0.66 * 0.87, alignment: .leading)
                                .fixedSize(horizontal: true, vertical: false)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onAppear {
                                            let size = content.size(withAttributes: [.font: SharedFontFamily.Pretendard.medium.font(size: 13)])
                                            
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
                VStack(spacing: 12) {
                    
                    Button(action: {
                        
                    }, label: {
                        SharedAsset.heartButtonSocial.swiftUIImage
                            .resizable()
                            .frame(width: 42, height: 42)
                            .background(
                                .white.opacity(0.1)
                            )
                            .mask {Circle()}
                    })
                    
                    Text("10")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    
                    Button(action: {
                        withAnimation(Animation.easeInOut(duration: 0.2)) {
                            self.appCoordinator.isMumoryDetailCommentSheetViewShown = true
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
                    
                    //                Text("10")
                    //                  .font(
                    //                    Font.custom("Pretendard", size: 15)
                    //                      .weight(.medium)
                    //                  )
                    //                  .multilineTextAlignment(.center)
                    //                  .foregroundColor(.white)
                    
                }
                .offset(x: UIScreen.main.bounds.width - 20 - 42 - 17)
                .alignmentGuide(VerticalAlignment.top) { d in
                    d[.bottom] - (UIScreen.main.bounds.width - 20) + 27
                }
            } // ZStack
            
            Spacer().frame(height: 40)
        } // VStack
    }
}

public struct SocialView: View {
    
    @State private var offsetY: CGFloat = 0
    @State private var isAddFriendNotification: Bool = false
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    @State private var translation: CGSize = .zero
    
    public init() {}
    
    public var body: some View {
        
        ZStack(alignment: .top) {
            
            SocialScrollViewRepresentable(offsetY: self.$offsetY, onRefresh: {
                print("onRefresh!")
            }, content: {
                SocialScrollCotentView()
            })
        
            HStack(alignment: .top, spacing: 0) {
                Spacer().frame(width: 10)

                Text("소셜")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 24))
                    .foregroundColor(.white)

                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.appCoordinator.rootPath.append(4)
                    }
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
                    (self.isAddFriendNotification ? SharedAsset.addFriendOnSocial.swiftUIImage : SharedAsset.addFriendOffSocial.swiftUIImage)
                        .resizable()
                        .frame(width: 30, height: 30)
                }

                Spacer().frame(width: 12)

                Button(action: {

                }) {
                    Image("UserProfile_BT")
                        .frame(width: 30, height: 30)
                        .background(
                            Image("PATH_TO_IMAGE")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30, height: 30)
                                .clipped()
                        )
                        .overlay(
                            Rectangle()
                                .stroke(.white, lineWidth: 1)
                        )
                }

                Spacer().frame(width: 10)
            } // HStack
            .padding(.horizontal, 10)
            .padding(.top, 19 + appCoordinator.safeAreaInsetsTop)
            .padding(.bottom, 15)
            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
            .offset(y: -self.offsetY)
            
        }
        .background(Color(red: 0.09, green: 0.09, blue: 0.09))
        .preferredColorScheme(.dark)
        .bottomSheet(isShown: $appCoordinator.isSocialMenuSheetViewShown, mumoryBottomSheet: MumoryBottomSheet(appCoordinator: appCoordinator, type: .mumorySocialView, songID: self.appCoordinator.choosedSongID))
    }
}

struct SocialView_Previews: PreviewProvider {
    static var previews: some View {
        SocialView()
            .environmentObject(AppCoordinator())
    }
}

struct TransparentBackground: UIViewRepresentable {
    private class BackgroundRemovalView: UIView {
           override func didMoveToWindow() {
               super.didMoveToWindow()
               superview?.superview?.backgroundColor = .clear
           }
       }
       
       func makeUIView(context: Context) -> UIView {
           return BackgroundRemovalView()
       }

    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

class CustomRefreshControl: UIControl {
    var isRefreshing = false

    func beginRefreshing() {
        isRefreshing = true
        // 새로고침 애니메이션 시작
    }

    func endRefreshing() {
        isRefreshing = false
        // 새로고침 애니메이션 종료
    }
}
