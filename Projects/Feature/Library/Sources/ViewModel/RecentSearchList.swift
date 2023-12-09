//
//  RecentSearchList.swift
//  Feature
//
//  Created by 제이콥 on 12/9/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import Foundation

public class RecentSearchObject: ObservableObject{
    public init() {}
    @Published var recentSearchList: [String] = []
}
