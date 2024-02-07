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
//                RewardView()
                HomeView()
//                SearchLocationMapView()
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

extension Int {
    func formatted() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

struct YearMonthPicker: View {
    @State private var selectedYear = 2022
    @State private var selectedMonth = "January"
    
    let years = Array(2000...2030)
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    var body: some View {
        HStack(spacing: 0) {
            Picker("Year", selection: $selectedYear) {
                ForEach(years, id: \.self) {
                    Text("\($0.formatted())년")
                }
            }
            .pickerStyle(WheelPickerStyle())
//            .frame(width: 100)
            
            Picker("Month", selection: $selectedMonth) {
                ForEach(months, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(WheelPickerStyle())
//            .frame(width: 150)
        }
        .padding()
    }
}

//
//struct ContentView: View {
//    @State private var selectedTab = 0
//    @State private var underlineOffset: CGFloat = 0
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // TabView와 언더라인을 포함한 탭 뷰
//            TabView(selection: $selectedTab) {
//                Text("Tab 1")
//                    .tag(0)
//
//                Text("Tab 2")
//                    .tag(1)
//
//                Text("Tab 3")
//                    .tag(2)
//            }
//            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//            .background(Color.white)
//
//            // 선택된 탭에 따라 언더라인을 표시하는 뷰
//            GeometryReader { geometry in
//                HStack(spacing: 0) {
//                    ForEach(0..<3) { index in
//                        Text("Tab \(index + 1)")
//                            .font(.headline)
//                            .padding()
//                            .onTapGesture {
//                                withAnimation {
//                                    selectedTab = index
//                                    // 언더라인 위치 업데이트
//                                    underlineOffset = geometry.size.width / 3 * CGFloat(index)
//                                }
//                            }
//                    }
//
//                    // 언더라인
//                    Rectangle()
//                        .fill(Color.blue)
//                        .frame(width: geometry.size.width / 3, height: 2)
//                        .offset(x: underlineOffset)
//                        .animation(.easeInOut)
//                        .onAppear {
////                            underlineOffset = geometry.size.width / 3 * CGFloat(selectedTab)
//                        }
//                        .onChange(of: selectedTab) { newIndex in
//                            withAnimation {
//                                underlineOffset = geometry.size.width / 3 * CGFloat(newIndex)
//                            }
//                        }
//                }
//            }
//        }
//        .frame(height: 50)
//    }
//}


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
