import SwiftUI
import MusicKit

import Feature
import Shared

@available(iOS 16.4, *)
@main
struct MumoryApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var appCoordinator: AppCoordinator = .init()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(appCoordinator)
//                .ignoresSafeArea()
        }
    }
}
