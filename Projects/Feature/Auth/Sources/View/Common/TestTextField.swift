//
//  TextField.swift
//  Feature
//
//  Created by 제이콥 on 2/6/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI

struct TestTextField: UIViewRepresentable {
    @Binding var text: String
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.text = text
        textField.delegate = context.coordinator
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        print("in update")
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    typealias UIViewType = UITextField
    

}

class Coordinator: NSObject, UITextFieldDelegate {
    @Binding private var text: String
    
    init(text: Binding<String>) {
        print("init")
           self._text = text
       }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("end")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("begin")
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        print("change")
    }
}
