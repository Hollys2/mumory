//
//  CustomizationManageViewModel.swift
//  Feature
//
//  Created by 제이콥 on 1/31/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import SwiftUI

class CustomizationManageViewModel: ObservableObject{
    @Published var step: Int = 0

    @Published var genreList: [String] = []
    @Published var selectedTime = 0
    
    @Published var nickname = ""
    @Published var id = ""
    
    @Published var profileImageData: Data?
    @Published var profileImage: Image?
    
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
        case 0: return genreList.count > 0
        case 1: return selectedTime != 0
        case 2: return id.count > 0 && nickname.count > 0
        default: return false
        }
    }

    
    public func appendGenre(genre: String){
        if genreList.contains(where: {$0 == genre}){
            genreList.removeAll(where: {$0 == genre})
        }else {
            if genreList.count < 5 {
                genreList.append(genre)
            }
        }
    }
    
    public func contains(genre: String) -> Bool{
        return genreList.contains(where: {$0 == genre})
    }
}
