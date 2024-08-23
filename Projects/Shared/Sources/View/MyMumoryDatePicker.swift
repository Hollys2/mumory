//
//  MyMumoryDatePicker.swift
//  Shared
//
//  Created by 다솔 on 2024/03/27.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI


public struct MyMumoryDatePicker: View {
    
    @Binding var selectedDate: Date
    let user: UserProfile
    
    @State private var yearMonth: [Int: [Int]] = [:]
    @State private var pickerDate: Date = Date()
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    public init(selectedDate: Binding<Date>, user: UserProfile) {
        self._selectedDate = selectedDate
        self.user = user
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Picker("Year and Month", selection: self.$pickerDate) {
                ForEach(self.yearMonth.keys.sorted(by: >), id: \.self) { year in
                    ForEach(self.yearMonth[year]!, id: \.self) { month in
                        Text("\(String(format: "%d", year))년 \(month)월")
                            .tag(DateManager.getYearMonthDate(year: year, month: month))
                            .foregroundColor(.white)
                    }
                }
            }
            .pickerStyle(WheelPickerStyle())
            
            Button(action: {
                print("pickerDate: \(pickerDate)")
                self.selectedDate = pickerDate

                let calendar = Calendar.current
                let lastDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1, hour: 24 + 8, minute: 59, second: 59), to: selectedDate)!
                let range = ...lastDayOfMonth
                let newDataBeforeSelectedDate = self.user.uId == currentUserViewModel.user.uId ? self.currentUserViewModel.mumoryViewModel.myMumorys.filter { range.contains($0.date) } : self.currentUserViewModel.mumoryViewModel.friendMumorys.filter { range.contains($0.date) }
                
                let mumorys = self.user.uId == currentUserViewModel.user.uId ? self.currentUserViewModel.mumoryViewModel.myMumorys : self.currentUserViewModel.mumoryViewModel.friendMumorys
                let filtedMumorys = mumorys.filter { mumory in
                    let pickedYear = Calendar.current.component(.year, from: self.pickerDate)
                    let pickedMonth = Calendar.current.component(.month, from: self.pickerDate)
                    let components = Calendar.current.dateComponents([.year, .month], from: mumory.date)
                    return components.year == pickedYear  && components.month == pickedMonth
                }
                
                self.currentUserViewModel.mumoryViewModel.monthlyMumorys = []
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.currentUserViewModel.mumoryViewModel.monthlyMumorys = filtedMumorys
                }
                
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
        .onAppear {
            self.yearMonth = getMumoryDate()
        }
    }

    func getMumoryDate() -> [Int: [Int]] {
        var yearMonthDictionary: [Int: [Int]] = [:]
        
        let mumoryArray: [Mumory] = self.user.uId == currentUserViewModel.user.uId ? self.currentUserViewModel.mumoryViewModel.myMumorys : self.currentUserViewModel.mumoryViewModel.friendMumorys
        
        for mumory in mumoryArray {
            let mumoryYear = Calendar.current.component(.year, from: mumory.date)
            let mumoryMonth = Calendar.current.component(.month, from: mumory.date)
            
            var months = yearMonthDictionary[mumoryYear, default: []]
            months.append(mumoryMonth)
            yearMonthDictionary[mumoryYear] = Array(Set(months)).sorted(by: >)
        }
        
        print("yearMonthDictionary: \(yearMonthDictionary)")

        return yearMonthDictionary
    }
}



public struct MonthlyStatDatePicker: View {
    
    @Binding var selectedDate: Date
    
    @State private var pickerDate: Date = Date()
    @State private var selectedYear: Int = 0
    @State private var selectedMonth: Int = 0
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    
    @Environment(\.dismiss) private var dismiss

    public init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Picker("Year and Month", selection: self.$pickerDate) {
                ForEach(getYears(), id: \.self) { year in
                    ForEach(getMonths(forYear: year), id: \.self) { month in
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
                var components = DateComponents()
                components.year = Calendar.current.component(.year, from: self.pickerDate)
                components.month = Calendar.current.component(.month, from: self.pickerDate)
                components.day = pickerDate.lastDayOfMonth()
                self.selectedDate = Calendar.current.date(from: components) ?? Date()
                
                let selectedYear = Calendar.current.component(.year, from: pickerDate)
                let selectedMonth = Calendar.current.component(.month, from: pickerDate)
                let filteredMumorys = self.currentUserViewModel.mumoryViewModel.myMumorys.filter { mumory in
                    let dataYear = Calendar.current.component(.year, from: mumory.date)
                    let dataMonth = Calendar.current.component(.month, from: mumory.date)
                    return dataYear == selectedYear && dataMonth == selectedMonth
                }
                
                self.currentUserViewModel.mumoryViewModel.monthlyMumorys = filteredMumorys

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
    
    func getYears() -> [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let siginUpYear = Calendar.current.component(.year, from: currentUserViewModel.user.signUpDate)
        return Array(siginUpYear...currentYear)
    }

    func getMonths(forYear year: Int) -> [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        let siginUpYear = Calendar.current.component(.year, from: currentUserViewModel.user.signUpDate)
        let siginUpMonth = Calendar.current.component(.month, from: currentUserViewModel.user.signUpDate)
        
        var months: [Int] = []
        if year == currentYear { // 현재 연도라면 현재 월까지만 추가
            months = Array(siginUpMonth...currentMonth)
        } else {
            months = Array(1...12)
        }
        
        return months
    }
}

extension Date {
    func lastDayOfMonth() -> Int? {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: self) else { return nil }
        return range.upperBound - 1
    }
}
