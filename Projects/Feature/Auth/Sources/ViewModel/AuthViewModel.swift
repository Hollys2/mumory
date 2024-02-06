//sample

import Foundation
import UIKit
import SwiftUI

struct AuthViewModel: UIViewControllerRepresentable {
    @State var nickname: String = ""

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = TextFieldHelper()
        vc.textfield.text = nickname
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let vc = uiViewController as? TextFieldHelper {
            vc.textfield.text = nickname
        }
    }
    
    typealias UIViewControllerType = UIViewController
    

    
}

final class TextFieldHelper: UIViewController, UITextFieldDelegate {
    var textfield = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textfield)
        
        textfield.delegate = self
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("end editing")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("begin")
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        print("change")
    }
}
