//
//  MyMumoryView.swift
//  Feature
//
//  Created by 다솔 on 2024/01/30.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import CoreLocation
import Combine

import Shared


public struct MyMumoryView: View {

    @State private var selectedDate: Date = Date()
    @State private var currentTabSelection: Int = 0
    @State private var isDatePickerShown: Bool = false
    @State private var isMyMumorySearchViewShown: Bool = false

    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    
    let user: UserProfile
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]

    public init(user: UserProfile) {
        self.user = user
    }

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button(action: {
                        self.appCoordinator.rootPath.removeLast()
                    }, label: {
                        SharedAsset.backButtonTopBar.swiftUIImage
                            .resizable()
                            .frame(width: 30, height: 30)
                    })
                    
                    Spacer()
                    
                    TopBarTitleView(title: self.user.uId == self.currentUserViewModel.user.uId ? "나의 뮤모리" : "\(self.user.nickname)의 뮤모리")
                    
                    Spacer()
                    
                    Button(action: {
                        self.isMyMumorySearchViewShown = true
                    }, label: {
                        SharedAsset.searchButtonMypage.swiftUIImage
                            .resizable()
                            .frame(width: 30, height: 30)
                    })
                }
                .padding(.top, self.getSafeAreaInsets().top + 19)
                .padding(.bottom, 13)
                .padding(.horizontal, 20)
                .background(.clear)
                
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
                        ScrollView {
                            VStack(spacing: 0) {
                                if self.currentUserViewModel.mumoryViewModel.monthlyMumorys.isEmpty {
                                    ZStack(alignment: .top) {
                                        Color.clear
                                        
                                        Text("뮤모리 기록이 없습니다.")
                                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                            .foregroundStyle(ColorSet.subGray)
                                            .multilineTextAlignment(.center)
                                            .offset(y: 145)
                                    }
                                } else {
                                    ForEach(Array(self.currentUserViewModel.mumoryViewModel.monthlyMumorys.enumerated()), id: \.element) { index, mumory in
                                        if index == 0 || (index > 0 && !isSameMonth(mumory, with: self.currentUserViewModel.mumoryViewModel.monthlyMumorys[index - 1])) {
                                            ZStack(alignment: .topLeading) {
                                                Rectangle()
                                                    .foregroundColor(.clear)
                                                    .frame(height: 31)
                                                    .overlay(
                                                        Rectangle()
                                                            .foregroundColor(.clear)
                                                            .frame(width: getUIScreenBounds().width, height: 0.5)
                                                            .background(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.4)),
                                                        alignment: .top
                                                    )
                                                
                                                Text("\(DateManager.formattedDate(date: mumory.date, dateFormat: "YYYY년 M월"))")
                                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                                    .foregroundColor(.white)
                                                    .padding(.leading, 12)
                                                    .offset(y: 21)
                                            }
                                            .padding(.top, index == 0 ? 0 : 30)
                                        }
                                        
                                        TimeLineItemView(mumory: mumory, isRecent: index == 0 ? true : false)
                                    }
                                }
                                
                                Spacer(minLength: 0)
                            } // VStack
                            .padding(.top, 55)
                        } // ScrollView
                        
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.95))
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
                                Text("지역 \(self.currentUserViewModel.mumoryViewModel.locationMumorys.count)곳에서 기록함")
                                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                                    .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                
                                Spacer()
                            }
                            .padding(.top, 16)
                            .padding(.bottom, 17)
                            .padding(.horizontal, 20)
                            
                            if self.currentUserViewModel.mumoryViewModel.monthlyMumorys.isEmpty {
                                ZStack(alignment: .top) {
                                    Color.clear
                                    
                                    Text("뮤모리 기록이 없습니다.")
                                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                        .foregroundStyle(ColorSet.subGray)
                                        .multilineTextAlignment(.center)
                                        .offset(y: 145)
                                }
                            }
                            
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(self.currentUserViewModel.mumoryViewModel.locationMumorys.sorted(by: { $0.key < $1.key }), id: \.key) { region, mumorys in
                                    RegionItemView(regionTitle: region, mumorys: mumorys)
                                        .onTapGesture {
                                            self.appCoordinator.rootPath.append(MumoryPage.regionMyMumoryView(user: self.user, regionTitle: region, mumorys: mumorys))
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
            .background(ColorSet.background)
            
            if self.isMyMumorySearchViewShown {
                MyMumorySearchView(isShown: self.$isMyMumorySearchViewShown)
            }
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
        .onAppear {
            if self.user.uId == self.currentUserViewModel.user.uId {
                self.selectedDate = self.currentUserViewModel.mumoryViewModel.myMumorys.first?.date ?? Date()
                self.currentUserViewModel.mumoryViewModel.monthlyMumorys = self.currentUserViewModel.mumoryViewModel.myMumorys
            } else {
                self.selectedDate = self.currentUserViewModel.mumoryViewModel.friendMumorys.first?.date ?? Date()
                self.currentUserViewModel.mumoryViewModel.monthlyMumorys = self.currentUserViewModel.mumoryViewModel.friendMumorys
            }
            
            
            self.currentUserViewModel.mumoryViewModel.monthlyMumorys = self.currentUserViewModel.mumoryViewModel.monthlyMumorys.filter({ mumory in
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month], from: mumory.date)
                let targetComponents = calendar.dateComponents([.year, .month], from: selectedDate)
                return components.year == targetComponents.year && components.month == targetComponents.month
            })
            
            self.currentUserViewModel.mumoryViewModel.locationMumorys = [:]
            
            for mumory in self.currentUserViewModel.mumoryViewModel.myMumorys {
                var country = mumory.location.country
                let administrativeArea = mumory.location.administrativeArea
                
                if country != "대한민국" {
                    if country == "영국" {
                        country += " 🇬🇧"
                    } else if country == "미 합중국" {
                        country = "미국 🇺🇸"
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
                    } else if country == "우크라이나" {
                        country += " 🇺🇦"
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
                    
                    if var countryMumories = self.currentUserViewModel.mumoryViewModel.locationMumorys[country] {
                        countryMumories.append(mumory)
                        self.currentUserViewModel.mumoryViewModel.locationMumorys[country] = countryMumories
                    } else {
                        self.currentUserViewModel.mumoryViewModel.locationMumorys[country] = [mumory]
                    }
                } else {
                    if var countryMumories = self.currentUserViewModel.mumoryViewModel.locationMumorys[administrativeArea] {
                        countryMumories.append(mumory)
                        self.currentUserViewModel.mumoryViewModel.locationMumorys[administrativeArea] = countryMumories
                    } else {
                        self.currentUserViewModel.mumoryViewModel.locationMumorys[administrativeArea] = [mumory]
                    }
                }
            }
        }
        .onChange(of: self.currentUserViewModel.mumoryViewModel.myMumorys, perform: { newValue in
            self.currentUserViewModel.mumoryViewModel.monthlyMumorys = newValue.filter({ mumory in
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month], from: mumory.date)
                let targetComponents = calendar.dateComponents([.year, .month], from: selectedDate)
                return components.year == targetComponents.year && components.month == targetComponents.month
            })
        })
        .fullScreenCover(isPresented: $isDatePickerShown, content: {
            BottomSheetWrapper(isPresent: $isDatePickerShown) {
                MyMumoryDatePicker(selectedDate: self.$selectedDate, user: self.user)
                    .frame(height: 309)
            }
            .background(TransparentBackground())
        })
    }

    func isSameMonth(_ mumory1: Mumory, with mumory2: Mumory) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month], from: mumory1.date)
        let components2 = calendar.dateComponents([.year, .month], from: mumory2.date)
        return components1.year == components2.year && components1.month == components2.month
    }
}

struct TimeLineItemView: View {

    @State private var vStackOffsetY: CGFloat = 0
    @State private var isTruncated: Bool = false

    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel

    private let mumory: Mumory
    private let isRecent: Bool

    init(mumory: Mumory, isRecent: Bool) {
        self.mumory = mumory
        self.isRecent = isRecent
    }

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                if !isSameDateAsPrevious {
                    VStack(alignment: .center, spacing: 3) {
                        Text("\(DateManager.formattedDate(date: mumory.date, dateFormat: "dd"))")
                            .font(self.isRecent ? SharedFontFamily.Pretendard.bold.swiftUIFont(size: 16) : SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundColor(self.isRecent ? Color(red: 0.09, green: 0.09, blue: 0.09) : .white)

                        Text("\(DateManager.formattedDate(date: mumory.date, dateFormat: "E"))")
                            .font(self.isRecent ? SharedFontFamily.Pretendard.bold.swiftUIFont(size: 12) : SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                            .foregroundColor(self.isRecent ? Color(red: 0.09, green: 0.09, blue: 0.09) : .white)
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
            .padding(.leading, 12)
            .padding(.trailing, 15)

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

                    Text(self.mumory.location.locationTitle)
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                        .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                        .frame(width: 210, height: 10, alignment: .leading)

                    Spacer()

                    SharedAsset.menuButtonMypage.swiftUIImage
                        .resizable()
                        .frame(width: 22, height: 22)
                        .onTapGesture {
                            self.appCoordinator.sheet = .myMumory(mumory: self.mumory, isOwn: self.mumory.uId == self.currentUserViewModel.user.uId, action: deleteMumoryAction)
                        }
                } // HStack
                .padding(.vertical, 6)
                .padding(.bottom, 2)

                ZStack(alignment: .topLeading) {
                    AsyncImage(url: self.mumory.song.artworkUrl) { phase in
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
                    .frame(width: UIScreen.main.bounds.width - 82, height: UIScreen.main.bounds.width - 82)
                    .cornerRadius(15)

                    HStack(spacing: 0) {
                        SharedAsset.musicIconSocial.swiftUIImage
                            .resizable()
                            .frame(width: 14, height: 14)

                        Spacer().frame(width: 5)

                        Group {
                            Text(self.mumory.song.title)
                                .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 14))
                            + Text("  \(self.mumory.song.artist)")
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

                            Text("\((mumory.likes ?? []).count)")
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
                                            .frame(width: 14, height: 14)

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
                                            .background(Color(red: 0.16, green: 0.16, blue: 0.16).opacity(0.7))
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
                        .frame(width: UIScreen.main.bounds.width - 82 - 40)
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
                                        .fixedSize(horizontal: true, vertical: false)
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
                .onTapGesture {
                    self.appCoordinator.rootPath.append(MumoryPage.mumoryDetailView(mumory: self.mumory))
                }
                .padding(.bottom, 40)
            } // VStack
            .padding(.trailing, 20)
        }
        .frame(height: 371)
        .padding(.top, !isSameDateAsPrevious ? 30 : 0)
    }
    
    private var previousDate: Date? {
        guard let index = currentUserViewModel.mumoryViewModel.monthlyMumorys.firstIndex(where: { $0.id == mumory.id }) else {
            return nil
        }
        guard index > 0 else {
            return nil
        }
        return currentUserViewModel.mumoryViewModel.monthlyMumorys[index - 1].date
    }

    private var isSameDateAsPrevious: Bool {
        guard let previousDate = previousDate else {
            return false
        }
        return Calendar.current.isDate(mumory.date, equalTo: previousDate, toGranularity: .day)
    }

    private func deleteMumoryAction() {
        self.appCoordinator.popUp = .none
        self.appCoordinator.isLoading = true
        self.currentUserViewModel.mumoryViewModel.deleteMumory(mumory) { result in
            switch result {
            case .success():
                print("SUCCESS deleteMumory!")
            case .failure(let error):
                print("ERROR deleteMumory: \(error)")
            }
            self.appCoordinator.isLoading = false
        }
    }
}

struct RegionItemView: View {

    let regionTitle: String
    let mumorys: [Mumory]
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: getUIScreenBounds().width * 0.435, height: getUIScreenBounds().width * 0.435)
                .background(
                    AsyncImage(url: self.mumorys[0].song.artworkUrl, transaction: Transaction(animation: .easeInOut(duration: 0.1))) { phase in
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
                            AsyncImage(url: self.mumorys[2].song.artworkUrl, transaction: Transaction(animation: .easeInOut(duration: 0.1))) { phase in
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
                            AsyncImage(url: self.mumorys[1].song.artworkUrl) { phase in
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
                            AsyncImage(url: self.mumorys[0].song.artworkUrl, transaction: Transaction(animation: .easeInOut(duration: 0.1))) { phase in
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
            .offset(x: getUIScreenBounds().width * 0.435 - 72 - 15, y: getUIScreenBounds().width * 0.435 - 36 - 15)
        }
    }
}
