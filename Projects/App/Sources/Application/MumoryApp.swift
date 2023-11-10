import SwiftUI
import Feature
import Shared
import MusicKit
//import Moya
//import Firebase
import FirebaseCore
import FirebaseFirestore

@main
struct MumoryApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            VStack{
                AuthView()
                HomeView()
            }
        }
    }
}


