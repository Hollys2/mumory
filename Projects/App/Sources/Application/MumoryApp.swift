import SwiftUI
import Feature
import Core
import Shared

@available(iOS 16.4, *)
@main
struct MumoryApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @ObservedObject var appCoordinator: AppCoordinator = .init()
    @ObservedObject var locationManager: LocationManager = .init() // 위치 권한
    @ObservedObject var mumoryDataViewModel: MumoryDataViewModel = .init()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(appCoordinator)
                .environmentObject(locationManager)
                .environmentObject(mumoryDataViewModel)
        }
    }
}
