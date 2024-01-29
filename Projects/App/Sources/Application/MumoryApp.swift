import SwiftUI
import Feature
import FirebaseCore
//import KakaoSDKCommon
import GoogleSignIn

@main
public struct MumoryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var nowPlaySong: NowPlaySong = NowPlaySong()
//    @StateObject var setView: SetView = SetView()
//    @StateObject var recentSearchObject: RecentSearchObject = RecentSearchObject()
    public init(){}
    
    public var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}



