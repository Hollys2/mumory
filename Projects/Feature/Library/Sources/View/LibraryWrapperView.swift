//
//  LibraryWrapperView.swift
//  Feature
//
//  Created by 제이콥 on 3/15/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI

struct LibraryWrapperView: View {
    @EnvironmentObject private var libraryCoordinator: LibraryCoordinator
    
    var body: some View {
            NavigationStack(path: $libraryCoordinator.stack) {
                ZStack(alignment: .top) {
                  
                }
            }
    }
}

#Preview {
    LibraryWrapperView()
}
