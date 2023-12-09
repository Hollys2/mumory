import SwiftUI
import Feature

@main
struct MumoryApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var nowPlaySong: NowPlaySong = NowPlaySong()
    @StateObject var setView: SetView = SetView()
    @StateObject var recentSearchObject: RecentSearchObject = RecentSearchObject()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(nowPlaySong)
                .environmentObject(setView)
                .environmentObject(recentSearchObject)
//                .ignoresSafeArea()
        }
    }
}

