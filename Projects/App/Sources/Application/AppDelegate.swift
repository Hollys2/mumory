//
//  AppDelegate.swift
//  App
//
//  Created by 다솔 on 2023/11/08.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import FirebaseCore
import KakaoSDKCommon
import KakaoSDKUser
import KakaoSDKAuth
import GoogleSignIn
import FirebaseMessaging

public class AppDelegate: NSObject, UIApplicationDelegate{

    public func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("launch in appdelegate")
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
               UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, _ in
                       if granted {
                           print("알림 등록이 완료되었습니다.")
                       }
                   }
               application.registerForRemoteNotifications()
        
        //테스트용 키. 추후에 원본 키로 수정하기
        KakaoSDK.initSDK(appKey: "ac7735b6f63e81d971e4a58a05994260")
        return true
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var gid = false
        gid = GIDSignIn.sharedInstance.handle(url)
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        }
        return gid
    }
    

}
extension AppDelegate: MessagingDelegate {
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("fcm token: \(fcmToken ?? "no fcm token")")
    }
}
extension AppDelegate: UNUserNotificationCenterDelegate{
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    // foreground 상에서 알림이 보이게끔 해준다.
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}

