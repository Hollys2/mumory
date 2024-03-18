//
//  CommentModel.swift
//  Shared
//
//  Created by 다솔 on 2024/03/15.
//  Copyright © 2024 hollys. All rights reserved.
//


import Foundation

public struct Comment: Codable, Hashable {
    
    public var id: String
    
    public let userDocumentID: String
    public let nickname: String
    public let parentId: String
    public let mumoryId: String
    public let date: Date
    public let content: String
    public let isPublic: Bool
    public var replies: [Comment] = []
    
    public init(id: String, uId: String, nickname: String, parentId: String, mumoryId: String, date: Date, content: String, isPublic: Bool) {
        self.id = id
        self.userDocumentID = uId
        self.nickname = nickname
        self.parentId = parentId
        self.mumoryId = mumoryId
        self.date = date
        self.content = content
        self.isPublic = isPublic
    }
    
    public init?(id: String, data: [String: Any]) {
        guard let userDocumentID = data["uId"] as? String,
              let nickname = data["nickname"] as? String,
              let parentId = data["parentId"] as? String,
              let mumoryId = data["mumoryId"] as? String,
              let date = data["date"] as? FirebaseManager.Timestamp,
              let content = data["content"] as? String,
              let isPublic = data["isPublic"] as? Bool
        else {
            print("Something is nil in Comment")
            return nil
        }

        self.id = id
        self.userDocumentID = userDocumentID
        self.nickname = nickname
        self.parentId = parentId
        self.mumoryId = mumoryId
        self.date = date.dateValue()
        self.content = content
        self.isPublic = isPublic
    }
    
    public init() {
        self.id = ""
        self.userDocumentID = ""
        self.nickname = ""
        self.parentId = ""
        self.mumoryId = ""
        self.date = Date()
        self.content = ""
        self.isPublic = false
    }
}

extension Comment {
    public func toDictionary() -> [String: Any] {
        return [
            "uId": userDocumentID,
            "nickname": nickname,
            "parentId": parentId,
            "mumoryId": mumoryId,
            "date": FirebaseManager.Timestamp(date: date),
            "content": content,
            "isPublic": isPublic
        ]
    }
    
    static func fromDocumentData(_ documentData: [String: Any], commentDocumentID: String, comments: [Comment]) -> Comment? {
        guard let userDocumentID = documentData["uId"] as? String,
              let nickname = documentData["nickname"] as? String,
              let parentId = documentData["parentId"] as? String,
              let mumoryId = documentData["mumoryId"] as? String,
              let date = documentData["date"] as? FirebaseManager.Timestamp,
              let content = documentData["content"] as? String,
              let isPublic = documentData["isPublic"] as? Bool
        else {
            return nil
        }
        return Comment(id: commentDocumentID, uId: userDocumentID, nickname: nickname, parentId: parentId, mumoryId: mumoryId, date: date.dateValue(), content: content, isPublic: isPublic)
    }
}
