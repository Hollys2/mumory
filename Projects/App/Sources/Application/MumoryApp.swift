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
    @StateObject var dateManager: DateManager = .init()
    @StateObject var keyboardResponder: KeyboardResponder = .init()
    //    @StateObject var firebaseManager: FirebaseManager = .init()
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                HomeView()
                    .environmentObject(appCoordinator)
                    .environmentObject(locationManager)
                    .environmentObject(localSearchViewModel)
                    .environmentObject(mumoryDataViewModel)
                    .environmentObject(dateManager)
                    .environmentObject(keyboardResponder)
                //                    .environmentObject(firebaseManager)
                    .onAppear {
                        print("MumoryApp onAppear")
                        
                        appCoordinator.safeAreaInsetsTop = geometry.safeAreaInsets.top
                        appCoordinator.safeAreaInsetsBottom = geometry.safeAreaInsets.bottom
                    }
            }
        }
    }
}

//public struct BottomSheetUIViewRepresentable: UIViewRepresentable {
//    
//    //    typealias UIViewType = UIView
//    
//    @Binding var isShown: Bool
//    
//    let mumoryBottomSheet: MumoryBottomSheet
//    
//    //    var menuOptions: [BottemSheetMenuOption] {
//    //        [
//    //            BottemSheetMenuOption(iconImage: SharedAsset.mapMumoryDetailMenu.swiftUIImage, title: "지도에서 보기", action: {
//    //
//    //            }),
//    //            BottemSheetMenuOption(iconImage: SharedAsset.deleteMumoryDetailMenu.swiftUIImage, title: "뮤모리 삭제") {
//    //            }
//    //        ]
//    //    }
//    
//    
//    public func makeUIView(context: Context) -> UIView {
//        
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let topSafeAreaHeight = windowScene.windows.first?.safeAreaInsets.top,
//              let bottomSafeAreaHeight = windowScene.windows.first?.safeAreaInsets.bottom
//        else { return UIView() }
//        
//        let view = UIView()
//        
//        let dimmingView = UIView(frame: UIScreen.main.bounds)
//        dimmingView.backgroundColor = UIColor.black
//        dimmingView.alpha = 0
//        view.addSubview(dimmingView)
//        
//        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTapGesture))
//        dimmingView.addGestureRecognizer(tapGestureRecognizer)
//        
//        let newView = UIView()
//        newView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: 0)
//        newView.backgroundColor = .clear
//        view.addSubview(newView)
//        
//        // Create the UIHostingController that will embed the SwiftUI View
//        let hostingController = UIHostingController(rootView: BottomSheetView(isShown: $isShown, menuOptions: self.mumoryBottomSheet.menuOptions))
//        hostingController.view.backgroundColor = .clear
//        hostingController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 54 * CGFloat(self.mumoryBottomSheet.menuOptions.count) + 31 + 27)
//        
//        newView.addSubview(hostingController.view)
//        
//        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut]) {
//            
//            dimmingView.alpha = 0.5
//            
//            newView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - (54 * CGFloat(self.mumoryBottomSheet.menuOptions.count) + 31) - 27, width: UIScreen.main.bounds.width, height: 54 * CGFloat(self.mumoryBottomSheet.menuOptions.count) + 31 + 27)
//        }
//        
//        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(_:)))
//        //        hostingController.view.addGestureRecognizer(panGesture)
//        newView.addGestureRecognizer(panGesture)
//        
//        context.coordinator.uiView = view
//        context.coordinator.newView = newView
//        context.coordinator.dimmingView = dimmingView
//        
//        
//        return view
//    }
//    
//    public func updateUIView(_ uiView: UIView, context: Context) {}
//    
//    public func makeCoordinator() -> Coordinator {
//        return Coordinator(parent: self)
//    }
//    
//    public class Coordinator: NSObject {
//        var parent: BottomSheetUIViewRepresentable
//        var uiView: UIView?
//        var newView: UIView?
//        var dimmingView: UIView?
//        
//        init(parent: BottomSheetUIViewRepresentable) {
//            self.parent = parent
//        }
//        
//        @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
//            
//            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                  let topSafeAreaHeight = windowScene.windows.first?.safeAreaInsets.top,
//                  let bottomSafeAreaHeight = windowScene.windows.first?.safeAreaInsets.bottom
//            else { return }
//            
//            guard let newView = newView, let dimmingView = dimmingView else { return }
//            
//            var initialPosition: CGPoint = .zero
//            
//            let translation = gesture.translation(in: newView)
//            
//            switch gesture.state {
//            case .began:
//                print(".began: \(newView.frame.origin)")
//                
//                initialPosition = newView.frame.origin
//                
//            case .changed:
//                
//                print(".changed")
//                if translation.y > Double(-10) {
//                    let newY = initialPosition.y + translation.y
//                    
//                    newView.frame.origin.y = newY + UIScreen.main.bounds.height - (54 * CGFloat(parent.mumoryBottomSheet.menuOptions.count) + 31) - 27
//                }
//                
//            case .ended, .cancelled:
//                print(".ended")
//                
//                if translation.y > Double(30) {
//                    UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseInOut], animations: {
//                        newView.frame.origin.y = UIScreen.main.bounds.height
//                        dimmingView.alpha = 0
//                    }) { value in
//                        
//                        print("value: \(value)")
//                        
//                        newView.removeFromSuperview()
//                        dimmingView.removeFromSuperview()
//                        self.parent.isShown = false
//                        
//                    }
//                } else {
//                    UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseInOut]) {
//                        newView.frame.origin.y = UIScreen.main.bounds.height - (54 * CGFloat(self.parent.mumoryBottomSheet.menuOptions.count) + 31) - 27
//                    }
//                }
//                
//            default:
//                break
//            }
//            
//            
//        }
//        
//        @objc func handleTapGesture() {
//            
//            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                  let topSafeAreaHeight = windowScene.windows.first?.safeAreaInsets.top,
//                  let bottomSafeAreaHeight = windowScene.windows.first?.safeAreaInsets.bottom
//            else { return }
//            
//            guard let newView = newView, let dimmingView = dimmingView else { return }
//            
//            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
//                
//                newView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height , width: UIScreen.main.bounds.width - 14, height: 54 * CGFloat(self.parent.mumoryBottomSheet.menuOptions.count) + 31 + 27)
//                
//                dimmingView.alpha = 0
//            }) { (_) in
//                newView.removeFromSuperview()
//                dimmingView.removeFromSuperview()
//                self.parent.isShown = false
//            }
//        }
//    }
//}
//
//struct ContentView: View {
//    
//    @State private var isShown = false
//    
//    var body: some View {
//        
//        ZStack {
//            
//            Color.white
//            
//            
//            Button(action: {
//                print("FUCK: \(isShown)")
//                isShown = true
//            }) {
//                Text("버튼")
//                    .padding()
//                    .background(.green)
//            }
//            
//            if isShown {
//                BottomSheetUIViewRepresentable(isShown: $isShown, mumoryBottomSheet: MumoryBottomSheet(type: .mumoryDetailView))
//                    .background(Color.clear)
//            }
//        }
//        .ignoresSafeArea()
//    }
//}

//public enum MumoryBottomSheetType {
//    case mumoryDetailView
//    case mumorySocialView
//}
//
//public struct MumoryBottomSheet {
//
//    let type: MumoryBottomSheetType
//
//    var menuOptions: [BottemSheetMenuOption] {
//        switch self.type {
//        case .mumoryDetailView:
//            return [
//                BottemSheetMenuOption(iconImage: SharedAsset.editMumoryDetailMenu.swiftUIImage, title: "뮤모리 수정", action: {
//
//                }),
//                BottemSheetMenuOption(iconImage: SharedAsset.lockMumoryDetailMenu.swiftUIImage, title: "나만 보기") {
//
//                },
//                BottemSheetMenuOption(iconImage: SharedAsset.mapMumoryDetailMenu.swiftUIImage, title: "지도에서 보기") {
//
//                },
//                BottemSheetMenuOption(iconImage: SharedAsset.deleteMumoryDetailMenu.swiftUIImage, title: "뮤모리 삭제") {
//
//                },
//                BottemSheetMenuOption(iconImage: SharedAsset.shareMumoryDetailMenu.swiftUIImage, title: "공유하기") {
//
//                },
//                BottemSheetMenuOption(iconImage: SharedAsset.complainMumoryDetailMenu.swiftUIImage, title: "신고") {
//                }
//            ]
//        case .mumorySocialView:
//            return [
//                BottemSheetMenuOption(iconImage: SharedAsset.mumoryButtonSocial.swiftUIImage, title: "뮤모리 보기", action: {
//
//                }),
//                BottemSheetMenuOption(iconImage: SharedAsset.shareMumoryDetailMenu.swiftUIImage, title: "공유하기") {
//                },
//                BottemSheetMenuOption(iconImage: SharedAsset.complainMumoryDetailMenu.swiftUIImage, title: "신고") {
//                }
//            ]
//        }
//    }
//
//}




//struct ContentView: View {
//    @GestureState private var dragState = DragState.inactive
//    @State var position = CGFloat(0)
//    @State var isSheetShown = false // 바텀 시트 표시 여부를 제어하는 변수
//
//    let maxHeight = CGFloat(50)
//
//    let imageURL = URL(string: "https://firebasestorage.googleapis.com:443/v0/b/music-app-62ca9.appspot.com/o/mumoryImages2%2F6F51D970-E066-4CD2-8874-B6E6B7328C7E.jpg?alt=media&token=43e9c3f2-3456-4bc4-b063-f3cecdb7013b")
//
//    var body: some View {
//        let drag = DragGesture()
//            .updating($dragState) { drag, state, transaction in
//                var newTranslation = drag.translation
//                if self.position + newTranslation.height < -maxHeight {  // 최대치를 넘지 않도록 제한
//                    newTranslation.height = -maxHeight - self.position
//                }
//
//                state = .dragging(translation: newTranslation)
////                state = .dragging(translation: drag.translation)
//            }
//            .onEnded(onDragEnded)
//
//        return             ZStack(alignment: .bottom) {
//
//            Rectangle()
//                .foregroundColor(.clear)
//                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
//                .background(Color(red: 0.17, green: 0.17, blue: 0.17).opacity(0.2))
//
////            Rectangle()
////                .foregroundColor(.clear)
////                .frame(width: UIScreen.main.bounds.width, height: 64)
////                .background(
////                    LinearGradient(
////                        stops: [
////                            Gradient.Stop(color: Color(red: 0.09, green: 0.09, blue: 0.09), location: 0.38),
////                            Gradient.Stop(color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0), location: 0.59),
////                        ],
////                        startPoint: UnitPoint(x: 0.5, y: 1.28),
////                        endPoint: UnitPoint(x: 0.5, y: 0.56)
////                    )
////                )
//
//        }
//    }
//
//    private func onDragEnded(drag: DragGesture.Value) {
//        print("drag.translation.height: \(drag.translation.height)")
////        let verticalDirection = drag.predictedEndLocation.y - drag.location.y
//        let cardDismiss = drag.translation.height > 100
//        let offset = cardDismiss ? drag.translation.height : 0
//        self.position = CGFloat(offset)
//
//        if cardDismiss {
//            withAnimation(.easeInOut(duration: 0.2)) {
//                self.isSheetShown = false
//            }
//        }
//    }
//}
//
//
//enum DragState {
//    case inactive
//    case dragging(translation: CGSize)
//
//    var translation: CGSize {
//        switch self {
//        case .inactive:
//            return .zero
//        case .dragging(let translation):
//            return translation
//        }
//    }
//
//    var isDragging: Bool {
//        switch self {
//        case .inactive:
//            return false
//        case .dragging:
//            return true
//        }
//    }
//}

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
