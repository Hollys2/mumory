import SwiftUI
import MusicKit

import Feature
import Core
import Shared

@available(iOS 16.4, *)
@main
struct MumoryApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @ObservedObject var appCoordinator: AppCoordinator = .init()
    @ObservedObject var locationManager: LocationManager = .init()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(appCoordinator)
                .environmentObject(locationManager)
//                .ignoresSafeArea()
        }
    }
}
