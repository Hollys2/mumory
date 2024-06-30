import SwiftUI
import Feature
import KakaoSDKAuth
import Core
import Shared
import MapKit
import Combine

@main
struct MumoryApp: App {
    
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
            }
            .ignoresSafeArea()
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
            .onAppear {
                bootstrap()
            }
        }
    }
    
    // MARK: - Methods
    private func bootstrap() {
        appCoordinator.isOnboardingShown = hasSignInHistory()
        let currentUserExists = hasCurrentUser()
        appCoordinator.isHomeViewShown = currentUserExists
        if currentUserExists {
            Task {
                let auth = FirebaseManager.shared.auth
                guard let currentUser = auth.currentUser else {return}
                await currentUserViewModel.initializeUserData(uId: currentUser.uid)
            }
        }
    }
        
    private func hasSignInHistory() -> Bool {
        return UserDefaults.standard.value(forKey: "SignInHistory") == nil
    }
    
    private func hasCurrentUser() -> Bool {
        let auth = FirebaseManager.shared.auth
        return auth.currentUser != nil
    }
}
