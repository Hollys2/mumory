import SwiftUI
import Feature
import KakaoSDKAuth
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
    @StateObject var currentUserData: CurrentUserData = .init()
    @StateObject var playerManager: PlayerViewModel = .init()
    @StateObject var snackBarViewModel: SnackBarViewModel = .init()
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                //                CreateMumoryBottomSheetView()
//                HomeView()
                //충독나서 스플래시 화면으로 수정함
                ZStack{
                    SplashView()
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
                        .environmentObject(playerManager)
                        .environmentObject(snackBarViewModel)
                        .onAppear {
                            print("MumoryApp onAppear")
                            
                            appCoordinator.currentUser = UserModel(documentID: "tester", nickname: "솔다", id: "solda")
                            
                            appCoordinator.safeAreaInsetsTop = geometry.safeAreaInsets.top
                            appCoordinator.safeAreaInsetsBottom = geometry.safeAreaInsets.bottom
                            
                            currentUserData.topInset = geometry.safeAreaInsets.top
                            currentUserData.bottomInset = geometry.safeAreaInsets.bottom
                        }
                    
                    SnackBarView()
                        .environmentObject(snackBarViewModel)
                        .environmentObject(appCoordinator)

                    
                }
            }
 
        }
    }
}
