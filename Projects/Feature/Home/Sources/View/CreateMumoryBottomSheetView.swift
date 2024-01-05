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
    
    @State private var translation: CGSize = .zero
    @State private var isScrollEnabled = true
    @State private var contentText: String = ""
    @State private var isPublic: Bool = true
    
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
            // MARK: Top bar
            Group {
                Spacer().frame(height: 12)
                
                Image(uiImage: SharedAsset.dragIndicator.image)
                    .resizable()
                    .frame(width: 47, height: 4)
                
                Spacer().frame(height: 12)
                
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
                                mumoryDataViewModel.createdMumoryAnnotation = newMumoryAnnotation
                                mumoryDataViewModel.mumoryAnnotations.append(newMumoryAnnotation)
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
                                .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                                .cornerRadius(31.5)
                                .overlay(
                                    Text("게시")
                                        .font(Font.custom("Pretendard", size: 13).weight(.bold))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.black)
                                )
                                .allowsHitTesting(true)
                            
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
                
                
                Spacer().frame(height: 9)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // MARK: -Search Music
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
                    
                    // MARK: -Underline
                    Divider()
                        .frame(height: 0.3)
                        .background(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                        .padding(.top, 16)
                    
                    // MARK: -Search location
                    HStack(spacing: 16) {
                        Button(action: {
                            appCoordinator.rootPath.append("location")
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
                .padding(.top, 25)
                .padding(.bottom, 50)
            } // ScrollView
            .gesture(TapGesture(count: 1))
            //            .simultaneousGesture(TapGesture(count: 1))
            
            ZStack {
                Rectangle()
                    .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.12))
                    .frame(width: UIScreen.main.bounds.width, height: 55 + appCoordinator.safeAreaInsetsBottom)
                    .overlay(
                        Rectangle()
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
                            .font(
                                Font.custom("Pretendard", size: 15)
                                    .weight(.semibold)
                            )
                            .foregroundColor(self.isPublic ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.76, green: 0.76, blue: 0.76))
                        
                        Spacer().frame(width: 7)
                        
                        Image(uiImage: self.isPublic ? SharedAsset.publicOnCreateMumory.image : SharedAsset.publicOffCreateMumory.image)
                            .frame(width: 17, height: 17)
                        
                        
                        Spacer()
                    }
                }
            } // ZStack
        } // VStack
        .padding(.horizontal, 20)
        .frame(width: UIScreen.main.bounds.width)
        .background(SharedAsset.backgroundColor.swiftUIColor)
        .cornerRadius(23, corners: [.topLeft, .topRight])
        .padding(.top, appCoordinator.safeAreaInsetsTop + 16)
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
