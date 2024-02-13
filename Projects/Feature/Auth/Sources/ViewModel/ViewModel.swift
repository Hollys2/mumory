//
//  ViewModel.swift
//  Feature
//
//  Created by 제이콥 on 2/6/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import UIKit

class ViewModel: NSObject, ObservableObject, UITextFieldDelegate{
    @Published var nickname: String = ""
    var textField = UITextField()
    override init() {
        super.init()
        textField.delegate = self
    }
    
    func setText(text: String){
        textField.text = text
    }

    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("end edit")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("begin")
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        print("change")
    }
}

