//
//  MonthlyStatView.swift
//  Feature
//
//  Created by 다솔 on 2024/01/30.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import Shared


public struct MonthlyStatView: View {
    
    @State private var selectedDate: Date = Date()
    @State private var isDatePickerShown: Bool = false
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
    
    public init() {}
    
    public var body: some View {
        
        VStack(spacing: 0) {
            
            TopBarView(title: "월간 통계", rightBarButtonNavigationPath: nil, paddingBottom: 28)
            
            ZStack(alignment: .top) {
                
                ScrollView(showsIndicators: false) {
                    
                    ContentView(date: self.$selectedDate)
                }
                .frame(width: getUIScreenBounds().width - 40)
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(SharedAsset.backgroundColor.swiftUIColor.opacity(0.9))
                    
                    HStack(spacing: 6) {
                        Text("\(DateManager.formattedDate(date: self.selectedDate, dateFormat: "YYYY"))년 \(DateManager.formattedDate(date: self.selectedDate, dateFormat: "M"))월")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                            .foregroundColor(.white)
                        
                        SharedAsset.dateButtonMypage.swiftUIImage
                            .resizable()
                            .frame(width: 15, height: 15)
                    }
                    .offset(x: 24)
                    .onTapGesture {
                        UIView.setAnimationsEnabled(false)
                        self.isDatePickerShown = true
                    }
                }
            }
        }
        .background(SharedAsset.backgroundColor.swiftUIColor)
        .fullScreenCover(isPresented: $isDatePickerShown, content: {
            BottomSheetWrapper(isPresent: $isDatePickerShown) {
                MonthlyStatDatePicker(selectedDate: self.$selectedDate)
                    .frame(height: 309)
            }
            .background(TransparentBackground())
        })
    }
}

struct ContentView: View {
    
    @Binding var date: Date
    
    @State var mumoryMonthly: [Mumory] = []
    @State var mumoriesCountByMonth: [Int] = Array(repeating: 0, count: 12)
    @State var mumoriesLikeCount: Int = 0
    @State var mumoriesCommentCount: Int = 0
    
    @State var days: Int = 0
    @State var mumoryDaily: [Int: [Mumory]] = [:]
    @State private var filteredLocations: [String: [Mumory]] = [:]
    
    @State var bottomPadding: CGFloat = 0
    @State var isPopUpViewShown: Bool = false
    
    @State private var favoriteGenre: String = "-"
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            ZStack(alignment: .topLeading) {
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: getUIScreenBounds().width - 40, height: 108)
                    .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                    .cornerRadius(15)
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("\(currentUserData.user.nickname)님의 이달의 관심 음악 장르는")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                        .foregroundColor(.white)
                    
                    Group {
                        
                        HStack(spacing: 0) {
                            
                            Text(self.favoriteGenre)
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 24))
                                .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                            
                            + Text("  입니다")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .overlay(
                            MonthlyStatGenrePopUpView()
                                .offset(x: 6, y: 3)
                                .opacity(self.favoriteGenre == "-" ? 1 : 0)
                            , alignment: .trailing
                        )
                        .onAppear {
                            Task {
                                // 뮤모리 외 MonthlyStat 컬렉션 추후 사용하기
                                let mumorySongIds: [String] = self.mumoryMonthly.map { $0.musicModel.songID.rawValue }
                                
                                self.favoriteGenre = await getModeGenre(songIds: mumorySongIds)
                            }
                        }
                    }
                }
                .padding(.top, 28)
                .padding(.horizontal, 20)
                
                SharedAsset.infoIconMonthlyStat.swiftUIImage
                    .resizable()
                    .frame(width: 15, height: 15)
                    .offset(x: getUIScreenBounds().width - 40 - 15 - 11, y: 108 - 15 - 11)
                    .onTapGesture {
                        self.isPopUpViewShown = true
                    }
            }
            
            ZStack(alignment: .topLeading) {
                
                VStack(spacing: 0) {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(DateManager.formattedDate(date: self.date, dateFormat: "M"))월 뮤모리 작성")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                            .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                        
                        HStack(spacing: 0) {
                            
                            Text("\(self.mumoryMonthly.count)개")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                                .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                            
                            Spacer()
                            
                            Text("\(DateManager.formattedDate(date: self.date, dateFormat: "M"))월 \(DateManager.formattedDate(date: self.date, dateFormat: "d"))일, \(DateManager.formattedRegionDate(date: self.date))")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                        }
                        .padding(.top, 13)
                    }
                    .padding(.top, 22)
                    .padding(.horizontal, 20)
                    
                    ScrollViewReader { proxy in
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            
                            HStack(spacing: 10) {
                                
                                ForEach(self.mumoryDaily.keys.sorted(), id: \.self) { day in
                                    let count = mumoryDaily[day]?.count ?? 0
                                    
                                    if DateManager.formattedDate(date: self.date, dateFormat: "d") == String(day) {
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(width: 42, height: 66)
                                            .background(Color(red: 0.89, green: 0.89, blue: 0.89))
                                            .cornerRadius(30)
                                            .overlay(
                                                Text("\(day)")
                                                    .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 15))
                                                    .multilineTextAlignment(.center)
                                                    .foregroundColor(.black)
                                                    .frame(height: 11)
                                                    .offset(y: -33 + 5.5 + 11)
                                            )
                                            .overlay(
                                                Circle()
                                                    .fill(Color(red: 0.64, green: 0.51, blue: 0.99))
                                                    .frame(width: 32, height: 32)
                                                    .overlay(
                                                        Text(count > 0 ? "+\(count)" : "")
                                                            .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 14))
                                                            .multilineTextAlignment(.center)
                                                            .foregroundColor(.black)
                                                    )
                                                    .offset(y: 12)
                                            )
                                            .id(0)
                                    } else if Int(DateManager.formattedDate(date: self.date, dateFormat: "d")) ?? 0 > day {
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(width: 42, height: 66)
                                            .background(Color(red: 0.47, green: 0.47, blue: 0.47))
                                            .cornerRadius(30)
                                            .overlay(
                                                Text("\(day)")
                                                    .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 15))
                                                    .multilineTextAlignment(.center)
                                                    .foregroundColor(Color(red: 0.21, green: 0.21, blue: 0.21))
                                                    .frame(height: 11)
                                                    .offset(y: -33 + 5.5 + 11)
                                            )
                                            .overlay(
                                                Circle()
                                                    .fill(Color(red: 0.76, green: 0.76, blue: 0.76))
                                                    .frame(width: 32, height: 32)
                                                    .overlay(
                                                        Text(count > 0 ? "+\(count)" : "")
                                                            .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 14))
                                                            .multilineTextAlignment(.center)
                                                            .foregroundColor(.black)
                                                    )
                                                    .offset(y: 12)
                                            )
                                    }
                                    
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .onAppear {
                            proxy.scrollTo(0, anchor: .trailing)
                        }
                        .onChange(of: self.date, perform: { _ in
                            proxy.scrollTo(0, anchor: .trailing)
                        })
                        .padding(.top, 25)
                    }
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: getUIScreenBounds().width * 0.82, height: 0.5)
                        .background(Color(red: 0.28, green: 0.28, blue: 0.28))
                        .padding(.top, 27)
                    
                    HStack(spacing: 0) {
                        
                        ZStack(alignment: .leading) {
                            
                            VStack(alignment: .leading, spacing: 7.5) {
                                Text("받은 좋아요")
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                    .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                
                                Text("\(mumoriesLikeCount)개")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                    .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                            }
                            
                            VStack(alignment: .leading, spacing: 7.5) {
                                Text("받은 댓글")
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                    .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                
                                Text("\(mumoriesCommentCount)개")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                    .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                            }
                            .offset(x: (getUIScreenBounds().width - 40) / 2)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 21)
                    .padding(.horizontal, 20)
                }
                .frame(width: getUIScreenBounds().width - 40)
                .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                .cornerRadius(15)
                .frame(width: getUIScreenBounds().width)
                
                
                if self.isPopUpViewShown {
                    MonthlyStatPopUpView(isShown: self.$isPopUpViewShown)
                        .offset(x: getUIScreenBounds().width - 270 - 20 + 5, y: -20)
                }
            }
            .padding(.top, 15)
            
            Text("뮤모리된 지역")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 30)
            
            HStack(spacing: 10) {
                let sortedLocationsArray = filteredLocations.sorted(by: { $0.key < $1.key })
                
                ForEach(Array(sortedLocationsArray.prefix(3).enumerated()), id: \.element.key) { index, element in
                    let region = element.key
                    let mumories = element.value
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: getUIScreenBounds().width * 0.28, height: getUIScreenBounds().width * 0.28)
                        .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                        .cornerRadius(15)
                        .overlay(
                            VStack(spacing: 0) {
                                HStack(alignment: .center, spacing: 10) {
                                    Text("TOP \(index + 1)")
                                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.white)
                                        .frame(height: 8)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, getUIScreenBounds().width * 0.015)
                                .background(Color(red: 0.32, green: 0.32, blue: 0.32))
                                .cornerRadius(30)
                                .padding(.top, getUIScreenBounds().width * 0.28 * 0.1)
                                
                                Spacer()
                                
                                Text("\(region)")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(mumories.count)개")
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                                    .frame(height: 15)
                                    .padding(.bottom, getUIScreenBounds().width * 0.28 * 0.12)
                            }
                                .frame(height: getUIScreenBounds().width * 0.28)
                        )
                }
                
                if sortedLocationsArray.count < 3 {
                    Spacer(minLength: 0)
                }
            }
            .padding(.top, 15)
            
            Text("음악 활동")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 30)
            
            HStack(spacing: 10) {
                
                ForEach(0..<2) { i in
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: getUIScreenBounds().width * 0.435, height: 108)
                        .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                        .cornerRadius(15)
                        .overlay(
                            VStack(alignment: .leading) {
                                Text(i == 0 ? "새 플레이리스트" : "즐겨찾기한 음악")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                                    .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                
                                Spacer()
                                
                                Text(i == 0 ? "\(currentUserData.playlistArray.count)개" : "\(currentUserData.playlistArray.first(where: {$0.id == "favorite"})?.songIDs.count ?? 0)개")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                                    .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                            }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(20)
                        )
                }
            }
            .padding(.top, 15)
            
            Spacer()
        }
        .frame(width: getUIScreenBounds().width - 40)
        .padding(.top, 65)
        .onAppear {
            for (region, boundary) in MapConstant.boundaries {
                let filteredMumorys = mumoryDataViewModel.myMumorys.filter { mumory in
                    let latInRange = boundary.latitude.min <= mumory.locationModel.coordinate.latitude && mumory.locationModel.coordinate.latitude <= boundary.latitude.max
                    let lonInRange = boundary.longitude.min <= mumory.locationModel.coordinate.longitude && mumory.locationModel.coordinate.longitude <= boundary.longitude.max
                    return latInRange && lonInRange
                }
                
                if !filteredMumorys.isEmpty {
                    self.filteredLocations[region] = filteredMumorys
                }
            }
            
            var daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
            let calendar = Calendar.current
            let year = calendar.component(.year, from: Date())
            let isLeapYear = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
            if isLeapYear {
                daysInMonth[1] = 29
            }
            let month = calendar.component(.month, from: self.date)
            self.days = daysInMonth[month - 1]
            self.mumoryMonthly = mumoryDataViewModel.myMumorys.filter { Calendar.current.component(.month, from: $0.date) == month }
            //                            self.mumoryMonthly = mumoryDataViewModel.filteredMumorys
            
            for mumory in self.mumoryMonthly {
                let day = Calendar.current.component(.day, from: mumory.date)
                
                // 해당 "일"을 키로 사용하여 딕셔너리에 추가합니다.
                if var mumories = self.mumoryDaily[day] {
                    // 이미 해당 "일"에 해당하는 Mumory 배열이 있는 경우에는 해당 배열에 Mumory를 추가합니다.
                    mumories.append(mumory)
                    self.mumoryDaily[day] = mumories
                } else {
                    // 해당 "일"에 해당하는 Mumory 배열이 없는 경우에는 새로운 배열을 생성하여 Mumory를 추가합니다.
                    self.mumoryDaily[day] = [mumory]
                }
            }
            
            for day in 1...self.days {
                if self.mumoryDaily[day] == nil {
                    self.mumoryDaily[day] = []
                }
            }
            
            for mumory in self.mumoryMonthly {
                for uId in mumory.likes {
                    if uId != currentUserData.user.uId {
                        mumoriesLikeCount += 1
                    }
                }
                
                mumoriesCommentCount += mumory.commentCount
            }
        }
        .onChange(of: self.date, perform: { _ in
            print("처음")
            self.mumoryDaily = [:]
            var daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
            let calendar = Calendar.current
            let year = calendar.component(.year, from: Date())
            let isLeapYear = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
            if isLeapYear {
                daysInMonth[1] = 29
            }
            let month = calendar.component(.month, from: self.date)
            self.days = daysInMonth[month - 1]
            self.mumoryMonthly = mumoryDataViewModel.myMumorys.filter { Calendar.current.component(.month, from: $0.date) == month }
            //                            self.mumoryMonthly = mumoryDataViewModel.filteredMumorys
            
            for mumory in self.mumoryMonthly {
                let day = Calendar.current.component(.day, from: mumory.date)
                
                // 해당 "일"을 키로 사용하여 딕셔너리에 추가합니다.
                if var mumories = self.mumoryDaily[day] {
                    // 이미 해당 "일"에 해당하는 Mumory 배열이 있는 경우에는 해당 배열에 Mumory를 추가합니다.
                    mumories.append(mumory)
                    self.mumoryDaily[day] = mumories
                } else {
                    // 해당 "일"에 해당하는 Mumory 배열이 없는 경우에는 새로운 배열을 생성하여 Mumory를 추가합니다.
                    self.mumoryDaily[day] = [mumory]
                }
            }
            
            for day in 1...self.days {
                if self.mumoryDaily[day] == nil {
                    self.mumoryDaily[day] = []
                }
            }
            
            mumoriesLikeCount = 0
            mumoriesCommentCount = 0
            
            for mumory in self.mumoryMonthly {
                for uId in mumory.likes {
                    if uId != currentUserData.user.uId {
                        mumoriesLikeCount += 1
                    }
                }
                
                mumoriesCommentCount += mumory.commentCount
            }
        })
    }
}

struct MonthlyStatPopUpView: View {
    
    @Binding var isShown: Bool
    
    var body: some View {
        
        VStack(alignment: .trailing, spacing: 0) {
            
            SharedAsset.popupUnionMonthlyStat.swiftUIImage
                .resizable()
                .frame(width: 12.12436, height: 9.75)
                .offset(x: -16.94, y: 1)
            
            HStack(alignment: .bottom, spacing: 6) {
                
                Text("뮤모리 기록, 재생 / 즐겨찾기 / 플레이리스트\n바탕으로 수집된 데이터 기반으로 나오는 결과입니다")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 11))
                    .foregroundColor(.black)
                    .frame(alignment: .topLeading)
                    .lineLimit(2)
                    .lineSpacing(5)
                    .fixedSize(horizontal: true, vertical: false)
                
                SharedAsset.closeButtonPopup.swiftUIImage
                    .resizable()
                    .frame(width: 13, height: 13)
                    .onTapGesture {
                        self.isShown = false
                    }
            }
            .padding(.leading, 17)
            .padding(.vertical, 13)
            .frame(width: 270, alignment: .leading)
            .background(Color(red: 0.64, green: 0.51, blue: 0.99))
            .cornerRadius(17)
        }
    }
}
