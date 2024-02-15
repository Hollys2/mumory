//
//  SocialView.swift
//  Feature
//
//  Created by 다솔 on 2024/01/03.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import Shared


struct SocialScrollViewRepresentable: UIViewRepresentable {
    
    //    typealias UIViewType = UIScrollView
    
    @Binding var offsetY: CGFloat
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()

        scrollView.delegate = context.coordinator
        
        scrollView.contentMode = .scaleToFill
//        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        
        let hostingController = UIHostingController(rootView: SocialScrollCotentView().environmentObject(mumoryDataViewModel))
        let x = hostingController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        hostingController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20, height: x)
        
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width - 20, height: x)
//        scrollView.contentInset = UIEdgeInsets(top: ㅌ, left: 0, bottom: 0, right: 0)
        scrollView.contentInsetAdjustmentBehavior = .never

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

extension SocialScrollViewRepresentable {
    
    class Coordinator: NSObject {
        
        let parent: SocialScrollViewRepresentable
        var preOffsetY: CGFloat = 0.0
        var topBarOffsetY: CGFloat = 0.0
        
        init(parent: SocialScrollViewRepresentable) {
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

extension SocialScrollViewRepresentable.Coordinator: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
    }
}


struct SocialMenuSheetView: View {
    
    @Binding private var translation: CGSize
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    @GestureState var dragAmount = CGSize.zero
    
    let mumoryAnnotation: MumoryAnnotation
    
    public init(mumoryAnnotation: MumoryAnnotation, translation: Binding<CGSize>) {
        self.mumoryAnnotation = mumoryAnnotation
        self._translation =  translation
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 9)
            
            SharedAsset.dragIndicator.swiftUIImage
                .resizable()
                .frame(width: 47, height: 4)

            Spacer().frame(height: 9)

            VStack(spacing: 0) {
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 54)
                        .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                    
                    HStack(spacing: 0) {
                        Spacer().frame(width: 20)
                        
                        SharedAsset.mumoryButtonSocial.swiftUIImage
                            .resizable()
                            .frame(width: 30, height: 30)
                        
                        Spacer().frame(width: 10)
                        
                        Text("뮤모리 보기")
                            .font(
                                Font.custom("Pretendard", size: 15)
                                    .weight(.medium)
                            )
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.appCoordinator.isSocialMenuSheetViewShown = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.appCoordinator.rootPath.append(0)
//                        if let id = self.mumoryAnnotation.id {
//                            self.appCoordinator.rootPath.append(id)
//                        } else {
//                            print("ERROR: NO ID")
//                        }
                    }
                }
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame( height: 0.3)
                    .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.5))
                
                Button(action: {
                    
                }) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: 54)
                            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                        
                        HStack(spacing: 0) {
                            Spacer().frame(width: 20)
                            
                            SharedAsset.shareMumoryDetailMenu.swiftUIImage
                                .resizable()
                                .frame(width: 30, height: 30)
                            
                            Spacer().frame(width: 10)
                            
                            Text("공유하기")
                                .font(
                                    Font.custom("Pretendard", size: 15)
                                        .weight(.medium)
                                )
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                    }
                }
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(height: 0.5)
                    .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.5))
                
                Button(action: {
                    
                }) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: 54)
                            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                        
                        HStack(spacing: 0) {
                            Spacer().frame(width: 20)
                            
                            SharedAsset.complainMumoryDetailMenu.swiftUIImage
                                .resizable()
                                .frame(width: 30, height: 30)
                            
                            Spacer().frame(width: 10)
                            
                            Text("신고")
                                .font(
                                    Font.custom("Pretendard", size: 15)
                                        .weight(.medium)
                                )
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                    }
                }
            } // VStack
            .cornerRadius(15)
            .padding(.horizontal, 9)
            
            Spacer().frame(height: 9)
        }
        .frame(width: UIScreen.main.bounds.width - 14, height: 190)
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .cornerRadius(15)
    }
}

struct SocialItemView: View {
    
    @State private var isMenuShown: Bool = false
    
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
                
                VStack(spacing: 5.25) {
                    
                    Text("이르음음음음음")
                        .font((SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16)))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 0) {
                        
                        Text(dateManager.formattedDate(date: self.mumoryAnnotation.date))
                            .font((SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15)))
                            .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                        
                        Image(uiImage: SharedAsset.lockMumoryDatail.image)
                            .resizable()
                            .frame(width: 18, height: 18)
                        
                        Spacer()
                        
                        Image(uiImage: SharedAsset.locationMumoryDatail.image)
                            .resizable()
                            .frame(width: 17, height: 17)
                        
                        Spacer().frame(width: 4)
                        
                        Text(self.mumoryAnnotation.locationModel.locationTitle)
                            .font((SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15)))
                            .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                            .frame(width: 106, height: 11, alignment: .leading)
                    } // HStack
                } // VStack
            } // HStack
            
            Spacer().frame(height: 13)
            
            ZStack(alignment: .topLeading) {
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.width - 20)
                    .background(
                        
//                        SharedAsset.artworkSample.swiftUIImage
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.width - 20)
//                            .clipped()
                        
                        AsyncImage(url: self.mumoryAnnotation.musicModel.artworkUrl, transaction: Transaction(animation: .easeInOut(duration: 0.2))) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
//                                    .transition(.move(edge: .trailing))
                            case .failure:
                                Text("Failed to load image")
                            default:
                                Color(red: 0.18, green: 0.18, blue: 0.18)
                            }
                        }
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.width - 20)
                            .clipped()
                        
//                        AsyncImage(url: URL(string: self.mumoryAnnotation)) { phase in
//                            switch phase {
//                            case .empty:
//                                ProgressView()
//                            case .success(let image):
//                                image
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill)
//                                    .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width - 40)
//                                    .clipped()
//                            case .failure:
//                                Text("Failed to load image")
//                            @unknown default:
//                                Text("Unknown state")
//                            }
//                        }

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
                                if let id = self.mumoryAnnotation.id {
                                    self.appCoordinator.rootPath.append(id)
                                } else {
                                    print("ERROR: NO ID")
                                }
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
                        self.isMenuShown = true
                        
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.appCoordinator.isSocialMenuSheetViewShown = true
                        }
                    }, label: {
                        SharedAsset.menuButtonSocial.swiftUIImage
                            .resizable()
                            .frame(width: 22, height: 22)
                    })
                } // HStack
                .padding(.top, 17)
                .padding(.leading, 20)
                .padding(.trailing, 17)
                
                VStack(spacing: 14) {
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
                    HStack(spacing: 0) {
                        
                        if let content = self.mumoryAnnotation.content, !content.isEmpty {
                            
                            Text(content)
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .frame(alignment: .leading)
                            
                            Spacer()
                            
                            // 컨텐트 너비에 따른 조건문 추가 예정
                            Text("더보기")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 11))
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(1)
                                .frame(alignment: .leading)
                        }
                    }
                } // VStack
                .frame(width: (UIScreen.main.bounds.width - 20) * 0.66)
                .padding(.leading, 22)
                //            .background(
                //                GeometryReader{ g in
                //                    Color.clear
                //                        .onAppear {
                //                            print("g.size.height: \(g.size.height)")
                //                        }
                //                }
                //            )
                .offset(y: UIScreen.main.bounds.width - 20 - 57 - 22)
                
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
        //        .sheet(isPresented: self.$isMenuShown, content: {
        //            SocialMenuSheetView()
        //                .padding(.horizontal, 9)
        //                .presentationDetents([.height(190)])
        //                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        //        })
        
    }
}

public struct SocialView: View {
    
    @State private var offsetY: CGFloat = 0
    @State private var isAddFriendNotification: Bool = false
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    @State private var translation: CGSize = .zero
    
//    var dragGesture: some Gesture {
//        DragGesture()
//            .onChanged { value in
//                //                print("onChanged: \(value.translation.height)")
//                if value.translation.height > 0 {
//                    //                    translation.height = value.translation.height
//                    let targetHeight = value.translation.height
//                    translation.height = lerp(translation.height, targetHeight, 1)
//                    
//                }
//            }
//            .onEnded { value in
//                //                print("onEnded: \(value.translation.height)")
//                withAnimation(Animation.easeInOut(duration: 0.1)) {
//                    if value.translation.height > 130 {
//                        appCoordinator.isCreateMumorySheetShown = false
//                        mumoryDataViewModel.choosedMusicModel = nil
//                        mumoryDataViewModel.choosedLocationModel = nil
//                    }
//                    translation.height = .zero
//                }
//            }
//    }
    
    public init() {}
    
    public var body: some View {
        
        ZStack(alignment: .top) {
            
            SocialScrollViewRepresentable(offsetY: self.$offsetY)
                .frame(width: UIScreen.main.bounds.width - 20)
        
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
            
            
            ZStack(alignment: .bottom) {
                if self.appCoordinator.isSocialMenuSheetViewShown {
                    Color.black.opacity(0.5).ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(Animation.easeOut(duration: 0.2)) {
                                self.appCoordinator.isSocialMenuSheetViewShown = false
                            }
                        }
                    
//                    SocialMenuSheetView(mumoryAnnotation: <#T##MumoryAnnotation#>, translation: $translation)
//                        .offset(y: self.translation.height - appCoordinator.safeAreaInsetsBottom)
//                        .simultaneousGesture(dragGesture)
//                        .transition(.move(edge: .bottom))
//                        .zIndex(1)
                }
            }
            
        }
        .background(Color(red: 0.09, green: 0.09, blue: 0.09))
        .preferredColorScheme(.dark)
    }
}

struct SocialView_Previews: PreviewProvider {
    static var previews: some View {
        SocialView()
            .environmentObject(AppCoordinator())
    }
}
