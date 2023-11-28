import SwiftUI
import Feature

@main
struct MumoryApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            HomeView()
//                .ignoresSafeArea()
        }
    }
}
