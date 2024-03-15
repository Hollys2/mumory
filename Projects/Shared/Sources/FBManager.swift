//
//  FBManager.swift
//  Shared
//
//  Created by 제이콥 on 3/10/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Firebase
import FirebaseMessaging
import FirebaseFunctions

public class FBManager {
    
    public static let shared = FBManager()
    public let db: Firestore
    public let storage: Storage
    public let auth: Auth
    public let app: FirebaseApp?
    public let messaging: Messaging
    public let functions: Functions
    public typealias TimeStamp = Timestamp
    public typealias Document = DocumentSnapshot

    private init() {
        db = Firestore.firestore()
        storage = Storage.storage()
        auth = Auth.auth()
        app = FirebaseApp.app()
        messaging = Messaging.messaging()
        functions = Functions.functions()
    }
    
    public func getGoogleCredential(idToken: String, accessToken: String) -> AuthCredential {
        return GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
    }
    
    public func storageMetadata() -> StorageMetadata {
        return StorageMetadata()
    }
    
    public func deleteFieldValue() -> FieldValue {
        return FieldValue.delete()
    }
}
