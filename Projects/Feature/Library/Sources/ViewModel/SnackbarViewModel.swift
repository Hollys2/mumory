//
//  SnackbarViewModel.swift
//  Feature
//
//  Created by 제이콥 on 2/22/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import SwiftUI
enum snackbarStatus {
    case success
    case failure
}
class SnackBarViewModel: ObservableObject {
    @Published var isPresent: Bool = false
    @Published var status: snackbarStatus = .success
    @Published var title: String = ""
    var timer: Timer?

    public func setSnackBarAboutPlaylist(status: snackbarStatus, playlistTitle: String) {
        self.timer?.invalidate()
        self.isPresent = false
        self.status = status
        self.title = playlistTitle
        
        self.setPresentValue(isPresent: true)

        self.timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { timer in
            self.setPresentValue(isPresent: false)
        })
    }
    
    private func setPresentValue(isPresent: Bool) {
        DispatchQueue.main.async {
            withAnimation {
                self.isPresent = isPresent
            }
        }
    }
}
