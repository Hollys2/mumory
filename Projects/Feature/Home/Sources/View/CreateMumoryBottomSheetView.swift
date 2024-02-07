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

import UIKit


public struct CreateMumoryBottomSheetView: View {
    
    @State private var translation: CGSize = .zero
    @State private var isScrollEnabled = true
    @State private var contentText: String = ""
    @State private var isPublic: Bool = true
    @State private var isSatisfied: Bool = false
    
    @StateObject private var photoPickerViewModel: PhotoPickerViewModel = .init()
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    
    public init () {
//        UIScrollView.appearance().bounces = false
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                print("onChanged: \(value.translation.height)")
                if value.translation.height > 0 {
                    DispatchQueue.main.async {
                        translation.height = value.translation.height
                    }
                }
            }
            .onEnded { value in
                print("onEnded: \(value.translation.height)")
                
                withAnimation(Animation.easeInOut(duration: 0.2)) {
                    //                    if value.translation.height > 130 {
                    //                        appCoordinator.isCreateMumorySheetShown = false
                    //
                    //                        mumoryDataViewModel.choosedMusicModel = nil
                    //                        mumoryDataViewModel.choosedLocationModel = nil
                    //                    }
                    translation.height = 0
                }
            }
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
                            withAnimation(Animation.easeInOut(duration: 0.2)) { // 사라질 때 애니메이션 적용
                                appCoordinator.isCreateMumorySheetShown = false
                                
                                mumoryDataViewModel.choosedMusicModel = nil
                                mumoryDataViewModel.choosedLocationModel = nil
                            }
                        })
                    
                    Spacer()
                    
                    Button(action: {
                        if let choosedMusicModel = mumoryDataViewModel.choosedMusicModel, let choosedLocationModel = mumoryDataViewModel.choosedLocationModel {
                            let newMumoryAnnotation = MumoryAnnotation(date: Date(), musicModel: choosedMusicModel, locationModel: choosedLocationModel)
//                            mumoryDataViewModel.createdMumoryAnnotation = newMumoryAnnotation
//                            mumoryDataViewModel.mumoryAnnotations.append(newMumoryAnnotation)
                            mumoryDataViewModel.createMumory(newMumoryAnnotation)
                        }
                        
                        withAnimation(Animation.easeInOut(duration: 0.2)) { // 사라질 때 애니메이션 적용
                            appCoordinator.isCreateMumorySheetShown = false
                        }
                        
                        mumoryDataViewModel.choosedMusicModel = nil
                        mumoryDataViewModel.choosedLocationModel = nil
                    }) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 46, height: 30)
                            .background(isSatisfied ? Color(red: 0.85, green: 0.85, blue: 0.85) : Color(red: 0.47, green: 0.47, blue: 0.47))
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
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 0) {
                    
                    VStack(spacing: 16) {
                        
                        NavigationLink(value: "music") {
                        
                            ContainerView(title: "음악 추가하기", image: SharedAsset.musicIconCreateMumory.swiftUIImage)
                        }
                        
                        NavigationLink(value: "location") {
                            
                            ContainerView(title: "위치 추가하기", image: SharedAsset.locationIconCreateMumory.swiftUIImage)
                        }

                        CalendarContainerView(title: "2023. 10. 02. 월요일")
                    }
                    .padding(.horizontal, 20)
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 6)
                        .background(.black)
                        .padding(.vertical, 18)
                    
                    VStack(spacing: 16) {
                        
                        TagContainerView(title: "#때끄")
                        
                        ContentContainerView(title: "하이")
                        
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
                    .padding(.bottom, 300)
                    
                    
                    
                    
                    
                    NavigationLink(value: "music") {
                        HStack(spacing: 16) {
                            Image(uiImage: SharedAsset.musicCreateMumory.image)
                                .resizable()
                                .frame(width: 60, height: 60)
                            
                            
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                    .cornerRadius(15)
                                
                                if let choosedMusicModel = mumoryDataViewModel.choosedMusicModel {
                                    HStack(spacing: 10) {
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(width: 40, height: 40)
                                            .background(
                                                AsyncImage(url: choosedMusicModel.artworkUrl) { phase in
                                                    switch phase {
                                                    case .success(let image):
                                                        image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 40, height: 40)
                                                    default:
                                                        Color.purple
                                                            .frame(width: 40, height: 40)
                                                    }
                                                }
                                            )
                                            .cornerRadius(6)
                                        
                                        VStack(spacing: 3) {
                                            Text(choosedMusicModel.title)
                                                .font(
                                                    Font.custom("Pretendard", size: 15)
                                                        .weight(.semibold)
                                                )
                                                .lineLimit(1)
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Text(choosedMusicModel.artist)
                                                .font(Font.custom("Pretendard", size: 13))
                                                .lineLimit(1)
                                                .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .frame(height: 60)
                                    } // HStack
                                    .padding(.horizontal, 15)
                                } else {
                                    Text("음악 추가하기")
                                        .font(Font.custom("Pretendard", size: 16))
                                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 20)
                                }
                            } // ZStack
                        } // HStack
                    } // NavigationLink
                    
                    // MARK: -Search location
                    HStack(spacing: 16) {
                        Button(action: {
                            appCoordinator.rootPath.append("location")
//                            appCoordinator.createMumoryPath.append(3)
                        }) {
                            Image(uiImage: SharedAsset.locationCreateMumory.image)
                                .resizable()
                                .frame(width: 60, height: 60)
                        }
                        
                        NavigationLink(value: "location") {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                    .cornerRadius(15)
                                
                                if let choosedLocationModel = mumoryDataViewModel.choosedLocationModel {
                                    VStack(spacing: 10) {
                                        Text("\(choosedLocationModel.locationTitle)")
                                            .font(Font.custom("Pretendard", size: 15))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .lineLimit(1)
                                        
                                        Text("\(choosedLocationModel.locationSubtitle)")
                                            .font(Font.custom("Pretendard", size: 13))
                                            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .lineLimit(1)
                                    }
                                    .padding(.horizontal, 15)
                                } else {
                                    Text("위치 추가하기")
                                        .font(Font.custom("Pretendard", size: 16))
                                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(1)
                                        .padding(.horizontal, 20)
                                }
                                
                            }
                        }
                    }
                    .padding(.top, 14)
                    
                    // MARK: -Date
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                            .cornerRadius(15)
                        
                        HStack {
                            Text("2023. 10. 02. 월요일")
                                .font(Font.custom("Pretendard", size: 16).weight(.medium))
                                .foregroundColor(.white)
                            Spacer()
                            
                            Button(action: {
                                //                                    self.showDatePicker = true
                            }) {
                                Image(uiImage: SharedAsset.calendarCreateMumory.image)
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                            //                                .popover(isPresented: $showDatePicker, content: {
                            //                                    DatePicker("", selection: $date)
                            //                                        .datePickerStyle(GraphicalDatePickerStyle())
                            //                                        .labelsHidden()
                            //                                        .frame(width: 100, height: 100)
                            //                                        .padding()
                            //                                })
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 14)
                    
                    // MARK: -Tag
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                            .cornerRadius(15)
                        
                        Text("#을 넣어 기분을 태그해 보세요  (최대 3개)")
                            .font(Font.custom("Pretendard", size: 15))
                            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 15)
                    
                    // MARK: -Content
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $contentText)
                            .scrollContentBackground(.hidden)
                            .foregroundColor(Color.white)
                            .font(.custom("Pretendard", size: 15))
                            .lineSpacing(5)
                            .frame(minHeight: 104)
                            .padding(.leading, 20 - 6)
                            .padding(.trailing, 42 - 6)
                            .padding(.vertical, 22 - 8)
                            .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                        //                                .onTapGesture {} // VStack의 onTapGesture를 무효화합니다.
                        //                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                        //                            isEditing = true
                        //                        }
                        //                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                        //                            isEditing = false
                        //                        }
                        
                        if self.contentText.isEmpty {
                            Text("자유롭게 내용을 입력하세요  (60자 이내)")
                                .font(Font.custom("Pretendard", size: 15))
                                .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                .allowsHitTesting(false)
                                .padding(.leading, 20)
                                .padding(.vertical, 22)
                        }
                    }
                    .cornerRadius(15)
                    .padding(.top, 15)
                    
                    // MARK: -Image
                    HStack(spacing: 10) {
                        PhotosPicker(selection: $photoPickerViewModel.imageSelections,
                                     maxSelectionCount: 3,
                                     matching: .images) {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 72, height: 72)
                                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .inset(by: 0.5)
                                        .stroke(Color(red: 0.47, green: 0.47, blue: 0.47), lineWidth: 1)
                                )
                                .overlay(
                                    VStack(spacing: 0) {
                                        Image(uiImage: SharedAsset.imageCreateMumory.image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 23.5, height: 23.5)
                                        
                                        HStack(spacing: 0) {
                                            Text("\(photoPickerViewModel.imageSelectionCount)")
                                                .font(Font.custom("Pretendard", size: 14).weight(.medium))
                                                .foregroundColor(photoPickerViewModel.imageSelectionCount >= 1 ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.47, green: 0.47, blue: 0.47))
                                            Text(" / 3")
                                                .font(Font.custom("Pretendard", size: 14).weight(.medium))
                                                .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                        }
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 11.25)
                                    }
                                )
                        }
                        
                        if !photoPickerViewModel.selectedImages.isEmpty {
                            ForEach(photoPickerViewModel.selectedImages, id: \.self) { image in
                                ZStack {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 72, height: 72)
                                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .inset(by: 0.5)
                                                .stroke(Color(red: 0.47, green: 0.47, blue: 0.47), lineWidth: 1)
                                        )
                                    Button(action: {
                                        photoPickerViewModel.removeImage(image)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .resizable()
                                            .frame(width: 27, height: 27)
                                            .foregroundColor(.white)
                                    }
                                    .offset(x: -51 + 57 + 27, y: -(-51 + 57 + 27))
                                }
                            }
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    //                            .padding(.bottom, 111)
                    .onChange(of: photoPickerViewModel.imageSelections) { _ in
                        photoPickerViewModel.convertDataToImage()
                    }
                } // VStack
                .padding(.top, 20)
                .padding(.bottom, 50)
            } // ScrollView
            .gesture(TapGesture(count: 1))
            //            .simultaneousGesture(TapGesture(count: 1))
            
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.12))
                    .frame(width: UIScreen.main.bounds.width, height: 72 + appCoordinator.safeAreaInsetsBottom)
                    .overlay(
                        Rectangle()
                            .inset(by: 0.15)
                            .fill(Color(red: 0.65, green: 0.65, blue: 0.65))
                            .frame(height: 0.5)
                        , alignment: .top
                    )
                
                
                Button(action: {
                    self.isPublic.toggle()
                }) {
                    HStack(spacing: 0) {
                        Spacer().frame(width: 20)
                        
                        Text("전체공개")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                            .foregroundColor(self.isPublic ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.76, green: 0.76, blue: 0.76))
                        
                        Spacer().frame(width: 7)
                        
                        Image(uiImage: self.isPublic ? SharedAsset.publicOnCreateMumory.image : SharedAsset.publicOffCreateMumory.image)
                            .frame(width: 17, height: 17)
                        
                        Spacer()
                    }
                    .padding(.top, 18)
                }
            } // ZStack
        } // VStack
        .background(SharedAsset.backgroundColor.swiftUIColor)
        .cornerRadius(23, corners: [.topLeft, .topRight])
        .padding(.top, self.appCoordinator.safeAreaInsetsTop + 16)
        .ignoresSafeArea()
        .onDisappear {
//            mumoryDataViewModel.choosedMusicModel = nil
//            mumoryDataViewModel.choosedLocationModel = nil
        }
    }
}
    
struct ContainerView: View {
    
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    let title: String
    let image: Image

    init(title: String, image: Image) {
        self.title = title
        self.image = image
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
                    
                    if let choosedMusicModel = self.mumoryDataViewModel.choosedMusicModel {
                        
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 36, height: 36)
                            .background(
                                AsyncImage(url: choosedMusicModel.artworkUrl) { phase in
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
                            
                            Text("\(choosedMusicModel.title)")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .frame(width: getUIScreenBounds().width * 0.464, alignment: .leading)
                            
                            Text("\(choosedMusicModel.artist)")
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
                } else {
                    
                    if let choosedLocationModel = mumoryDataViewModel.choosedLocationModel {
                        
                        VStack(spacing: 5) {
                            
                            Text("\(choosedLocationModel.locationTitle)")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .frame(width: getUIScreenBounds().width * 0.587, alignment: .leading)
                            
                            Text("\(choosedLocationModel.locationSubtitle)")
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
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 17)
        }
    }
}

struct CalendarContainerView: View {
    
    let title: String

    init(title: String) {
        self.title = title
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
                
                Text("\(title)")
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
    
    let title: String

    init(title: String) {
        self.title = title
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
                
                Text("태그를 입력하세요. (5글자 이내, 최대 3개)")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                    .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                
//                Text("#태그태그태")
//                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
//                    .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 17)
        }
    }
}

struct ContentContainerView: View {
    
    let title: String

    init(title: String) {
        self.title = title
    }
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            
            Rectangle()
                .foregroundColor(.clear)
                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                .frame(minHeight: getUIScreenBounds().height == 667 ? 60 : 111)
                .cornerRadius(15)
            
            HStack(spacing: 0) {
                
                SharedAsset.contentIconCreateMumory.swiftUIImage
                    .resizable()
                    .frame(width: 26, height: 26)
                
                Spacer().frame(width: 17)
                
                Text("자유롭게 내용을 입력하세요.")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                    .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                
//                Text("내용내용내용내용옹내용일상일상일상내용내용내용내용옹내용일상일상일상내용내용내용내용옹내용일상일내용내용내용내용옹")
//                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
//                    .kerning(0.24)
//                    .foregroundColor(.white)
//                    .frame(width: 270, alignment: .topLeading)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 17)
        }
    }
}

struct CreateMumoryBottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        let appCoordinator = AppCoordinator()
        let mumoryDataViewModel = MumoryDataViewModel()
        CreateMumoryBottomSheetView()
            .environmentObject(appCoordinator)
            .environmentObject(mumoryDataViewModel)
    }
}
