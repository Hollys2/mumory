import SwiftUI
import Feature

@main
struct MumoryApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var nowPlaySong: NowPlaySong = NowPlaySong()
    @StateObject var setView: SetView = SetView()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(nowPlaySong)
                .environmentObject(setView)
//                .ignoresSafeArea()
        }
    }
}

