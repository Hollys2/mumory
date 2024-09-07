//
//  CreateMumorySheetView.swift
//  Feature
//
//  Created by 다솔 on 2024/06/25.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import MapKit
import PhotosUI
import Combine

import Core
import Shared


public struct CreateMumorySheetUIViewRepresentable: UIViewRepresentable {
    
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject private var keyboardResponder: KeyboardResponder
    @EnvironmentObject private var playerViewModel: PlayerViewModel
    
    public init() {}
    
    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let dimmingView = UIView(frame: UIScreen.main.bounds)
        dimmingView.backgroundColor = UIColor.black
        dimmingView.alpha = 0
        view.addSubview(dimmingView)
        
        let sheetView = UIView()
        sheetView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - getSafeAreaInsets().top - (getUIScreenBounds().height > 800 ? 8 : 16))
        
        let corners: UIRectCorner = [.topLeft, .topRight]
        let maskPath = UIBezierPath(roundedRect: sheetView.bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: 23.0, height: 23.0))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        sheetView.layer.mask = maskLayer
        sheetView.backgroundColor = .clear
        
        let hostingController = UIHostingController(rootView: CreateMumorySheetView(dismiss: context.coordinator.handleDismiss))
        hostingController.view.frame = sheetView.bounds
        hostingController.view.backgroundColor = .clear
        sheetView.addSubview(hostingController.view)
        
        let redView = UIView()
        redView.backgroundColor = .clear
        redView.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(redView)
        
        NSLayoutConstraint.activate([
            redView.topAnchor.constraint(equalTo: sheetView.topAnchor),
            redView.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor),
            redView.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor),
            redView.heightAnchor.constraint(equalToConstant: 26)
        ])
        
        let blueView = UIView()
        blueView.backgroundColor = .clear
        blueView.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(blueView)
        
        NSLayoutConstraint.activate([
            blueView.topAnchor.constraint(equalTo: redView.bottomAnchor, constant: 0),
            blueView.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20 + 25),
            blueView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 25 - 46 - 40),
            blueView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        let greenView = UIView()
        greenView.backgroundColor = .clear
        greenView.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(greenView)
        
        NSLayoutConstraint.activate([
            greenView.topAnchor.constraint(equalTo: blueView.bottomAnchor, constant: 0),
            greenView.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor),
            greenView.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor),
            greenView.heightAnchor.constraint(equalToConstant: 11),
        ])
        
        view.addSubview(sheetView)
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut]) {
            dimmingView.alpha = 0.5
            sheetView.frame.origin.y = getSafeAreaInsets().top + (getUIScreenBounds().height > 800 ? 8 : 16)
        }
        
        let tapCloseButtonGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDismiss))
        dimmingView.addGestureRecognizer(tapCloseButtonGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTapGesture))
        sheetView.addGestureRecognizer(tapGestureRecognizer)
        
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(_:)))
        let panGesture1 = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(_:)))
        let panGesture2 = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(_:)))
        redView.addGestureRecognizer(panGesture)
        blueView.addGestureRecognizer(panGesture1)
        greenView.addGestureRecognizer(panGesture2)
        
        context.coordinator.view = view
        context.coordinator.sheetView = sheetView
        context.coordinator.dimmingView = dimmingView
        
        return view
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    public class Coordinator: NSObject {
        var parent: CreateMumorySheetUIViewRepresentable
        var view: UIView?
        var sheetView: UIView?
        var dimmingView: UIView?
        
        init(parent: CreateMumorySheetUIViewRepresentable) {
            self.parent = parent
        }
        
        @objc func handleDismiss() {
            guard let view, let sheetView, let dimmingView = dimmingView else { return }
            
            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                sheetView.frame.origin.y = UIScreen.main.bounds.height
                dimmingView.alpha = 0
            }) { (_) in
                view.removeFromSuperview()
                self.parent.appCoordinator.draftMumorySong = nil
                self.parent.appCoordinator.draftMumoryLocation = nil
                self.parent.appCoordinator.isCreateMumorySheetShown = false
            }
        }
        
        @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
            guard let sheetView = sheetView, let dimmingView = dimmingView else { return }
            
            let translation = gesture.translation(in: sheetView)
            
            switch gesture.state {
            case .changed:
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                
                if translation.y > Double(0) {
                    sheetView.frame.origin.y = translation.y + self.parent.getSafeAreaInsets().top + (self.parent.getUIScreenBounds().height > 800 ? 8 : 16)
                }
                
            case .ended, .cancelled:
                if translation.y > Double(30) {
                    self.handleDismiss()
                } else {
                    UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseInOut]) {
                        sheetView.frame.origin.y = self.parent.getSafeAreaInsets().top + (self.parent.getUIScreenBounds().height > 800 ? 8 : 16)
                    }
                }
            default:
                break
            }
        }
        
        @objc func handleTapGesture() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

public struct CreateMumorySheetView: View {
    
    @State private var isDeletePopUpShown: Bool = false
    
    @State private var isPublic: Bool = true
    @State private var tags: [String] = []
    @State private var contentText: String = ""
    @State private var imageURLs: [String] = []
    @State private var calendarYOffset: CGFloat = .zero
    
    @State var photoSelections: [PhotosPickerItem] = []
    @State var selectedImages: [UIImage] = []
    
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject private var keyboardResponder: KeyboardResponder
    @EnvironmentObject private var playerViewModel: PlayerViewModel
    
    let dismiss: (() -> Void)
    
    public init(dismiss: @escaping (() -> Void)) { // 파라미터를 옵셔널로 할당할 경우 @escaping 키워드 필요 없음
        self.dismiss = dismiss
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Image(uiImage: SharedAsset.closeCreateMumory.image)
                            .resizable()
                            .frame(width: 25, height: 25)
                            .onTapGesture(perform: {
                                if self.appCoordinator.draftMumorySong != nil || self.appCoordinator.draftMumoryLocation != nil {
                                    self.appCoordinator.popUp = .deleteDraft(action: {
                                        self.appCoordinator.popUp = .none
                                        self.dismiss()
                                    })
                                } else {
                                    self.dismiss()
                                }
                            })
                        
                        Spacer()
                        
                        Button(action: {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            
                            if (self.appCoordinator.draftMumorySong != nil) && (self.appCoordinator.draftMumoryLocation != nil) {
                                self.appCoordinator.popUp = .publishMumory(action: {
                                    self.appCoordinator.popUp = .none
                                    self.appCoordinator.isLoading = true
                                    
                                    if let song = self.appCoordinator.draftMumorySong, let location = self.appCoordinator.draftMumoryLocation {
                                        Task {
                                            self.imageURLs = await PhotoPickerManager.uploadAllImages(selectedImages: self.selectedImages)
                                            
                                            let newMumory = Mumory(uId: self.currentUserViewModel.user.uId, date: self.appCoordinator.selectedDate, song: song, location: location, isPublic: self.isPublic, tags: self.tags.isEmpty ? nil : self.tags, content: self.contentText.isEmpty ? nil : self.contentText, imageURLs: self.imageURLs.isEmpty ? nil : self.imageURLs, commentCount: 0)
                                            
                                            self.currentUserViewModel.mumoryViewModel.createMumory(newMumory) { result in
                                                switch result {
                                                case .success:
                                                    print("SUCCESS createMumory")
                                                    
                                                    self.generateHapticFeedback(style: .medium)
                                                    self.playerViewModel.setLibraryPlayerVisibilityWithoutAnimation(isShown: false)
                                                    
                                                case .failure(let error):
                                                    print("FAILURE createMumory: \(error.localizedDescription)")
                                                }
                                                
                                                self.appCoordinator.isLoading = false
                                                self.dismiss()
                                                self.appCoordinator.selectedTab = .home
                                                self.appCoordinator.rootPath = NavigationPath()
                                                self.appCoordinator.createdMumoryRegion = MKCoordinateRegion(center: location.coordinate, span: MapConstant.defaultSpan)
                                            }
                                        }
                                    }
                                } )
                            } else {
                                self.appCoordinator.popUp = .publishError
                            }
                        }) {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 46, height: 30)
                                .background((self.appCoordinator.draftMumorySong != nil) && (self.appCoordinator.draftMumoryLocation != nil) ? SharedAsset.mainColor.swiftUIColor : Color(red: 0.47, green: 0.47, blue: 0.47))
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
                
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            VStack(spacing: 16) {
                                Button {
                                    self.appCoordinator.rootPath.append("music")
                                } label: {
                                    ContainerView(title: "음악 추가하기", image: SharedAsset.musicIconCreateMumory.swiftUIImage)
                                }
                                
                                Button {
                                    self.appCoordinator.rootPath.append("location")
                                } label: {
                                    ContainerView(title: "위치 추가하기", image: SharedAsset.locationIconCreateMumory.swiftUIImage)
                                }
                                
                                CalendarContainerView(date: self.$appCoordinator.selectedDate)
                                    .background {
                                        GeometryReader { geometry in
                                            Color.clear
                                                .onAppear {
                                                    self.calendarYOffset = geometry.frame(in: .global).maxY
                                                }
                                                .onChange(of: geometry.frame(in: .global).maxY) { newOffset in
                                                    self.calendarYOffset = newOffset
                                                }
                                        }
                                    }
                                    .onTapGesture {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        
                                        self.appCoordinator.isDatePickerShown.toggle()
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
                                    .onTapGesture {
                                        withAnimation {
                                            proxy.scrollTo(0, anchor: .top)
                                        }
                                    }
                                
                                ContentContainerView(contentText: self.$contentText)
                                    .id(1)
                                    .onTapGesture {
                                        withAnimation {
                                            proxy.scrollTo(0, anchor: .top)
                                        }
                                    }
                                
                                HStack(spacing: 11) {
                                    PhotosPicker(selection: self.$photoSelections,
                                                 maxSelectionCount: 3 - self.selectedImages.count,
                                                 matching: .images) {
                                        VStack(spacing: 0) {
                                            (self.selectedImages.count == 3 ?  SharedAsset.photoFullIconCreateMumory.swiftUIImage : SharedAsset.photoIconCreateMumory.swiftUIImage)
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                                .offset(y: 1)
                                            
                                            Spacer(minLength: 0)
                                            
                                            HStack(spacing: 0) {
                                                Text("\(self.selectedImages.count)")
                                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                                    .foregroundColor(self.selectedImages.count > 0 ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.47, green: 0.47, blue: 0.47))
                                                Text(" / 3")
                                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                                    .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                            }
                                            .multilineTextAlignment(.center)
                                            .offset(y: 2)
                                        }
                                        .padding(.vertical, 15)
                                        .frame(width: 75, height: 75)
                                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                        .cornerRadius(10)
                                    }
                                                 .disabled(self.selectedImages.count == 3)
                                    
                                    if !self.selectedImages.isEmpty {
                                        ForEach(self.selectedImages, id: \.self) { image in
                                            ZStack {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 75, height: 75)
                                                    .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                                    .cornerRadius(10)
                                                
                                                Button(action: {
                                                    if let index = self.selectedImages.firstIndex(of: image) {
                                                        self.selectedImages.remove(at: index)
                                                    }
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
                                .onChange(of: self.photoSelections) { _ in
                                    if !self.photoSelections.isEmpty {
                                        for photoItem in self.photoSelections {
                                            Task {
                                                if let imageData = try? await photoItem.loadTransferable(type: Data.self) {
                                                    if let image = UIImage(data: imageData), !self.selectedImages.contains(image) {
                                                        self.selectedImages.append(image)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    self.photoSelections.removeAll()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .onTapGesture {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                            }
                            .padding(.horizontal, 20)
                        } // VStack
                        .padding(.top, 20)
                        .padding(.bottom, 71 + getSafeAreaInsets().top)
                        .padding(.bottom, keyboardResponder.keyboardHeight != .zero ? keyboardResponder.keyboardHeight + 55 : 0)
                    } // ScrollView
                    .scrollIndicators(.hidden)
                    .onAppear {
                        UIScrollView.appearance().bounces = false
                    }
                }
            } // VStack
            .background(SharedAsset.backgroundColor.swiftUIColor)
            
            HStack(spacing: 0) {
                Group {
                    Text("전체공개")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                        .foregroundColor(self.isPublic ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.76, green: 0.76, blue: 0.76))
                    
                    Spacer().frame(width: 7)
                    
                    Image(uiImage: self.isPublic ? SharedAsset.publicOnCreateMumory.image : SharedAsset.publicOffCreateMumory.image)
                        .frame(width: 17, height: 17)
                }
                .gesture(TapGesture(count: 1).onEnded {
                    self.isPublic.toggle()
                })
                
                Spacer()
                
                if self.keyboardResponder.isKeyboardHiddenButtonShown {
                    Button(action: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }) {
                        SharedAsset.keyboardButtonCreateMumory.swiftUIImage
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .frame(height: 55)
            .padding(.leading, 25)
            .padding(.trailing, 20)
            .background(Color(red: 0.12, green: 0.12, blue: 0.12))
            .overlay(
                Rectangle()
                    .inset(by: 0.15)
                    .fill(Color(red: 0.65, green: 0.65, blue: 0.65))
                    .frame(height: 0.7)
                , alignment: .top
            )
        }
        .onAppear {
            print("onAppear CreateMumorySheetView")
        }
        .onDisappear {
            print("onDisappear CreateMumorySheetView")
        }
        .simultaneousGesture(
            DragGesture()
                .onChanged({ _ in
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }))
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

struct ContainerView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    let title: String
    let image: Image
    var mumoryAnnotation: Mumory?
    
    init(title: String, image: Image, mumoryAnnotation: Mumory? = nil) {
        self.title = title
        self.image = image
        self.mumoryAnnotation = mumoryAnnotation
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                .frame(height: 60)
                .cornerRadius(15)
            
            HStack(spacing: 0) {
                self.image
                    .resizable()
                    .frame(width: 26, height: 26)
                
                SharedAsset.starIconCreateMumory.swiftUIImage
                    .resizable()
                    .frame(width: 7, height: 7)
                    .offset(y: -13)
                
                Spacer().frame(width: 10)
                
                if self.title == "음악 추가하기" {
                    if let mumoryAnnotation = self.mumoryAnnotation {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 36, height: 36)
                            .background(
                                AsyncImage(url: self.appCoordinator.draftMumorySong?.artworkUrl ?? mumoryAnnotation.song.artworkUrl) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 36, height: 36)
                                    default:
                                        Color.clear
                                            .frame(width: 36, height: 36)
                                    }
                                }
                            )
                            .cornerRadius(6)
                        
                        Spacer().frame(width: 12)
                        
                        VStack(spacing: 5) {
                            Text(self.appCoordinator.draftMumorySong?.title ?? mumoryAnnotation.song.title)
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .frame(width: getUIScreenBounds().width * 0.464, alignment: .leading)
                            
                            Text(self.appCoordinator.draftMumorySong?.artist ?? mumoryAnnotation.song.artist)
                                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                                .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                .lineLimit(1)
                                .frame(width: getUIScreenBounds().width * 0.464, alignment: .leading)
                        }
                        
                        Spacer().frame(width: 15)
                        
                        SharedAsset.editIconCreateMumory.swiftUIImage
                            .resizable()
                            .frame(width: 31, height: 31)
                    } else {
                        if let song = self.appCoordinator.draftMumorySong {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 36, height: 36)
                                .background(
                                    AsyncImage(url: song.artworkUrl) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 36, height: 36)
                                        default:
                                            Color.clear
                                                .frame(width: 36, height: 36)
                                        }
                                    }
                                )
                                .cornerRadius(6)
                            
                            Spacer().frame(width: 12)
                            
                            VStack(spacing: 5) {
                                
                                Text("\(song.title)")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .frame(width: getUIScreenBounds().width * 0.464, alignment: .leading)
                                
                                Text("\(song.artist)")
                                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                                    .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                    .lineLimit(1)
                                    .frame(width: getUIScreenBounds().width * 0.464, alignment: .leading)
                            }
                            
                            Spacer().frame(width: 15)
                            
                            SharedAsset.editIconCreateMumory.swiftUIImage
                                .resizable()
                                .frame(width: 31, height: 31)
                            
                        } else {
                            Group {
                                Text("\(self.title)")
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                    .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                
                                Spacer().frame(width: 5)
                                
                                SharedAsset.nextIconCreateMumory.swiftUIImage
                                    .resizable()
                                    .frame(width: 19, height: 19)
                                
                                Spacer()
                            }
                        }
                    }
                } else {
                    if let mumoryAnnotation = self.mumoryAnnotation {
                        Text(self.appCoordinator.draftMumoryLocation?.locationTitle ?? mumoryAnnotation.location.locationTitle)
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .frame(width: getUIScreenBounds().width * 0.587, alignment: .leading)
                        
                        Spacer().frame(width: 15)
                        
                        SharedAsset.editIconCreateMumory.swiftUIImage
                            .resizable()
                            .frame(width: 31, height: 31)
                        
                    } else {
                        if let location = self.appCoordinator.draftMumoryLocation {
                            Text("\(location.locationTitle)")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .frame(width: getUIScreenBounds().width * 0.587, alignment: .leading)
                            
                            Spacer().frame(width: 15)
                            
                            SharedAsset.editIconCreateMumory.swiftUIImage
                                .resizable()
                                .frame(width: 31, height: 31)
                        } else {
                            Group {
                                Text("\(self.title)")
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                    .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                
                                Spacer().frame(width: 5)
                                
                                SharedAsset.nextIconCreateMumory.swiftUIImage
                                    .resizable()
                                    .frame(width: 19, height: 19)
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 17)
        }
        .frame(width: getUIScreenBounds().width - 40)
    }
}

struct CalendarContainerView: View {
    
    @Binding var date: Date
    
    init(date: Binding<Date>) {
        self._date = date
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                .frame(height: 60)
                .cornerRadius(15)
            
            HStack(spacing: 0) {
                
                SharedAsset.calendarIconCreateMumory.swiftUIImage
                    .resizable()
                    .frame(width: 26, height: 26)
                
                Spacer().frame(width: 17)
                
                Text(DateManager.formattedDate(date: self.date, dateFormat: "yyyy. M. d. EEEE"))
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 17)
        }
        .frame(width: getUIScreenBounds().width - 40)
    }
}

struct TagContainerView: View {
    
    @Binding private var tags: [String]
    @State private var tagText: String = ""
    @State private var isEditing = false
    
    init(tags: Binding<[String]>) {
        self._tags = tags
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                .frame(height: 60)
                .cornerRadius(15)
            
            
            HStack(spacing: 0) {
                SharedAsset.tagIconCreateMumory.swiftUIImage
                    .resizable()
                    .frame(width: 26, height: 26)
                
                Spacer().frame(width: 17)
                
                ForEach(self.tags.indices, id: \.self) { index in
                    TextField("", text: Binding(
                        get: { "#\(self.tags[index])" },
                        set: { self.tags[index] = $0.replacingOccurrences(of: "#", with: "") }
                    ), onEditingChanged: { isEditing in
                        self.isEditing = isEditing
                    })
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                    .onChange(of: self.tags[index], perform: { newValue in
                        if newValue.count > 5 {
                            self.tags[index] = String(newValue.prefix(5))
                        }
                        
                        if newValue.contains(" ") {
                            let beforeSpace = newValue.components(separatedBy: " ").first ?? ""
                            self.tags[index] = beforeSpace
                        } else if newValue == "" {
                            self.tags.remove(at: index)
                        }
                    })
                    .fixedSize(horizontal: true, vertical: false)
                    
                    Spacer().frame(width: 8)
                }
                
                
                if self.tags.count < 3 {
                    TextField("", text: self.$tagText)
                        .foregroundColor(.white)
                        .onChange(of: self.tagText, perform: { newValue in
                            if newValue.count > 5 {
                                tagText = String(newValue.prefix(5))
                            }
                            
                            if newValue.contains(" ") {
                                self.tags.append(String(newValue.dropLast()))
                                self.tagText = ""
                            }
                        })
                        .onSubmit {
                            print("FXXK onSubmit")
                            if !self.tagText.isEmpty {
                                self.tags.append(tagText)
                                self.tagText = ""
                            }
                        }
                }
                
                Spacer(minLength: 0)
            } // HStack
            .padding(.horizontal, 17)
            
            if self.tags.count == 0 && self.tagText.isEmpty {
                Text(self.isEditing ? "" : "태그를 입력하세요. (5글자 이내, 최대 3개)")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                    .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 17 + 26 + 17)
                    .allowsHitTesting(false)
            }
        } // ZStack
        .frame(width: getUIScreenBounds().width - 40, height: 60)
    }
}

struct ContentContainerView: View {
    
    @Binding var contentText: String
    
    init(contentText: Binding<String>) {
        self._contentText = contentText
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .foregroundColor(.clear)
                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                .cornerRadius(15)
            
            HStack(alignment: .top, spacing: 0) {
                
                SharedAsset.contentIconCreateMumory.swiftUIImage
                    .resizable()
                    .frame(width: 26, height: 26)
                
                Spacer().frame(width: 17)
                
                TextEditor(text: self.$contentText)
                    .scrollContentBackground(.hidden)
                    .scrollIndicators(.visible)
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .kerning(0.24)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .offset(x: -5, y: -5)
                    .overlay(
                        Text(self.contentText.isEmpty ? "자유롭게 내용을 입력하세요." : "")
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                            .offset(y: 3)
                            .allowsHitTesting(false)
                        , alignment: .topLeading
                    )
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.leading, 17)
        }
        .frame(width: getUIScreenBounds().width - 40, height: 111)
    }
}
