//
//  AppDelegate.swift
//  App
//
//  Created by 다솔 on 2023/11/08.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Firebase
import KakaoSDKCommon

class AppDelegate: NSObject, UIApplicationDelegate{

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        FirebaseApp.configure()
        KakaoSDK.initSDK(appKey: "ac7735b6f63e81d971e4a58a05994260")
        
        return true
    }
}

