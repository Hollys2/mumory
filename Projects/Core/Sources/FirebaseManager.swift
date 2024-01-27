//
//  FirebaseManager.swift
//  Core
//
//  Created by 다솔 on 2023/11/14.
//  Copyright © 2023 hollys. All rights reserved.
//


import FirebaseFirestore
import FirebaseAuth

import FirebaseStorage


public class FirebaseManager {
    
    public static let shared = FirebaseManager()
    public let db: Firestore
//    public let storage: Storage = Storage.storage()
    public let auth: Auth
    
    private init() {
        db = Firestore.firestore()
//        storage = Storage.storage()
        auth = Auth.auth()
    }
}
