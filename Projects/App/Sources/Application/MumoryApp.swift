import SwiftUI
import Feature
import KakaoSDKAuth
import GoogleSignIn

@main
public struct MumoryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var scrollWrapperManager: ScrollWrapperViewModel = ScrollWrapperViewModel()

    public init(){}
    
    public var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(scrollWrapperManager)
                .onOpenURL(perform: { url in
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
                        AuthController.handleOpenUrl(url: url)
                    }
                })
        }
    }
}



