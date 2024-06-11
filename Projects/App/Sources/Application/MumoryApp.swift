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
    
    @StateObject var bootstrapViewModel: BootstrapViewModel = .init()
    @StateObject var currentUserViewModel: CurrentUserViewModel = .init()

    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if bootstrapViewModel.isShownHomeView {
                    HomeView()
                        .environmentObject(appCoordinator)
                        .onAppear {
                            Task {
                                guard let uId = FirebaseManager.shared.auth.currentUser?.uid else {return}
                                currentUserViewModel.user = await FetchManager.shared.fetchUser(uId: uId)
                            }
                        }
                    
                } else {
                    LoginView()
                }
                
                if bootstrapViewModel.isShownSplashView {
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
            
            .environmentObject(bootstrapViewModel)

            

                
//                ZStack {
//
//                    if {
//                        NavigationStack(path1) {
//                            ZStack {
//                                if {
//                                    온보딩뷰
//                                }
//
//                                로그인뷰
//                                    .navigationDestination()
//                            }
//                        }
//                    } else {
//                        NavigationStack(path2) {
//                            ZStack {
//                                홈뷰
//
//                                소셜, 라이브러리 -> A B, 알람
//                                    .navigationDestination()
//
//                            }
//
//                        }
//                    }
//
//
//                    if  {
//                        스플래쉬
//                            .onAppear {
//                                0-1.
//
//                                1-1. 로그인 여부 (파이어베이스 캐시) X -> 온보딩뷰
//                                1-2. 로그인 여부 (파이어베이스 캐시) O -> 홈뷰
//
//                                2.
//                            }
//                    }
//
//                    CreateMumoryBottomSheetView()
//
//                    if appState.isPopUpShown {
////                        팝업(언제: Bool, 어떻게: {appState.sajkdhaskjdh}})
//
//                        func testFunc() -> Void {
//
//                        }
//
//                        팝업(type: enum, action: {})) // 테스트 요망
//                    }
//
//                    if appState.isBottomShown {
//
//                    }
//
//                    스낵바
//
//                    리워드
//
//                    뮤직플레이어
//                }

//                ZStack {
//                    SplashView()
//                        .onOpenURL(perform: { url in
//                            if (AuthApi.isKakaoTalkLoginUrl(url)) {
//                                AuthController.handleOpenUrl(url: url)
//                            }
//                        })
//                        .onAppear {
//                            appCoordinator.safeAreaInsetsTop = geometry.safeAreaInsets.top
//                            appCoordinator.safeAreaInsetsBottom = geometry.safeAreaInsets.bottom
//
//                            currentUserData.topInset = geometry.safeAreaInsets.top
//                            currentUserData.bottomInset = geometry.safeAreaInsets.bottom
//
//                            playerViewModel.isShownMiniPlayer = false
//                        }
//
//                    MiniPlayerViewInLibrary()
//                        .fullScreenCover(isPresented: $playerViewModel.isPresentNowPlayingView, content: {
//                            NowPlayingView()
//                        })
//
//                    SnackBarView()
//                        .rewardBottomSheet(isShown: self.$mumoryDataViewModel.isRewardPopUpShown)
//                }
//                .ignoresSafeArea()
//                .preferredColorScheme(.dark)
//                .environmentObject(appCoordinator)
//                .environmentObject(locationManager)
//                .environmentObject(localSearchViewModel)
//                .environmentObject(mumoryDataViewModel)
//                .environmentObject(firebaseManager)
//                .environmentObject(keyboardResponder)
//                .environmentObject(currentUserData)
//                .environmentObject(playerViewModel)
//                .environmentObject(snackBarViewModel)
        }
    }
}
