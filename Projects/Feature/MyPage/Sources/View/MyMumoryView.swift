//
//  MyMumoryView.swift
//  Feature
//
//  Created by 다솔 on 2024/01/30.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import Shared

public struct MyMumoryView: View {
    
    @State private var translation: CGSize = .zero
    @State private var currentTabSelection: Int = 0
    @State private var isDatePickerShown: Bool = false
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    @State private var offset: CGFloat = 0.0
    @State private var scrollViewOffsetY: CGFloat = 0.0
    @State private var dateViewOffsetY: CGFloat = 0.0
    
    public init() {}
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height > 0 {
                    DispatchQueue.main.async {
                        translation.height = value.translation.height
                    }
                }
            }
            .onEnded { value in
                
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
        ZStack(alignment: .bottom) {
            
            VStack(spacing: 0) {
                
                VStack(spacing: 0) {
                    
                    Spacer().frame(height: self.appCoordinator.safeAreaInsetsTop + 19)
                    
                    HStack(spacing: 0) {
                        
                        Button(action: {
                            self.appCoordinator.rootPath.removeLast()
                        }, label: {
                            SharedAsset.backButtonTopBar.swiftUIImage
                                .frame(width: 30, height: 30)
                        })
                        
                        Spacer()
                        
                        TopBarTitleView(title: "나의 뮤모리")
                        
                        Spacer()
                        
                        Button(action: {
                            self.appCoordinator.rootPath.append(4)
                        }, label: {
                            SharedAsset.searchButtonMypage.swiftUIImage
                                .frame(width: 30, height: 30)
                        })
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer().frame(height: 13)
                    
                    PageTabView(selection: $currentTabSelection) {
                        
                        ForEach(Array(["타임라인", "지역"].enumerated()), id: \.element) { index, title in
                            Text(title)
                                .font(
                                    currentTabSelection == index ? SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16) : SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16)
                                )
                                .multilineTextAlignment(.center)
                                .foregroundColor(currentTabSelection == index ? .white : Color(red: 0.82, green: 0.82, blue: 0.82))
                                .background(
                                    GeometryReader{ g in
                                        Color.clear
                                            .preference(key: TabWidthPreferenceKey.self, value: [index: g.size.width])
                                    }
                                )
                                .pageLabel()
                                .background(Color(red: 0.09, green: 0.09, blue: 0.09)) // 터치영역 확장
                                .onTapGesture {
                                    withAnimation {
                                        currentTabSelection = index
                                    }
                                }
                        }
                        
                    } content: {
                        VStack(spacing: 0) {
                            
                            ZStack(alignment: .leading) {
                                
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: getUIScreenBounds().width, height: 55)
                                    .background(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.9))
                                    .overlay(
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(width: getUIScreenBounds().width, height: 0.3)
                                            .background(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.3))
                                        , alignment: .bottom
                                    )
                                
                                HStack(spacing: 6) {
                                    Text("\(self.appCoordinator.selectedMonth)월")
                                        .font(
                                            Font.custom("Pretendard", size: 20)
                                                .weight(.semibold)
                                        )
                                        .foregroundColor(.white)
                                    
                                    SharedAsset.dateButtonMypage.swiftUIImage
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                }
                                .padding(.leading, 12)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        self.isDatePickerShown = true
                                    }
                                }
                            }
                            
                            ScrollView(showsIndicators: false) {
                                
                                VStack(spacing: 0) {
                                    ItemView(viewModel: ItemViewModel(isSelected: true, heartCount: 2, commentCount: 3))
                                        .padding(.top, 20)
                                    
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(height: 61)
                                            .overlay(
                                                Rectangle()
                                                    .foregroundColor(.clear)
                                                    .frame(width: getUIScreenBounds().width, height: 0.3)
                                                    .background(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.4)),
                                                alignment: .top
                                            )
                                        
                                        Text("2023년 9월")
                                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                            .foregroundColor(.white)
                                            .padding(.leading, 12)
                                    }
                                    .background(
                                        GeometryReader { geometry in
                                            Color.clear
                                                .onAppear {
                                                    self.dateViewOffsetY = geometry.frame(in: .global).minY
                                                }
                                                .onChange(of: self.offset) { newValue in
                                                    print("ScrollView offset changed: \(newValue)")
                                                    
                                                    if self.scrollViewOffsetY + newValue >= self.dateViewOffsetY {
                                                        self.appCoordinator.updateSelectedDate(year: 2020, month: 9)
                                                    } else {
                                                        self.appCoordinator.updateSelectedDate(year: 2020, month: 1)
                                                    }
                                                }
                                        }
                                    )
                                    
                                    
                                    ItemView(viewModel: ItemViewModel(isLocked: true, heartCount: 0, commentCount: 0))
                                        .padding(.top, 5)
                                    
                                    ItemView(viewModel: ItemViewModel(heartCount: 0, commentCount: 0))
                                        .background(.red)
                                    ItemView(viewModel: ItemViewModel(heartCount: 0, commentCount: 0))
                                        .background(.blue)
                                } // VStack
                            } // ScrollView
                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            let scrollView = UIScrollView.appearance()
                                            scrollView.delegate = self.makeCoordinator()
                                            
                                            self.scrollViewOffsetY = geometry.frame(in: .global).minY
                                        }
//                                        .onChange(of: self.offset) { newValue in
//                                            // 스크롤이 변할 때
//                                            print("ScrollView offset changed1: \(newValue)")
//                                        }
                                }
                            )
//                            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
//                                // 스크롤의 실시간 변화를 감지하고 출력
//                                print("ScrollView offset changed in real-time: \(value)")
//                            }
                            
                        } // VStack
                        .pageView()
                        .tag(0)
                        
                        ScrollView(showsIndicators: false) {
                            
                            VStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    Text("지역 8곳에서 기록함")
                                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 22)
                                .padding(.horizontal, 20)
                                
                                ForEach(0..<10) { row in
                                    LazyHStack(spacing: 11) {
                                        RoundedSquareView()
                                        RoundedSquareView()
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 12)
                                }
                            }
                            .padding(.bottom, 100)
                        }
                        .pageView()
                        .tag(1)
                    }
                }
            }
            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
            
            //            if self.isDatePickerShown {
            //                Color.black.opacity(0.5).ignoresSafeArea()
            //                    .onTapGesture {
            //                        withAnimation(Animation.easeOut(duration: 0.2)) {
            //                            self.isDatePickerShown = false
            //                        }
            //                    }
            //
            //                CustomDatePicker()
            //                    .offset(y: self.translation.height - appCoordinator.safeAreaInsetsBottom)
            //                    .gesture(dragGesture)
            //                    .transition(.move(edge: .bottom))
            //                    .zIndex(1)
            //            }
            
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
        .sheet(isPresented: self.$isDatePickerShown, content: {
            CustomDatePicker()
                .presentationDetents([.height(309)])
        })
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        
        var parent: MyMumoryView
        
        init(_ parent: MyMumoryView) {
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            parent.offset = scrollView.contentOffset.y
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


struct CustomDatePicker: View {
    
    @State private var selectedDate: Date = Date()
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("Year and Month", selection: self.$selectedDate) {
                ForEach(2000..<2030) { year in
                    ForEach(1..<13) { month in
                        Text("\(String(format: "%d", year))년 \(month)월")
                            .tag(AppCoordinator.getYearMonthDate(year: year, month: month))
                            .foregroundColor(.white)
                    }
                }
            }
            .pickerStyle(WheelPickerStyle())
            .onAppear {
                let year = Calendar.current.component(.year, from: Date())
                let month = Calendar.current.component(.month, from: Date())
                
                self.selectedDate = AppCoordinator.getYearMonthDate(year: year, month: month)
            }
            
            Button(action: {
                self.appCoordinator.selectedDate = self.selectedDate
                dismiss()
            }) {
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: UIScreen.main.bounds.width - 40, height: 58)
                        .background(Color(red: 0.64, green: 0.51, blue: 0.99))
                        .cornerRadius(35)
                    
                    Text("완료")
                        .font(
                            SharedFontFamily.Pretendard.bold.swiftUIFont(size: 18)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                }
            }
        }
        .frame(height: 309)
        .padding(.vertical, 100)
        .background(Color(red: 0.09, green: 0.09, blue: 0.09))
    }
}

struct ItemViewModel {
    let isSelected: Bool
    let isLocked: Bool
    let heartCount: Int
    let commentCount: Int
    
    init(isSelected: Bool = false, isLocked: Bool = false, heartCount: Int = 0, commentCount: Int = 0) {
        self.isSelected = isSelected
        self.isLocked = isLocked
        self.heartCount = heartCount
        self.commentCount = commentCount
    }
}

struct ItemView: View {
    
    @State private var isMenuShown: Bool = false
    @State private var vStackOffsetY: CGFloat = 0
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    let viewModel: ItemViewModel
    
    init(viewModel: ItemViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
                
        HStack(spacing: 0) {

            Spacer().frame(width: 12)
            
            VStack(spacing: 0) {
                
                VStack(alignment: .center, spacing: 3) {
                    Text("\(appCoordinator.formattedDate(date: Date(), dateFormat: "dd"))")
                        .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                        .foregroundColor(self.viewModel.isSelected ? Color(red: 0.09, green: 0.09, blue: 0.09) : .white)
                        .fixedSize(horizontal: true, vertical: false)
                    
                    Text("\(appCoordinator.formattedDate(date: Date(), dateFormat: "E"))")
                        .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 12))
                        .foregroundColor(self.viewModel.isSelected ? Color(red: 0.09, green: 0.09, blue: 0.09) : .white)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 14)
                .frame(width: 35, alignment: .center)
                .background(self.viewModel.isSelected ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.25, green: 0.25, blue: 0.25))
                .cornerRadius(18)
                
                Spacer().frame(height: 15)
                
                Rectangle()
                    .frame(width: 1, height: (UIScreen.main.bounds.width - 82) * 0.97)
                    .overlay(
                        Rectangle()
                            .inset(by: 0.25)
                            .stroke(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.5), lineWidth: 0.5)
                    )

                Spacer().frame(height: 30)
            }
            
            Spacer().frame(width: 15)
            
            VStack(spacing: 0) {
                
                Spacer().frame(height: 11)

                HStack(spacing: 0) {
                    
                    if self.viewModel.isLocked {
                        Image(uiImage: SharedAsset.lockIconMypage.image)
                            .resizable()
                            .frame(width: 20, height: 20)
                        
                        Spacer().frame(width: 4)
                        
                        Text("・")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                            .frame(width: 4, alignment: .bottom)
                        
                        Spacer().frame(width: 4)
                    }
                    
                    Image(uiImage: SharedAsset.locationIconMypage.image)
                        .resizable()
                        .frame(width: 18, height: 18)

                    Spacer().frame(width: 4)

                    Text("반포한강공원반포한강공원반포한강공원반포한강공원")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                        .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                        .frame(width: 210, height: 10, alignment: .leading)
                    
                    Spacer()

                    SharedAsset.menuButtonMypage.swiftUIImage
                        .resizable()
                        .frame(width: 22, height: 22)
                } // HStack

                Spacer().frame(height: 11)

                ZStack(alignment: .topLeading) {

                    SharedAsset.artworkSample.swiftUIImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width - 82, height: UIScreen.main.bounds.width - 82)
                        .cornerRadius(15)

                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: UIScreen.main.bounds.width - 82, height: UIScreen.main.bounds.width - 82)
                        .background(
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: .black.opacity(0.5), location: 0.00),
                                    Gradient.Stop(color: .black.opacity(0), location: 0.26),
                                    Gradient.Stop(color: .black.opacity(0), location: 0.63),
                                    Gradient.Stop(color: .black.opacity(0.5), location: 0.96),
                                ],
                                startPoint: UnitPoint(x: 0.5, y: 0),
                                endPoint: UnitPoint(x: 0.5, y: 1)
                            )
                        )
                        .cornerRadius(15)
                        .gesture(
                            TapGesture(count: 1)
                                .onEnded {
//                                    self.appCoordinator.rootPath.append(0)
                                }
                        )

                    // MARK: Title & Menu & Heart & Comment
                    HStack(spacing: 0) {
                        SharedAsset.musicIconSocial.swiftUIImage
                            .resizable()
                            .frame(width: 14, height: 14)
                        
                        Spacer().frame(width: 5)
                        
                        Group {
                            Text("Hollywood")
                                .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 14))
                            
                            + Text("  검정치마")
                                .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 14))
                        }
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .frame(width: 158, alignment: .leading)
                        
                        Spacer()
                        
                        Group {
                            SharedAsset.heartMypage.swiftUIImage
                                .resizable()
                                .frame(width: 18, height: 18)
                            
                            Spacer().frame(width: 2)
                            
                            Text("\(self.viewModel.heartCount)")
                                .font(
                                    Font.custom("Pretendard", size: 12)
                                        .weight(.medium)
                                )
                                .foregroundColor(.white)
                            
                            Spacer().frame(width: 8)
                            
                            SharedAsset.commentMypage.swiftUIImage
                                .resizable()
                                .frame(width: 18, height: 18)
                            
                            Spacer().frame(width: 2)
                            
                            Text("\(self.viewModel.commentCount)")
                                .font(
                                    Font.custom("Pretendard", size: 12)
                                        .weight(.medium)
                                )
                                .foregroundColor(.white)
                        }
                    } // HStack
                    .padding(.top, 19)
                    .padding(.leading, 20)
                    .padding(.trailing, 19)
                    
                    VStack(spacing: 14) {
                        // MARK: Image Counter & Tag
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                HStack(spacing: 4) {
                                    SharedAsset.imageCountSocial.swiftUIImage
                                        .frame(width: 18, height: 18)
                                    Text("2")
                                        .font(
                                            Font.custom("Pretendard", size: 15)
                                                .weight(.medium)
                                        )
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.white)
                                }
                                .frame(width: 48, height: 28)
                                .background(
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 48, height: 28)
                                        .background(Color(red: 0.16, green: 0.16, blue: 0.16).opacity(0.6))
                                        .cornerRadius(15)
                                )
                                
                                HStack(alignment: .center, spacing: 5) {
                                    SharedAsset.tagMumoryDatail.swiftUIImage
                                        .resizable()
                                        .frame(width: 14, height: 14)
                                    
                                    Text("태그태그태그태그태그태그태그태그태그태그태그태그태그태그태그태그태그")
                                        .font(
                                            Font.custom("Pretendard", size: 12)
                                                .weight(.semibold)
                                        )
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                }
                                .padding(.leading, 8)
                                .padding(.trailing, 10)
                                .padding(.vertical, 7)
                                .background(.white.opacity(0.25))
                                .cornerRadius(14)
                                
                                HStack(alignment: .center, spacing: 5) {
                                    SharedAsset.tagMumoryDatail.swiftUIImage
                                        .resizable()
                                        .frame(width: 14, height: 14)
                                    
                                    Text("태그태그태그태그태그태그태그태그태그태그태그태그태그태그태그태그태그")
                                        .font(
                                            Font.custom("Pretendard", size: 12)
                                                .weight(.semibold)
                                        )
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                }
                                .padding(.leading, 8)
                                .padding(.trailing, 10)
                                .padding(.vertical, 7)
                                .background(.white.opacity(0.25))
                                .cornerRadius(14)
                                
                                HStack(alignment: .center, spacing: 5) {
                                    SharedAsset.tagMumoryDatail.swiftUIImage
                                        .resizable()
                                        .frame(width: 14, height: 14)
                                    
                                    Text("태그태그태그태그태그태그태그태그태그태그태그태그태그태그태그태그태그")
                                        .font(
                                            Font.custom("Pretendard", size: 12)
                                                .weight(.semibold)
                                        )
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                }
                                .padding(.leading, 8)
                                .padding(.trailing, 10)
                                .padding(.vertical, 7)
                                .background(.white.opacity(0.25))
                                .cornerRadius(14)
                                
                                Spacer()
                            } // HStack
                            
                        } // ScrollView
                        .mask(
                            Rectangle()
                                .frame(height: 44)
                                .blur(radius: 3)
                        )
                        
                        // MARK: Content
                        HStack(spacing: 0) {
                            Text("내용 내용내용 내용내용내용 내용내용내용내용내용 내용내용내용내용내용내용")
                                .font(
                                    Font.custom("Pretendard", size: 13)
                                        .weight(.medium)
                                )
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .frame(alignment: .leading)
                            
                            Spacer()
                            
                            // 컨텐트 너비에 따른 조건문 추가 예정
                            Text("더보기")
                                .font(
                                    Font.custom("Pretendard", size: 11)
                                        .weight(.medium)
                                )
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(1)
                                .frame(alignment: .leading)
                        }
                    } // VStack
                    .frame(width: UIScreen.main.bounds.width - 82 - 47)
                    .background(
                        GeometryReader{ g in
                            Color.clear
                                .onAppear {
                                    DispatchQueue.main.async {
                                        self.vStackOffsetY = g.size.height
                                    }
                                }
                        }
                    )
                    .padding(.leading, 20)
                    .offset(y: UIScreen.main.bounds.width - 82 - self.vStackOffsetY - 17)
                } // ZStack
                
                Spacer()
            } // VStack
            
            Spacer().frame(width: 20)
        }
//        .frame(height: 401)
        //        .sheet(isPresented: self.$isMenuShown, content: {
        //            SocialMenuSheetView()
        //                .padding(.horizontal, 9)
        //                .presentationDetents([.height(190)])
        //                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        //        })
    }
}

struct RoundedSquareView: View {
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            Rectangle()
              .foregroundColor(.clear)
              .frame(width: getUIScreenBounds().width * 0.435, height: getUIScreenBounds().width * 0.435)
              .background(
                SharedAsset.artworkSample.swiftUIImage
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(width: getUIScreenBounds().width * 0.435, height: getUIScreenBounds().width * 0.435)
                  .clipped()
              )
              .cornerRadius(10)
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: getUIScreenBounds().width * 0.435, height: getUIScreenBounds().width * 0.435)
                .background(.black.opacity(0.4))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 6) {
                Text("서울특별시")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                    .foregroundColor(.white)

                Text("오늘")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundColor(.white)
            }
            .offset(x: 15, y: 22)

            HStack {
                Text("55핀")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .frame(minWidth: 18)
                    .frame(height: 8)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .cornerRadius(30)
            .overlay(
              RoundedRectangle(cornerRadius: 30)
                .inset(by: 0.5)
                .stroke(.white, lineWidth: 1)
            )
            .background(
                GeometryReader { g in
                    Color.clear
                        .onAppear {
//                            print(g.size.height)
                        }
                }
            )
            .offset(x: 15, y: getUIScreenBounds().width * 0.435 - 24 - 15)
            
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 36, height: 36)
                    .background(
                        SharedAsset.artworkSample.swiftUIImage
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 36, height: 36)
                            .clipped()
                    )
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .inset(by: 0.5)
                            .stroke(.white, lineWidth: 1)
                    )
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 36, height: 36)
                    .background(
                        SharedAsset.artworkSample.swiftUIImage
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 36, height: 36)
                            .clipped()
                    )
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .inset(by: 0.5)
                            .stroke(.white, lineWidth: 1)
                    )
                    .offset(x: 16)
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 36, height: 36)
                    .background(
                        SharedAsset.artworkSample.swiftUIImage
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 36, height: 36)
                            .clipped()
                    )
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .inset(by: 0.5)
                            .stroke(.white, lineWidth: 1)
                    )
                    .offset(x: 32)
                                    
                SharedAsset.artworkFilterMypage.swiftUIImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 36, height: 36)
                    .offset(x: 32)
            }
            .offset(x: getUIScreenBounds().width * 0.435 - 36 - 32 - 15, y: getUIScreenBounds().width * 0.435 - 36 - 15)
        }
    }
}


struct MyMumoryView_Previews: PreviewProvider {
    static var previews: some View {
        MyMumoryView()
    }
}
