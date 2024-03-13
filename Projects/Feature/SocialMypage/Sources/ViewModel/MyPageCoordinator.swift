//
//  MyPageViewModel.swift
//  Feature
//
//  Created by 제이콥 on 2/27/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import SwiftUI
import Shared

public enum MyPage: Hashable {
//    case myPage
    case setting
    case account
    case notification
    case setPW
    case question
    case emailVerification
    case selectNotificationTime
    case login
    case friendList(friends: [MumoriUser])
    case friendPage(friend: MumoriUser)
    case activityList
}
class MyPageCoordinator: ObservableObject {
    @Published public var stack: [MyPage] = []
    public init() {}
    
    func pop() {
        _ = self.stack.popLast()
    }
    
    func push(destination: MyPage) {
        self.stack.append(destination)
    }
    
    func resetPath(destination: MyPage){
        self.stack.removeAll()
        self.stack.append(destination)
    }
        
    @ViewBuilder
    func getView(destination: MyPage) -> some View {
        switch(destination){
        case .setting:
            SettingView()
  
        case .account:
            AccountManageView()
         
        case .notification:
            NotificationView()
             
        case .setPW:
            SetPWView()

        case .question:
            QuestionView()

        case .emailVerification:
            EmailLoginForWithdrawView()

        case .selectNotificationTime:
            SelectNotificationTimeView()
            
        case .login:
            LoginView()
            
        case .friendList(friends: let friends):
            FriendListView(friends: friends)
            
        case .friendPage(friend: let friend):
            FriendPageView(friend: friend)
            
        case .activityList:
            ActivityListView()
        }

    }
}
