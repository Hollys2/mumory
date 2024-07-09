//
//  MyPageManageView.swift
//  Feature
//
//  Created by 제이콥 on 2/27/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
//deprecated
struct MyPageManageView: View {
//    @EnvironmentObject var userManager: UserViewModel
//    @StateObject var myPageCoordinator: MyPageViewModel = MyPageViewModel()
//    @StateObject var withdrawManager: WithdrawViewModel = WithdrawViewModel()
//
    var body: some View {
        Text("")
//        NavigationStack {
//            ZStack(alignment: .top) {
//                ColorSet.background.ignoresSafeArea()
//                
//                ForEach(0 ..< myPageCoordinator.stack.count, id: \.self){ index in
//                    VStack(spacing: 0){
//                        switch(myPageCoordinator.stack[index]){
//                        case .myPage:
//                            MyPageView()
//                                .environmentObject(myPageCoordinator)
//
//                                
//                        case .setting:
//                            SettingView()
//                                .environmentObject(myPageCoordinator)
//                                .environmentObject(withdrawManager)
//
//
//                        case .account:
//                            AccountManageView()
//                                .environmentObject(myPageCoordinator)
//
//
//                        case .notification:
//                            NotificationView()
//                                .environmentObject(myPageCoordinator)
//
//                        case .setPW:
//                            SetPWView()
//                                .environmentObject(myPageCoordinator)
//                            
//                        case .question:
//                            QuestionView()
//                                .environmentObject(myPageCoordinator)
//                            
//                        case .emailVerification:
//                            EmailLoginForWithdrawView()
//                                .environmentObject(myPageCoordinator)
//                                .environmentObject(withdrawManager)
//
//                        case .selectNotificationTime:
//                            SelectNotificationTimeView()
//                                .environmentObject(myPageCoordinator)
//
//                        }
//                    }
//                    .offset(x: isCurrentPage(index: index) ? myPageCoordinator.xOffset : isPreviousPage(index: index) ? ((70/userManager.width) * myPageCoordinator.xOffset) - 70 : 0)
//                    .simultaneousGesture(drag)
//                    .transition(.move(edge: .trailing))
//                }
//            }
//            .onAppear {
//                myPageCoordinator.width = userManager.width
//            }
//            .navigationDestination(isPresented: $myPageCoordinator.goToLoginView) {
//                LoginView()
//            }
//        }
//     
//    }
//    
//    private func isCurrentPage(index: Int) -> Bool {
//        if index == 0 {
//            return false
//        }else if index == myPageCoordinator.stack.count - 1 {
//            return true
//        }else {
//            return false
//        }
//    }
//    
//    private func isPreviousPage(index: Int) -> Bool {
//        let length = myPageCoordinator.stack.count
//        if length > 1 && index == length - 2 {
//            return true
//        }else {
//            return false
//        }
//    }
//    
//    var drag: some Gesture {
//        DragGesture()
//            .onChanged({ drag in
//                if drag.startLocation.x > 20{
//                    return
//                }
//                DispatchQueue.main.async {
//                    myPageCoordinator.xOffset = drag.location.x
//                }
//            })
//            .onEnded({ drag in
//                if myPageCoordinator.stack.count < 1 || drag.startLocation.x > 20{
//                    return
//                }
//                
//                if drag.velocity.width > 1000.0{
//                    myPageCoordinator.pop()
//                }else if drag.location.x > userManager.width/2 {
//                    myPageCoordinator.shortPop()
//                }else{
//                    myPageCoordinator.revoke()
//                }
//            })
    }
}
