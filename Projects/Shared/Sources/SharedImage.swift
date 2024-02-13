//
//  SharedImage.swift
//  Shared
//
//  Created by 다솔 on 2023/11/24.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI

public class SharedBundle {
}

extension Bundle {
    public static var shared: Bundle {
        return Bundle(for: SharedBundle.self)
    }
}

extension UIImage {
    convenience init?(namedInShared name: String) {
        self.init(named: name, in: .shared, compatibleWith: nil)
    }
}
