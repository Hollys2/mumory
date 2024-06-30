//
//  CustomizationManageViewModel.swift
//  Feature
//
//  Created by 제이콥 on 1/31/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import Shared
import SwiftUI

public class CustomizationManageViewModel: ObservableObject{
    @Published var step: Int = 0
    
    @Published var isCheckedRequiredItems: Bool?
    @Published var isCheckedServiceNewsNotification: Bool?

    @Published var selectedGenres: [MusicGenre] = []
    @Published var selectedTime = 0
    
    @Published var nickname = ""
    @Published var id = ""
    
    @Published var isValidNickname = false
    @Published var isValidID = false
    
    @Published var profileImageData: Data?
    @Published var profileImage: Image?
    @Published var isLoading: Bool = false
    
    
    var randomProfileIndex: Int
    var randomProfilePath: String
    
    init() {
        switch(Int.random(in: 0...3)){
        case 0:
            self.randomProfileIndex = 0
            self.randomProfilePath = "ProfileImage/profile0.png"
        case 1:
            self.randomProfileIndex = 1
            self.randomProfilePath = "ProfileImage/profile1.png"
        case 2:
            self.randomProfileIndex = 2
            self.randomProfilePath = "ProfileImage/profile2.png"
        case 3:
            self.randomProfileIndex = 3
            self.randomProfilePath = "ProfileImage/profile3.png"
        default:
            self.randomProfileIndex = 1
            self.randomProfilePath = "ProfileImage/profile0.png"
        }
    }
    
    
    public func getNavigationTitle() -> String {
        return ""
    }
    
    public func getButtonTitle() -> String {
        switch(step){
        case 2: return "완료"
        default: return "다음"
        }
    }
    
    public func isButtonEnabled() -> Bool {
        switch(step){
        case 0: return selectedGenres.count > 0
        case 1: return selectedTime != 0
        case 2: return isValidID && isValidNickname
        default: return false
        }
    }
    
    public func appendGenre(genre: MusicGenre){
        if selectedGenres.contains(where: {$0.id == genre.id}){
            selectedGenres.removeAll(where: {$0.id == genre.id})
        }else {
            if selectedGenres.count < 5 {
                selectedGenres.append(genre)
            }
        }
    }
    
    public func contains(genre: MusicGenre) -> Bool{
        return selectedGenres.contains(where: {$0.id == genre.id})
    }
    
    public func getSelectProfileImage() -> Image {
        switch(self.randomProfileIndex) {
        case 0: return SharedAsset.profileRedForSelection.swiftUIImage
        case 1: return SharedAsset.profilePurpleForSelection.swiftUIImage
        case 2: return SharedAsset.profileYellowForSelection.swiftUIImage
        case 3: return SharedAsset.profileOrangeForSelection.swiftUIImage
        default: return SharedAsset.profileRedForSelection.swiftUIImage
        }
    }
    
    public func getProfileImage() -> Image {
        if let image = self.profileImage {
            return image
        }else {
            switch(self.randomProfileIndex) {
            case 0: return SharedAsset.profileRed.swiftUIImage
            case 1: return SharedAsset.profilePurple.swiftUIImage
            case 2: return SharedAsset.profileYellow.swiftUIImage
            case 3: return SharedAsset.profileOrange.swiftUIImage
            default: return SharedAsset.profileRed.swiftUIImage
            }
        }
    }
    
    public func removeProfileImage() {
        DispatchQueue.main.async {
            self.profileImage = nil
            self.profileImageData = nil
        }
    }
}
