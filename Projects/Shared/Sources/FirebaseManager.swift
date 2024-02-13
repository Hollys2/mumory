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
    public let auth: Auth
    public let storage: Storage
    
    public typealias Timestamp = FirebaseFirestore.Timestamp
    
    public func timestampToString(timestamp: Timestamp) -> String {
        
        let date = timestamp.dateValue()
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        let weekday = calendar.component(.weekday, from: date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE" // 요일을 문자열로 표시하기 위한 포맷
        let dayOfWeek = dateFormatter.string(from: date)
        
        let result = "\(year)년 \(month)월 \(day)일 \(dayOfWeek)"
        
        return result
    }

    
    private init() {
        self.db = Firestore.firestore()
        self.auth = Auth.auth()
        self.storage = Storage.storage()
    }
}
