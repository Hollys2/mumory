//
//  FirebaseManager.swift
//  Core
//
//  Created by 다솔 on 2023/11/14.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import FirebaseMessaging
import FirebaseFunctions

struct FBManager {
    public let db: Firestore
    public let auth: Auth
    public let storage: Storage
    public let app: FirebaseApp?
    public let messaging: Messaging
    public let functions: Functions
    
    public init() {
        self.db = Firestore.firestore()
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.app = FirebaseApp.app()
        self.messaging = Messaging.messaging()
        self.functions = Functions.functions()
    }
}

public class FirebaseManager {
    
    public static let shared = FirebaseManager()
    
    public let db: Firestore
    public let auth: Auth
    public let storage: Storage
    public let app: FirebaseApp?
    public let messaging: Messaging
    public let functions: Functions
    
    public typealias Timestamp = FirebaseFirestore.Timestamp
    public typealias Document = DocumentSnapshot
    public typealias Fieldvalue = FieldValue
        
    public init() {
        self.db = Firestore.firestore()
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.app = FirebaseApp.app()
        self.messaging = Messaging.messaging()
        self.functions = Functions.functions()
    }
    
    public func getDocumentReference(collection: String, document: String) -> DocumentReference {
        return db.collection(collection).document(document)
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
    
    public func timestampToString(timestamp: Timestamp) -> String {
        
        let date = timestamp.dateValue()
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
//        let hour = calendar.component(.hour, from: date)
//        let minute = calendar.component(.minute, from: date)
//        let second = calendar.component(.second, from: date)
//        let weekday = calendar.component(.weekday, from: date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeek = dateFormatter.string(from: date)
        
        let result = "\(year)년 \(month)월 \(day)일 \(dayOfWeek)"
        
        return result
    }
}

public struct FriendSearch: Identifiable, Equatable, Hashable {
    
    public var uid = UUID()
    
    public var nickname: String
    public var id: String
    
    public init(nickname: String, id: String) {
        self.nickname = nickname
        self.id = id
    }
    
    public static func == (lhs: FriendSearch, rhs: FriendSearch) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
