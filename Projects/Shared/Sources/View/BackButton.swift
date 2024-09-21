//
//  BackButton.swift
//  Shared
//
//  Created by Kane on 9/10/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI

public struct BackButton: View {
    public init() {}
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    public var body: some View {
        SharedAsset.back.swiftUIImage
            .resizable()
            .frame(width: 30, height: 30)
            .onTapGesture {
                appCoordinator.rootPath.removeLast()
            }
    }
}
