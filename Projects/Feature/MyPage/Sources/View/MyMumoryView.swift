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
    
    @State private var selectedDate: Date = Date()
    @State private var currentTabSelection: Int = 0
    @State private var isDatePickerShown: Bool = false
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    @State private var offset: CGFloat = 0.0
    @State private var scrollViewOffsetY: CGFloat = 0.0
    @State private var dateViewOffsetY: CGFloat = 0.0
    
    public init() {}
    
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
                                .resizable()
                                .frame(width: 30, height: 30)
                        })
                        
                        Spacer()
                        
                        TopBarTitleView(title: "나의 뮤모리")
                        
                        Spacer()
                        
                        Button(action: {
                            self.appCoordinator.rootPath.append(4)
                        }, label: {
                            SharedAsset.searchButtonMypage.swiftUIImage
                                .resizable()
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
                                    Text("\(Calendar.current.component(.month, from: self.selectedDate))월")
                                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                                        .foregroundColor(.white)
                                    
                                    SharedAsset.dateButtonMypage.swiftUIImage
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                }
                                .padding(.leading, 12)
                                .onTapGesture {
                                    self.isDatePickerShown = true
                                }
                            }
                            
                            ScrollView(showsIndicators: false) {
                                
                                VStack(spacing: 0) {
                                    
                                    Spacer().frame(height: 20)
                                    
                                    ForEach(Array(mumoryDataViewModel.filterdMumorys.enumerated()), id: \.element) { index, mumory in
                                        
                                        let spacing = calculateSpacing(forIndex: index)
                                        
                                        if index > 0 && !isSameMonth(mumory, with: mumoryDataViewModel.filterdMumorys[index - 1]) {
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
                                                
                                                Text("\(DateManager.formattedDate(date: mumory.date, dateFormat: "YYYY년 M월"))")
                                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                                    .foregroundColor(.white)
                                                    .padding(.leading, 12)
                                            }
                                            .padding(.top, 30)
                                        }
                                        
                                        MumoryItemView(mumory: mumory, isRecent: index == 0 ? true : false)
                                            .padding(.bottom, CGFloat(spacing))
                                    }
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
        }
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.dark)
        .sheet(isPresented: self.$isDatePickerShown, content: {
            MyMumoryDatePicker(selectedDate: self.$selectedDate)
                .presentationDetents([.height(309)])
        })
        .bottomSheet(isShown: $appCoordinator.isMyMumoryBottomSheetShown, mumoryBottomSheet: MumoryBottomSheet(appCoordinator: appCoordinator, mumoryDataViewModel: mumoryDataViewModel, type: .myMumory, mumoryAnnotation: Mumory()))
        .popup(show: $appCoordinator.isDeleteMumoryPopUpViewShown, content: {
            PopUpView(isShown: $appCoordinator.isDeleteMumoryPopUpViewShown, type: .twoButton, title: "해당 뮤모리를 삭제하시겠습니까?", buttonTitle: "뮤모리 삭제", buttonAction: {
                mumoryDataViewModel.deleteMumory(self.appCoordinator.choosedMumoryAnnotation) {
                    print("뮤모리 삭제 성공")
                    appCoordinator.isDeleteMumoryPopUpViewShown = false
                }
            })
        })
        .ignoresSafeArea()
    }
    
    func calculateSpacing(forIndex index: Int) -> CGFloat {
        guard index > 0 else {
            return 0
        }
        let previousDate = mumoryDataViewModel.filterdMumorys[index - 1].date
        let currentDate = mumoryDataViewModel.filterdMumorys[index].date
                    
        print("previousDate: \(previousDate)")
        print("currentDate: \(currentDate)")
        print(!Calendar.current.isDate(currentDate, equalTo: previousDate, toGranularity: .day))
            
        return !Calendar.current.isDate(currentDate, equalTo: previousDate, toGranularity: .day) ? 0 : 30
    }
    
    func isSameMonth(_ mumory1: Mumory, with mumory2: Mumory) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month], from: mumory1.date)
        let components2 = calendar.dateComponents([.year, .month], from: mumory2.date)
        return components1.year == components2.year && components1.month == components2.month
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
//            parent.offset = scrollView.contentOffset.y
        }
    }
}

struct MumoryItemView: View {
    
    @State private var vStackOffsetY: CGFloat = 0
    @State private var isTruncated: Bool = false
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    private let mumory: Mumory
    private let isRecent: Bool
    
    init(mumory: Mumory, isRecent: Bool) {
        self.mumory = mumory
        self.isRecent = isRecent
    }
    
    private var previousDate: Date? {
        guard let index = mumoryDataViewModel.filterdMumorys.firstIndex(where: { $0.id == mumory.id }) else {
            return nil
        }
        guard index > 0 else {
            return nil
        }
        return mumoryDataViewModel.filterdMumorys[index - 1].date
    }
    
    private var isSameDateAsPrevious: Bool {
        guard let previousDate = previousDate else {
            return false
        }
        return Calendar.current.isDate(mumory.date, equalTo: previousDate, toGranularity: .day)
    }
    
    var body: some View {
        
        HStack(spacing: 0) {

            Spacer().frame(width: 12)
            
            VStack(spacing: 0) {
                
                if !isSameDateAsPrevious {
                    VStack(alignment: .center, spacing: 3) {
                        Text("\(DateManager.formattedDate(date: mumory.date, dateFormat: "dd"))")
                            .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                            .foregroundColor(self.isRecent ? Color(red: 0.09, green: 0.09, blue: 0.09) : .white)
                            .fixedSize(horizontal: true, vertical: false)
                        
                        Text("\(DateManager.formattedDate(date: mumory.date, dateFormat: "E"))")
                            .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 12))
                            .foregroundColor(self.isRecent ? Color(red: 0.09, green: 0.09, blue: 0.09) : .white)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
                    .frame(width: 35, alignment: .center)
                    .background(self.isRecent ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.25, green: 0.25, blue: 0.25))
                    .cornerRadius(18)
                    
                    Spacer().frame(height: 15)
                }
                
                Rectangle()
                    .frame(width: 0.5)
//                , height: (UIScreen.main.bounds.width - 82) * 0.97)
                    .overlay(
                        Rectangle()
                            .inset(by: 0.25)
                            .stroke(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.5), lineWidth: 0.5)
                    )
            }
            .frame(width: 35)
            
            Spacer().frame(width: 15)
            
            VStack(spacing: 0) {
                
                Spacer().frame(height: 11)

                HStack(spacing: 0) {
                    
                    if !self.mumory.isPublic {
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

                    Text(self.mumory.locationModel.locationTitle)
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                        .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                        .frame(width: 210, height: 10, alignment: .leading)
                    
                    Spacer()

                    SharedAsset.menuButtonMypage.swiftUIImage
                        .resizable()
                        .frame(width: 22, height: 22)
                        .onTapGesture {
                            self.appCoordinator.choosedMumoryAnnotation = self.mumory
                            appCoordinator.isMyMumoryBottomSheetShown = true
                        }
                } // HStack
                
                Spacer().frame(height: 11)
                
                ZStack(alignment: .topLeading) {
                    
                    AsyncImage(url: self.mumory.musicModel.artworkUrl, transaction: Transaction(animation: .easeInOut(duration: 0.1))) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        case .failure:
                            Text("Failed to load image")
                        case .empty:
                            ProgressView()
                        default:
                            Color(red: 0.18, green: 0.18, blue: 0.18)
                        }
                    }
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
                                    mumoryDataViewModel.selectedMumoryAnnotation = mumory
                                    self.appCoordinator.rootPath.append(MumoryView(type: .mumoryDetailView, mumoryAnnotation: self.mumory))
                                }
                        )

                    // MARK: Title & Menu & Heart & Comment
                    HStack(spacing: 0) {
                        SharedAsset.musicIconSocial.swiftUIImage
                            .resizable()
                            .frame(width: 14, height: 14)
                        
                        Spacer().frame(width: 5)
                        
                        Group {
                            Text(self.mumory.musicModel.title)
                                .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 14))
                            
                            + Text("  \(self.mumory.musicModel.artist)")
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
                            
                            Text("\(self.mumory.likes.count)")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                .foregroundColor(.white)
                            
                            Spacer().frame(width: 8)
                            
                            SharedAsset.commentMypage.swiftUIImage
                                .resizable()
                                .frame(width: 18, height: 18)
                            
                            Spacer().frame(width: 2)
                            
                            Text("\(self.mumory.commentCount)")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
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
                                
                                if let imageURLs = self.mumory.imageURLs, !imageURLs.isEmpty {
                                    HStack(spacing: 4) {
                                        
                                        SharedAsset.imageCountSocial.swiftUIImage
                                            .frame(width: 18, height: 18)
                                        
                                        Text("\(imageURLs.count)")
                                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15))
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
                                }
                                
                                if let tags = self.mumory.tags, !tags.isEmpty {
                                    ForEach(tags, id: \.self) { tag in
                                        HStack(alignment: .center, spacing: 5) {
                                            SharedAsset.tagMumoryDatail.swiftUIImage
                                                .resizable()
                                                .frame(width: 14, height: 14)
                                            
                                            Text("\(tag)")
                                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                        }
                                        .padding(.leading, 8)
                                        .padding(.trailing, 10)
                                        .padding(.vertical, 7)
                                        .background(.white.opacity(0.25))
                                        .cornerRadius(14)
                                    }
                                }
                                
                                Spacer()
                            } // HStack
                            
                        } // ScrollView
                        .mask(
                            Rectangle()
                                .frame(height: 44)
                                .blur(radius: 3)
                        )
                        
                        // MARK: Content
                        if let content = self.mumory.content, !content.isEmpty {
                            
                            HStack(spacing: 0) {
                                
                                Text(content)
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .frame(maxWidth: (UIScreen.main.bounds.width - 82) * 0.66 * 0.87, alignment: .leading)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .background(
                                        GeometryReader { proxy in
                                            Color.clear.onAppear {
                                                let size = content.size(withAttributes: [.font: SharedFontFamily.Pretendard.medium.font(size: 13)])
                                                
                                                if size.width > proxy.size.width {
                                                    self.isTruncated = true
                                                } else {
                                                    self.isTruncated = false
                                                }
                                            }
                                        }
                                    )
                                
                                Spacer(minLength: 0)
                                
                                if self.isTruncated {
                                    Text("더보기")
                                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 11))
                                        .multilineTextAlignment(.trailing)
                                        .foregroundColor(.white.opacity(0.7))
                                        .lineLimit(1)
                                        .frame(alignment: .leading)
                                }
                            }
                            .padding(.top, 14)
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
    }
}

struct MyMumoryDatePicker: View {
    
    @Binding var selectedDate: Date
    
    @State private var pickerDate: Date = Date()
    @State private var selectedYear: Int = 0
    @State private var selectedMonth: Int = 0
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
                  
            Picker("Year and Month", selection: self.$pickerDate) {
                ForEach(2000..<2030) { year in
                    ForEach(1..<13) { month in
                        Text("\(String(format: "%d", year))년 \(month)월")
                            .tag(DateManager.getYearMonthDate(year: year, month: month))
                            .foregroundColor(.white)
                    }
                }
            }
            .pickerStyle(WheelPickerStyle())
            .onAppear {
                self.selectedYear = Calendar.current.component(.year, from: self.selectedDate)
                self.selectedMonth = Calendar.current.component(.month, from: self.selectedDate)
                self.pickerDate = DateManager.getYearMonthDate(year: self.selectedYear, month: self.selectedMonth)
            }
            
            Button(action: {
                self.selectedDate = pickerDate
                
                let calendar = Calendar.current
                let lastDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1, hour: 24 + 8, minute: 59, second: 59), to: selectedDate)!
                let range = ...lastDayOfMonth
                let newDataBeforeSelectedDate = mumoryDataViewModel.myMumorys.filter { range.contains($0.date) }
                
                for m in newDataBeforeSelectedDate {
                    print("date: \(m.date)")
                }
                mumoryDataViewModel.filterdMumorys = newDataBeforeSelectedDate
                
                dismiss()
            }) {
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: UIScreen.main.bounds.width - 40, height: 58)
                        .background(Color(red: 0.64, green: 0.51, blue: 0.99))
                        .cornerRadius(35)
                    
                    Text("완료")
                        .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 18))
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

struct RoundedSquareView: View {
    
    let mumory: Mumory = Mumory()
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            Rectangle()
              .foregroundColor(.clear)
              .frame(width: getUIScreenBounds().width * 0.435, height: getUIScreenBounds().width * 0.435)
              .background(
                AsyncImage(url: self.mumory.musicModel.artworkUrl, transaction: Transaction(animation: .easeInOut(duration: 0.1))) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Text("Failed to load image")
                    case .empty:
                        ProgressView()
                    default:
                        Color(red: 0.18, green: 0.18, blue: 0.18)
                    }
                }
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
                        AsyncImage(url: self.mumory.musicModel.artworkUrl, transaction: Transaction(animation: .easeInOut(duration: 0.1))) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            case .failure:
                                Text("Failed to load image")
                            case .empty:
                                ProgressView()
                            default:
                                Color(red: 0.18, green: 0.18, blue: 0.18)
                            }
                        }
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
