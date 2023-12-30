import SwiftUI
import Feature
import Core
import Shared

@available(iOS 16.4, *)
@main
struct MumoryApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @ObservedObject var appCoordinator: AppCoordinator = .init()
    @ObservedObject var locationManager: LocationManager = .init() // 위치 권한
    @ObservedObject var localSearchViewModel: LocalSearchViewModel = .init()
    @ObservedObject var mumoryDataViewModel: MumoryDataViewModel = .init()
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
//                HomeView()
                ContentView()
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
        VStack {
            ZStack(alignment: .bottom) {
                Rectangle()
                  .foregroundColor(.clear)
                  .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                  .background(Color(red: 0.17, green: 0.17, blue: 0.17).opacity(0.2))
                
                Rectangle()
                  .foregroundColor(.clear)
                  .frame(width: UIScreen.main.bounds.width, height: 64)
                  .background(
                    LinearGradient(
                      stops: [
                        Gradient.Stop(color: Color(red: 0.09, green: 0.09, blue: 0.09), location: 0.38),
                        Gradient.Stop(color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0), location: 0.59),
                      ],
                      startPoint: UnitPoint(x: 0.5, y: 1.28),
                      endPoint: UnitPoint(x: 0.5, y: 0.56)
                    )
                  )
            }
            
            
            Spacer()
        }
    }
}



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
