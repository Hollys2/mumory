import SwiftUI
import Feature
import Core
import Shared

@available(iOS 16.4, *)
@main
struct MumoryApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var appCoordinator: AppCoordinator = .init()
    @StateObject var locationManager: LocationManager = .init() // 위치 권한
    @StateObject var localSearchViewModel: LocalSearchViewModel = .init()
    @StateObject var mumoryDataViewModel: MumoryDataViewModel = .init()
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                HomeView()
//                ContentView()
                    .environmentObject(appCoordinator)
                    .environmentObject(locationManager)
                    .environmentObject(localSearchViewModel)
                    .environmentObject(mumoryDataViewModel)
                    .onAppear {
                        appCoordinator.safeAreaInsetsTop = geometry.safeAreaInsets.top
                        appCoordinator.safeAreaInsetsBottom = geometry.safeAreaInsets.bottom
                        
                    }
            }
        }
    }
}


struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.orange
                VStack {
                    Color.red
                    Color.blue
                }
            }
            .background(.green)
            .ignoresSafeArea()
        }
    }
}


// blur
//ZStack {
//    SharedAsset.artworkSample.swiftUIImage
//        .frame(width: UIScreen.main.bounds.width)
//
//    Text("FUCK YOU")
//        .padding()
//        .background(
//            HStack{
//                Rectangle()
//                    .frame(width: 5)
//                    .background(.ultraThinMaterial)
//                    .blur(radius: 5)
//                Spacer()
//            }
//        )
//        .offset(y: 100)
//}

//struct ContentView: View {
//    @State private var scrollOffset: Int = 0
//
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                ForEach(1...30, id: \.self) { index in
//                    Text("Item \(index)")
//                        .frame(width: 200, height: 50)
//                        .background(Color.blue)
//                        .cornerRadius(8)
//                }
//                Spacer()
//            }
//        }
//        .background(
//            GeometryReader { geometry in
//                Color.green.onChange(of: geometry.frame(in: .global).minY) { value in
//                    // 스크롤 뷰의 스크롤된 위치를 업데이트합니다.
//                    self.scrollOffset = Int(value)
//                    if value <= -910 {
//                        print("hello \(value)")
//                    }
//                }
//            }
//        )
//        .overlay(
//            Text("Scrolled Offset: \(scrollOffset)")
//                .padding()
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .background(Color.yellow.opacity(0.5))
//        )
//        .ignoresSafeArea()
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

//struct ContentView: View {
//    @State private var scrollToIndex: Int?
//
//    var body: some View {
//        ScrollView {
//            ScrollViewReader { proxy in
//                VStack(spacing: 20) {
//                    ForEach(0..<50) { index in
//                        Text("Row \(index)")
//                            .id(index) // <-- 아이디를 설정해야 합니다.
//                    }
//
//                    Button("Scroll to Top") {
//                               // 스크롤 뷰의 맨 위로 스크롤
//                               withAnimation {
////                                   proxy.scrollTo(25, anchor: .bottom)
//                                   proxy.scrollTo(3)
//                               }
//                           }
//                }
//                .padding()
//                .onChange(of: scrollToIndex) { newIndex in
//                    if let index = newIndex {
//                        withAnimation {
//                            proxy.scrollTo(index)
//                        }
//                    }
//                }
//            }
//        }
//        .navigationBarItems(trailing: Button("Scroll to Top") {
//            scrollToIndex = 0 // 스크롤 뷰 맨 위로 스크롤
//        })
//    }
//}
