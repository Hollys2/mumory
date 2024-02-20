//
//  HomeView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/08.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import MapKit
import MusicKit
import CoreLocation
import CoreLocationUI
import PhotosUI

import Core
import Shared


@available(iOS 16.0, *)
struct MumoryCarousel: UIViewRepresentable {
    
    //    typealias UIViewType = UIScrollView
    
    @Binding var mumoryAnnotations: [MumoryAnnotation]
    //    @Binding var annotationSelected: Bool
    
    //    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        
        scrollView.delegate = context.coordinator
        
        let totalWidth = (310 + 20) * CGFloat(mumoryAnnotations.count)
        scrollView.contentSize = CGSize(width: totalWidth, height: 1)
        
        scrollView.isPagingEnabled = true
        scrollView.contentMode = .scaleToFill
        scrollView.clipsToBounds = false
        scrollView.bounces = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        let hostingController = UIHostingController(rootView: MumoryList(mumoryAnnotations: $mumoryAnnotations))
        hostingController.view.frame = CGRect(x: 0, y: 0, width: totalWidth, height: 418)
        
        scrollView.addSubview(hostingController.view)
        //        view.backgroundColor = .red
        hostingController.view.backgroundColor = .clear
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension MumoryCarousel {
    
    class Coordinator: NSObject {
        
        let parent: MumoryCarousel
        
        init(parent: MumoryCarousel) {
            self.parent = parent
            super.init()
        }
    }
}

extension MumoryCarousel.Coordinator: UIScrollViewDelegate {
    //    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    //           let pageWidth: CGFloat = 330.0 // 페이지의 너비
    //
    //           // 사용자가 놓은 스크롤의 최종 위치를 페이지 단위로 계산하여 목표 위치(targetContentOffset)를 조정
    //           let targetX = targetContentOffset.pointee.x
    //           let contentWidth = scrollView.contentSize.width
    //           let newPage = round(targetX / pageWidth)
    //           let xOffset = min(newPage * pageWidth, contentWidth - scrollView.bounds.width) // 너무 많이 이동하지 않도록 bounds 체크
    //
    //           targetContentOffset.pointee = CGPoint(x: xOffset, y: 0)
    //       }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //        print(scrollView.contentOffset.x)
    }
    
}

@available(iOS 16.0, *)
struct MumoryList: View {
    
    @Binding var mumoryAnnotations: [MumoryAnnotation]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(mumoryAnnotations.indices, id: \.self) { index in
                MumoryCard(mumoryAnnotation: $mumoryAnnotations[index], selectedIndex: index)
                    .padding(.horizontal, 10)
            }
        }
    }
}

struct MumoryCard: View {
    
    @Binding var mumoryAnnotation: MumoryAnnotation
    //    @Binding var annotationSelected: bool
    
    let selectedIndex: Int
    
    @State var date: String = ""
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
        
        ZStack {
            VStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 310, height: 310)
                    .background(
                        AsyncImage(url: mumoryAnnotation.musicModel.artworkUrl) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 310, height: 310)
                            default:
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 310, height: 310)
                                    .background(Color(red: 0.25, green: 0.25, blue: 0.25))
                                    .overlay(
                                        Rectangle()
                                            .inset(by: 0.5)
                                            .stroke(.white, lineWidth: 1)
                                    )
                                    .overlay(
                                        SharedAsset.defaultArtwork.swiftUIImage
                                            .frame(width: 103, height: 124)
                                            .background(Color(red: 0.47, green: 0.47, blue: 0.47))
                                    )
                            }
                        }
                    )
                    .cornerRadius(15)
                Spacer()
            }
            
            VStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 310, height: 310)
                    .background(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: Color(red: 0.64, green: 0.52, blue: 0.98).opacity(0), location: 0.35),
                                Gradient.Stop(color: Color(red: 0.64, green: 0.52, blue: 0.98), location: 0.85),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0.74),
                            endPoint: UnitPoint(x: 0.5, y: 1)
                        )
                    )
                    .cornerRadius(15)
                Spacer()
            }
            
            VStack {
                
                Spacer()
                
                HStack(spacing: 5)  {
                    Text("\(self.date)")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                        .foregroundColor(.white)
                        .onAppear {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy.MM.dd"
                            self.date = dateFormatter.string(from: mumoryAnnotation.date)
                        }
                    
                    
                    Spacer(minLength: 59)
                    
                    SharedAsset.locationMumoryPopup.swiftUIImage
                        .resizable()
                        .frame(width: 17, height: 17)
                    
                    Text("\(mumoryAnnotation.locationModel.locationTitle)")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                        .foregroundColor(.white)
//                        .frame(maxWidth: getUIScreenBounds().width * 0.3, alignment: .leading)
                        .lineLimit(1)
                } // HStack
                .padding(.horizontal, 16)
                
                // MARK: - Underline
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 284, height: 0.5)
                    .background(.white.opacity(0.5))
                
                HStack {
                    VStack(spacing: 12) {
                        Text("\(mumoryAnnotation.musicModel.title)")
                            .font(
                                Font.custom("Pretendard", size: 18)
                                    .weight(.bold)
                            )
                            .foregroundColor(.white)
                            .frame(width: 199, height: 13, alignment: .topLeading)
                            .lineLimit(1)
                        
                        Text("\(mumoryAnnotation.musicModel.artist)")
                            .font(Font.custom("Pretendard", size: 18))
                            .foregroundColor(.white)
                            .frame(width: 199, height: 13, alignment: .topLeading)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        //                        withAnimation(Animation.easeInOut(duration: 0.2)) {
//                        //                            appCoordinator.isMumoryDetailShown = true
//                        //                        }
//                        appCoordinator.mumoryPopUpZIndex = 0
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                            appCoordinator.mumoryPopUpZIndex = 2
//                        }
                        appCoordinator.rootPath.append(MumoryView(type: .mumoryDetailView, musicItemID: self.mumoryAnnotation.musicModel.songID))
                    }, label: {
                        SharedAsset.nextButtonMumoryPopup.swiftUIImage
                            .resizable()
                            .frame(width: 48, height: 48)
                    })
                } // HStack
                .padding(.horizontal, 16)
                .padding(.bottom, 22)
            } // VStack
        } // ZStack
        .frame(width: 310, height: 418)
        .background(Color(red: 0.64, green: 0.51, blue: 0.99))
        .cornerRadius(15)
    }
}


public struct HomeView: View {
    
    @State private var selectedTab: Tab = .home
    
    @State private var showDatePicker: Bool = false
    
    @State private var translation: CGSize = .zero
    @State private var offsetY: CGFloat = .zero
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    public init() {}
    
    private func lerp(_ v0: CGFloat, _ v1: CGFloat, _ t: CGFloat) -> CGFloat {
        return (1 - t) * v0 + t * v1
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                //                print("onChanged: \(value.translation.height)")
                if value.translation.height > 0 {
                    //                    translation.height = value.translation.height
                    let targetHeight = value.translation.height
                    translation.height = lerp(translation.height, targetHeight, 1)
                    
                }
            }
            .onEnded { value in
                //                print("onEnded: \(value.translation.height)")
                withAnimation(Animation.easeInOut(duration: 0.1)) {
                    if value.translation.height > 130 {
                        appCoordinator.isCreateMumorySheetShown = false
                        mumoryDataViewModel.choosedMusicModel = nil
                        mumoryDataViewModel.choosedLocationModel = nil
                    }
                    translation.height = .zero
                }
            }
    }
    
    public var body: some View {
        
        NavigationStack(path: $appCoordinator.rootPath) {
            
            ZStack(alignment: .bottom) { // 바텀시트를 위해 정렬
                
                VStack(spacing: 0) {
                    
                    switch selectedTab {
                    case .home:
                        homeView
                    case .social:
                        SocialView()
//                            .zIndex(self.appCoordinator.isSocialMenuSheetViewShown ? 3 : 0)
                    case .library:
                        Text("The Third Tab")
                    case .notification:
                        VStack(spacing: 0){
                            Color.red
                            Color.blue
                        }
                    }
                    
                    HomeTabView(selectedTab: $selectedTab)
//                        .zIndex(self.appCoordinator.isSocialMenuSheetViewShown ? 0 : 3)
                }
                
                TestBottomSheetView(isSheetShown: $appCoordinator.isCreateMumorySheetShown, offsetY: $appCoordinator.offsetY)
                
//                if appCoordinator.isSocialMenuSheetViewShown {
//                    BottomSheetUIViewRepresentable(isShown: $appCoordinator.isSocialMenuSheetViewShown, mumoryBottomSheet: MumoryBottomSheet(appCoordinator: appCoordinator, type: .mumoryDetailView))
//                }
                
                //                if appCoordinator.isCreateMumorySheetShown {
                //                    Color.black.opacity(0.6)
                //                        .onTapGesture {
                //                            withAnimation(Animation.easeInOut(duration: 0.1)) { // 사라질 때 애니메이션 적용
                //                                appCoordinator.isCreateMumorySheetShown = false
                //
                //                                mumoryDataViewModel.choosedMusicModel = nil
                //                                mumoryDataViewModel.choosedLocationModel = nil
                //                            }}
                //
                //                    CreateMumoryBottomSheetView(showDatePicker: $showDatePicker)
                //                        .offset(y: translation.height)
                //                        .gesture(self.dragGesture)
                //                        .transition(.move(edge: .bottom))
                //                        .zIndex(1)
                //                }
                
                if self.appCoordinator.isMumoryPopUpShown {
                    ZStack { // 부모 ZStack의 정렬 무시
                        Color.black.opacity(0.6)
                            .onTapGesture {
                                self.appCoordinator.isMumoryPopUpShown = false
                            }
                        
                        MumoryCarousel(mumoryAnnotations: $mumoryDataViewModel.mumoryCarouselAnnotations)
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
                
//                if self.appCoordinator.isSocialMenuSheetViewShown {
//                    Color.black.opacity(0.5).ignoresSafeArea()
//                        .onTapGesture {
//                            withAnimation(Animation.easeOut(duration: 0.2)) {
//                                self.appCoordinator.isSocialMenuSheetViewShown = false
//                            }
//                        }
//                    
//                    SocialMenuSheetView(translation: $translation)
//                        .offset(y: self.translation.height - appCoordinator.safeAreaInsetsBottom)
//                        .simultaneousGesture(dragGesture)
//                        .transition(.move(edge: .bottom))
//                        .zIndex(1)
//                }
                
                if appCoordinator.isMumoryDetailCommentSheetViewShown {
                    Color.black.opacity(0.5).ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(Animation.easeInOut(duration: 0.2)) {
                                appCoordinator.isMumoryDetailCommentSheetViewShown = false
                            }
                        }
                    
                    MumoryDetailCommentSheetView() // 스크롤뷰만 제스처 추가해서 드래그 막음
                        .offset(y: self.translation.height - appCoordinator.safeAreaInsetsBottom)
                        .gesture(dragGesture)
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                }
                
                if self.appCoordinator.isAddFriendViewShown {
                    SocialFriendView()
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                }
                
            } // ZStack
            .ignoresSafeArea()
//            .bottomSheet(isShown: $appCoordinator.isCreateMumorySheetShown)
            .navigationDestination(for: Int.self) { i in
                switch i {
                case 0:
//                    MumoryDetailView(mumoryAnnotation: mumoryDataViewModel.mumoryAnnotations[1])
                    Color.green
                case 1:
//                    MumoryDetailEditView()
                    Color.red
                case 2:
                    SearchMusicView()
                case 3:
                    SearchLocationView()
                case 4:
                    SocialSearchView()
                default:
                    Color.pink
                }
            }
            .navigationDestination(for: String.self, destination: { i in
                if let mumoryAnnotation = self.mumoryDataViewModel.mumoryAnnotations.first(where: { $0.id == i }) {
                    Color.purple
                        .ignoresSafeArea()
                } else if i == "music" {
                    SearchMusicView()
                } else if i == "location" {
                    SearchLocationView()
                } else if i == "map" {
                    SearchLocationMapView()
                } else {
                    Color.gray
                }
            })
            .navigationDestination(for: SearchFriendType.self, destination: { type in
                switch type {
                case .cancelRequestFriend:
                    FriendMenuView(type: .cancelRequestFriend)
                case .unblockFriend:
                    FriendMenuView(type: .unblockFriend)
                default:
                    Color.pink
                }
            })
            .navigationDestination(for: MumoryView.self) { view in
                switch view.type {
                case .mumoryDetailView:
                    if let mumoryAnnotation = self.mumoryDataViewModel.mumoryAnnotations.first(where: { $0.musicModel.songID == view.songID }) {
                        MumoryDetailView(mumoryAnnotation: mumoryAnnotation)
                    } else {
                        Color.red
                    }
                case .editMumoryView:
                    if let mumoryAnnotation = self.mumoryDataViewModel.mumoryAnnotations.first(where: { $0.musicModel.songID == view.songID }) {
                        MumoryDetailEditView(mumoryAnnotation: mumoryAnnotation)
                    } else {
                        Color.blue
                    }
                }
            }
        
        } // NavigationStack
        .onAppear {
            print("HomeMapViewRepresentable onAppear")
            //                    Task {
            self.mumoryDataViewModel.fetchData()
            //                        await mumoryDataViewModel.loadMusics()
            //                    }
            
        }
        
    }
    
    var homeView: some View {
        
        ZStack {
            
            HomeMapViewRepresentable(annotationSelected: $appCoordinator.isMumoryPopUpShown)
            
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
}
                          
                          

public struct TestBottomSheetView: View {
    
    @Binding var isSheetShown: Bool
    @Binding var offsetY: CGFloat
    
    @State private var showDatePicker: Bool = false
    @State private var isPublishPopUpShown: Bool = false
    @State private var isPublishErrorPopUpShown: Bool = false
    @State private var isTagErrorPopUpShown: Bool = false
    @State private var isDeletePopUpShown: Bool = false
    
    @GestureState private var dragState = DragState.inactive
    
    @State private var tags: [String] = []
    @State private var contentText: String = ""
    @State private var imageURLs: [String] = []
    
    @State private var isPublic: Bool = true
    @State private var calendarYOffset: CGFloat = .zero
    @State private var scrollViewOffset: CGFloat = 0
    @State private var tagOffset: CGFloat = 0
    @State private var contentOffset: CGFloat = 0
    @State private var tagContainerViewFrame: CGRect = .zero

    @State var date: Date = Date()
    
    @StateObject private var photoPickerViewModel: PhotoPickerViewModel = .init()
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject private var dateManager: DateManager
    
    public init(isSheetShown: Binding<Bool>, offsetY: Binding<CGFloat>) {
        self._isSheetShown = isSheetShown
        self._offsetY = offsetY
    }
//    public init(isSheetShown: Binding<Bool>) {
//        self._isSheetShown = isSheetShown
//    }
    
    let maxHeight = CGFloat(16)
    
    public var body: some View {
        
        let drag = DragGesture()
            .updating($dragState) { drag, state, transaction in
                var newTranslation = drag.translation
                if self.offsetY + newTranslation.height < -maxHeight {  // 최대치를 넘지 않도록 제한
                    newTranslation.height = -maxHeight - self.offsetY
                }
                state = .dragging(translation: newTranslation)
                //                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)
        
        return ZStack(alignment: .bottom) {
            
            if isSheetShown {
                
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        self.isDeletePopUpShown = true
                    }
                
                VStack(spacing: 0) {
                    
                    // MARK: -Top bar
                    ZStack {
                        
                        HStack {
                            Image(uiImage: SharedAsset.closeCreateMumory.image)
                                .resizable()
                                .frame(width: 25, height: 25)
                                .gesture(TapGesture(count: 1).onEnded {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    self.isDeletePopUpShown = true
                                })
                            
                            Spacer()
                            
                            Button(action: {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                
                                if (self.mumoryDataViewModel.choosedMusicModel != nil) && (self.mumoryDataViewModel.choosedLocationModel != nil) {
                                    self.isPublishPopUpShown = true
                                } else {
                                    self.isPublishErrorPopUpShown = true
                                }
                            }) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 46, height: 30)
                                    .background((self.mumoryDataViewModel.choosedMusicModel != nil) && (self.mumoryDataViewModel.choosedLocationModel != nil) ? SharedAsset.mainColor.swiftUIColor : Color(red: 0.47, green: 0.47, blue: 0.47))
                                    .cornerRadius(31.5)
                                    .overlay(
                                        Text("게시")
                                            .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 13))
                                            .foregroundColor(.black)
                                    )
                                    .allowsHitTesting(true)
                            }
                        } // HStack
                        
                        Text("뮤모리 만들기")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                            .foregroundColor(.white)
                    } // ZStack
                    .padding(.top, 26)
                    .padding(.bottom, 11)
                    .padding(.horizontal, 20)
                    
                    ScrollViewReader { reader in
                        
                        ScrollView(showsIndicators: false) {
                            
                            VStack(spacing: 0) {
                                
                                VStack(spacing: 16) {
                                    
                                    NavigationLink(value: "music") {
                                        ContainerView(title: "음악 추가하기", image: SharedAsset.musicIconCreateMumory.swiftUIImage)
                                    }
                                    
                                    NavigationLink(value: "location") {
                                        ContainerView(title: "위치 추가하기", image: SharedAsset.locationIconCreateMumory.swiftUIImage)
                                    }
                                    
                                    CalendarContainerView(title: "\(DateManager.formattedDate(date: self.date, dateFormat: "yyyy. MM. dd. EEEE"))")
                                        .onTapGesture {
                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                            
                                            withAnimation(.easeInOut(duration: 0.1)) {
                                                self.showDatePicker.toggle()
                                            }
                                        }
                                        .background {
                                            GeometryReader { geometry in
                                                Color.clear
                                                    .onAppear {
                                                        self.calendarYOffset = geometry.frame(in: .global).maxY
                                                    }
                                                    .onChange(of: geometry.frame(in: .global).maxY) { newOffset in
                                                        // Update calendarYOffset when the offset changes
                                                        self.calendarYOffset = newOffset
                                                    }
                                            }
                                        }
                                    
                                }
                                .padding(.horizontal, 20)
                                
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(height: 6)
                                    .background(.black)
                                    .padding(.vertical, 18)
                                
                                VStack(spacing: 16) {
                                    
                                    TagContainerView(tags: self.$tags)
                                        .id(0)
                                        .background(GeometryReader { geometry -> Color in
                                            DispatchQueue.main.async {
                                                self.tagContainerViewFrame = geometry.frame(in: .global)
                                            }
                                            return Color.clear
                                        })
                                        .background {
                                            GeometryReader { geometry in
                                                Color.clear
                                                    .onAppear {
                                                        self.tagOffset = geometry.frame(in: .global).maxY
                                                    }
                                                    .onChange(of: geometry.frame(in: .global).maxY) { newOffset in
                                                        self.tagOffset = newOffset
                                                    }
                                            }
                                        }
                                    
                                    
                                    ContentContainerView(contentText: self.$contentText)
                                        .id(1)
                                        .background {
                                            GeometryReader { geometry in
                                                Color.clear
                                                    .onAppear {
                                                        self.contentOffset = geometry.frame(in: .global).maxY
                                                    }
                                                    .onChange(of: geometry.frame(in: .global).maxY) { newOffset in
                                                        self.contentOffset = newOffset
                                                    }
                                            }
                                        }

                                    HStack(spacing: 11) {
                                        PhotosPicker(selection: $photoPickerViewModel.imageSelections,
                                                     maxSelectionCount: 3,
                                                     matching: .images) {
                                            
                                            Rectangle()
                                                .foregroundColor(.clear)
                                                .frame(width: 75, height: 75)
                                                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                                .cornerRadius(10)
                                                .overlay(
                                                    VStack(spacing: 0) {
                                                        (photoPickerViewModel.imageSelectionCount == 3 ?  SharedAsset.photoFullIconCreateMumory.swiftUIImage : SharedAsset.photoIconCreateMumory.swiftUIImage)
                                                            .resizable()
                                                            .frame(width: 25, height: 25)
                                                        
                                                        HStack(spacing: 0) {
                                                            Text("\(photoPickerViewModel.imageSelectionCount)")
                                                                .font(Font.custom("Pretendard", size: 14).weight(.medium))
                                                                .foregroundColor(photoPickerViewModel.imageSelectionCount >= 1 ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.47, green: 0.47, blue: 0.47))
                                                            Text(" / 3")
                                                                .font(Font.custom("Pretendard", size: 14).weight(.medium))
                                                                .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                                        }
                                                        .multilineTextAlignment(.center)
                                                        .padding(.top, 10)
                                                    }
                                                )
                                        }
                                        
                                        if !photoPickerViewModel.selectedImages.isEmpty {
                                            
                                            ForEach(photoPickerViewModel.selectedImages, id: \.self) { image in
                                                
                                                ZStack {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .frame(width: 75, height: 75)
                                                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                                        .cornerRadius(10)
                                                    
                                                    Button(action: {
                                                        photoPickerViewModel.removeImage(image)
                                                    }) {
                                                        SharedAsset.closeButtonCreateMumory.swiftUIImage
                                                            .resizable()
                                                            .frame(width: 27, height: 27)
                                                    }
                                                    .offset(x: -51 + 57 + 27, y: -(-51 + 57 + 27))
                                                }
                                            }
                                        }
                                    }
                                    .onChange(of: photoPickerViewModel.imageSelections) { _ in
                                        photoPickerViewModel.convertDataToImage()
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 50)
                                
                            } // VStack
                            .padding(.top, 20)
                            .padding(.bottom, 50)
//                            .offset(y : appCoordinator.keyboardHeight == .zero ? 0 : (getUIScreenBounds().height - self.tagOffset - appCoordinator.keyboardHeight - 55 - 17))
//                            .offset(y : appCoordinator.keyboardHeight == .zero ? 0 : (getUIScreenBounds().height - self.contentOffset - appCoordinator.keyboardHeight - 55 - 17))
                            .offset(y : appCoordinator.keyboardHeight == .zero ? 0 : -200)
                            
                        } // ScrollView
                        .simultaneousGesture(DragGesture().onChanged { i in
                            print("simultaneousGesture DragGesture")
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        })
                    }
                    
                    ZStack(alignment: .topLeading) {
                        Rectangle()
                            .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.12))
                            .frame(height: 55)
                        
                        HStack(spacing: 0) {
                            
                            Group {
                                Text("전체공개")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                                    .foregroundColor(self.isPublic ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.76, green: 0.76, blue: 0.76))
                                
                                Spacer().frame(width: 7)
                                
                                Image(uiImage: self.isPublic ? SharedAsset.publicOnCreateMumory.image : SharedAsset.publicOffCreateMumory.image)
                                    .frame(width: 17, height: 17)
                                
                            }
                            .gesture(TapGesture(count: 1)
                                .onEnded {
                                    self.isPublic.toggle()
                                })

                            Spacer()
                            
                            Button(action: {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }) {
                                SharedAsset.keyboardButtonCreateMumory.swiftUIImage
                                    .resizable()
                                    .frame(width: 26, height: 26)
                            }
                        }
                        .padding(.vertical, 15)
                        .padding(.horizontal, 20)
                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                        .padding(.bottom, getUIScreenBounds().height == 667 || getUIScreenBounds().height == 736 ? 17 : 27)
                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                        .overlay(
                            Rectangle()
                                .inset(by: 0.15)
                                .fill(Color(red: 0.65, green: 0.65, blue: 0.65))
                                .frame(height: 0.5)
                            , alignment: .top
                        )
                        .offset(y: -self.appCoordinator.keyboardHeight)
                    } // ZStack
//                                        .offset(y: getUIScreenBounds().height == 667 || getUIScreenBounds().height == 736 ? -33  : -getSafeAreaInsets().bottom - 16)
                    .highPriorityGesture(DragGesture())
                    
                } // VStack
                .background(SharedAsset.backgroundColor.swiftUIColor)
                .cornerRadius(23, corners: [.topLeft, .topRight])
                .padding(.top, appCoordinator.safeAreaInsetsTop + 16)
//                .padding(.bottom, -appCoordinator.safeAreaInsetsTop - 16)
                .offset(y: self.offsetY + self.dragState.translation.height)
                .gesture(drag)
                .gesture(TapGesture(count: 1).onEnded {
//                    print("FUCK U")
//                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                })
                .transition(.move(edge: .bottom))
                .zIndex(1)
                .calendarPopup(show: self.$showDatePicker, yOffset: self.calendarYOffset) {
                    
                    DatePicker("", selection: self.$date, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .accentColor(SharedAsset.mainColor.swiftUIColor)
                        .background(SharedAsset.backgroundColor.swiftUIColor)
                        .preferredColorScheme(.dark)
                    //                        .onChange(of: self.date) { _ in
                    //                            withAnimation(.easeInOut(duration: 0.1)) {
                    //                                self.showDatePicker = false
                    //                            }
                    //                        }
                }
                .popup(show: self.$isPublishPopUpShown, content: {
                    PopUpView(isShown: self.$isPublishPopUpShown, type: .twoButton, title: "게시하기겠습니까?", buttonTitle: "게시", buttonAction: {
                        if let choosedMusicModel = mumoryDataViewModel.choosedMusicModel, let choosedLocationModel = mumoryDataViewModel.choosedLocationModel {
                            
                            let group = DispatchGroup()
                            
                            for (index, selectedImage) in self.photoPickerViewModel.selectedImages.enumerated() {
                                
                                guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
                                    print("Could not convert image to Data.")
                                    continue
                                }
                                
                                let storageRef = FirebaseManager.shared.storage.reference()
                                let imageRef = storageRef.child("mumoryImages/\(UUID().uuidString).jpg")
                                
                                group.enter()
                                _ = imageRef.putData(imageData, metadata: nil) { (metadata, error) in
                                    
                                    guard metadata != nil else {
                                        print("Image upload error: \(error?.localizedDescription ?? "Unknown error")")
                                        group.leave()
                                        return
                                    }
                                    
                                    print("Image \(index + 1) uploaded successfully.")
                                    
                                    imageRef.downloadURL { (url, error) in
                                        guard let url = url, error == nil else {
                                            print("Error getting download URL: \(error?.localizedDescription ?? "")")
                                            group.leave()
                                            return
                                        }
                                        
                                        print("Download URL for Image \(index + 1)")
                                        self.imageURLs.append(url.absoluteString)
                                        group.leave()
                                    }
                                }
                            }
                            
                            group.notify(queue: .main) {
                                let newMumoryAnnotation = MumoryAnnotation(date: self.date, musicModel: choosedMusicModel, locationModel: choosedLocationModel, tags: tags, content: contentText, imageURLs: self.imageURLs, isPublic: self.isPublic)
                                
                                mumoryDataViewModel.createMumory(newMumoryAnnotation)

                                mumoryDataViewModel.choosedMusicModel = nil
                                mumoryDataViewModel.choosedLocationModel = nil
                                self.tags.removeAll()
                                self.contentText.removeAll()
                                photoPickerViewModel.removeAll()
                                self.imageURLs.removeAll()
                                
                                withAnimation(Animation.easeInOut(duration: 0.2)) {
                                    isPublishPopUpShown = false
                                    appCoordinator.isCreateMumorySheetShown = false
                                }
                            }
                        }
                        else {
                            print("else 일리가 없지?")
                        }
                    })
                })
                .popup(show: self.$isPublishErrorPopUpShown, content: {
                    PopUpView(isShown: self.$isPublishErrorPopUpShown, type: .oneButton, title: "음악, 위치, 날짜를 입력해주세요.", subTitle: "뮤모리를 남기시려면\n해당 조건을 필수로 입력해주세요!", buttonTitle: "확인", buttonAction: {
                        self.isPublishErrorPopUpShown = false
                    })
                    
                })
                .popup(show: self.$isTagErrorPopUpShown, content: {
                    PopUpView(isShown: self.$isTagErrorPopUpShown, type: .oneButton, title: "태그는 최대 3개까지 입력할 수 있습니다.", buttonTitle: "확인", buttonAction: {
                        self.isTagErrorPopUpShown = false
                    })
                })
                .popup(show: self.$isDeletePopUpShown, content: {
                    PopUpView(isShown: self.$isDeletePopUpShown, type: .delete, title: "해당 기록을 삭제하시겠습니까?", subTitle: "지금 이 페이지를 나가면 작성하던\n기록이 삭제됩니다.", buttonTitle: "계속 작성하기", buttonAction: {
                        mumoryDataViewModel.choosedMusicModel = nil
                        mumoryDataViewModel.choosedLocationModel = nil
                        self.tags.removeAll()
                        self.contentText.removeAll()
                        photoPickerViewModel.removeAll()
                        self.imageURLs.removeAll()
                        
                        self.isDeletePopUpShown = false
                    })
                    
                })
                .onAppear {
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
                        guard let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                        let keyboardHeight = keyboardSize.height
                        print("keyboard: \(keyboardHeight)")

                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.appCoordinator.keyboardHeight = keyboardHeight
                            self.scrollViewOffset = keyboardHeight
                        }
                    }
                    
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
                        DispatchQueue.main.async{
                            withAnimation(.easeInOut(duration: 0.3)) {
                                self.appCoordinator.keyboardHeight = CGFloat.zero
                                scrollViewOffset = 0
                            }
                        }
                    }
                }
            }
        }
    }
    
    func uploadImageToStorage(completion: @escaping (URL?) -> Void) {
        // 이미지를 Storage에 업로드하고, 그 URL을 가져오는 로직 추가
        // ...

        // 예시: Firebase Storage에 이미지를 업로드하고, 다운로드 URL을 반환
        let storageRef = FirebaseManager.shared.storage.reference()
        let imageRef = storageRef.child("images/example.jpg")

        // 예시: 이미지 데이터를 업로드
        guard let imageData = UIImage(named: "exampleImage")?.jpegData(compressionQuality: 0.8) else {
            print("Could not convert image to Data.")
            completion(nil)
            return
        }

        imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
                print("Image upload error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            print("Image uploaded successfully.")

            // 다운로드 URL을 가져오기
            imageRef.downloadURL { (url, error) in
                guard let url = url, error == nil else {
                    print("Error getting download URL: \(error?.localizedDescription ?? "")")
                    completion(nil)
                    return
                }

                print("Download URL: \(url)")

                // 이미지 다운로드 URL을 completionHandler에 전달
                completion(url)
            }
        }
    }
//    uploadImageToStorage { imageURL in
//                    // imageURL을 사용하여 Firestore에 추가적인 데이터 업데이트
//                    if let imageURL = imageURL {
//                        let additionalData: [String: Any] = [
//                            "additionalImageURL": imageURL
//                        ]
//
//                        db.collection("User").document("tester").collection("mumory").document().setData(additionalData, merge: true)
//                    }
//                }
    
    private func onDragEnded(drag: DragGesture.Value) {
//        print("drag.translation.height: \(drag.translation.height)")
        //        let verticalDirection = drag.predictedEndLocation.y - drag.location.y
        let cardDismiss = drag.translation.height > 100
        let offset = cardDismiss ? drag.translation.height : 0
        
        self.offsetY = CGFloat(offset)
        
        if cardDismiss {
            withAnimation(.spring(response: 0.1)) {
                mumoryDataViewModel.choosedMusicModel = nil
                mumoryDataViewModel.choosedLocationModel = nil
                self.tags.removeAll()
                self.contentText.removeAll()
                photoPickerViewModel.removeAll()
                self.imageURLs.removeAll()
                
                self.isSheetShown = false
            }
        }
    }
}

enum DragState {
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    
    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}



//public struct CreateMumoryBottomSheetUIViewRepresentable: UIViewRepresentable {
//
//    //    typealias UIViewType = UIView
//
//    @Binding var isShown: Bool
//
//    public init(isShown: Binding<Bool>) {
//        self._isShown = isShown
//    }
//
//    public func makeUIView(context: Context) -> UIView {
////        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
////              let topSafeAreaHeight = windowScene.windows.first?.safeAreaInsets.top,
////              let bottomSafeAreaHeight = windowScene.windows.first?.safeAreaInsets.bottom
////        else { return UIView() }
//
//        let view = UIView()
//
//        let dimmingView = UIView(frame: UIScreen.main.bounds)
//        dimmingView.backgroundColor = UIColor.black
//        dimmingView.alpha = 0
//        view.addSubview(dimmingView)
//
//        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTapGesture))
//        dimmingView.addGestureRecognizer(tapGestureRecognizer)
//
//        let newView = UIView()
//        newView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: 0)
//        newView.backgroundColor = .clear
//        view.addSubview(newView)
//
////        let hostingController = UIHostingController(rootView: BottomSheetView(isShown: $isShown, menuOptions: self.mumoryBottomSheet.menuOptions, action: {
////            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
////
////                newView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height , width: UIScreen.main.bounds.width, height: 54 * CGFloat(self.mumoryBottomSheet.menuOptions.count) + 31)
////
////                dimmingView.alpha = 0
////            }) { (_) in
////                newView.removeFromSuperview()
////                dimmingView.removeFromSuperview()
////                self.isShown = false
////            }
////
////        }))
//        let hostingController = UIHostingController(rootView: TestBottomSheetView(isSheetShown: $isShown).ignoresSafeArea())
//        hostingController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//        hostingController.view.backgroundColor = .clear
//
//        newView.addSubview(hostingController.view)
//
//        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut]) {
//
//            dimmingView.alpha = 0.5
//
//            newView.frame = CGRect(x: 0, y: 36, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//        }
//
//        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(_:)))
//        //        hostingController.view.addGestureRecognizer(panGesture)
//        newView.addGestureRecognizer(panGesture)
//
//        context.coordinator.uiView = view
//        context.coordinator.newView = newView
//        context.coordinator.dimmingView = dimmingView
//
//        return view
//    }
//
//    public func updateUIView(_ uiView: UIView, context: Context) {
//
//    }
//
//    public func makeCoordinator() -> Coordinator {
//        return Coordinator(parent: self)
//    }
//
//    public class Coordinator: NSObject {
//        var parent: CreateMumoryBottomSheetUIViewRepresentable
//        var uiView: UIView?
//        var newView: UIView?
//        var dimmingView: UIView?
//
//        init(parent: CreateMumoryBottomSheetUIViewRepresentable) {
//            self.parent = parent
//        }
//
//        @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
//
//            guard let newView = newView, let dimmingView = dimmingView else { return }
//
//            var initialPosition: CGPoint = .zero
//
//            let translation = gesture.translation(in: newView)
//
//            switch gesture.state {
//            case .began:
//                print(".began: \(newView.frame.origin)")
//
//                initialPosition = newView.frame.origin
//
//            case .changed:
//
//                print(".changed")
////                if translation.y > Double(-10) {
//                    let newY = initialPosition.y + translation.y
//
////                    newView.frame.origin.y = newY + UIScreen.main.bounds.height - (54 * CGFloat(parent.mumoryBottomSheet.menuOptions.count) + 31) - 27
////                }
//
//            case .ended, .cancelled:
//                print(".ended")
//
//                if translation.y > Double(30) {
//                    UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseInOut], animations: {
//                        newView.frame.origin.y = UIScreen.main.bounds.height
//                        dimmingView.alpha = 0
//                    }) { value in
//
//                        print("value: \(value)")
//
//                        newView.removeFromSuperview()
//                        dimmingView.removeFromSuperview()
//                        self.parent.isShown = false
//
//                    }
//                } else {
//                    UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseInOut]) {
////                        newView.frame.origin.y = UIScreen.main.bounds.height - (54 * CGFloat(self.parent.mumoryBottomSheet.menuOptions.count) + 31) - 27
//                    }
//                }
//
//            default:
//                break
//            }
//
//
//        }
//
//        @objc func handleTapGesture() {
//
//            guard let newView = newView, let dimmingView = dimmingView else { return }
//
//            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
//
////                newView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height , width: UIScreen.main.bounds.width, height: 54 * CGFloat(self.parent.mumoryBottomSheet.menuOptions.count) + 31)
//
//                dimmingView.alpha = 0
//            }) { (_) in
//                newView.removeFromSuperview()
//                dimmingView.removeFromSuperview()
//                self.parent.isShown = false
//            }
//        }
//    }
//}
//
//struct BottomSheetViewModifier2: ViewModifier {
//
//    @Binding var isShown: Bool
//
//    func body(content: Content) -> some View {
//
//        ZStack {
//            SharedAsset.mainColor.swiftUIColor
//
//            content
//
//            if isShown {
//                CreateMumoryBottomSheetUIViewRepresentable(isShown: $isShown)
//            }
//        }
//        .zIndex(1)
//    }
//}
//
//extension View {
//    public func bottomSheet(isShown: Binding<Bool>) -> some View {
//        self.modifier(BottomSheetViewModifier2(isShown: isShown))
//    }
//}
