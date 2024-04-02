import SwiftUI
import Feature
import KakaoSDKAuth
import Core
import Shared
import MapKit

@main
struct MumoryApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var appCoordinator: AppCoordinator = .init()
    @StateObject var locationManager: LocationManager = .init()
    @StateObject var localSearchViewModel: LocalSearchViewModel = .init()
    @StateObject var mumoryDataViewModel: MumoryDataViewModel = .init()
    @StateObject var firebaseManager: FirebaseManager = .init()
    @StateObject var keyboardResponder: KeyboardResponder = .init()
    @StateObject var currentUserData: CurrentUserData = .init()
    @StateObject var playerViewModel: PlayerViewModel = .init()
    @StateObject var snackBarViewModel: SnackBarViewModel = .init()

    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                ZStack {
                    SplashView()
                        .preferredColorScheme(.dark)
//                    MumoryEditView(mumoryAnnotation: Mumory())
                        .onOpenURL(perform: { url in
                            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                                AuthController.handleOpenUrl(url: url)
                            }
                        })
                        .environmentObject(snackBarViewModel)
                        .environmentObject(appCoordinator)
                        .environmentObject(locationManager)
                        .environmentObject(localSearchViewModel)
                        .environmentObject(mumoryDataViewModel)
                        .environmentObject(firebaseManager)
                        .environmentObject(keyboardResponder)
                        .environmentObject(currentUserData)
                        .environmentObject(playerViewModel)
                        .onAppear {
                            appCoordinator.safeAreaInsetsTop = geometry.safeAreaInsets.top
                            appCoordinator.safeAreaInsetsBottom = geometry.safeAreaInsets.bottom
                            
                            currentUserData.topInset = geometry.safeAreaInsets.top
                            currentUserData.bottomInset = geometry.safeAreaInsets.bottom
                            
                            playerViewModel.isShownMiniPlayer = false
                        }
                    
                    MiniPlayerViewInLibrary()
                        .environmentObject(snackBarViewModel)
                        .environmentObject(appCoordinator)
                        .environmentObject(currentUserData)
                    
                    SnackBarView()
                        .environmentObject(snackBarViewModel)
                        .environmentObject(appCoordinator)
                        .environmentObject(currentUserData)
                }
                .ignoresSafeArea()
                .environmentObject(snackBarViewModel)
                .environmentObject(appCoordinator)
                .environmentObject(locationManager)
                .environmentObject(localSearchViewModel)
                .environmentObject(mumoryDataViewModel)
                .environmentObject(firebaseManager)
                .environmentObject(keyboardResponder)
                .environmentObject(currentUserData)
                .environmentObject(playerViewModel)
            }
        }
    }
}
