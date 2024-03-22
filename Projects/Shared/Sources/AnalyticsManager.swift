//
//  AnalyticsManager.swift
//  Shared
//
//  Created by 제이콥 on 3/21/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAnalytics

public class AnalyticsManager {
    static public let shared = AnalyticsManager()
    public init(){}
    
    
    public func setSelectContentLog(title: String){
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "id-\(title)",
            AnalyticsParameterItemName: title,
            AnalyticsParameterContentType: "cont",
        ])
    }
    
    public func setScreenLog(screenTitle: String) {
        Analytics.logEvent(AnalyticsEventScreenView,
                           parameters: [AnalyticsParameterScreenName: screenTitle])
    }
}
