import SwiftUI
import Feature

@main
struct MumoryApp: App {
    var body: some Scene {
        WindowGroup {
            VStack{
                Text("This is MyApp.")
                AuthView()
                HomeView()
            }
        }
    }
}

