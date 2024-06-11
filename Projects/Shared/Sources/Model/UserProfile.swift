//
//  User.swift
//  Shared
//
//  Created by 제이콥 on 3/6/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import SwiftUI
import Core


public struct UserProfile: Hashable {
    public static func == (lhs: UserProfile, rhs: UserProfile) -> Bool {
        return lhs.uId == rhs.uId
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uId)
    }
    
    public init() {
        self.uId = ""
        self.nickname = "nickname"
        self.id = "id"
        self.profileImageURL = URL(string: "")
        self.backgroundImageURL = URL(string: "")
        self.bio = "bio"
        self.defaultProfileImage = SharedAsset.profileWithdrawal.swiftUIImage
        self.signUpDate = Date()
    }
    
    public init(uId: String, nickname: String, id: String, profileImageURL: URL? = nil, backgroundImageURL: URL? = nil, bio: String = "", defaultProfileImage: Image, signUpDate: Date) {
        self.uId = uId
        self.nickname = nickname
        self.id = id
        self.profileImageURL = profileImageURL
        self.backgroundImageURL = backgroundImageURL
        self.bio = bio
        self.defaultProfileImage = defaultProfileImage
        self.signUpDate = signUpDate
    }
    
    
    public var uId: String
    public var nickname: String
    public var id: String
    public var profileImageURL: URL?
    public var backgroundImageURL: URL?
    public var bio: String
    public var defaultProfileImage: Image = SharedAsset.circle.swiftUIImage
    public var signUpDate: Date

}

public let randomProfiles: [Image] = [SharedAsset.profileRed.swiftUIImage, SharedAsset.profilePurple.swiftUIImage, SharedAsset.profileYellow.swiftUIImage, SharedAsset.profileOrange.swiftUIImage]
