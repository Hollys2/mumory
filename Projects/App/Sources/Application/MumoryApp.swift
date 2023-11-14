import SwiftUI
import MusicKit

import Feature
import Shared

@main
struct MumoryApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            VStack{
                AuthView()
                HomeView()
                SampleView()
            }
        }
    }
}


