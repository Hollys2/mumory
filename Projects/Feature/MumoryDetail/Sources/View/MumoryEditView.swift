//
//  MumoryEditView.swift
//  Feature
//
//  Created by 다솔 on 2024/01/01.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import PhotosUI
import Combine

import Core
import Shared


public struct MumoryEditView: View {
    
    @State var mumoryAnnotation: Mumory
    
    @State private var isDatePickerShown: Bool = false
    @State private var isPublishPopUpShown: Bool = false
    @State private var isPublishErrorPopUpShown: Bool = false
    @State private var isTagErrorPopUpShown: Bool = false
    @State private var isDeletePopUpShown: Bool = false
    
    @State private var calendarDate: Date
    @State private var tags: [String]
    @State private var contentText: String = ""
    @State private var imageURLs: [String] = []
    
    @State private var isPublic: Bool = false
    @State private var calendarYOffset: CGFloat = .zero
    @State private var scrollViewOffset: CGFloat = 0
    @State private var tagContainerViewFrame: CGRect = .zero
    
    
    @StateObject private var photoPickerViewModel: PhotoPickerViewModel = .init()
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject private var dateManager: DateManager
    @EnvironmentObject private var keyboardResponder: KeyboardResponder
    
    let bottomBarHeight: CGFloat = 55
    
    public init(mumoryAnnotation: Mumory) {
        self._mumoryAnnotation = State(initialValue: mumoryAnnotation)
        self._calendarDate = State(initialValue: mumoryAnnotation.date)
        self._imageURLs = State(initialValue: mumoryAnnotation.imageURLs ?? [])
        self._isPublic = State(initialValue: mumoryAnnotation.isPublic)
        self._tags = State(initialValue: mumoryAnnotation.tags ?? [])
        self._contentText = State(initialValue: mumoryAnnotation.content ?? "NO CONTENT")
    }
    
    public var body: some View {
        
        VStack(spacing: 0) {
            
            // MARK: -Top bar
            ZStack {
                
                HStack {
                    Image(uiImage: SharedAsset.closeCreateMumory.image)
                        .resizable()
                        .frame(width: 25, height: 25)
                        .gesture(TapGesture(count: 1).onEnded {
                            //                            self.isDeletePopUpShown = true
                            self.appCoordinator.rootPath.removeLast()
                            self.mumoryDataViewModel.choosedMusicModel = nil
                            self.mumoryDataViewModel.choosedLocationModel = nil
                        })
                    
                    Spacer()
                    
                    Button(action: {
                        self.isPublishPopUpShown = true
                    }) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 46, height: 30)
                            .background(SharedAsset.mainColor.swiftUIColor)
                            .cornerRadius(31.5)
                            .overlay(
                                Text("완료")
                                    .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 13))
                                    .foregroundColor(.black)
                            )
                            .allowsHitTesting(true)
                    }
                } // HStack
                
                Text("수정하기")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                    .foregroundColor(.white)
            } // ZStack
            .frame(height: 57)
            .padding(.top, appCoordinator.safeAreaInsetsTop)
            .padding(.bottom, 11)
            .padding(.horizontal, 20)
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 0) {
                    
                    VStack(spacing: 16) {
                        
                        NavigationLink(value: "music") {
                            ContainerView(title: "음악 추가하기", image: SharedAsset.musicIconCreateMumory.swiftUIImage, mumoryAnnotation: self.mumoryAnnotation)
                        }
                        
                        NavigationLink(value: "location") {
                            ContainerView(title: "위치 추가하기", image: SharedAsset.locationIconCreateMumory.swiftUIImage, mumoryAnnotation: self.mumoryAnnotation)
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
                            .background(GeometryReader { geometry -> Color in
                                DispatchQueue.main.async {
                                    self.tagContainerViewFrame = geometry.frame(in: .global)
                                }
                                return Color.clear
                            })
                        
                        ContentContainerView(contentText: self.$contentText)
                        
                        HStack(spacing: 11) {
                            PhotosPicker(selection: $photoPickerViewModel.imageSelections,
                                         maxSelectionCount: 1,
                                         matching: .images) {
                                
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 75, height: 75)
                                    .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                    .cornerRadius(10)
                                    .overlay(
                                        VStack(spacing: 0) {
                                            (imageURLs.count + photoPickerViewModel.imageSelectionCount == 3 ?  SharedAsset.photoFullIconCreateMumory.swiftUIImage : SharedAsset.photoIconCreateMumory.swiftUIImage)
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                            
                                            HStack(spacing: 0) {
                                                Text("\(imageURLs.count + photoPickerViewModel.imageSelectionCount)")
                                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                                    .foregroundColor(imageURLs.count + photoPickerViewModel.imageSelectionCount >= 1 ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.47, green: 0.47, blue: 0.47))
                                                Text(" / 3")
                                                    .font(Font.custom("Pretendard", size: 14).weight(.medium))
                                                    .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                            }
                                            .multilineTextAlignment(.center)
                                            .padding(.top, 10)
                                        }
                                    )
                            }
                            
                            
                            ForEach(self.imageURLs, id: \.self) { url in
                                
                                ZStack {
                                    AsyncImage(url: URL(string: url)) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .frame(width: 75, height: 75)
                                                .aspectRatio(contentMode: .fill)
                                                .clipped()
                                        case .failure:
                                            Text("Failed to load image")
                                        @unknown default:
                                            Text("Unknown state")
                                        }
                                    }
                                    .frame(width: 75, height: 75)
                                    .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                    .cornerRadius(10)
                                    
                                    Button(action: {
                                        if let indexToRemove = self.imageURLs.firstIndex(of: url) {
                                            self.imageURLs.remove(at: indexToRemove)
                                        }
                                    }) {
                                        SharedAsset.closeButtonCreateMumory.swiftUIImage
                                            .resizable()
                                            .frame(width: 27, height: 27)
                                    }
                                    .offset(x: -51 + 57 + 27, y: -(-51 + 57 + 27))
                                }
                            }
                            
                            if !photoPickerViewModel.selectedImages.isEmpty {
                                
                                ForEach(photoPickerViewModel.selectedImages.indices, id: \.self) { index in
                                    
                                    ZStack {
                                        Image(uiImage: photoPickerViewModel.selectedImages[index])
                                            .resizable()
                                            .frame(width: 75, height: 75)
                                            .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                            .cornerRadius(10)
                                        
                                        Button(action: {
                                            photoPickerViewModel.removeImage(photoPickerViewModel.selectedImages[index])
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onChange(of: photoPickerViewModel.imageSelections) { newValue in
                            print("onChange(of: photoPickerViewModel.imageSelections)")
                            photoPickerViewModel.convertDataToImage(imageURLsCount: imageURLs.count)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                    
                } // VStack
                .padding(.top, 20)
                .padding(.bottom, 50)
                
            } // ScrollView
            .simultaneousGesture(DragGesture().onChanged { i in
                print("simultaneousGesture DragGesture")
                
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            })
            
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
                        .frame(height: 0.7)
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
                .overlay(
                    Rectangle()
                        .inset(by: 0.15)
                        .fill(Color(red: 0.65, green: 0.65, blue: 0.65))
                        .frame(height: 0.5)
                    , alignment: .top
                )
                .highPriorityGesture(DragGesture())
                .offset(y: self.bottomBarHeight)
                .offset(y: self.keyboardResponder.isKeyboardHiddenButtonShown ? -self.keyboardResponder.keyboardHeight - self.bottomBarHeight : 0)
            }
            
            Spacer(minLength: 0)
            
        } // VStack
        .background(SharedAsset.backgroundColor.swiftUIColor)
        .toolbar(.hidden)
        .ignoresSafeArea()
        .calendarPopup(show: self.$isDatePickerShown, yOffset: self.calendarYOffset - appCoordinator.safeAreaInsetsTop) {
            
            DatePicker("", selection: self.$calendarDate, displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .labelsHidden()
                .accentColor(SharedAsset.mainColor.swiftUIColor)
                .background(SharedAsset.backgroundColor.swiftUIColor)
                .preferredColorScheme(.dark)
        }
        .popup(show: self.$isPublishPopUpShown, content: {
            PopUpView(isShown: self.$isPublishPopUpShown, type: .twoButton, title: "수정하시겠습니까?", buttonTitle: "수정", buttonAction: {
                
                mumoryDataViewModel.isUpdating = true
                
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
                    let newMumoryAnnotation = Mumory(id: mumoryAnnotation.id, userDocumentID: "tester", date: self.calendarDate, musicModel: mumoryDataViewModel.choosedMusicModel ?? mumoryAnnotation.musicModel, locationModel: mumoryDataViewModel.choosedLocationModel ?? mumoryAnnotation.locationModel, tags: self.tags, content: self.contentText, imageURLs: self.imageURLs , isPublic: self.isPublic, likes: mumoryAnnotation.likes, comments: mumoryAnnotation.comments)
                    
                    mumoryDataViewModel.updateMumory(newMumoryAnnotation) {

                        mumoryDataViewModel.isUpdating = false
                        mumoryDataViewModel.selectedMumoryAnnotation = newMumoryAnnotation
                        
                        mumoryDataViewModel.choosedMusicModel = nil
                        mumoryDataViewModel.choosedLocationModel = nil
                        self.tags.removeAll()
                        self.contentText.removeAll()
                        photoPickerViewModel.removeAllSelectedImages()
                        self.imageURLs.removeAll()
                        
                        appCoordinator.rootPath.removeLast()
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
                self.isDeletePopUpShown = false
            })
        })
        .popup(show: self.$photoPickerViewModel.isPhotoErrorPopUpShown, content: {
            PopUpView(isShown: self.$photoPickerViewModel.isPhotoErrorPopUpShown, type: .oneButton, title: "사진은 최대 3개까지 첨부할 수 있습니다.", buttonTitle: "확인", buttonAction: {
                self.photoPickerViewModel.isPhotoErrorPopUpShown = false
            })
            
        })
    }
}

