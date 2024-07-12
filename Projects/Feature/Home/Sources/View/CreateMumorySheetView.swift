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
    @EnvironmentObject private var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject private var currentUserData: CurrentUserData
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
        sheetView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - self.appCoordinator.safeAreaInsetsTop - (getUIScreenBounds().height > 800 ? 8 : 16))
        
        let corners: UIRectCorner = [.topLeft, .topRight]
        let maskPath = UIBezierPath(roundedRect: sheetView.bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: 23.0, height: 23.0))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        sheetView.layer.mask = maskLayer
        sheetView.backgroundColor = .clear
        
        let hostingController = UIHostingController(rootView: CreateMumorySheetView(action: {
            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                sheetView.frame.origin.y = UIScreen.main.bounds.height
                dimmingView.alpha = 0
            }) { (_) in
                self.appCoordinator.sheet = .none
            }
        }))
        hostingController.view.frame = sheetView.bounds
        hostingController.view.backgroundColor = .clear
        sheetView.addSubview(hostingController.view)
        
        // 컨테이너 뷰 생성
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
        
        // 나타날 때
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut]) {
            dimmingView.alpha = 0.5
            sheetView.frame.origin.y = self.appCoordinator.safeAreaInsetsTop + (getUIScreenBounds().height > 800 ? 8 : 16)
        }
        
        let tapCloseButtonGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTapCloseButtonGesture))
        dimmingView.addGestureRecognizer(tapCloseButtonGestureRecognizer)

        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTapGesture))
        sheetView.addGestureRecognizer(tapGestureRecognizer)
        
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(_:)))
        let panGesture1 = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(_:)))
        let panGesture2 = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(_:)))
        redView.addGestureRecognizer(panGesture)
        blueView.addGestureRecognizer(panGesture1)
        greenView.addGestureRecognizer(panGesture2)
        
        context.coordinator.uiView = view
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
        var uiView: UIView?
        var sheetView: UIView?
        var dimmingView: UIView?
        
        init(parent: CreateMumorySheetUIViewRepresentable) {
            self.parent = parent
        }
        
        @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
            guard let sheetView = sheetView, let dimmingView = dimmingView else { return }
            
            //            var initialPosition: CGPoint = .zero
            let translation = gesture.translation(in: sheetView)
            
            switch gesture.state {
                //            case .began:
                //                initialPosition = sheetView.frame.origin
            case .changed:
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                
                if translation.y > Double(0) {
                    sheetView.frame.origin.y = translation.y + self.parent.appCoordinator.safeAreaInsetsTop + (self.parent.getUIScreenBounds().height > 800 ? 8 : 16)
                }
                
            case .ended, .cancelled:
                if translation.y > Double(30) {
                    UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseInOut], animations: {
                        sheetView.frame.origin.y = UIScreen.main.bounds.height
                        dimmingView.alpha = 0
                    }) { value in
                        self.parent.appCoordinator.sheet = .none
                    }
                } else {
                    UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseInOut]) {
                        sheetView.frame.origin.y = self.parent.appCoordinator.safeAreaInsetsTop + (self.parent.getUIScreenBounds().height > 800 ? 8 : 16)
                    }
                }
            default:
                break
            }
        }
        
        @objc func handleTapCloseButtonGesture() {
            guard let sheetView = sheetView, let dimmingView = dimmingView else { return }
            
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            
            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                sheetView.frame.origin.y = UIScreen.main.bounds.height
                dimmingView.alpha = 0
            }) { (_) in
                self.parent.appCoordinator.sheet = .none
            }
        }
        
        @objc func handleTapGesture() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        
    }
}

public struct CreateMumorySheetView: View {
    
    @State private var isDatePickerShown: Bool = false
    @State private var isPublishPopUpShown: Bool = false
    @State private var isPublishErrorPopUpShown: Bool = false
    @State private var isTagErrorPopUpShown: Bool = false
    @State private var isDeletePopUpShown: Bool = false
    
    @State private var calendarDate: Date = Date()
    @State private var isPublic: Bool = true
    @State private var tags: [String] = []
    @State private var contentText: String = ""
    @State private var imageURLs: [String] = []
    @State private var calendarYOffset: CGFloat = .zero
    
    @StateObject private var photoPickerViewModel: PhotoPickerViewModel = .init()
    
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject private var currentUserData: CurrentUserData
    @EnvironmentObject private var keyboardResponder: KeyboardResponder
    @EnvironmentObject private var playerViewModel: PlayerViewModel
    
    
    let action: (() -> Void)?
    
    //    public init(action: @escaping (() -> Void)) { // 파라미터를 옵셔널로 할당할 경우 @escaping 키워드 필요 없음
    public init(action: (() -> Void)? = nil) {
        self.action = action
    }
    
    public var body: some View {
        //            Color.black.opacity(0.6)
        //                .ignoresSafeArea()
        //                .onTapGesture {
        //                    if mumoryDataViewModel.choosedMusicModel != nil ||
        //                        mumoryDataViewModel.choosedLocationModel != nil {
        //                        self.isDeletePopUpShown = true
        //                    } else {
        //                        mumoryDataViewModel.choosedMusicModel = nil
        //                        mumoryDataViewModel.choosedLocationModel = nil
        //                        self.calendarDate = Date()
        //                        self.tags.removeAll()
        //                        self.contentText.removeAll()
        //                        photoPickerViewModel.removeAllSelectedImages()
        //                        self.imageURLs.removeAll()
        //                        withAnimation(.easeInOut(duration: 0.1)) {
        //                            self.appCoordinator.bottomSheet = .none
        //                        }
        //                    }
        //                }
        
        ZStack(alignment: .bottom) {
            
            VStack(spacing: 0) {
                
                // MARK: -Top bar
                ZStack {
                    
                    HStack {
                        Image(uiImage: SharedAsset.closeCreateMumory.image)
                            .resizable()
                            .frame(width: 25, height: 25)
                            .onTapGesture(perform: {
                                if let action = self.action {
                                    action()
                                }
                                
                                if mumoryDataViewModel.choosedMusicModel != nil ||
                                    mumoryDataViewModel.choosedLocationModel != nil {
                                    self.isDeletePopUpShown = true
                                } else {
                                    mumoryDataViewModel.choosedMusicModel = nil
                                    mumoryDataViewModel.choosedLocationModel = nil
                                    self.calendarDate = Date()
                                    self.tags.removeAll()
                                    self.contentText.removeAll()
                                    photoPickerViewModel.removeAllSelectedImages()
                                    self.imageURLs.removeAll()
                                    
                                    //                                    appCoordinator.sheet = .none
                                }
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
                
                //                CreateMumoryScrollViewRepresentable(tags: self.$tags)
                
                ScrollViewReader { proxy in
                    
                    ScrollView(showsIndicators: false) {
                        
                        VStack(spacing: 0) {
                            
                            VStack(spacing: 16) {
                                
                                NavigationLink(value: "music") {
                                    ContainerView(title: "음악 추가하기", image: SharedAsset.musicIconCreateMumory.swiftUIImage)
                                }
                                
                                NavigationLink(value: "location") {
                                    ContainerView(title: "위치 추가하기", image: SharedAsset.locationIconCreateMumory.swiftUIImage)
                                }
                                
                                CalendarContainerView(date: self.$calendarDate)
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
                                        withAnimation(.easeInOut(duration: 0.1)) {
                                            self.isDatePickerShown.toggle()
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
                                    PhotosPicker(selection: $photoPickerViewModel.imageSelections,
                                                 maxSelectionCount: 3,
                                                 matching: .images) {
                                        VStack(spacing: 0) {
                                            (photoPickerViewModel.imageSelectionCount == 3 ?  SharedAsset.photoFullIconCreateMumory.swiftUIImage : SharedAsset.photoIconCreateMumory.swiftUIImage)
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                                .offset(y: 1)
                                            
                                            Spacer(minLength: 0)
                                            
                                            HStack(spacing: 0) {
                                                Text("\(photoPickerViewModel.imageSelectionCount)")
                                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                                    .foregroundColor(photoPickerViewModel.imageSelectionCount >= 1 ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.47, green: 0.47, blue: 0.47))
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
                                    
                                    
                                    if !photoPickerViewModel.selectedImages.isEmpty {
                                        
                                        ForEach(photoPickerViewModel.selectedImages, id: \.self) { image in
                                            
                                            ZStack {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .scaledToFill()
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
                                .onTapGesture {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                            }
                            .padding(.horizontal, 20)
                        } // VStack
                        .padding(.top, 20)
                        .padding(.bottom, 71 + appCoordinator.safeAreaInsetsBottom)
                        .padding(.bottom, keyboardResponder.keyboardHeight != .zero ? keyboardResponder.keyboardHeight + 55 : 0)
                        
                    } // ScrollView
                    .scrollIndicators(.hidden)
                    .onAppear {
                        UIScrollView.appearance().bounces = false
                    }
                }
            } // VStack
            .background(SharedAsset.backgroundColor.swiftUIColor)
            .calendarPopup(show: self.$isDatePickerShown, yOffset: self.calendarYOffset) {
                DatePicker("", selection: self.$calendarDate, in: ...Date(), displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .accentColor(SharedAsset.mainColor.swiftUIColor)
                    .background(SharedAsset.backgroundColor.swiftUIColor)
                    .environment(\.locale, Locale.init(identifier: "ko_KR"))
            }
            .popup(show: self.$isPublishPopUpShown, content: {
                PopUpView(isShown: self.$isPublishPopUpShown, type: .twoButton, title: "게시하시겠습니까?", buttonTitle: "게시", buttonAction: {
                    let calendar = Calendar.current
                    let newDate = calendar.date(bySettingHour: calendar.component(.hour, from: Date()),
                                                minute: calendar.component(.minute, from: Date()),
                                                second: calendar.component(.second, from: Date()),
                                                of: calendarDate) ?? Date()
                    self.calendarDate = newDate
                    
                    if let choosedMusicModel = mumoryDataViewModel.choosedMusicModel,
                       let choosedLocationModel = mumoryDataViewModel.choosedLocationModel {
                        mumoryDataViewModel.isLoading = true
                        
                        let dispatchGroup = DispatchGroup()
                        
                        for (index, selectedImage) in self.photoPickerViewModel.selectedImages.enumerated() {
                            
                            guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
                                print("Could not convert image to Data.")
                                continue
                            }
                            
                            dispatchGroup.enter()
                            
                            let imageRef = FirebaseManager.shared.storage.reference().child("mumoryImages/\(UUID().uuidString).jpg")
                            _ = imageRef.putData(imageData, metadata: nil) { (metadata, error) in
                                guard metadata != nil else {
                                    print("Image upload error: \(error?.localizedDescription ?? "Unknown error")")
                                    dispatchGroup.leave()
                                    return
                                }
                                
                                imageRef.downloadURL { (url, error) in
                                    guard let url = url, error == nil else {
                                        print("Error getting download URL: \(error?.localizedDescription ?? "")")
                                        dispatchGroup.leave()
                                        return
                                    }
                                    
                                    print("Download URL for Image \(index + 1)")
                                    self.imageURLs.append(url.absoluteString)
                                    dispatchGroup.leave()
                                }
                            }
                        }
                        
                        dispatchGroup.notify(queue: .main) {
                            
                            let newMumory = Mumory(uId: currentUserData.user.uId, date: self.calendarDate, song: choosedMusicModel, location: choosedLocationModel, isPublic: self.isPublic, tags: self.tags, content: self.contentText.isEmpty ? nil : contentText, imageURLs: self.imageURLs, commentCount: 0, myCommentCount: 0)
                            
                            mumoryDataViewModel.createMumory(newMumory) { result in
                                switch result {
                                case .success:
                                    self.generateHapticFeedback(style: .medium)
                                    print("뮤모리 만들기 성공")
                                    mumoryDataViewModel.isLoading = false
                                    playerViewModel.setLibraryPlayerVisibilityWithoutAnimation(isShown: false)
                                    
                                    mumoryDataViewModel.choosedMusicModel = nil
                                    mumoryDataViewModel.choosedLocationModel = nil
                                    self.tags.removeAll()
                                    self.contentText.removeAll()
                                    photoPickerViewModel.removeAllSelectedImages()
                                    self.imageURLs.removeAll()
                                    
                                case .failure(let error):
                                    print("뮤모리 만들기 실패: \(error.localizedDescription)")
                                }
                            }
                            
                            withAnimation(Animation.easeInOut(duration: 0.1)) {
                                isPublishPopUpShown = false
                                appCoordinator.sheet = .none
                                appCoordinator.selectedTab = .home
                                appCoordinator.rootPath = NavigationPath()
                                self.appCoordinator.createdMumoryRegion = MKCoordinateRegion(center: choosedLocationModel.coordinate, span: MapConstant.defaultSpan)
                            }
                        }
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
                    self.calendarDate = Date()
                    self.tags.removeAll()
                    self.contentText.removeAll()
                    photoPickerViewModel.removeAllSelectedImages()
                    self.imageURLs.removeAll()
                    
                    self.isDeletePopUpShown = false
                    withAnimation(.easeInOut(duration: 0.1)) {
                        appCoordinator.sheet = .none
                    }
                })
                
            })
            
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
            .opacity(self.isDatePickerShown ? 0 : 1)
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
                    print("FUCK0")
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }))
        .gesture(
            TapGesture()
                .onEnded({ _ in
                    print("FUCK1")
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }))
    }
}

public struct CreateMumoryContentView: View {
    
    let scrollView: UIScrollView
    
    @State private var isDatePickerShown: Bool = false
    @State private var isPublishPopUpShown: Bool = false
    @State private var isPublishErrorPopUpShown: Bool = false
    @State private var isTagErrorPopUpShown: Bool = false
    @State private var isDeletePopUpShown: Bool = false
    
    @State private var calendarDate: Date = Date()
    @State private var isPublic: Bool = true
    @State private var tags: [String] = []
    @State private var contentText: String = ""
    @State private var imageURLs: [String] = []
    @State private var calendarYOffset: CGFloat = .zero
    
    @State private var contentHeight: CGFloat = 111
    
    @StateObject private var photoPickerViewModel: PhotoPickerViewModel = .init()
    
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject private var currentUserData: CurrentUserData
    @EnvironmentObject private var keyboardResponder: KeyboardResponder
    @EnvironmentObject private var playerViewModel: PlayerViewModel
    
    public init(scrollView: UIScrollView) {
        self.scrollView = scrollView
    }
    
    public var body: some View {
        
        VStack(spacing: 0) {
            
            VStack(spacing: 16) {
                
                NavigationLink(value: "music") {
                    ContainerView(title: "음악 추가하기", image: SharedAsset.musicIconCreateMumory.swiftUIImage)
                }
                
                NavigationLink(value: "location") {
                    ContainerView(title: "위치 추가하기", image: SharedAsset.locationIconCreateMumory.swiftUIImage)
                }
                
                CalendarContainerView(date: self.$calendarDate)
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
                        withAnimation(.easeInOut(duration: 0.1)) {
                            self.isDatePickerShown.toggle()
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
                    .tag(0)
                
                ContentContainerView(contentText: self.$contentText)
                    .id(1)
                    .tag(1)
                
                TagContainerViewRepresentable(tags: self.$tags, scrollView: self.scrollView)
                    .frame(height: 60)
                
                ContentTextViewRepresentable(scrollView: self.scrollView, contentHeight: self.$contentHeight)
//                    .frame(height: self.appCoordinator.contentHeight)
                    .frame(height: self.contentHeight)
                    .background(.pink)
                
//                ContentContainerViewRepresentable(content: self.$contentText, scrollView: self.scrollView)
//                    .overlay(
//                        GeometryReader { proxy in
//                            Color.clear
//                                .onChange(of: proxy.size.height) { newValue in
//                                    print("newV: \(newValue)")
//                                }
//                                .onAppear {
//                                    // ContentContainerViewRepresentable의 높이가 변할 때마다 호출되는 로직
//                                    DispatchQueue.main.async {
//                                        // ContentContainerViewRepresentable의 높이
//                                        let contentContainerHeight = proxy.size.height
//
//                                        // HStack의 Y 위치 조정
//                                        let offset = contentContainerHeight + 16 // 예시로 상단에 16의 여백 추가
//
//                                        // HStack의 위치를 업데이트
//
//                                    }
//                                }
//                        }
//
//                            )
                
                HStack(spacing: 11) {
                    PhotosPicker(selection: $photoPickerViewModel.imageSelections,
                                 maxSelectionCount: 3,
                                 matching: .images) {
                        VStack(spacing: 0) {
                            (photoPickerViewModel.imageSelectionCount == 3 ?  SharedAsset.photoFullIconCreateMumory.swiftUIImage : SharedAsset.photoIconCreateMumory.swiftUIImage)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .offset(y: 1)
                            
                            Spacer(minLength: 0)
                            
                            HStack(spacing: 0) {
                                Text("\(photoPickerViewModel.imageSelectionCount)")
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                    .foregroundColor(photoPickerViewModel.imageSelectionCount >= 1 ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.47, green: 0.47, blue: 0.47))
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
                    
                    if !photoPickerViewModel.selectedImages.isEmpty {
                        
                        ForEach(photoPickerViewModel.selectedImages, id: \.self) { image in
                            
                            ZStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
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
        } // VStack
        .padding(.top, 20)
        .padding(.bottom, 71 + appCoordinator.safeAreaInsetsBottom)
    }
}

struct TagContainerViewRepresentable: UIViewRepresentable {
    
    @Binding var tags: [String]
    
    @EnvironmentObject private var keyboardResponder: KeyboardResponder
    
    var scrollView: UIScrollView
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
        view.layer.cornerRadius = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.frame = CGRect(x: 17, y: 0, width: 100, height: 60)
        textField.backgroundColor = .purple
        textField.tag = 0
        
        
        view.addSubview(textField)
        //        NSLayoutConstraint.activate([
        //            view.heightAnchor.constraint(equalToConstant: 60)
        //        ])
        
        //        for index in 0..<3 {
        //            let textField = UITextField()
        //            textField.delegate = context.coordinator
        //            textField.borderStyle = .roundedRect
        //            textField.backgroundColor = .purple
        //            textField.textColor = .white
        //            textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange(_:)), for: .editingChanged)
        //            textField.placeholder = index == 0 ? "태그를 입력하세요. (5글자 이내, 최대 3개)" : nil
        //            textField.tag = index
        //
        //            context.coordinator.textFields.append(textField)
        //        }
        
        return view
    }
    
    //    NotificationCenter.default.addObserver(context.coordinator, selector: #selector(context.coordinator.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    //    NotificationCenter.default.addObserver(context.coordinator, selector: #selector(context.coordinator.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    //        let textEditor = UITextView()
    //        textEditor.delegate = context.coordinator
    //        textEditor.frame = CGRect(origin: CGPoint(x: 17, y: 76), size: CGSize(width: 300, height: 200))
    //        textEditor.backgroundColor = .green
    //        view.addSubview(textEditor)
    
    
    func updateUIView(_ uiView: UIView, context: Context) {
        //        for (index, textField) in context.coordinator.textFields.enumerated() {
        //            if index < tags.count {
        //                textField.text = tags[index]
        //            } else {
        //                textField.text = ""
        //            }
        //
        //            textField.frame = CGRect(x: 17 + (index * 100), y: 0, width: 100, height: 60)
        //        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, scrollView: self.scrollView)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate, UITextViewDelegate {
        var parent: TagContainerViewRepresentable
        var textFields: [UITextField] = []
        weak var scrollView: UIScrollView?
        var keyboardHeight: CGFloat = .zero
        
        init(parent: TagContainerViewRepresentable, scrollView: UIScrollView) {
            self.parent = parent
            self.scrollView = scrollView
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
        @objc func keyboardWillShow(notification: NSNotification) {
            guard let userInfo = notification.userInfo,
                  let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                  let scrollView = scrollView
            else { return }
            
            self.keyboardHeight = keyboardFrame.height
        }
        
        @objc func keyboardWillHide(notification: NSNotification) {
            guard let scrollView = scrollView else { return }
            
            //            let contentInset = UIEdgeInsets.zero
            //            scrollView.contentInset = contentInset
            //            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
        
        @objc func textFieldDidChange(_ textField: UITextField) {
            guard let index = textFields.firstIndex(of: textField) else { return }
            
            if index < parent.tags.count {
                parent.tags[index] = textField.text ?? ""
                if parent.tags[index].count > 5 {
                    parent.tags[index] = String(parent.tags[index].prefix(5))
                    textField.text = parent.tags[index]
                }
                
                if parent.tags[index].contains(" ") {
                    parent.tags[index] = parent.tags[index].replacingOccurrences(of: " ", with: "")
                    textField.text = parent.tags[index]
                }
            } else if !textField.text!.isEmpty {
                let newTag = textField.text!.replacingOccurrences(of: " ", with: "")
                if newTag.count <= 5 && !parent.tags.contains(newTag) {
                    parent.tags.append(newTag)
                    textField.text = ""
                    parent.tags = Array(parent.tags.prefix(3))
                }
            }
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            
            switch textField.tag {
            case 0:
                guard let nextTextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField else {
                    print("guard else")
                    textField.resignFirstResponder()
                    return true
                }
                nextTextField.becomeFirstResponder()
            default:
                break
            }
            
            return true
        }
        
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            print("textFieldDidBeginEditing")
            guard let scrollView = scrollView
            else { return }
            
            switch textField.tag {
            case 0:
                print("case0")
                scrollView.setContentOffset(CGPoint(x: 0, y: 255), animated: true)
                //                let textFieldFrameInContainer = textField.convert(textField.bounds, to: containerView)
                //                var textFieldFrameInScrollView = containerView.convert(textFieldFrameInContainer, to: scrollView)
                //                textFieldFrameInScrollView.origin.y -= scrollView.contentOffset.y
                //                print("TextField Frame in ScrollView0: \(textFieldFrameInContainer)")
                //                print("TextField Frame in ScrollView1: \(textFieldFrameInScrollView)")
                //
                //                let containerViewFrameInWindow = containerView.convert(containerView.bounds, to: nil)
                //                print("TextField Frame in ScrollView2: \(containerViewFrameInWindow)")
                //
                //                print("TextField Frame in ScrollView3: \(self.keyboardHeight)")
                
                //                scrollView.setContentOffset(CGPoint(x: 0, y: 160), animated: true)
                //                scrollView.scrollRectToVisible(containerView.frame, animated: true)
                
                // 현재 스크롤뷰의 contentOffset을 가져옴
                //                 var contentOffset = scrollView.contentOffset
                //
                //                 // 키보드보다 100포인트 위에 위치하도록 contentOffset을 조정
                //                let desiredOffsetY = textFieldFrameInScrollView.origin.y - 0
                //                 if desiredOffsetY < 0 {
                //                     contentOffset.y = max(contentOffset.y + desiredOffsetY, -scrollView.contentInset.top)
                //                 } else {
                //                     contentOffset.y = min(contentOffset.y + desiredOffsetY, scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
                //                 }
                //
                //                 // contentOffset을 설정하여 스크롤뷰를 애니메이션과 함께 스크롤
            default:
                break
            }
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            guard let scrollView = scrollView else { return }
            
//            scrollView.setContentOffset(CGPoint(x: 0, y: 300), animated: true)
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            guard let scrollView = scrollView else { return }
            
            print("textView.frame.origin.y: \(textView.frame.origin.y)")
            let textViewBottomY = textView.frame.origin.y + textView.frame.size.height
            let scrollOffset = textViewBottomY - 336
            scrollView.setContentOffset(CGPoint(x: 0, y: 55), animated: true)
        }
        
        //        func textViewDidEndEditing(_ textView: UITextView) {
        //            guard let scrollView = scrollView else { return }
        //
        //            let textViewBottomY = textView.frame.origin.y + textView.frame.size.height
        //            let scrollOffset = textViewBottomY - 336
        //            scrollView.setContentOffset(CGPoint(x: 0, y: -scrollOffset), animated: true)
        //        }
    }
}

struct ContentContainerViewRepresentable: UIViewRepresentable {
    
    @Binding var content: String
    
    var scrollView: UIScrollView
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .brown
        
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = SharedFontFamily.Pretendard.medium.font(size: 16)
        textView.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
        textView.layer.cornerRadius = 15
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
//        textView.translatesAutoresizingMaskIntoConstraints = false
//
//        textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 111).isActive = true

        view.addSubview(textView)

        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, scrollView: self.scrollView)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: ContentContainerViewRepresentable
        var textFields: [UITextField] = []
        weak var scrollView: UIScrollView?
        var keyboardHeight: CGFloat = .zero
        
        init(parent: ContentContainerViewRepresentable, scrollView: UIScrollView) {
            self.parent = parent
            self.scrollView = scrollView
        }
        
        @objc func buttonTapped() {
              print("Button tapped!")
              // 원하는 동작 구현
          }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            //            guard let scrollView = scrollView else { return }
            //
            //            print("textView.frame.origin.y: \(textView.frame.origin.y)")
            //            let textViewBottomY = textView.frame.origin.y + textView.frame.size.height
            //            let scrollOffset = textViewBottomY - 336
            //            scrollView.setContentOffset(CGPoint(x: 0, y: 55), animated: true)
        }
    }
}

struct ContentTextViewRepresentable: UIViewRepresentable {
    
    var scrollView: UIScrollView
    
    @Binding var contentHeight: CGFloat
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    func makeUIView(context: UIViewRepresentableContext<ContentTextViewRepresentable>) -> UITextView {
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: 111))
        textView.delegate = context.coordinator
        textView.font = SharedFontFamily.Pretendard.medium.font(size: 16)
        textView.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
        textView.layer.cornerRadius = 15
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
//        textView.isUserInteractionEnabled = true
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        DispatchQueue.main.async {
            self.contentHeight = uiView.contentSize.height
        }
    }
    
    func makeCoordinator() -> Coordinator {
        ContentTextViewRepresentable.Coordinator(parent: self, scrollView: self.scrollView)
    }
    
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: ContentTextViewRepresentable
        weak var scrollView: UIScrollView?
        
        init(parent: ContentTextViewRepresentable, scrollView: UIScrollView) {
            self.parent = parent
            self.scrollView = scrollView
        }
        
        func textViewDidChange(_ textView: UITextView) {
            print("textViewDidChange: \(textView.contentSize.height)")
            self.parent.appCoordinator.contentHeight = textView.contentSize.height
        }
    }
    
}

struct CreateMumoryScrollViewRepresentable: UIViewRepresentable {
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject private var keyboardResponder: KeyboardResponder
    @EnvironmentObject private var playerViewModel: PlayerViewModel
    
    @Binding var tags: [String]
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .brown
        
        scrollView.delegate = context.coordinator
        
        scrollView.isScrollEnabled = true
        //        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        context.coordinator.scrollView = scrollView
        
        let hostingController = UIHostingController(rootView:
                                                        CreateMumoryContentView(scrollView: scrollView)
            .environmentObject(appCoordinator)
            .environmentObject(mumoryDataViewModel)
            .environmentObject(currentUserData)
            .environmentObject(keyboardResponder)
            .environmentObject(playerViewModel)
        )
        
        
        let contentHeight = hostingController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: contentHeight)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: contentHeight)
        
        //        scrollView.backgroundColor = .clear
        hostingController.view.backgroundColor = .gray
        
        //        scrollView.subviews.forEach { $0.removeFromSuperview() }
        scrollView.addSubview(hostingController.view)
        
        return scrollView
    }
    
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension CreateMumoryScrollViewRepresentable {
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        let parent: CreateMumoryScrollViewRepresentable
        var scrollView: UIScrollView?
        var contentHeight: CGFloat = .zero
        var hostingController: UIHostingController<CreateMumoryScrollViewRepresentable>?
        
        var tagContainerCoordinator: TagContainerViewRepresentable.Coordinator?
        
        
        init(parent: CreateMumoryScrollViewRepresentable) {
            self.parent = parent
            super.init()
        }
    }
}

extension CreateMumoryScrollViewRepresentable.Coordinator: UIScrollViewDelegate {
    
    //    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //        let offsetY = scrollView.contentOffset.y
    //
    //        if self.parent.keyboardResponder.isKeyboardHiddenButtonShown {
    ////            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    //        }
    //        print("offsetY: \(offsetY)")
    //    }
}
