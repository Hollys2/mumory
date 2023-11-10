//
//  FirebaseManager.swift
//  Core
//
//  Created by 다솔 on 2023/11/09.
//  Copyright © 2023 hollys. All rights reserved.
//


import UIKit
import FirebaseCore
import FirebaseFirestore

public class FirestoreManager {
    public static let shared = FirestoreManager()
    public let db: Firestore
    
    private init() {
        db = Firestore.firestore()
    }
}

