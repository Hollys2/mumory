import SwiftUI
import MusicKit
import Shared
import Feature

@main
struct MumoryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var nowPlaySong = NowPlaySong()

    var body: some Scene {
        WindowGroup {
            VStack{
                LibraryView()
                    .environmentObject(nowPlaySong)
            }
        }
    }
}


