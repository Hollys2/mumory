//
//  TestView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/27.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Shared
import _MapKit_SwiftUI


@available(iOS 16.0, *)
struct ContentView: View {
    
    @StateObject var viewModel: ContentViewModel
    @FocusState private var isFocusedTextField: Bool
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                
                TextField("Type address", text: $viewModel.searchableText)
                    .padding()
                    .autocorrectionDisabled()
                    .focused($isFocusedTextField)
                    .font(.title)
                    .onReceive(
                        viewModel.$searchableText
                        //                        viewModel.$searchableText.debounce(
                        //                            for: .seconds(1),
                        //                            scheduler: DispatchQueue.main
                        //                        )
                    ) {
                        viewModel.searchAddress($0)
                    }
                    .background(Color.init(uiColor: .systemBackground))
                    .overlay {
                        ClearButton(text: $viewModel.searchableText)
                            .padding(.trailing)
                            .padding(.top, 8)
                    }
                    .onAppear {
                        isFocusedTextField = true
                    }
                
//                List(self.viewModel.results) { address in
//                    AddressRow(address: address)
//                        .listRowBackground(backgroundColor)
//                }
//                .listStyle(.plain)
//                .scrollContentBackground(.hidden)
            }
            .background(backgroundColor)
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    var backgroundColor: Color = Color.init(uiColor: .systemGray6)
}



struct ClearButton: View {
    
    @Binding var text: String
    
    var body: some View {
        if text.isEmpty == false {
            HStack {
                Spacer()
                Button {
                    text = ""
                } label: {
                    Image(systemName: "multiply.circle.fill")
                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                }
                .foregroundColor(.secondary)
            }
        } else {
            EmptyView()
        }
    }
}

//struct MapView: View {
//    
//    @StateObject private var viewModel = MapViewModel()
//    
//    private let address: AddressResult
//    
//    init(address: AddressResult) {
//        self.address = address
//    }
//    
//    var body: some View {
//        Map(
//            coordinateRegion: $viewModel.region,
//            annotationItems: viewModel.annotationItems,
//            annotationContent: { item in
//                MapMarker(coordinate: item.coordinate)
//            }
//        )
//        .onAppear {
//            self.viewModel.getPlace(from: address)
//        }
//        .edgesIgnoringSafeArea(.bottom)
//    }
//}

class SwipeBackHostingController<Content: View>: UIHostingController<Content> {
    override init(rootView: Content) {
        super.init(rootView: rootView)
        
        // 백 스와이프를 처리하는 GestureRecognizer 추가
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        gesture.direction = .right
        view.addGestureRecognizer(gesture)
    }
    
    @objc private func handleSwipeGesture() {
        // 백 스와이프가 감지되면 뷰를 닫음
        presentationController?.presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


@available(iOS 16.0, *)
public struct TestView: View {
    
    @Binding var isShown: Bool
    @EnvironmentObject var appCoordinator: AppCoordinator
    @GestureState private var dragOffset = CGSize.zero
    
    let address: AddressResult = AddressResult(title: "타이틀2", subtitle: "서브타이틀2")
    
    public init(isShown: Binding<Bool>){
        _isShown = isShown
    }
    
    public var body: some View {
            ZStack {
                Color.yellow
                
                // 뒤로가기 버튼
                Button("Back") {
                    //                isShown = false // TestView를 닫습니다.
//                    appCoordinator.isCreateMumoryShown = false
                    appCoordinator.isSearchLocationMapViewShown = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding()
            }
            .gesture(
                DragGesture()
            )
    
//                                    .gesture(
//                                        DragGesture()
//                                            .updating($dragOffset) { value, state, _ in
//                                                state = value.translation
//                                            }
//                                            .onEnded { value in
//                                                if value.translation.width < -100 { // 좌측 드래그 시, 숨기기
//                                                    isShown = false
//                                                }
//                                            }
//                                    )
//                                    .offset(x: dragOffset.width)
//        .onAppear {
//                    // 뷰가 나타날 때 백 스와이프를 처리할 수 있는 UIKit 뷰 컨트롤러 생성
//                    let hostingController = SwipeBackHostingController(rootView: AnyView(EmptyView()))
//                    UIApplication.shared.windows.first?.rootViewController?.present(hostingController, animated: true, completion: nil)
//                }
//        .gesture(
//            DragGesture()
//                .onChanged { value in
//
//                }
//                .onEnded { gesture in
//                    if gesture.translation.width < -100 { // 좌측 스와이프 시, TestView를 닫음
//                        isShown = false
//                    }
//                }
//        )
    }
}

struct OnBoardingView: View {
    
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "star")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            Text(title)
                .font(.title).bold()
            
            Text(description)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 50)
    }
}


extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        return Path(path.cgPath)
    }
}

//        VStack {
//            DatePicker("Select a date", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
//                        .datePickerStyle(GraphicalDatePickerStyle())
//                        .accentColor(.orange)
//                        .frame(maxHeight: 400)
//                }
//        TabView {
//            OnBoardingView(title: "Hello1", description: "It's me1.")
//            OnBoardingView(title: "Hello2", description: "It's me2.")
//            OnBoardingView(title: "Hello3", description: "It's me3.")
//        }
//        .tabViewStyle(.page)
//        HomeMapView(tappedLocation: .constant(nil), isChanging: .constant(false))

@available(iOS 16.0, *)
struct ParentView: View {
    @State private var isShown = true
    
    var body: some View {
        TestView(isShown: $isShown)
    }
}

