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
                ForEach(getPastYears(), id: \.self) { year in
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
                self.selectedDate = pickerDate
                
                let calendar = Calendar.current
                let lastDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1, hour: 24 + 8, minute: 59, second: 59), to: selectedDate)!
                let range = ...lastDayOfMonth
                let newDataBeforeSelectedDate = mumoryDataViewModel.myMumorys.filter { range.contains($0.date) }
                
                for m in newDataBeforeSelectedDate {
                    print("date: \(m.date)")
                }
                mumoryDataViewModel.myMumorys = newDataBeforeSelectedDate
                
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

}

