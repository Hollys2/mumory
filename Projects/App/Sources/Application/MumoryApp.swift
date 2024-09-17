import SwiftUI
import Feature
import Core
import Shared


@main
struct MumoryApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var appCoordinator: AppCoordinator = .init()
    @StateObject var locationManager: LocationManager = .init() // 위치 권한
    @StateObject var localSearchViewModel: LocalSearchViewModel = .init()
    @StateObject var mumoryDataViewModel: MumoryDataViewModel = .init()
    @StateObject var dateManager: DateManager = .init()
    @StateObject var firebaseManager: FirebaseManager = .init()
    @StateObject var keyboardResponder: KeyboardResponder = .init()
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                HomeView()
                    .environmentObject(appCoordinator)
                    .environmentObject(locationManager)
                    .environmentObject(localSearchViewModel)
                    .environmentObject(mumoryDataViewModel)
                    .environmentObject(dateManager)
                    .environmentObject(firebaseManager)
                    .environmentObject(keyboardResponder)
                    .onAppear {
                        print("MumoryApp onAppear")

                        appCoordinator.currentUser = UserModel(documentID: "tester", nickname: "솔다", id: "solda")
                        
                        appCoordinator.safeAreaInsetsTop = geometry.safeAreaInsets.top
                        appCoordinator.safeAreaInsetsBottom = geometry.safeAreaInsets.bottom
                        
                    }
            }
        }
    }
}
