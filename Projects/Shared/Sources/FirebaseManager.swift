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
import Firebase
import FirebaseMessaging

public class FirebaseManager {
    
    public static let shared = FirebaseManager()
    public let db: Firestore
    public let storage: Storage
    public let auth: Auth
    public let app: FirebaseApp?
    public let messaging: Messaging
    
    private init() {
        db = Firestore.firestore()
        storage = Storage.storage()
        auth = Auth.auth()
        app = FirebaseApp.app()
        messaging = Messaging.messaging()
    }
}
