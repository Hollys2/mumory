//
//  AppDelegate.swift
//  App
//
//  Created by 다솔 on 2023/11/08.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import FirebaseCore
//import KakaoSDKCommon
import GoogleSignIn

public class AppDelegate: NSObject, UIApplicationDelegate{

    public func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("launch in appdelegate")
        FirebaseApp.configure()
//        KakaoSDK.initSDK(appKey: "ac7735b6f63e81d971e4a58a05994260")
        return true
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("handle url")
        return GIDSignIn.sharedInstance.handle(url)
    }

}

