//
//  SignUpViewModel.swift
//  Feature
//
//  Created by 제이콥 on 12/10/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import Foundation

public class SignUpViewModel: ObservableObject{
    public init(){}
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isValidEmail: Bool = false
    @Published var isValidPassword: Bool = false
    @Published var isValidConfirmPassword: Bool = false
    @Published var isCheckedConsent: Bool = false

}
