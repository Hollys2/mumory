//
//  AppCoordinator.swift
//  Shared
//
//  Created by 다솔 on 2023/12/01.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Foundation

public enum StackViewType {
    case firstView
    case secondView
}

public struct StackView: Hashable {
    public let type: StackViewType
//    let content: String
    
//    public init() {
//        self.type = .firstView
//    }
}


@available(iOS 16.0, *)
public class AppCoordinator: ObservableObject {

    @Published public var rootPath: NavigationPath = NavigationPath()
    @Published public var createMumoryPath: NavigationPath = NavigationPath()
    
    @Published public var isCreateMumorySheetShown = false
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
    @Published public var isAddFriendViewShown = false
    @Published public var isPopUpViewShown = false
    
    @Published public var isTestViewShown = false
    
    @Published public var isNavigationStackShown = false
    
    @Published public var page: Int = -1
    
    @Published public var translation: CGSize = CGSize(width: 0, height: 0)
    
    @Published public var safeAreaInsetsTop: CGFloat = 0.0
    @Published public var safeAreaInsetsBottom: CGFloat = 0.0
    
    @Published public var selectedDate = Date()
    
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

    public func formattedDate(date: Date, dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
        
        //        let date = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: 1)) ?? Date()
        //        return dateFormatter.string(from: date)
    }
    
    public static func getYearMonthDate(year: Int, month: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        
        return Calendar.current.date(from: components) ?? Date()
    }
    
    public init () {}
}
