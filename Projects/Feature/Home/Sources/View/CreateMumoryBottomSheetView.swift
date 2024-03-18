//
//  CreateMumoryBottomSheetView.swift
//  Feature
//
//  Created by 다솔 on 2023/12/02.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import PhotosUI
import Core
import Shared
import MapKit


public struct CreateMumoryBottomSheetView: View {
    
    @Binding var isSheetShown: Bool
    @Binding var offsetY: CGFloat
    @Binding private var newRegion: MKCoordinateRegion?
    
    @State private var bottomBarHeight: CGFloat = 55
    
    @State private var isDatePickerShown: Bool = false
    @State private var isPublishPopUpShown: Bool = false
    @State private var isPublishErrorPopUpShown: Bool = false
    @State private var isTagErrorPopUpShown: Bool = false
    @State private var isDeletePopUpShown: Bool = false
    
    @GestureState private var dragState = DragState.inactive
    
    @State private var calendarDate: Date = Date()
    @State private var tags: [String] = []
    @State private var contentText: String = ""
    @State private var imageURLs: [String] = []
    
    @State private var isPublic: Bool = true
    @State private var calendarYOffset: CGFloat = .zero
    @State private var contentOffset: CGFloat = 0
    @State private var bottomBarOffset: CGFloat = 0
    @State private var tagContainerViewFrame: CGRect = .zero
    
    @StateObject private var photoPickerViewModel: PhotoPickerViewModel = .init()
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject private var keyboardResponder: KeyboardResponder
    
    public init(isSheetShown: Binding<Bool>, offsetY: Binding<CGFloat>, newRegion: Binding<MKCoordinateRegion?> ) {
        self._isSheetShown = isSheetShown
        self._offsetY = offsetY
        self._newRegion = newRegion
    }
    
    public var body: some View {
        
        let dragGesture = DragGesture()
            .updating($dragState) { value, state, transaction in
                var newTranslation = value.translation
                
                if self.offsetY + newTranslation.height < 0 {
                    newTranslation.height = -self.offsetY
                }
                
                state = .dragging(translation: newTranslation)
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
                                    
                                    CalendarContainerView(date: self.$calendarDate)
                                        .onTapGesture {
                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                            
                                            withAnimation(.easeInOut(duration: 0.1)) {
                                                self.isDatePickerShown.toggle()
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
                                    
                                    
                                    ContentContainerView(contentText: self.$contentText)
                                        .id(1)
                                        .background {
                                            GeometryReader { geometry in
                                                Color.clear
                                                    .onChange(of: geometry.frame(in: .global)) { i in
                                                        self.contentOffset = i.maxY
                                                    }
                                                    .onChange(of: geometry.size.height) { newOffset in
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
                            } // VStack
                            .padding(.top, 20)
                            .offset(y: self.keyboardResponder.isKeyboardHiddenButtonShown ? -200 : 0)
                        } // ScrollView
                        .simultaneousGesture(DragGesture().onChanged { i in
                            print("simultaneousGesture DragGesture")
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        })
                    }
                    
                    ZStack(alignment: .bottom) {
                        
                        VStack {
                            
                            Spacer()
                            
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
                            }
                            Spacer()
                        }
                        .frame(height: self.bottomBarHeight)
                        .padding(.leading, 25)
                        .padding(.trailing, 20)
                        .padding(.bottom, self.appCoordinator.safeAreaInsetsBottom)
                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                        .overlay(
                            Rectangle()
                                .inset(by: 0.15)
                                .fill(Color(red: 0.65, green: 0.65, blue: 0.65))
                                .frame(height: 0.5)
                            , alignment: .top
                        )
                        .highPriorityGesture(DragGesture())
                        
                        VStack {
                            Spacer()
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
                                
                                Button(action: {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }) {
                                    SharedAsset.keyboardButtonCreateMumory.swiftUIImage
                                        .resizable()
                                        .frame(width: 26, height: 26)
                                }
                            }
                            Spacer()
                        }
                        .frame(height: self.bottomBarHeight)
                        .padding(.leading, 25)
                        .padding(.trailing, 20)
                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                        .background {
                            GeometryReader { geometry in
                                Color.red
                                    .onChange(of: geometry.frame(in: .global)) { i in
                                        self.bottomBarOffset = i.minY
                                    }
                                    .onChange(of: geometry.size.height) { newOffset in
                                    }
                            }
                        }
                        .overlay(
                            Rectangle()
                                .inset(by: 0.15)
                                .fill(Color(red: 0.65, green: 0.65, blue: 0.65))
                                .frame(height: 0.5)
                            , alignment: .top
                        )
                        .offset(y: self.bottomBarHeight)
                        .offset(y: self.keyboardResponder.isKeyboardHiddenButtonShown ? -self.keyboardResponder.keyboardHeight - self.bottomBarHeight : 0)
                        .highPriorityGesture(DragGesture())
                        
                    }
                } // VStack
                .background(SharedAsset.backgroundColor.swiftUIColor)
                .cornerRadius(23, corners: [.topLeft, .topRight])
                .padding(.top, appCoordinator.safeAreaInsetsTop + 16)
                .offset(y: self.offsetY + self.dragState.translation.height)
                .gesture(dragGesture)
                .gesture(TapGesture(count: 1).onEnded {
                    //                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                })
                .transition(.move(edge: .bottom))
                .zIndex(1)
                .calendarPopup(show: self.$isDatePickerShown, yOffset: self.calendarYOffset) {
                    
                    DatePicker("", selection: self.$calendarDate, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .accentColor(SharedAsset.mainColor.swiftUIColor)
                        .background(SharedAsset.backgroundColor.swiftUIColor)
                        .preferredColorScheme(.dark)
                }
                .popup(show: self.$isPublishPopUpShown, content: {
                    PopUpView(isShown: self.$isPublishPopUpShown, type: .twoButton, title: "게시하시겠습니까?", buttonTitle: "게시", buttonAction: {
                        print("calendarDate1: \(calendarDate)")
                        var calendar = Calendar.current
                        let newDate = calendar.date(bySettingHour: calendar.component(.hour, from: Date()),
                                                    minute: calendar.component(.minute, from: Date()),
                                                    second: calendar.component(.second, from: Date()),
                                                    of: calendarDate) ?? Date()
                        self.calendarDate = newDate
                        
                        if let choosedMusicModel = mumoryDataViewModel.choosedMusicModel,
                           let choosedLocationModel = mumoryDataViewModel.choosedLocationModel {
                            mumoryDataViewModel.isCreating = true

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

                                let newMumoryAnnotation = Mumory(id: "", uId: appCoordinator.currentUser.uId, date: self.calendarDate, musicModel: choosedMusicModel, locationModel: choosedLocationModel, tags: self.tags, content: self.contentText, imageURLs: self.imageURLs, isPublic: self.isPublic, likes: [], commentCount: 0)

                                mumoryDataViewModel.createMumory(newMumoryAnnotation) { result in
                                    switch result {
                                    case .success:
                                        print("뮤모리 만들기 성공")

                                        mumoryDataViewModel.choosedMusicModel = nil
                                        mumoryDataViewModel.choosedLocationModel = nil
                                        self.tags.removeAll()
                                        self.contentText.removeAll()
                                        photoPickerViewModel.removeAllSelectedImages()
                                        self.imageURLs.removeAll()

                                        self.newRegion = MKCoordinateRegion(center: choosedLocationModel.coordinate, span: MapConstant.defaultSpan)

                                    case .failure(let error):
                                        print("뮤모리 만들기 실패: \(error.localizedDescription)")
                                    }
                                }

                                withAnimation(Animation.easeInOut(duration: 0.2)) {
                                    isPublishPopUpShown = false
                                    appCoordinator.isCreateMumorySheetShown = false
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
                        
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.appCoordinator.isCreateMumorySheetShown = false
                        }
                    })
                    
                })
            }
        }
    }
    
    private func onDragEnded(drag: DragGesture.Value) {
        
        let cardDismiss = drag.translation.height > 100
        let offset = cardDismiss ? drag.translation.height : 0
        
        self.offsetY = CGFloat(offset)
        
        if cardDismiss {
            withAnimation(.spring(response: 0.1)) {
                mumoryDataViewModel.choosedMusicModel = nil
                mumoryDataViewModel.choosedLocationModel = nil
                self.tags.removeAll()
                self.contentText.removeAll()
                photoPickerViewModel.removeAllSelectedImages()
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


struct ContainerView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    let title: String
    let image: Image
    var mumoryAnnotation: Mumory?
    
    @State private var isMusicChoosed: Bool = false
    @State private var isLocationChoosed: Bool = false
    
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
                        
                        if let choosed = self.mumoryDataViewModel.choosedMusicModel {
                            
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 36, height: 36)
                                .background(
                                    AsyncImage(url: choosed.artworkUrl) { phase in
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
                                
                                Text("\(choosed.title)")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .frame(width: getUIScreenBounds().width * 0.464, alignment: .leading)
                                
                                Text("\(choosed.artist)")
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
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 36, height: 36)
                                .background(
                                    AsyncImage(url: mumoryAnnotation.musicModel.artworkUrl) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 36, height: 36)
                                        default:
                                            Color(red: 0.184, green: 0.184, blue: 0.184)
                                                .frame(width: 36, height: 36)
                                        }
                                    }
                                )
                                .cornerRadius(6)
                            
                            Spacer().frame(width: 12)
                            
                            VStack(spacing: 5) {
                                
                                Text("\(mumoryAnnotation.musicModel.title)")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .frame(width: getUIScreenBounds().width * 0.464, alignment: .leading)
                                
                                Text("\(mumoryAnnotation.musicModel.artist)")
                                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                                    .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                    .lineLimit(1)
                                    .frame(width: getUIScreenBounds().width * 0.464, alignment: .leading)
                            }
                            
                            Spacer().frame(width: 15)
                            
                            SharedAsset.editIconCreateMumory.swiftUIImage
                                .resizable()
                                .frame(width: 31, height: 31)
                        }
                    } else {
                        if let choosed = self.mumoryDataViewModel.choosedMusicModel {
                            
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 36, height: 36)
                                .background(
                                    AsyncImage(url: choosed.artworkUrl) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 36, height: 36)
                                        default:
                                            Color.purple
                                                .frame(width: 36, height: 36)
                                        }
                                    }
                                )
                                .cornerRadius(6)
                            
                            Spacer().frame(width: 12)
                            
                            VStack(spacing: 5) {
                                
                                Text("\(choosed.title)")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .frame(width: getUIScreenBounds().width * 0.464, alignment: .leading)
                                
                                Text("\(choosed.artist)")
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
                        
                        VStack(spacing: 5) {
                            
                            Text("\(mumoryAnnotation.locationModel.locationTitle)")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .frame(width: getUIScreenBounds().width * 0.587, alignment: .leading)
                            
                            Text("\(mumoryAnnotation.locationModel.locationSubtitle)")
                                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                                .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                .lineLimit(1)
                                .frame(width: getUIScreenBounds().width * 0.587, alignment: .leading)
                        }
                        
                        Spacer().frame(width: 15)
                        
                        SharedAsset.editIconCreateMumory.swiftUIImage
                            .resizable()
                            .frame(width: 31, height: 31)
                    } else {
                        
                        if let choosed = self.mumoryDataViewModel.choosedLocationModel {
                            VStack(spacing: 5) {

                                Text("\(choosed.locationTitle)")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .frame(width: getUIScreenBounds().width * 0.587, alignment: .leading)
                                
                                Text("\(choosed.locationSubtitle)")
                                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                                    .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                    .lineLimit(1)
                                    .frame(width: getUIScreenBounds().width * 0.587, alignment: .leading)
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
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 17)
        }
        
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
    }
}

struct TagContainerView: View {
    
    @Binding private var tags: [String]
    
    @State private var tagText: String = ""
    
    @State private var isEditing = false
    @State private var isTagEditing = false
    
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
                        self.isTagEditing = isEditing
                    })
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .foregroundColor(self.isTagEditing ? .white : Color(red: 0.64, green: 0.51, blue: 0.99))
                    .onChange(of: tags[index], perform: { newValue in
                        if newValue.count > 6 {
                            tags[index] = String(newValue.prefix(6))
                        }

                        if newValue.contains(" ") || newValue.hasSuffix(" ") {
                            let beforeSpace = newValue.components(separatedBy: " ").first ?? ""
                            tags[index] = beforeSpace

                        } else if newValue == "" {
                            tags.remove(at: index)
                        } else if !newValue.hasPrefix("#") {
                            //                            tags.remove(at: index)
                        }
                    })
                    .fixedSize(horizontal: true, vertical: false)
                    
                    Spacer().frame(width: 8)
                }
                
                
                if self.tags.count < 3 {
                    TagTextField(text: $tagText, onCommit: {
                        if tagText.first == "#" {
                            tagText.removeFirst()
                            tags.append(tagText)
                            tagText = ""
                        }
                    }, onEditingChanged: { isEditing in
                        self.isEditing = isEditing
                    })
                    .onChange(of: tagText) { newValue in
                        if !self.isEditing {
                            tagText = ""
                        }
                    }
                }
                
                Spacer(minLength: 0)
            } // HStack
            .padding(.horizontal, 17)
            
            if self.tags.count == 0 {
                Text(self.isEditing ? "" : "태그를 입력하세요. (5글자 이내, 최대 3개)")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                    .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 17 + 26 + 17)
                    .allowsHitTesting(false)
            }
        } // ZStack
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
                .frame(minHeight: getUIScreenBounds().height == 667 ? 86 : 111)
                .cornerRadius(15)
            
            HStack(alignment: .top, spacing: 0) {
                
                SharedAsset.contentIconCreateMumory.swiftUIImage
                    .resizable()
                    .frame(width: 26, height: 26)
                
                Spacer().frame(width: 17)
                
                TextEditor(text: $contentText)
                    .scrollContentBackground(.hidden)
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .kerning(0.24)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding([.top, .leading], -5)
                    .overlay(
                        Text("자유롭게 내용을 입력하세요.")
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                            .offset(y: 3)
                            .opacity(self.contentText.isEmpty ? 1 : 0)
                            .allowsHitTesting(false)
                        , alignment: .topLeading
                    )
                    .onChange(of: contentText) { newValue in
                        //                        print("newValue: \(newValue)@")
                    }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 17)
        }
    }
}

struct TagTextField: UIViewRepresentable {
    
    @Binding var text: String
    
    var onCommit: () -> Void
    var onEditingChanged: ((Bool) -> Void)?
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        
        if let customFont = UIFont(name: "Pretendard", size: 16) {
            textField.font = customFont
        } else {
            print("폰트 로드에 실패했습니다.")
        }
        
        textField.textColor = .white
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: TagTextField
        
        init(parent: TagTextField) {
            self.parent = parent
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            print("textFieldDidChangeSelection")
            
            DispatchQueue.main.async {
                self.parent.text = textField.text ?? ""
                
                if let lastCharacter = textField.text?.last, lastCharacter == " " {
                    self.parent.onCommit()
                }
            }
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // 최대 길이를 6로 제한
            let currentText = textField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            return newText.count <= 6
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.parent.onCommit()
            return true
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            // 포커스가 들어왔을 때 호출
            self.parent.onEditingChanged?(true)
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            // 포커스가 나갔을 때 호출
            self.parent.onEditingChanged?(false)
            
            self.parent.text = ""
        }
    }
}
