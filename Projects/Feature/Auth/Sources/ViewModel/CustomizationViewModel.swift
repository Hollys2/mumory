//
//  CustomizationViewModel.swift
//  Feature
//
//  Created by 제이콥 on 12/26/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import Foundation

class CustomizationViewModel: ObservableObject{
    @Published var nowStep: Int = 0 //첫번째스탭부터 0, 1, 2
    @Published var checkedCount: Int = 0
    @Published var selectedGenreList: [String] = []
    @Published var selectedTime: Int = 0 //아침부터 순서대로 1,2,3,4,5
    @Published var nickname: String = ""
    @Published var id: String = ""
    
    func getNextButtonEnabled() -> Bool {
        if nowStep == 0 && checkedCount > 0 {
            return true
        }else if nowStep == 1 && selectedTime != 0 {
            return true
        }else if nowStep == 2 && nickname != "" && id != ""{
            return true
        }
        return false
    }
    
    func isContained(term: String) -> Bool{
        return selectedGenreList.contains(where: {$0 == term})
    }
    
}
