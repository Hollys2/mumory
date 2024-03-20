import SwiftUI
import Feature
import KakaoSDKAuth
import Core
import Shared


@main
struct MumoryApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var appCoordinator: AppCoordinator = .init()
    @StateObject var locationManager: LocationManager = .init()
    @StateObject var localSearchViewModel: LocalSearchViewModel = .init()
    @StateObject var mumoryDataViewModel: MumoryDataViewModel = .init()
    @StateObject var dateManager: DateManager = .init()
    @StateObject var firebaseManager: FirebaseManager = .init()
    @StateObject var keyboardResponder: KeyboardResponder = .init()
    @StateObject var currentUserData: CurrentUserData = .init()
    @StateObject var playerViewModel: PlayerViewModel = .init()
    @StateObject var snackBarViewModel: SnackBarViewModel = .init()
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                ZStack {
//                    SplashView()
                    MumoryEditView(mumoryAnnotation: Mumory())
                        .onOpenURL(perform: { url in
                            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                                AuthController.handleOpenUrl(url: url)
                            }
                        })
                        .environmentObject(appCoordinator)
                        .environmentObject(locationManager)
                        .environmentObject(localSearchViewModel)
                        .environmentObject(mumoryDataViewModel)
                        .environmentObject(dateManager)
                        .environmentObject(firebaseManager)
                        .environmentObject(keyboardResponder)
                        .environmentObject(currentUserData)
                        .environmentObject(playerViewModel)
                        .environmentObject(snackBarViewModel)
                        .onAppear {                            
                            appCoordinator.safeAreaInsetsTop = geometry.safeAreaInsets.top
                            appCoordinator.safeAreaInsetsBottom = geometry.safeAreaInsets.bottom
                            
                            currentUserData.topInset = geometry.safeAreaInsets.top
                            currentUserData.bottomInset = geometry.safeAreaInsets.bottom
                        }
                    
                    SnackBarView()
                        .environmentObject(snackBarViewModel)
                        .environmentObject(appCoordinator)
                        .environmentObject(currentUserData)
                }
            }
        }
    }
}
