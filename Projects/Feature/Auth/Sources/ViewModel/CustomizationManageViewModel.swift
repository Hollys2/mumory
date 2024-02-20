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

class CustomizationManageViewModel: ObservableObject{
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
    @Published var randomProfileImageIndex = Int.random(in: 0...3)
    
    
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
    
    public func RandomSelectProfile() -> some View {
        switch(randomProfileImageIndex){
        case 0: return SharedAsset.profileSelectPurple.swiftUIImage
                .frame(width: 105, height: 105)
                .clipShape(Circle())
        case 1: return SharedAsset.profileSelectRed.swiftUIImage
                .frame(width: 105, height: 105)
                .clipShape(Circle())
        case 2: return SharedAsset.profileSelectYellow.swiftUIImage
                .frame(width: 105, height: 105)
                .clipShape(Circle())
        case 3: return SharedAsset.profileSelectOrange.swiftUIImage
                .frame(width: 105, height: 105)
                .clipShape(Circle())
        default: return SharedAsset.profileSelectRed.swiftUIImage
                 .frame(width: 105, height: 105)
                 .clipShape(Circle())
        }
    }
    
    public func RandomProfile() -> some View {
        switch(randomProfileImageIndex){
        case 0: return SharedAsset.profilePurple.swiftUIImage
                .frame(width: 105, height: 105)
                .clipShape(Circle())
        case 1: return SharedAsset.profileRed.swiftUIImage
                .frame(width: 105, height: 105)
                .clipShape(Circle())
        case 2: return SharedAsset.profileYellow.swiftUIImage
                .frame(width: 105, height: 105)
                .clipShape(Circle())
        case 3: return SharedAsset.profileOrange.swiftUIImage
                .frame(width: 105, height: 105)
                .clipShape(Circle())
        default: return SharedAsset.profileSelectRed.swiftUIImage
                 .frame(width: 105, height: 105)
                 .clipShape(Circle())
        }
    }
}