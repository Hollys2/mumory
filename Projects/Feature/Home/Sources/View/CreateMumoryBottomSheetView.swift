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

struct CreateMumoryBottomSheet: Hashable {
    let title: String
}

@available(iOS 16.0, *)
public struct CreateMumoryBottomSheetView: View {
    
//    @State private var translation: CGSize = CGSize(width: 0, height: 0)
    @State private var contentText: String = ""
    @State private var isPublic: Bool = true
    
    @StateObject private var photoPickerViewModel = PhotoPickerViewModel()
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @StateObject var locationManager: LocationManager = .init()
    @StateObject var mapViewModel: MapViewModel = .init()
    @StateObject var viewModel: ContentViewModel = .init()
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let address: AddressResult = AddressResult(title: "타이틀2", subtitle: "서브타이틀2")
    
    @GestureState var dragAmount = CGSize.zero
    @State private var translation: CGSize = .zero
    
    @State private var path: NavigationPath = NavigationPath()
    
    
    var createMumoryBottomSheets: [CreateMumoryBottomSheet] = [.init(title: "음악 추가"),
                                                               .init(title: "위치 추가")]
    
    public init() {
    }
    
    public var body: some View {
        NavigationStack(path: $path) {
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
                            NavigationLink(value: createMumoryBottomSheets[0]) {
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
                            //                            .navigationDestination(for: CreateMumoryBottomSheet.self, destination: { _ in SearchMusicView()})
                            
                            // MARK: -Underline
                            Divider()
                                .frame(height: 0.3)
                                .background(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                                .padding(.top, 16)
                            
                            // MARK: -Search location
                            NavigationLink(isActive: $appCoordinator.isSearchLocationViewShown, destination: { SearchLocationView(translation: $translation) }, label: {
                                EmptyView()
                            })
                            
                            HStack(spacing: 16) {
                                Image(uiImage: SharedAsset.locationCreateMumory.image)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .onTapGesture {
                                        appCoordinator.isSearchLocationViewShown = true
                                    }
                                
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 60)
                                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                        .cornerRadius(15)
                                    
                                    Text(mapViewModel.address.isEmpty ? "위치 추가하기" : "\(mapViewModel.address)")
                                        .font(Font.custom("Pretendard", size: 16))
                                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(1)
                                        .padding(.horizontal, 20)
                                }
                                .onTapGesture {
                                    appCoordinator.isSearchLocationViewShown = true
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
                                                //                                    .offset(y: -(75 - 23.5) / 2 + 15.25)
                                                //                                .padding(.bottom, 36.25)
                                                
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
                        //                        .padding(.horizontal, -20 + 25)
                    }
                    //                    Button("Close Sheet") {
                    //                        withAnimation(Animation.easeInOut(duration: 0.3)) {
                    //                            appCoordinator.isCreateMumorySheetShown = false
                    //                        }
                    //                    }
                    //
                    //                    Button("SearchLocationView") {
                    //                        appCoordinator.isNavigationStackShown = false
                    //                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    //                            appCoordinator.isSearchLocationViewShown = true
                    //                        }
                    //                    }
                    //
                    //                    Button("SearchLocationMapView") {
                    //                        appCoordinator.isNavigationStackShown = true
                    //
                    //                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    //                            withAnimation(Animation.easeInOut(duration: 0.2)) {
                    //                                appCoordinator.isCreateMumorySheetShown = false
                    //                            }
                    //                        }
                    //
                    //                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    //                            appCoordinator.isSearchLocationMapViewShown = true
                    //                        }
                    //                    }
                    
                } // VStack
                
                //                NavigationLink(destination: SearchLocationView(), isActive: $appCoordinator.isSearchLocationViewShown) {
                //                    EmptyView()
                //                }
                
                //                NavigationLink(destination: SearchLocationMapView(address: address), isActive: $appCoordinator.isSearchLocationMapViewShown) {
                //                    EmptyView()
                //                }
                
                //                NavigationLink(value: <#T##(Decodable & Encodable & Hashable)?#>, label: <#T##() -> _#>)
                //                Button(action: {
                //                    path.append("1")
                //                }, label: {
                //                    Rectangle()
                //                        .frame(width: 200, height: 50)
                //                        .foregroundColor(.orange)
                //                })
            } // ZStack
            .padding(.horizontal, 20)
            .background(SharedAsset.backgroundColor.swiftUIColor)
            .ignoresSafeArea()
//            .navigationDestination(for: CreateMumoryBottomSheet.self, destination: { sheet in
//                if sheet.title == "음악 추가" {
//                    SearchMusicView()
//                } else {
//                    SearchLocationView(mapViewModel: mapViewModel)
//                }
//            })
            
            
        } // NavigationStack
        .cornerRadius(23, corners: [.topLeft, .topRight])
        .offset(y: translation.height + 36) // withAnimation과 연관 있음
//        .offset(y: appCoordinator.isCreateMumorySheetShown ? 36 + dragAmount.height : UIScreen.main.bounds.height) // withAnimation과 연관 있음
        .ignoresSafeArea()
        .navigationDestination(isPresented: $appCoordinator.isSearchLocationMapViewShown, destination: {SearchLocationMapView(address: address)})
    }
}

//@available(iOS 16.0, *)
//struct CreateMumoryBottomSheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        let appCoordinator = AppCoordinator()
//        CreateMumoryBottomSheetView(isShown: .constant(false))
//            .environmentObject(appCoordinator)
//    }
//}
