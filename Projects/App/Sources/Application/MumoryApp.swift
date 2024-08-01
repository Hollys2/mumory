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
    @StateObject var currentUserViewModel: CurrentUserViewModel = .init()
//    @StateObject var locationManagerViewModel: LocationManagerViewModel = .init()
    @StateObject var keyboardResponder: KeyboardResponder = .init()
    @StateObject var playerViewModel: PlayerViewModel = .init()
    @StateObject var snackBarViewModel: SnackBarViewModel = .init()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if self.appCoordinator.isHomeViewShown {
                    HomeView()
                }
                
                if self.appCoordinator.isLoginViewShown {
                    LoginView()
                }
                
                if self.appCoordinator.isLoading
                    || self.appCoordinator.localSearchViewModel.isSearching
                    || self.currentUserViewModel.isLoading {
                    LoadingAnimationView()
                }

                if self.appCoordinator.isSplashViewShown {
                    SplashView()
                }
                

                //                if 뮤모리작성 {
                //
                //                }

            }
            .preferredColorScheme(.dark)
            .ignoresSafeArea()
            .environmentObject(appCoordinator)
//            .environmentObject(mumoryViewModel)
            .environmentObject(currentUserViewModel)
//            .environmentObject(locationManagerViewModel)
            .environmentObject(keyboardResponder)
            .environmentObject(snackBarViewModel)
            .environmentObject(playerViewModel)
        }
    }
}
