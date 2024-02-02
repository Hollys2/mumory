//
//  KeyboardHide.swift
//  Shared
//
//  Created by 제이콥 on 2/3/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
  public func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}
