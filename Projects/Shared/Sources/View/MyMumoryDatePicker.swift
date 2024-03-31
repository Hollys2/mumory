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
    
    @State private var pickerDate: Date = Date()
    @State private var selectedYear: Int = 0
    @State private var selectedMonth: Int = 0
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    @Environment(\.dismiss) private var dismiss

    
    public init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
    }
    
    public var body: some View {
        VStack(spacing: 0) {
                  
            Picker("Year and Month", selection: self.$pickerDate) {
                ForEach(getMumoryDate().keys.sorted().reversed(), id: \.self) { year in
                    ForEach(getMumoryDate()[year]!, id: \.self) { month in
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
                print("pickerDate: \(pickerDate)")
                self.selectedDate = pickerDate
                
                let calendar = Calendar.current
                let lastDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1, hour: 24 + 8, minute: 59, second: 59), to: selectedDate)!
                let range = ...lastDayOfMonth
                let newDataBeforeSelectedDate = mumoryDataViewModel.myMumorys.filter { range.contains($0.date) }
                
                mumoryDataViewModel.filteredMumorys = []
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    mumoryDataViewModel.filteredMumorys = newDataBeforeSelectedDate
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
    }
    
    func getPastYears() -> [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear - 20)...currentYear) // 20년 전부터 현재 연도까지
    }

    func getMonths(forYear year: Int) -> [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        var months: [Int] = []
        if year == currentYear { // 현재 연도라면 현재 월까지만 추가
            months = Array(1...currentMonth)
        } else {
            months = Array(1...12)
        }
        
        return months
    }
    
    func getMumoryDate() -> [Int: [Int]]{
        
        var yearMonthDictionary = [Int: [Int]]()
        // Mumory 배열을 순회하면서 연도와 월을 추출하여 배열에 추가
        
        let mumoryArray: [Mumory] = mumoryDataViewModel.myMumorys
        
        // 딕셔너리를 생성하여 연도를 키로 하고 해당 연도에 속하는 월의 배열을 값으로 함
//        var yearMonthDictionary = [Int: [Int]]()
        
        // Mumory 배열을 순회하면서 연도와 월을 추출하여 딕셔너리에 추가
        for mumory in mumoryArray {
            let mumoryYear = Calendar.current.component(.year, from: mumory.date)
            let mumoryMonth = Calendar.current.component(.month, from: mumory.date)
            
            // 딕셔너리에 이미 해당 연도가 있는지 확인하고 없으면 새로운 배열을 생성하여 추가
            if yearMonthDictionary[mumoryYear] == nil {
                yearMonthDictionary[mumoryYear] = [mumoryMonth]
            } else {
                // 이미 해당 연도가 있는 경우 해당 연도의 배열에 월을 추가
                yearMonthDictionary[mumoryYear]?.append(mumoryMonth)
            }
        }
        
        // 값으로 저장된 배열에서 중복을 제거하고 내림차순으로 정렬
        for (year, months) in yearMonthDictionary {
            yearMonthDictionary[year] = Array(Set(months)).sorted(by: >)
        }

        
        // 결과 확인
        return yearMonthDictionary
    }

}

public struct MonthlyStatDatePicker: View {
    
    @Binding var selectedDate: Date
    
    @State private var pickerDate: Date = Date()
    @State private var selectedYear: Int = 0
    @State private var selectedMonth: Int = 0
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
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
                let filteredMumorys = mumoryDataViewModel.myMumorys.filter { mumory in
                    let dataYear = Calendar.current.component(.year, from: mumory.date)
                    let dataMonth = Calendar.current.component(.month, from: mumory.date)
                    return dataYear == selectedYear && dataMonth == selectedMonth
                }
                
                mumoryDataViewModel.filteredMumorys = filteredMumorys

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
        return Array((2024)...currentYear)
    }

    func getMonths(forYear year: Int) -> [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        var months: [Int] = []
        if year == currentYear { // 현재 연도라면 현재 월까지만 추가
            months = Array(1...currentMonth)
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
