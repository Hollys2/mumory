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

public class FirebaseManager {
    
    public static let shared = FirebaseManager()
    public let db: Firestore
//    public let storage: Storage
    public let auth: Auth
    public let app: FirebaseApp?
    
    private init() {
        db = Firestore.firestore()
//        storage = Storage.storage()
        auth = Auth.auth()
        app = FirebaseApp.app()
    }
    
    public func getGoogleCredential(idToken: String, accessToken: String) -> AuthCredential {
        return GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
    }
}
