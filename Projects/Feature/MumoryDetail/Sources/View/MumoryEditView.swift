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
    
    @State private var isDatePickerShown: Bool = false
    
    @State private var isPublic: Bool
    @State private var tags: [String]
    @State private var contentText: String
    @State private var imageURLs: [String]
    
    @State private var photoSelections: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    
    @State private var isFirst: Bool = true
    
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject private var keyboardResponder: KeyboardResponder
    @EnvironmentObject private var playerViewModel: PlayerViewModel
    
    private var mumory: Mumory

    public init(mumory: Mumory) {
        self.mumory = mumory
        self._tags = State(initialValue: mumory.tags ?? [])
        self._contentText = State(initialValue: mumory.content ?? "")
        self._imageURLs = State(initialValue: mumory.imageURLs ?? [])
        self._isPublic = State(initialValue: mumory.isPublic)
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
                                self.appCoordinator.draftMumorySong = nil
                                self.appCoordinator.draftMumoryLocation = nil
                                self.appCoordinator.rootPath.removeLast()
                            })
                        
                        Spacer()
                        
                        Button(action: {
                            self.appCoordinator.popUp = .editMumory(action: self.editMumoryAction)
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
                .padding(.horizontal, 20)
                
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            VStack(spacing: 16) {
                                NavigationLink(value: "music") {
                                    ContainerView(title: "음악 추가하기", image: SharedAsset.musicIconCreateMumory.swiftUIImage, mumoryAnnotation: self.mumory)
                                }
                                
                                NavigationLink(value: "location") {
                                    ContainerView(title: "위치 추가하기", image: SharedAsset.locationIconCreateMumory.swiftUIImage, mumoryAnnotation: self.mumory)
                                }
                                
                                CalendarContainerView(date: self.$appCoordinator.selectedDate)
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
                                                 maxSelectionCount: 3 - self.imageURLs.count,
                                                 matching: .images) {
                                        VStack(spacing: 0) {
                                            (self.selectedImages.count + self.imageURLs.count == 3 ?  SharedAsset.photoFullIconCreateMumory.swiftUIImage : SharedAsset.photoIconCreateMumory.swiftUIImage)
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                                .offset(y: 1)
                                            
                                            Spacer(minLength: 0)
                                            
                                            HStack(spacing: 0) {
                                                Text("\(self.selectedImages.count + self.imageURLs.count)")
                                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                                    .foregroundColor(self.selectedImages.count + self.imageURLs.count > 0 ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.47, green: 0.47, blue: 0.47))
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
                                                 .disabled(self.selectedImages.count + self.imageURLs.count == 3)
                                    
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
                                                            .scaledToFill()
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
                                    
                                    if !self.selectedImages.isEmpty {
                                        ForEach(self.selectedImages.indices, id: \.self) { index in
                                            ZStack {
                                                Image(uiImage: self.selectedImages[index])
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 75, height: 75)
                                                    .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                                    .cornerRadius(10)
                                                
                                                Button(action: {
                                                    self.selectedImages.remove(at: index)
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
                                .onChange(of: self.photoSelections) { newValue in
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
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 50)
                            
                        } // VStack
                        .padding(.top, 20)
                        .padding(.bottom, 50 + self.getSafeAreaInsets().bottom)
                        .padding(.bottom, self.keyboardResponder.keyboardHeight != .zero ? self.keyboardResponder.keyboardHeight + 55 : 0)
                    } // ScrollView
                    .scrollIndicators(.hidden)
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
                .onTapGesture {
                    self.isPublic.toggle()
                }
                
                Spacer()
                
                Button(action: {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    SharedAsset.keyboardButtonCreateMumory.swiftUIImage
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .opacity(self.keyboardResponder.isKeyboardHiddenButtonShown ? 1 : 0)
                
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
        .toolbar(.hidden)
        .onAppear {
            print("@FUCK MumoryEditView onAppear")
            if self.isFirst {
                self.appCoordinator.selectedDate = self.mumory.date
                self.isFirst = false
            }
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
    
    private func editMumoryAction() {
        self.appCoordinator.popUp = .none
        
        guard let mumoryId = self.mumory.id else { return }
        
        self.appCoordinator.isLoading = true
        
        Task {
            self.imageURLs += await PhotoPickerManager.uploadAllImages(selectedImages: self.selectedImages)
            
            let newMumory = Mumory(uId: self.currentUserViewModel.user.uId, date: self.appCoordinator.selectedDate, song: self.appCoordinator.draftMumorySong ?? self.mumory.song, location: self.appCoordinator.draftMumoryLocation ?? self.mumory.location, isPublic: self.isPublic, tags: self.tags, content: self.contentText, imageURLs: self.imageURLs, likes: self.mumory.likes, commentCount: self.mumory.commentCount)
            
            self.currentUserViewModel.mumoryViewModel.updateMumory(mumoryId: mumoryId, mumory: newMumory) { result in
                switch result {
                case .success():
                    print("SUCCESS updateMumory!")
                case .failure(let error):
                    print("ERROR updateMumory: \(error.localizedDescription)")
                }
                
                self.appCoordinator.draftMumorySong = nil
                self.appCoordinator.draftMumoryLocation = nil
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: {
                    self.appCoordinator.rootPath.removeLast()
                    self.appCoordinator.isLoading = false
                })
            }
        }
    }
}
