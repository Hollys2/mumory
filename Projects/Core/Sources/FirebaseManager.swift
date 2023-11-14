//
//  FirebaseManager.swift
//  Core
//
//  Created by 다솔 on 2023/11/14.
//  Copyright © 2023 hollys. All rights reserved.
//


import FirebaseFirestore

public class FirebaseManager {
    
    public static let shared = FirebaseManager()
    public let db: Firestore
    
    private init() {
        db = Firestore.firestore()
    }
}
