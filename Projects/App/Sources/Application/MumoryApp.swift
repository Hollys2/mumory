import SwiftUI
import Feature
import KakaoSDKAuth
import Core
import Shared
import MapKit
import Combine

@main
struct MumoryApp: App {
    // MARK: - Propoerties
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var appCoordinator: AppCoordinator = .init()
    @StateObject var locationManager: LocationManager = .init()
    @StateObject var localSearchViewModel: LocalSearchViewModel = .init()
    @StateObject var mumoryDataViewModel: MumoryDataViewModel = .init()
    @StateObject var firebaseManager: FirebaseManager = .init()
    @StateObject var keyboardResponder: KeyboardResponder = .init()
    @StateObject var playerViewModel: PlayerViewModel = .init()
    @StateObject var snackBarViewModel: SnackBarViewModel = .init()
    @StateObject var currentUserViewModel: CurrentUserViewModel = .init()

    var body: some Scene {
        WindowGroup {
            ZStack {
                if appCoordinator.isHomeViewShown {
                    HomeView()
                } else {
                    LoginView()
                }
                
                if appCoordinator.isSplashViewShown {
                    SplashView()
                }
                
                if appCoordinator.isLoading {
                    LoadingAnimationView(isLoading: $appCoordinator.isLoading)
                }
                
//                if 뮤모리작성 {
//                    
//                }

            }
            .preferredColorScheme(.dark)
            .environmentObject(locationManager)
            .environmentObject(localSearchViewModel)
            .environmentObject(mumoryDataViewModel)
            .environmentObject(firebaseManager)
            .environmentObject(keyboardResponder)
            .environmentObject(currentUserViewModel)
            .environmentObject(snackBarViewModel)
            .environmentObject(playerViewModel)
            .environmentObject(appCoordinator)

            
            
        }
    }
}
