//
//  MumoryDetailEditView.swift
//  Feature
//
//  Created by 다솔 on 2024/01/01.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import PhotosUI

import Core
import Shared


public struct MumoryDetailEditView: View {
    
    var mumoryAnnotation: MumoryAnnotation
    
    @State private var showDatePicker: Bool = false
    @State private var isPublishPopUpShown: Bool = false
    @State private var isPublishErrorPopUpShown: Bool = false
    @State private var isTagErrorPopUpShown: Bool = false
    @State private var isDeletePopUpShown: Bool = false
    
    @GestureState private var dragState = DragState.inactive
//    @State var offsetY = CGFloat(0)
    
    @State private var tags: [String] = []
    @State private var contentText: String = ""
    @State private var imageURLs: [String] = []
    
    @State private var isPublic: Bool = true
    @State private var calendarYOffset: CGFloat = .zero
    @State private var scrollViewOffset: CGFloat = 0
    @State private var tagContainerViewFrame: CGRect = .zero

    @State var date: Date = Date()
    
    @StateObject private var photoPickerViewModel: PhotoPickerViewModel = .init()
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject private var dateManager: DateManager
    
    @Environment(\.dismiss) private var dismiss
    
    public init(mumoryAnnotation: MumoryAnnotation) {
        self.mumoryAnnotation = mumoryAnnotation
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
                        })
                    
                    Spacer()
                    
                    Button(action: {
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
                
                Text("수정하기")
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
                                ContainerView(title: "음악 추가하기", image: SharedAsset.musicIconCreateMumory.swiftUIImage, mumoryAnnotation: self.mumoryAnnotation)
                            }

                            NavigationLink(value: "location") {
                                ContainerView(title: "위치 추가하기", image: SharedAsset.locationIconCreateMumory.swiftUIImage, mumoryAnnotation: self.mumoryAnnotation)
                            }

                            CalendarContainerView(title: "\(dateManager.formattedDate(date: self.date, dateFormat: "yyyy. MM. dd. EEEE"))")
                                .onTapGesture {
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
                                .background(GeometryReader { geometry -> Color in
                                    DispatchQueue.main.async {
                                        self.tagContainerViewFrame = geometry.frame(in: .global)
                                    }
                                    return Color.clear
                                })

                            ContentContainerView(contentText: self.$contentText)

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

            } // ScrollView
            .simultaneousGesture(DragGesture().onChanged { i in
                // 스크롤할 때 바텀시트 움직이는 것 방지?
                print("simultaneousGesture DragGesture")

                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            })
            

            ZStack(alignment: .topLeading) {
                Rectangle()
                    .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.12))
                    .frame(height: 72 + appCoordinator.safeAreaInsetsBottom)
                    .overlay(
                        Rectangle()
                            .inset(by: 0.15)
                            .fill(Color(red: 0.65, green: 0.65, blue: 0.65))
                            .frame(height: 0.5)
                        , alignment: .top
                    )
                
                
                    HStack(spacing: 0) {

                        Group {
                            
                            Text("전체공개")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                                .foregroundColor(self.isPublic ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.76, green: 0.76, blue: 0.76))
                            
                            Spacer().frame(width: 7)
                            
                            Image(uiImage: self.isPublic ? SharedAsset.publicOnCreateMumory.image : SharedAsset.publicOffCreateMumory.image)
                                .frame(width: 17, height: 17)
                            
                            Spacer()
                        }
                        .gesture(TapGesture(count: 1)
                            .onEnded {
                                self.isPublic.toggle()
                            })
                        
                        SharedAsset.keyboardButtonCreateMumory.swiftUIImage
                            .resizable()
                            .frame(width: 26, height: 26)
                    }
                    .padding(.top, 18)
                    .padding(.horizontal, 20)
            } // ZStack
            .offset(y: getUIScreenBounds().height == 667 || getUIScreenBounds().height == 736 ? -33  : -getSafeAreaInsets().bottom - 16)
            .offset(y: -self.appCoordinator.keyboardHeight)
            .highPriorityGesture(DragGesture())
            
        } // VStack
        .background(SharedAsset.backgroundColor.swiftUIColor)
        .padding(.bottom, -appCoordinator.safeAreaInsetsTop - 16)
        .navigationBarBackButtonHidden(true )
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
                        let newMumoryAnnotation = MumoryAnnotation(date: self.date, musicModel: choosedMusicModel, locationModel: choosedLocationModel, tags: tags, content: contentText, imageURLs: self.imageURLs)
                        
                        mumoryDataViewModel.createMumory(newMumoryAnnotation)
                        
                        withAnimation(Animation.easeInOut(duration: 0.2)) {
                            appCoordinator.isCreateMumorySheetShown = false
                        }
                    }
                }
                else {
                    print("else 일리가 없지?")
                }
                

                
                mumoryDataViewModel.choosedMusicModel = nil
                mumoryDataViewModel.choosedLocationModel = nil
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
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
                guard let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                let keyboardHeight = keyboardSize.height
                
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.appCoordinator.keyboardHeight = keyboardSize.height
//                            scrollViewOffset = tagContainerViewFrame.maxY - (getUIScreenBounds().height - keyboardHeight) + 16
                }
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
                DispatchQueue.main.async{
                    withAnimation(.easeInOut(duration: 0.25)) {
                        self.appCoordinator.keyboardHeight = CGFloat.zero
                        //                            scrollViewOffset = 0
                    }
                }
            }
        }
        
//        ZStack {
//            SharedAsset.backgroundColor.swiftUIColor
//
//            VStack(spacing: 0) {
//                ZStack {
//                    HStack {
//                        Button(action: {
//                            withAnimation(Animation.easeInOut(duration: 0.2)) {
//                                appCoordinator.isCreateMumorySheetShown = false
//
//                                mumoryDataViewModel.choosedMusicModel = nil
//                                mumoryDataViewModel.choosedLocationModel = nil
//
//                                appCoordinator.rootPath.removeLast()
//                            }
//                        }) {
//                            Image(uiImage: SharedAsset.closeCreateMumory.image)
//                                .resizable()
//                                .frame(width: 25, height: 25)
//                        }
//
//                        Spacer()
//
//                        Button(action: {
//                            if let choosedMusicModel = mumoryDataViewModel.choosedMusicModel, let choosedLocationModel = mumoryDataViewModel.choosedLocationModel {
////                                let newMumoryAnnotation = MumoryAnnotation(date: Date(), musicModel: choosedMusicModel, locationModel: choosedLocationModel)
////                                mumoryDataViewModel.createdMumoryAnnotation = newMumoryAnnotation
////                                mumoryDataViewModel.mumoryAnnotations.append(newMumoryAnnotation)
//                            }
//
//                            withAnimation(Animation.easeInOut(duration: 0.2)) { // 사라질 때 애니메이션 적용
//                                appCoordinator.isCreateMumorySheetShown = false
//
//                            }
//
//                            mumoryDataViewModel.choosedMusicModel = nil
//                            mumoryDataViewModel.choosedLocationModel = nil
//                        }) {
//                            Rectangle()
//                                .foregroundColor(.clear)
//                                .frame(width: 46, height: 30)
//                                .background(Color(red: 0.85, green: 0.85, blue: 0.85))
//                            //                                .background(Color(red: 0.47, green: 0.47, blue: 0.47)) 미충족
//                                .cornerRadius(31.5)
//                                .overlay(
//                                    Text("완료")
//                                        .font(Font.custom("Pretendard", size: 13).weight(.bold))
//                                        .multilineTextAlignment(.center)
//                                        .foregroundColor(.black)
//                                )
//                        }
//                    } // HStack
//
//                    Text("수정하기") // 추후 재사용 위해 분리
//                        .font(
//                            Font.custom("Pretendard", size: 18)
//                                .weight(.semibold)
//                        )
//                        .multilineTextAlignment(.center)
//                        .foregroundColor(.white)
//                } // ZStack
//                .padding(.top, 16 + appCoordinator.safeAreaInsetsTop)
//                .padding(.bottom, 11)
//
//                ScrollView {
//                    VStack(spacing: 0) {
//                        // MARK: -Search Music
//                        NavigationLink(value: 2) {
//                            HStack(spacing: 16) {
//                                Image(uiImage: SharedAsset.musicCreateMumory.image)
//                                    .resizable()
//                                    .frame(width: 60, height: 60)
//
//                                ZStack {
//                                    Rectangle()
//                                        .foregroundColor(.clear)
//                                        .frame(maxWidth: .infinity)
//                                        .frame(height: 60)
//                                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
//                                        .cornerRadius(15)
//                                    if let choosedMusicModel = mumoryDataViewModel.choosedMusicModel {
//                                        HStack(spacing: 10) {
//                                            Rectangle()
//                                                .foregroundColor(.clear)
//                                                .frame(width: 40, height: 40)
//                                                .background(
//                                                    AsyncImage(url: choosedMusicModel.artworkUrl) { phase in
//                                                        switch phase {
//                                                        case .success(let image):
//                                                            image
//                                                                .resizable()
//                                                                .aspectRatio(contentMode: .fit)
//                                                                .frame(width: 40, height: 40)
//                                                        default:
//                                                            Color.purple
//                                                                .frame(width: 40, height: 40)
//                                                        }
//                                                    }
//                                                )
//                                                .cornerRadius(6)
//
//                                            VStack(spacing: 3) {
//                                                Text(choosedMusicModel.title)
//                                                    .font(
//                                                        Font.custom("Pretendard", size: 15)
//                                                            .weight(.semibold)
//                                                    )
//                                                    .lineLimit(1)
//                                                    .foregroundColor(.white)
//                                                    .frame(maxWidth: .infinity, alignment: .leading)
//
//                                                Text(choosedMusicModel.artist)
//                                                    .font(Font.custom("Pretendard", size: 13))
//                                                    .lineLimit(1)
//                                                    .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
//                                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                            }
//                                            .frame(height: 60)
//                                        } // HStack
//                                        .padding(.horizontal, 15)
//                                    } else {
//                                        Text("음악 추가하기")
//                                            .font(Font.custom("Pretendard", size: 16))
//                                            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
//                                            .frame(maxWidth: .infinity, alignment: .leading)
//                                            .padding(.horizontal, 20)
//                                    }
//                                } // ZStack
//                            } // HStack
//                        } // NavigationLink
//
//                        // MARK: -Underline
//                        Divider()
//                            .frame(height: 0.3)
//                            .background(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
//                            .padding(.top, 16)
//
//                        // MARK: -Search location
//                        HStack(spacing: 16) {
//                            NavigationLink(value: 3) {
//                                Image(uiImage: SharedAsset.locationCreateMumory.image)
//                                    .resizable()
//                                    .frame(width: 60, height: 60)
//                            }
//
//                            NavigationLink(value: 3) {
//                                ZStack {
//                                    Rectangle()
//                                        .foregroundColor(.clear)
//                                        .frame(maxWidth: .infinity)
//                                        .frame(height: 60)
//                                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
//                                        .cornerRadius(15)
//                                    if let choosedLocationModel = mumoryDataViewModel.choosedLocationModel {
//                                        VStack(spacing: 10) {
//                                            Text("\(choosedLocationModel.locationTitle)")
//                                                .font(Font.custom("Pretendard", size: 15))
//                                                .foregroundColor(.white)
//                                                .frame(maxWidth: .infinity, alignment: .leading)
//                                                .lineLimit(1)
//
//                                            Text("\(choosedLocationModel.locationSubtitle)")
//                                                .font(Font.custom("Pretendard", size: 13))
//                                                .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
//                                                .frame(maxWidth: .infinity, alignment: .leading)
//                                                .lineLimit(1)
//                                        }
//                                        .padding(.horizontal, 15)
//                                    } else {
//                                        Text("위치 추가하기")
//                                            .font(Font.custom("Pretendard", size: 16))
//                                            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
//                                            .frame(maxWidth: .infinity, alignment: .leading)
//                                            .lineLimit(1)
//                                            .padding(.horizontal, 20)
//                                    }
//
//                                }
//                            }
//                        }
//                        .padding(.top, 14)
//
//                        // MARK: -Underline
//                        Divider()
//                            .frame(height: 0.5) // ???
//                            .background(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
//                            .padding(.top, 16)
//
//                        // MARK: -Date
//                        ZStack {
//                            Rectangle()
//                                .foregroundColor(.clear)
//                                .frame(maxWidth: .infinity)
//                                .frame(height: 50)
//                                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
//                                .cornerRadius(15)
//
//                            HStack {
//                                Text("\(formattedDate)")
//                                    .font(Font.custom("Pretendard", size: 16).weight(.medium))
//                                    .foregroundColor(.white)
//                                Spacer()
//
//                                Button(action: {
//                                    self.showDatePicker = true
//                                }) {
//                                    Image(uiImage: SharedAsset.calendarCreateMumory.image)
//                                        .resizable()
//                                        .frame(width: 25, height: 25)
//                                }
//                                .popover(isPresented: $showDatePicker, content: {
//                                    DatePicker("", selection: $selectedDate)
//                                        .datePickerStyle(.automatic)
//                                        .presentationDetents([.height(100)])
//                                        .frame(width: 0, height: 0)
//                                        .background(.black)
//                                })
//                            }
//                            .padding(.horizontal, 20)
//                        }
//                        .padding(.top, 14)
//
//                        // MARK: -Tag
//                        // 긴 문자열 수정시 오류
//                        ZStack {
//                            Rectangle()
//                                .foregroundColor(.clear)
//                                .frame(height: 50)
//                                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
//                                .cornerRadius(15)
//
//                            HStack(spacing: 8) {
//                                ForEach(tags.indices, id: \.self) { index in
//                                    TextField("", text: $tags[index], onEditingChanged: { isEditing in
//                                        self.isTagEditing = isEditing
//                                    })
//                                    .font(
//                                        Font.custom("Pretendard", size: 16)
//                                            .weight(.medium)
//                                    )
//                                    .foregroundColor(self.isTagEditing ? .white : Color(red: 0.64, green: 0.51, blue: 0.99))
//                                    .frame(width: min(CGFloat(tags[index].count * 9), (UIScreen.main.bounds.width - 80 - 16) / 3), alignment: .leading)
//                                    .onChange(of: tags[index], perform: { i in
//                                        if i.contains(" ") || i.hasSuffix(" ") {
//                                            let beforeSpace = i.components(separatedBy: " ").first ?? ""
//                                            tags[index] = beforeSpace
//
//                                            self.isCommit = true
//                                        } else if i == "" {
//                                            tags.remove(at: index)
//                                        } else if !i.hasPrefix("#") {
//                                            tags.remove(at: index)
//                                        }
//                                    })
//                                }
//
//
//                                if self.tags.count < 3 {
//                                    CustomTextField(text: $tagText, onCommit: {
//                                        if tagText.first == "#" {
//                                            tags.append(tagText)
//                                            tagText = ""
//                                        }
//                                    }, onEditingChanged: { isEditing in
//                                        self.isEditing = isEditing
//                                    })
//                                    .frame(maxWidth: (UIScreen.main.bounds.width - 80 - 16) / 3, alignment: .leading)
//                                }
//
//                                Spacer(minLength: 0)
//                            } // HStack
//                            .padding(.horizontal, 20)
//
//                            if self.tags.count == 0 {
//                                Text(self.isEditing ? "" : "#을 넣어 기분을 태그해 보세요  (최대 3개)")
//                                    .font(Font.custom("Pretendard", size: 15))
//                                    .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.horizontal, 20)
//                                    .allowsHitTesting(false)
//                            }
//                        } // ZStack
//                        .padding(.top, 15)
//
//                        // MARK: -Content
//                        ZStack(alignment: .topLeading) {
//                            TextEditor(text: $contentText)
//                                .scrollContentBackground(.hidden)
//                                .foregroundColor(Color.white)
//                                .font(.custom("Pretendard", size: 15))
//                                .lineSpacing(5)
//                                .frame(minHeight: 104)
//                                .padding(.leading, 20 - 6)
//                                .padding(.trailing, 20 - 6)
//                                .padding(.vertical, 22 - 8)
//                            //                                .onReceive(contentText.publisher.collect()) {
//                            //                                    let newText = String($0.prefix(60))
//                            //                                    if newText != contentText {
//                            //                                        contentText = newText
//                            //                                    }
//                            //                                }
//                                .onTapGesture {} // VStack의 onTapGesture를 무효화합니다.
//                                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
//                            //                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
//                            //                            isEditing = true
//                            //                        }
//                            //                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
//                            //                            isEditing = false
//                            //                        }
//
//
//                            //                            Text(contentText.count > 0 ? "\(contentText.count)" : "00")
//                            //                                .font(Font.custom("Pretendard", size: 13))
//                            //                                .foregroundColor(.white)
//                            //                                .padding(.trailing, 15)
//                            //                                .padding(.vertical, 22)
//                            //                                .frame(maxWidth: .infinity, alignment: .trailing)
//
//
//                            if self.contentText.isEmpty {
//                                Text("자유롭게 내용을 입력하세요  (60자 이내)")
//                                    .font(Font.custom("Pretendard", size: 15))
//                                    .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
//                                    .allowsHitTesting(false)
//                                    .padding(.leading, 20)
//                                //                                    .padding(.trailing, 42)
//                                    .padding(.vertical, 22)
//                            }
//                        }
//                        .cornerRadius(15)
//                        .padding(.top, 15)
//
//                        // MARK: -Image
//                        HStack(spacing: 10) {
//                            PhotosPicker(selection: $photoPickerViewModel.imageSelections,
//                                         maxSelectionCount: 3,
//                                         matching: .images) {
//                                Rectangle()
//                                    .foregroundColor(.clear)
//                                    .frame(width: 72, height: 72)
//                                    .background(Color(red: 0.12, green: 0.12, blue: 0.12))
//                                    .cornerRadius(10)
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .inset(by: 0.5)
//                                            .stroke(Color(red: 0.47, green: 0.47, blue: 0.47), lineWidth: 1)
//                                    )
//                                    .overlay(
//                                        VStack(spacing: 0) {
//                                            Image(uiImage: SharedAsset.imageCreateMumory.image)
//                                                .resizable()
//                                                .scaledToFit()
//                                                .frame(width: 23.5, height: 23.5)
//
//                                            HStack(spacing: 0) {
//                                                Text("\(photoPickerViewModel.imageSelectionCount)")
//                                                    .font(Font.custom("Pretendard", size: 14).weight(.medium))
//                                                    .foregroundColor(photoPickerViewModel.imageSelectionCount >= 1 ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.47, green: 0.47, blue: 0.47))
//                                                Text(" / 3")
//                                                    .font(Font.custom("Pretendard", size: 14).weight(.medium))
//                                                    .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
//                                            }
//                                            .multilineTextAlignment(.center)
//                                            .padding(.top, 11.25)
//                                        }
//                                    )
//                            }
//
//                            if !photoPickerViewModel.selectedImages.isEmpty {
//                                ForEach(photoPickerViewModel.selectedImages, id: \.self) { image in
//                                    ZStack {
//                                        Image(uiImage: image)
//                                            .resizable()
//                                            .frame(width: 72, height: 72)
//                                            .background(Color(red: 0.12, green: 0.12, blue: 0.12))
//                                            .cornerRadius(10)
//                                            .overlay(
//                                                RoundedRectangle(cornerRadius: 10)
//                                                    .inset(by: 0.5)
//                                                    .stroke(Color(red: 0.47, green: 0.47, blue: 0.47), lineWidth: 1)
//                                            )
//                                        Button(action: {
//                                            photoPickerViewModel.removeImage(image)
//                                        }) {
//                                            Image(systemName: "xmark.circle.fill")
//                                                .resizable()
//                                                .frame(width: 27, height: 27)
//                                                .foregroundColor(.white)
//                                        }
//                                        .offset(x: -51 + 57 + 27, y: -(-51 + 57 + 27))
//                                    }
//                                }
//                            }
//                            Spacer()
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding(.top, 20)
//                        .onChange(of: photoPickerViewModel.imageSelections) { _ in
//                            photoPickerViewModel.convertDataToImage()
//                        }
//                    } // VStack
//                    .padding(.top, 25)
//                    .padding(.bottom, 50)
//                    .frame(width: UIScreen.main.bounds.width - 40)
//
//                } // ScrollView
//                .scrollIndicators(.hidden)
//
//                ZStack {
//                    Rectangle()
//                        .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.12))
//                        .frame(height: 55 + appCoordinator.safeAreaInsetsBottom)
//                        .overlay(
//                            Rectangle()
//                                .fill(Color(red: 0.65, green: 0.65, blue: 0.65))
//                                .frame(height: 0.5),
//                            alignment: .top
//                        )
//                        .padding(.horizontal, -20)
//
//                    HStack(spacing: 7) {
//                        Button(action: {
//                            self.isPublic.toggle()
//                        }) {
//                            Text("전체공개")
//                                .font(
//                                    Font.custom("Pretendard", size: 15)
//                                        .weight(self.isPublic ? .semibold : .medium)
//                                )
//                                .foregroundColor(self.isPublic ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.76, green: 0.76, blue: 0.76))
//                                .padding(.leading, 5)
//
//                            Image(uiImage: self.isPublic ? SharedAsset.publicOnCreateMumory.image : SharedAsset.publicOffCreateMumory.image)
//                                .frame(width: 17, height: 17)
//                        }
//
//                        Spacer()
//                    }
//                } // ZStack
//            } // VStack
//        } // ZStack
//        .frame(width: UIScreen.main.bounds.width - 40)
//        .padding(.horizontal, 20)
//        .background(SharedAsset.backgroundColor.swiftUIColor)
//        .ignoresSafeArea()
//        .navigationBarBackButtonHidden(true)
//        .preferredColorScheme(.dark)
    }
}


struct CustomTextField: UIViewRepresentable {
    
    @Binding var text: String
    
    var onCommit: () -> Void
    var onEditingChanged: ((Bool) -> Void)?
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator

        if let customFont = UIFont(name: "Pretendard", size: 16) {
            textField.font = customFont
            //        textField.font = UIFont.systemFont(ofSize: 36, weight: .medium)
        } else {
            print("폰트 로드에 실패했습니다.")
        }

        textField.textColor = .white
        
//        textField.attributedPlaceholder = NSAttributedString(
//             string: "",
//             attributes: [NSAttributedString.Key.foregroundColor: UIColor.red],
//             font: UIFont(name: "Pretendard", size: 36)
//         )
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextField
        
        init(parent: CustomTextField) {
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

