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


@available(iOS 16.0, *)
public struct CreateMumoryBottomSheetView: View {
    
    @State private var contentText: String = ""
    @State private var isPublic: Bool = true
    
    @StateObject private var photoPickerViewModel: PhotoPickerViewModel = .init()
    
    @EnvironmentObject private var locationViewModel: LocationViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var mumoryDataModel: MumoryDataViewModel
    
    @GestureState var dragAmount = CGSize.zero
    @State private var translation: CGSize = .zero
    
    @State var annotationItem: MumoryModel?
    
    
    public init() {}
    
    public var body: some View {
        NavigationStack(path: self.$appCoordinator.path) {
            ZStack {
                SharedAsset.backgroundColor.swiftUIColor
                
                VStack(spacing: 0) {
                    Image(uiImage: SharedAsset.dragIndicator.image)
                        .padding(.top, 14)
                        .frame(maxWidth: .infinity)
                        .gesture(
                            DragGesture()
                                .updating($dragAmount) { value, state, _ in
                                    if value.translation.height > 0 {
                                        translation.height = value.translation.height
                                    }
                                }
                                .onEnded { value in
                                    withAnimation(Animation.easeInOut(duration: 0.1)) {
                                        if value.translation.height > 130 {
                                            appCoordinator.isCreateMumorySheetShown = false
                                        }
                                        translation.height = 0
                                    }
                                }
                        )
                    
                    ZStack {
                        HStack {
                            Button(action: {
                                withAnimation(Animation.easeInOut(duration: 0.2)) { // 사라질 때 애니메이션 적용
                                    appCoordinator.isCreateMumorySheetShown = false
                                }
                            }) {
                                Image(uiImage: SharedAsset.closeCreateMumory.image)
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                if let x = locationViewModel.choosedMumoryModel {
                                    let newMumoryModel = MumoryModel(locationTitle: x.locationTitle, locationSubtitle: x.locationSubtitle, coordinate: x.coordinate)
                                    print("x: \(x.coordinate)")
                                    let newMumoryAnnotation = MumoryAnnotation(coordinate: x.coordinate!)
                                    mumoryDataModel.mumoryAnnotations.append(newMumoryAnnotation)
                                }
                             
                                withAnimation(Animation.easeInOut(duration: 0.2)) { // 사라질 때 애니메이션 적용
                                    appCoordinator.isCreateMumorySheetShown = false
                                }
                            }) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 46, height: 30)
                                    .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                                    .cornerRadius(31.5)
                                    .overlay(
                                        Text("게시")
                                            .font(Font.custom("Pretendard", size: 13).weight(.bold))
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.black)
                                    )
                            }
                        } // HStack
                        
                        Text("뮤모리 만들기") // 추후 재사용 위해 분리
                            .font(
                                Font.custom("Pretendard", size: 18)
                                    .weight(.semibold)
                            )
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                    } // ZStack
                    .padding(.top, 12)
                    .background(SharedAsset.backgroundColor.swiftUIColor) // 색이 존재해야 제스처 동작함
                    .gesture(
                        DragGesture()
                            .updating($dragAmount) { value, state, _ in
                                if value.translation.height > 0 {
                                    translation.height = value.translation.height
                                }
                            }
                            .onEnded { value in
                                withAnimation(Animation.easeInOut(duration: 0.1)) {
                                    if value.translation.height > 130 {
                                        appCoordinator.isCreateMumorySheetShown = false
                                    }
                                    translation.height = 0
                                }
                            }
                    )
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            // MARK: -Search Music
                            NavigationLink(value: 0) {
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
                                        
                                        Text("음악 추가하기")
                                            .font(Font.custom("Pretendard", size: 16))
                                            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 20)
                                    }
                                }
                            }
                            
                            // MARK: -Underline
                            Divider()
                                .frame(height: 0.3)
                                .background(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                                .padding(.top, 16)
                            
                            // MARK: -Search location
                            HStack(spacing: 16) {
                                NavigationLink(value: 1) {
                                    Image(uiImage: SharedAsset.locationCreateMumory.image)
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                }
                                
                                NavigationLink(value: 1) {
                                    ZStack {
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 60)
                                            .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                            .cornerRadius(15)
                                        if let choosedMumoryModel = locationViewModel.choosedMumoryModel {
                                            VStack(spacing: 10) {
                                                Text("\(choosedMumoryModel.locationTitle!)")
                                                    .font(Font.custom("Pretendard", size: 15))
                                                    .foregroundColor(.white)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .lineLimit(1)
                                                
                                                Text("\(choosedMumoryModel.locationSubtitle!)")
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
                            
                            // MARK: -Underline
                            Divider()
                                .frame(height: 0.5) // ???
                                .background(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                                .padding(.top, 16)
                            
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
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 104)
                                    .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                
                                TextEditor(text: $contentText)
                                    .frame(maxWidth: .infinity)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .foregroundColor(Color.white)
                                    .font(.custom("Pretendard", size: 15))
                                    .lineSpacing(5)
                                    .padding(.leading, 20 - 6)
                                    .padding(.trailing, 42 - 6)
                                    .padding(.vertical, 22 - 8)
                                    .onReceive(contentText.publisher.collect()) {
                                        let newText = String($0.prefix(60))
                                        if newText != contentText {
                                            contentText = newText
                                        }
                                    }
                                    .onTapGesture {} // VStack의 onTapGesture를 무효화합니다.
                                //                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                                //                            isEditing = true
                                //                        }
                                //                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                                //                            isEditing = false
                                //                        }
                                
                                
                                Text(contentText.count > 0 ? "\(contentText.count)" : "00")
                                    .font(Font.custom("Pretendard", size: 13))
                                    .foregroundColor(.white)
                                    .padding(.trailing, 15)
                                    .padding(.vertical, 22)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                
                                
                                if self.contentText.isEmpty {
                                    Text("자유롭게 내용을 입력하세요  (60자 이내)")
                                        .font(Font.custom("Pretendard", size: 15))
                                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                        .allowsHitTesting(false)
                                        .padding(.leading, 20)
                                        .padding(.trailing, 42)
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
                        .padding(.top, 25)
                        .padding(.bottom, 50)
                        
                    } // ScrollView
                    .scrollIndicators(.hidden)
                    .padding(.top, 11)
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                            .overlay(
                                Rectangle()
                                    .fill(Color(red: 0.65, green: 0.65, blue: 0.65))
                                    .frame(height: 0.5),
                                alignment: .top
                            )
                            .padding(.horizontal, -20)
                        
                        
                        HStack(spacing: 7) {
                            Button(action: {
                                self.isPublic.toggle()
                            }) {
                                if self.isPublic {
                                    Text("전체공개")
                                        .font(
                                            Font.custom("Pretendard", size: 15)
                                                .weight(.semibold)
                                        )
                                        .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                                    
                                    Image(uiImage: SharedAsset.publicOnCreateMumory.image)
                                        .frame(width: 17, height: 17)
                                } else {
                                    Text("전체공개")
                                        .font(
                                            Font.custom("Pretendard", size: 15)
                                                .weight(.medium)
                                        )
                                        .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                    
                                    Image(uiImage: SharedAsset.publicOffCreateMumory.image)
                                        .frame(width: 17, height: 17)
                                }
                            }
                            Spacer()
                        }
                        .padding(.bottom, 100 - 19 - 19 - 18)
                    }
                } // VStack
            } // ZStack
            .padding(.horizontal, 20)
            .background(SharedAsset.backgroundColor.swiftUIColor)
            .ignoresSafeArea()
            .onDisappear {
                locationViewModel.choosedMumoryModel = nil
            }
            .navigationDestination(for: Int.self, destination: { i in // NavigationStack 안에 있어야 동작함
                if i == 0 {
                    SearchMusicView()
                } else if i == 1 {
                    SearchLocationView(translation: $translation)
                } else if i == 2 {
                    SearchLocationMapView()
                }
            })
        } // NavigationStack
        .cornerRadius(23, corners: [.topLeft, .topRight])
        .offset(y: translation.height + 36) // withAnimation과 연관 있음
        .ignoresSafeArea()
    }
}


//Button("SearchLocationView") {
//    appCoordinator.isNavigationStackShown = false
//    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//        appCoordinator.isSearchLocationViewShown = true
//    }
//}
//
//Button("SearchLocationMapView") {
//    appCoordinator.isNavigationStackShown = true
//
//    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//        withAnimation(Animation.easeInOut(duration: 0.2)) {
//            appCoordinator.isCreateMumorySheetShown = false
//        }
//    }
//
//    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//        appCoordinator.isSearchLocationMapViewShown = true
//    }
//}

//@available(iOS 16.0, *)
//struct CreateMumoryBottomSheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        let appCoordinator = AppCoordinator()
//        CreateMumoryBottomSheetView(isShown: .constant(false))
//            .environmentObject(appCoordinator)
//    }
//}
