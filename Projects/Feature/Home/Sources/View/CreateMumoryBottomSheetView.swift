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
        
    @Binding private var showDatePicker: Bool

    @State private var contentText: String = ""
    @State private var isPublic: Bool = true
    @State private var calendarYOffset: CGFloat = .zero
    
    @State private var date: Date = Date()
    
//    {
//
//        var components = DateComponents()
//        components.year = 2023
//        components.month = 1
//        components.day = 21
//        components.hour = 12 // Set the desired hour
//        components.minute = 0 // Set the desired minute
//        return Calendar.current.date(from: components) ?? Date()
//    }()
    
    @State private var scrollViewOffset: CGFloat = 0
    @State private var tagContainerViewFrame: CGRect = .zero
    @State private var isEditing: Bool = false
    
    @StateObject private var photoPickerViewModel: PhotoPickerViewModel = .init()
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var dateManager: DateManager
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    
    public init (showDatePicker: Binding<Bool>) {
        self._showDatePicker = showDatePicker
//        UIScrollView.appearance().bounces = false
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
                            let newMumoryAnnotation = MumoryAnnotation(date: self.date, musicModel: choosedMusicModel, locationModel: choosedLocationModel)
                            
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
                            .background((self.mumoryDataViewModel.choosedMusicModel != nil) && (self.mumoryDataViewModel.choosedLocationModel != nil) ? SharedAsset.mainColor.swiftUIColor : Color(red: 0.47, green: 0.47, blue: 0.47))
                            .cornerRadius(31.5)
                            .overlay(
                                Text("게시")
                                    .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 13))
                                    .foregroundColor(.black)
                            )
                            .allowsHitTesting(true)
                    }
                    .disabled(!((self.mumoryDataViewModel.choosedMusicModel != nil) && (self.mumoryDataViewModel.choosedLocationModel != nil)))
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

                            TagContainerView(title: "#때끄")
                                .background(GeometryReader { geometry -> Color in
                                    DispatchQueue.main.async {
                                        self.tagContainerViewFrame = geometry.frame(in: .global)
                                    }
                                    return Color.clear
                                })
                            //                            .onAppear {
                            //                                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
                            //                                    guard let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                            //                                    let keyboardHeight = keyboardSize.height
                            //
                            //                                    withAnimation {
                            //                                        scrollViewOffset = tagContainerViewFrame.maxY - (getUIScreenBounds().height - keyboardHeight) + 16
                            //                                    }
                            //                                }
                            //
                            //                                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
                            //                                    withAnimation {
                            //                                         scrollViewOffset = 0
                            //                                    }
                            //                                }
                            //                            }

                            ContentContainerView(contentText: "하이")

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
                        Spacer().frame(width: 20)         
                        
                        Group {
                            Text("전체공개")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                                .foregroundColor(self.isPublic ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.76, green: 0.76, blue: 0.76))
                            
                            Spacer().frame(width: 7)
                            
                            Image(uiImage: self.isPublic ? SharedAsset.publicOnCreateMumory.image : SharedAsset.publicOffCreateMumory.image)
                                .frame(width: 17, height: 17)
                            
                            Spacer()
                        }
                        .onTapGesture {
                            self.isPublic.toggle()
                        }
                    }
                    .padding(.top, 18)
            } // ZStack
            .offset(y: getUIScreenBounds().height == 667 ? -33  : -getSafeAreaInsets().bottom - 16)
        } // VStack
        .background(SharedAsset.backgroundColor.swiftUIColor)
        .cornerRadius(23, corners: [.topLeft, .topRight])
//        .padding(.top, self.appCoordinator.safeAreaInsetsTop + 16)
        .onDisappear {
//            mumoryDataViewModel.choosedMusicModel = nil
//            mumoryDataViewModel.choosedLocationModel = nil
        }
        .gesture(
            TapGesture()
                .onEnded {
                    print("UIApplication.shared.sendAction")
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        )
        .calendarPopup(show: self.$showDatePicker, yOffset: self.calendarYOffset) {

            DatePicker("", selection: self.$date, displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .labelsHidden()
                .accentColor(SharedAsset.mainColor.swiftUIColor)
                .background(SharedAsset.backgroundColor.swiftUIColor)
                .preferredColorScheme(.dark)
                .onChange(of: self.date) { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        self.showDatePicker = false
                    }
                }
        }
    }
}
    
struct ContainerView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    let title: String
    let image: Image
    
    @State private var isMusicChoosed: Bool = false
    @State private var isLocationChoosed: Bool = false

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
    
    @State private var date = Date()
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
//        .popover(isPresented: $isPopOverShown, content: {
//            ZStack {
//                DatePicker("",
//                           selection: $date,
//                           displayedComponents: [.date])
//                .datePickerStyle(.graphical)
//            }
//
//        })
    }
}

struct DatePickerView: UIViewRepresentable {
    @Binding var selectedDate: Date

    func makeUIView(context: Context) -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(context.coordinator, action: #selector(Coordinator.dateChanged(_:)), for: .valueChanged)
        
        return datePicker
    }

    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        uiView.date = selectedDate
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: DatePickerView

        init(_ parent: DatePickerView) {
            self.parent = parent
        }

        @objc func dateChanged(_ senders: UIDatePicker) {
            parent.selectedDate = senders.date
        }
    }
}


struct TagContainerView: View {
    
    let title: String
    
    @State private var tagText: String = ""
    @State private var tags: [String] = []
    
    @State private var isEditing = false
    @State private var isTagEditing = false
    @State private var isCommit = false

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
                
                ForEach(tags.indices, id: \.self) { index in
                    
                    TextField("", text: $tags[index], onEditingChanged: { isEditing in
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
                            
                            self.isCommit = true
                        } else if newValue == "" {
                            tags.remove(at: index)
                        } else if !newValue.hasPrefix("#") {
                            tags.remove(at: index)
                        }
                    })
                    .fixedSize(horizontal: true, vertical: false)
                    
                    Spacer().frame(width: 8)
                }
                
                
                if self.tags.count < 3 {
                    CustomTextField(text: $tagText, onCommit: {
                        if tagText.first == "#" {
                            tags.append(tagText)
                            tagText = ""
                        }
                    }, onEditingChanged: { isEditing in
                        self.isEditing = isEditing
                    })
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
    
    @State var contentText: String = ""
    @State private var textEditorHeight: CGFloat = .zero


    init(contentText: String) {
        self.contentText = contentText
    }
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            
            Rectangle()
                .foregroundColor(.clear)
                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                .frame(minHeight: getUIScreenBounds().height == 667 ? 102 : 127)
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
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 17)
        }
    }
}

//struct CreateMumoryBottomSheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        let appCoordinator = AppCoordinator()
//        let mumoryDataViewModel = MumoryDataViewModel()
//        CreateMumoryBottomSheetView()
//            .environmentObject(appCoordinator)
//            .environmentObject(mumoryDataViewModel)
//    }
//}


