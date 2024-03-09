//
//  GoogleManager.swift
//  Core
//
//  Created by 제이콥 on 1/28/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import GoogleSignIn

public class GoogleManager {
    public static let shared = GoogleManager()
    public let instance: GIDSignIn
    
    private init(){
        instance = GIDSignIn.sharedInstance
    }
    
    public func getConfiguration(clientID: String) -> GIDConfiguration {
        return GIDConfiguration(clientID: clientID)
    }
    
    
    
    
}
