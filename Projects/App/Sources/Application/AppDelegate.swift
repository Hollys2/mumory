//
//  AppDelegate.swift
//  App
//
//  Created by 다솔 on 2023/11/08.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate{

    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}
