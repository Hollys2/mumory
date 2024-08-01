//
//  DateManager.swift
//  Shared
//
//  Created by 다솔 on 2024/05/14.
//  Copyright © 2024 hollys. All rights reserved.
//


import Foundation

public struct DateManager {
    
    public init () {}
    
    public static func formattedDate(date: Date, dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        return dateFormatter.string(from: date)
    }
    
    public static func formattedDate(date: Date, isPublic: Bool) -> String {
        let dateFormatter = DateFormatter()
        
        let currentYear = Calendar.current.component(.year, from: Date())
        let targetYear = Calendar.current.component(.year, from: date)
        
        if currentYear > targetYear {
            dateFormatter.dateFormat = isPublic ? "yyyy년 M월 d일" : "yyyy년 M월 d일 ・ "
        } else {
            dateFormatter.dateFormat = isPublic ? "M월 d일" : "M월 d일 ・ "
        }
        
        return dateFormatter.string(from: date)
    }
    
    public static func formattedCommentDate(date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute], from: date, to: Date())
        
        if let year = components.year, year > 0 {
            return "\(year)년 전"
        } else if let month = components.month, month > 0 {
            return "\(month)개월 전"
        } else if let week = components.weekOfYear, week > 0 {
            return "\(week)주 전"
        } else if let day = components.day, day > 0 {
            return "\(day)일 전"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)시간 전"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)분 전"
        } else {
            return "방금 전"
        }
    }
    
    public static func formattedRegionDate(date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute], from: date, to: Date())
        
        if let year = components.year, year > 0 {
            return "\(year)년 전"
        } else if let month = components.month, month > 0 {
            return "\(month)개월 전"
        } else if let week = components.weekOfYear, week > 0 {
            return "\(week)주 전"
        } else if let day = components.day, day > 0 {
            return "\(day)일 전"
        } else {
            return "오늘"
        }
    }
    
    public static func getYearMonthDate(year: Int, month: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        
        return Calendar.current.date(from: components) ?? Date()
    }
}
    
