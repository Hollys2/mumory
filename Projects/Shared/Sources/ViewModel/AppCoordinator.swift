//
//  AppCoordinator.swift
//  Shared
//
//  Created by 다솔 on 2023/12/01.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Foundation
import MusicKit


public class AppCoordinator: ObservableObject {
    
    @Published public var currentUser: MumoriUser = MumoriUser()

    @Published public var rootPath: NavigationPath = NavigationPath()
    @Published public var selectedTab: Tab = .home
    @Published public var offsetY: CGFloat = .zero
    @Published public var isCreateMumorySheetShown: Bool = false
    @Published public var isSearchLocationViewShown = false
    @Published public var isSearchLocationMapViewShown = false
    @Published public var isMumoryDetailShown = false
    @Published public var isNavigationBarShown = true
    @Published public var isNavigationBarColored = false
    @Published public var isReactionBarShown = true
    @Published public var isMumoryDetailMenuSheetShown = false
    @Published public var isMumoryDetailShownInSocial = false
    @Published public var isMumoryPopUpShown = false
    @Published public var isSocialMenuSheetViewShown = false
    @Published public var isMumoryDetailCommentSheetViewShown = false
    @Published public var isSocialCommentSheetViewShown: Bool = false
    @Published public var isMyMumorySearchViewShown: Bool = false
    @Published public var isMumoryMapSheetShown: Bool = false
    @Published public var comments: [Comment] = []
    @Published public var isCommentBottomSheetShown = false
    @Published public var isMyMumoryBottomSheetShown = false
    @Published public var isDeleteCommentPopUpViewShown = false
    @Published public var isAddFriendViewShown = false
    @Published public var isPopUpViewShown = false
    @Published public var isRewardPopUpViewShown = false
    @Published public var isDeleteMumoryPopUpViewShown = false
    @Published public var isLoading = false
    @Published public var isFirstTabSelected: Bool = false
    
    @Published public var isTestViewShown = true
    
    @Published public var isNavigationStackShown = false
    
    @Published public var choosedSongID: MusicItemID?
    @Published public var choosedMumoryAnnotation: Mumory = Mumory()
    
    @Published public var page: Int = -1
    
    @Published public var translation: CGSize = CGSize(width: 0, height: 0)
    
    @Published public var safeAreaInsetsTop: CGFloat = 0.0
    @Published public var safeAreaInsetsBottom: CGFloat = 0.0
    @Published public var keyboardHeight: CGFloat = 0.0
    @Published public var isKeyboardButtonShown: Bool = false
    
    @Published public var selectedDate = Date()
    @Published public var isHiddenTabBar: Bool = false
    @Published public var isHiddenTabBarWithoutAnimation: Bool = false
    
    @Published public var bottomAnimationViewStatus: BottomAnimationPage = .remove
    
    public var selectedYear: Int {
        Calendar.current.component(.year, from: self.selectedDate)
     }

    public var selectedMonth: Int {
        Calendar.current.component(.month, from: self.selectedDate)
    }
    
    public func updateSelectedDate(year: Int, month: Int){
         var components = DateComponents()
         components.year = year
         components.month = month

        self.selectedDate = Calendar.current.date(from: components) ?? Date()
     }
    
    //아래에서 나오는 뷰 관리 용도
    public enum BottomAnimationPage {
        case myPage
        case play
        case remove
    }
    
    public func setBottomAnimationPage(page: BottomAnimationPage) {
        withAnimation {
            self.bottomAnimationViewStatus = page
        }
    }
    
    public init () {}
}

public class DateManager: ObservableObject {
    
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
    
