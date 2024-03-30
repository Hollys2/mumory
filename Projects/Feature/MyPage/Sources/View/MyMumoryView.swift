//
//  MyMumoryView.swift
//  Feature
//
//  Created by 다솔 on 2024/01/30.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import CoreLocation

import Shared


public struct MyMumoryView: View {
    
    @State private var selectedDate: Date = Date()
    @State private var currentTabSelection: Int = 0
    @State private var isDatePickerShown: Bool = false
    @State private var isMyMumorySearchViewShown: Bool = false
    
    @State private var isBlur: Bool = false
    @State private var bluroffset: CGFloat = 0
    
    @State private var myMumorys: [Mumory] = []
    @State private var filteredLocations: [String: [Mumory]] = [:]
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
    
    @State private var offset: CGFloat = 0.0
    @State private var scrollViewOffsetY: CGFloat = 0.0
    @State private var dateViewOffsetY: CGFloat = 0.0
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    public init() {}
    
    public var body: some View {
        ZStack {
            
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
                        self.isMyMumorySearchViewShown = true
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
                            
                            ZStack(alignment: .top) {
                                
//                                ScrollView(showsIndicators: false) {

                                        VStack(spacing: 0) {
                                            
                                            ForEach(Array(mumoryDataViewModel.filteredMumorys.enumerated()), id: \.element) { index, mumory in
                                                
                                                if index > 0 && !isSameMonth(mumory, with: mumoryDataViewModel.filteredMumorys[index - 1]) {
                                                    ZStack(alignment: .topLeading) {
                                                        Rectangle()
                                                            .foregroundColor(.clear)
                                                            .frame(height: 31)
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
                                                            .offset(y: 21)
                                                    }
                                                    .padding(.top, 30)
                                                }
                                                
                                                MumoryItemView(mumory: mumory, isRecent: index == 0 ? true : false)
                                            }
                                        } // VStack
                                        .padding(.top, 45)
                                        .blurScroll(10)
//                                } // ScrollView

                                ZStack(alignment: .leading) {
                                    
                                    Rectangle()
                                        .fill(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.9))
                                        .frame(width: getUIScreenBounds().width, height: 55)
                                        .overlay(
                                            Rectangle()
                                                .foregroundColor(.clear)
                                                .frame(width: getUIScreenBounds().width, height: 0.3)
                                                .background(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.4))
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
                                        UIView.setAnimationsEnabled(false)
                                        self.isDatePickerShown = true
                                    }
                                }
                            }
                        .pageView()
                        .tag(0)
                        
                        ScrollView(showsIndicators: false) {
                            
                            VStack(spacing: 0) {
                                
                                HStack(spacing: 0) {
                                    
                                    Text("지역 \(self.filteredLocations.count)곳에서 기록함")
                                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                    
                                    Spacer()
                                }
                                .padding(.top, 16)
                                .padding(.bottom, 17)
                                .padding(.horizontal, 20)
                                
                                LazyVGrid(columns: columns, spacing: 12) {
                                    
                                    ForEach(self.filteredLocations.sorted(by: { $0.key < $1.key }), id: \.key) { region, mumories in

                                        RoundedSquareView(regionTitle: region, mumorys: mumories)
                                            .onTapGesture {
                                                self.appCoordinator.rootPath.append(MumoryView(type: .regionMyMumoryView, mumoryAnnotation: Mumory(), region: region, mumorys: mumories))
                                            }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)

                            }
                            .padding(.bottom, 100)
                        }
                        .pageView()
                        .tag(1)
                    }
                }
            }
            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
            
            
            if self.isMyMumorySearchViewShown {
                MyMumorySearchView(isShown: self.$isMyMumorySearchViewShown)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            self.selectedDate = self.mumoryDataViewModel.myMumorys.first?.date ?? Date()
            self.mumoryDataViewModel.fetchFriendsMumorys(uId: self.currentUserData.user.uId) { myMumorys in
                self.myMumorys = myMumorys
                print("myMumorys: \(myMumorys)")
                DispatchQueue.main.async {
                    self.mumoryDataViewModel.isUpdating = false
                }
            }
            
            let dispatchGroup = DispatchGroup()
            
            var results: [(Mumory, country: String?, administrativeArea: String?)] = []
            
            for mumory in mumoryDataViewModel.myMumorys {
                dispatchGroup.enter() // 비동기 작업 시작
                
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(CLLocation(latitude: mumory.locationModel.coordinate.latitude, longitude: mumory.locationModel.coordinate.longitude)) { placemarks, error in
                    defer { dispatchGroup.leave() } // 비동기 작업 종료
                    
                    guard let placemark = placemarks?.first, error == nil else {
                        print("Error: ", error?.localizedDescription ?? "Unknown error")
                        return
                    }
                    
                    let country = placemark.country
                    let administrativeArea = placemark.administrativeArea
                    
                    results.append((mumory, country, administrativeArea))
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                filteredLocations = [:]
                for result in results {
                    let (mumory, country, administrativeArea) = result
                    if var country = country, let administrativeArea = administrativeArea {
                        if country != "대한민국" {
                            if country == "영국" {
                                country += " 🇬🇧"
                            } else if country == "미국" {
                                country += " 🇺🇸"
                            } else if country == "이탈리아" {
                                country += " 🇮🇹"
                            } else if country == "프랑스" {
                                country += " 🇫🇷"
                            } else if country == "독일" {
                                country += " 🇩🇪"
                            } else if country == "일본" {
                                country += " 🇯🇵"
                            } else if country == "중국" {
                                country += " 🇨🇳"
                            } else if country == "캐나다" {
                                country += " 🇨🇦"
                            } else if country == "오스트레일리아" {
                                country += " 🇦🇹"
                            } else if country == "브라질" {
                                country += " 🇧🇷"
                            } else if country == "인도" {
                                country += " 🇮🇳"
                            } else if country == "러시아" {
                                country += " 🇷🇺"
                            } else if country == "호주" {
                                country += " 🇦🇺"
                            } else if country == "멕시코" {
                                country += " 🇲🇽"
                            } else if country == "인도네시아" {
                                country += " 🇮🇩"
                            } else if country == "터키" {
                                country += " 🇹🇷"
                            } else if country == "사우디아라비아" {
                                country += " 🇸🇦"
                            } else if country == "스페인" {
                                country += " 🇪🇸"
                            } else if country == "네덜란드" {
                                country += " 🇳🇱"
                            } else if country == "스위스" {
                                country += " 🇨🇭"
                            } else if country == "아르헨티나" {
                                country += " 🇦🇷"
                            } else if country == "스웨덴" {
                                country += " 🇸🇪"
                            } else if country == "폴란드" {
                                country += " 🇵🇱"
                            } else if country == "벨기에" {
                                country += " 🇧🇪"
                            } else if country == "태국" {
                                country += " 🇹🇭"
                            } else if country == "이란" {
                                country += " 🇮🇷"
                            } else if country == "오스트리아" {
                                country += " 🇦🇹"
                            } else if country == "노르웨이" {
                                country += " 🇳🇴"
                            } else if country == "아랍에미리트" {
                                country += " 🇦🇪"
                            } else if country == "나이지리아" {
                                country += " 🇳🇬"
                            } else if country == "남아프리카공화국" {
                                country += " 🇿🇦"
                            } else {
                                country = "기타 🏁"
                            }

                            // 해당 국가를 키로 가지는 배열이 이미 딕셔너리에 존재하는지 확인
                            if var countryMumories = filteredLocations[country] {
                                // 존재하는 경우 해당 배열에 뮤모리 추가
                                countryMumories.append(mumory)
                                // 딕셔너리에 업데이트
                                filteredLocations[country] = countryMumories
                            } else {
                                // 존재하지 않는 경우 새로운 배열 생성 후 뮤모리 추가
                                filteredLocations[country] = [result.0]
                            }
                        } else {
                            if var countryMumories = filteredLocations[administrativeArea] {
                                // 존재하는 경우 해당 배열에 뮤모리 추가
                                countryMumories.append(mumory)
                                // 딕셔너리에 업데이트
                                filteredLocations[administrativeArea] = countryMumories
                            } else {
                                // 존재하지 않는 경우 새로운 배열 생성 후 뮤모리 추가
                                filteredLocations[administrativeArea] = [result.0]
                            }
                        }
                    }
                }
                print("FUCK: \(filteredLocations)")
            }
        }
        .fullScreenCover(isPresented: $isDatePickerShown, content: {
            BottomSheetWrapper(isPresent: $isDatePickerShown) {
                MyMumoryDatePicker(selectedDate: self.$selectedDate)
                    .frame(height: 309)
            }
            .background(TransparentBackground())
        })
        .bottomSheet(isShown: $appCoordinator.isMyMumoryBottomSheetShown, mumoryBottomSheet: MumoryBottomSheet(appCoordinator: appCoordinator, mumoryDataViewModel: mumoryDataViewModel, type: .myMumory, mumoryAnnotation: .constant(Mumory())))
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
        let previousDate = mumoryDataViewModel.filteredMumorys[index - 1].date
        let currentDate = mumoryDataViewModel.filteredMumorys[index].date
                    
        print("previousDate: \(previousDate)")
        print("currentDate: \(currentDate)")
        print(Calendar.current.isDate(currentDate, equalTo: previousDate, toGranularity: .day))
            
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
        guard let index = mumoryDataViewModel.filteredMumorys.firstIndex(where: { $0.id == mumory.id }) else {
            return nil
        }
        guard index > 0 else {
            return nil
        }
        return mumoryDataViewModel.filteredMumorys[index - 1].date
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
                            .font(self.isRecent ? SharedFontFamily.Pretendard.bold.swiftUIFont(size: 16) : SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundColor(self.isRecent ? Color(red: 0.09, green: 0.09, blue: 0.09) : .white)
//                            .fixedSize(horizontal: true, vertical: false)
                        
                        Text("\(DateManager.formattedDate(date: mumory.date, dateFormat: "E"))")
                            .font(self.isRecent ? SharedFontFamily.Pretendard.bold.swiftUIFont(size: 12) : SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                            .foregroundColor(self.isRecent ? Color(red: 0.09, green: 0.09, blue: 0.09) : .white)
//                            .fixedSize(horizontal: true, vertical: false)
                    }
                    .frame(width: 35, height: 56, alignment: .center)
                    .background(self.isRecent ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.25, green: 0.25, blue: 0.25))
                    .cornerRadius(18)
                }
                
                Rectangle()
                    .fill(Color(red: 0.247, green: 0.247, blue: 0.247))
                    .frame(width: 0.5)
                    .frame(maxHeight: .infinity)
            }
            .frame(width: 35)
            
            Spacer().frame(width: 15)
            
            VStack(spacing: 0) {

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
                .padding(.vertical, 6)
                .padding(.bottom, 2)
                
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
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
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
                    
                    VStack(spacing: 0) {
                        
                        Spacer(minLength: 0)
                        
                        // MARK: Image Counter & Tag
                        ScrollView(.horizontal, showsIndicators: false) {
                            
                            HStack(spacing: 8) {
                                
                                if let imageURLs = self.mumory.imageURLs, !imageURLs.isEmpty {
                                    HStack(spacing: 4) {
                                        
                                        SharedAsset.imageCountSocial.swiftUIImage
                                            .resizable()
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
                                
                                Text(content.replacingOccurrences(of: "\n", with: " "))
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.58, alignment: .leading)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .background(
                                        GeometryReader { proxy in
                                            Color.clear.onAppear {
                                                let size = content.replacingOccurrences(of: "\n", with: " ").size(withAttributes: [.font: SharedFontFamily.Pretendard.medium.font(size: 13)])
                                                
                                                if size.width > proxy.size.width {
                                                    self.isTruncated = true
                                                } else {
                                                    self.isTruncated = false
                                                }
                                            }
                                        }
                                    )
                                
                                if self.isTruncated {
                                    Text("더보기")
                                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 11))
                                        .multilineTextAlignment(.trailing)
                                        .foregroundColor(.white.opacity(0.7))
                                        .lineLimit(1)
                                        .frame(alignment: .leading)
                                        .padding(.leading, 7)
                                }
                                
                                Spacer(minLength: 0)
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
        .frame(height: 371)
        .padding(.top, !isSameDateAsPrevious ? 30 : 0)
    }
}

struct RoundedSquareView: View {
    
    let regionTitle: String
    let mumorys: [Mumory]
    
    let mumory: Mumory = Mumory()
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            Rectangle()
              .foregroundColor(.clear)
              .frame(width: getUIScreenBounds().width * 0.435, height: getUIScreenBounds().width * 0.435)
              .background(
                AsyncImage(url: self.mumorys[0].musicModel.artworkUrl, transaction: Transaction(animation: .easeInOut(duration: 0.1))) { phase in
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
                  .cornerRadius(10)
                  .blur(radius: 5, opaque: true)
                  .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
//                  .clipped {
//                      Rectangle()
//                          .frame(width: getUIScreenBounds().width * 0.435, height: getUIScreenBounds().width * 0.435)
//                          .cornerRadius(10)
//                  }
              )
              .cornerRadius(10)
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: getUIScreenBounds().width * 0.435, height: getUIScreenBounds().width * 0.435)
                .background(.black.opacity(0.4))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 6) {
                Text(regionTitle)
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: getUIScreenBounds().width <= 375 ? 16 : 18))
                    .foregroundColor(.white)

                Text(DateManager.formattedRegionDate(date: self.mumorys[0].date))
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundColor(.white)
            }
            .offset(x: 15, y: 22)

            HStack {
                Text("\(mumorys.count)핀")
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
            .offset(x: 15, y: getUIScreenBounds().width * 0.435 - 24 - 15)
            
            ZStack {
                if self.mumorys.count >= 3 {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 36, height: 36)
                        .background(
                            AsyncImage(url: self.mumorys[2].musicModel.artworkUrl, transaction: Transaction(animation: .easeInOut(duration: 0.1))) { phase in
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
                }
                
                if self.mumorys.count >= 2 {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 36, height: 36)
                        .background(
                            AsyncImage(url: self.mumorys[1].musicModel.artworkUrl, transaction: Transaction(animation: .easeInOut(duration: 0.1))) { phase in
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
                        .offset(x: 18)
                }
                
                if self.mumorys.count >= 1 {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 36, height: 36)
                        .background(
                            AsyncImage(url: self.mumorys[0].musicModel.artworkUrl, transaction: Transaction(animation: .easeInOut(duration: 0.1))) { phase in
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
                        .offset(x: 36)
                }
                                      
                if self.mumorys.count > 3 {
                    SharedAsset.artworkFilterMypage.swiftUIImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 36, height: 36)
                        .offset(x: 36)
                }
            }
            .offset(x: getUIScreenBounds().width * 0.435 - 84, y: getUIScreenBounds().width * 0.435 - 36 - 15)
        }
    }
}



private struct BlurScroll: ViewModifier {
    
    let blur: CGFloat
    let coordinateSpaceName = "scroll"
    
    @State private var scrollPosition: CGPoint = .zero
    
    func body(content: Content) -> some View {
        
        let gradient = LinearGradient(stops: [
            .init(color: .white, location: 0.10),
            .init(color: .clear, location: 0.25)],
                                      startPoint: .bottom,
                                      endPoint: .top)
        
        let invertedGradient = LinearGradient(stops: [
            .init(color: .clear, location: 0.10),
            .init(color: .white, location: 0.25)],
                                              startPoint: .bottom,
                                              endPoint: .top)
        
        GeometryReader { proxy in
            ScrollView {
                ZStack(alignment: .top) {
                    
                    content
                    
                    content
                        .background(Color(red: 0.09, green: 0.09, blue: 0.09, opacity: 0.9))
                        .blur(radius: blur)
                        .frame(height: proxy.size.height, alignment: .top)
                        .mask {
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.width, height: 55)
                                .offset(y:  -scrollPosition.y - (proxy.size.height / 2) + (55 / 2))
                        }
                }
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self,
                                        value: geo.frame(in: .named(coordinateSpaceName)).origin)
                    }
                )
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    self.scrollPosition = value
                }
            }
            .scrollIndicators(.hidden)
            .coordinateSpace(name: coordinateSpaceName)
        }
        .ignoresSafeArea()
    }
}

//MARK: PreferenceKey
private struct ScrollOffsetPreferenceKey: PreferenceKey {
    
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) { }
}

extension View {
    func blurScroll(_ blur: CGFloat) -> some View {
        modifier(BlurScroll(blur: blur))
    }
}
