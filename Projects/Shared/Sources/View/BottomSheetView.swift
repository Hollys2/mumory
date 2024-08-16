//
//  BottomSheetView.swift
//  Shared
//
//  Created by 다솔 on 2024/01/09.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import MusicKit


public enum SearchFriendType {
    case addFriend
    case requestFriend
    case cancelRequestFriend
    case unblockFriend
}

public enum Sheet: Equatable {
    case socialMenu(mumory: Mumory)
    case mumoryDetailMenu(mumory: Mumory, isOwn: Bool)
    case commentMenu(mumory: Mumory, isOwn: Bool)
    
    case addFriend
    case myMumory(mumory: Mumory, isOwn: Bool)
    
    case none
}

public struct BottomSheetOption: Identifiable {
    
    public let id = UUID()
    public let iconImage: Image
    public let title: String
    public let action: () -> Void
    
    public init(iconImage: Image, title: String, action: @escaping () -> Void) {
        self.iconImage = iconImage
        self.title = title
        self.action = action
    }
}

public struct BottomSheetUIViewRepresentable: UIViewRepresentable {
    
    private let bottomSheetOptions: [BottomSheetOption]
    
    private var hostingViewHeight: CGFloat {
        54 * CGFloat(self.bottomSheetOptions.count) + 31 + (getSafeAreaInsets().bottom != .zero ? getSafeAreaInsets().bottom : 27)
    }
    private var hostingViewOriginY: CGFloat {
        UIScreen.main.bounds.height - self.hostingViewHeight
    }
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    public init(bottomSheetOptions: [BottomSheetOption]) {
        self.bottomSheetOptions = bottomSheetOptions
    }
    
    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let dimmingView = UIView(frame: UIScreen.main.bounds)
        dimmingView.backgroundColor = UIColor.black
        dimmingView.alpha = 0
        view.addSubview(dimmingView)
        
        let hostingController = UIHostingController(rootView: BottomSheetView(options: self.bottomSheetOptions, dismiss: {
            context.coordinator.handleDismiss()
        }))
        hostingController.view.frame =  CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: self.hostingViewHeight)
        hostingController.view.backgroundColor = .clear
        view.addSubview(hostingController.view)
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut]) {
            dimmingView.alpha = 0.5
            hostingController.view.frame.origin.y = self.hostingViewOriginY
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDismiss))
        dimmingView.addGestureRecognizer(tapGestureRecognizer)
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(_:)))
        hostingController.view.addGestureRecognizer(panGesture)
        
        context.coordinator.view = view
        context.coordinator.hostingView = hostingController.view
        context.coordinator.dimmingView = dimmingView
        
        return view
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    public class Coordinator: NSObject {
        var parent: BottomSheetUIViewRepresentable
        var view: UIView?
        var hostingView: UIView?
        var dimmingView: UIView?
        
        init(parent: BottomSheetUIViewRepresentable) {
            self.parent = parent
        }
        
        @objc func handleDismiss() {
            guard let view, let hostingView = hostingView, let dimmingView = dimmingView else { return }
            
            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                hostingView.frame.origin.y = UIScreen.main.bounds.height
                dimmingView.alpha = 0
            }) { (_) in
                view.removeFromSuperview()
                self.parent.appCoordinator.sheet = .none
            }
        }
        
        @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
            guard let hostingView else { return }
            
            var initialPosition: CGPoint = .zero
            let translation = gesture.translation(in: hostingView)
            
            switch gesture.state {
            case .began:
                initialPosition = hostingView.frame.origin
                
            case .changed:
                if translation.y > Double(0) {
                    let newY = initialPosition.y + translation.y
                    hostingView.frame.origin.y = newY + self.parent.hostingViewOriginY
                }
                
            case .ended, .cancelled:
                if translation.y > Double(30) {
                    handleDismiss()
                } else {
                    UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseInOut]) {
                        hostingView.frame.origin.y = self.parent.hostingViewOriginY
                    }
                }
                
            default:
                break
            }
        }
    }
}

public struct BottomSheetView: View {
    
    var options: [BottomSheetOption]
    var dismiss: (() -> Void)
    
    public init(options: [BottomSheetOption], dismiss: @escaping (() -> Void)) {
        self.options = options
        self.dismiss = dismiss
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Image(uiImage: SharedAsset.dragIndicator.image)
                .resizable()
                .frame(width: 47, height: 4)
                .padding(.vertical, 8)
            
            VStack(spacing: 0) {
                ForEach(self.options) { option in
                    Button(action: {
                        self.dismiss()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                            option.action()
                        })
                    }) {
                        HStack(spacing: 0) {
                            Spacer().frame(width: option.iconImage == SharedAsset.editMumoryDetailMenu.swiftUIImage || option.iconImage == SharedAsset.mapMumoryDetailMenu.swiftUIImage ? 24 : 20)
                            
                            option.iconImage
                                .resizable()
                                .frame(width: option.iconImage == SharedAsset.editMumoryDetailMenu.swiftUIImage || option.iconImage == SharedAsset.mapMumoryDetailMenu.swiftUIImage ? 22 : 30, height: option.iconImage == SharedAsset.editMumoryDetailMenu.swiftUIImage || option.iconImage == SharedAsset.mapMumoryDetailMenu.swiftUIImage ? 22 : 30)
                            
                            Spacer().frame(width: option.iconImage == SharedAsset.editMumoryDetailMenu.swiftUIImage || option.iconImage == SharedAsset.mapMumoryDetailMenu.swiftUIImage ? 14 : 10)
                            
                            if option.title.contains("나만보기") {
                                Text(option.title)
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                    .foregroundColor(SharedAsset.mainColor.swiftUIColor)
                                    .frame(height: 55)
                            } else {
                                Text(option.title)
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                    .foregroundColor(option.title.contains("삭제") ? .red : .white)
                                    .frame(height: 55)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    EmptyView()
                }
            }
            .frame(width: UIScreen.main.bounds.width - 14 - 18, height: 55 * CGFloat(options.count))
            .padding(.bottom, 8)
        }
        .ignoresSafeArea()
        .frame(width: UIScreen.main.bounds.width - 14, height: 55 * CGFloat(options.count) + 31)
        .background(ColorSet.background)
        .cornerRadius(15)
    }
}

public struct RewardBottomSheetView: View {
    
    @Binding var isShown: Bool
    
    @EnvironmentObject private var currentUserViewModel: CurrentUserViewModel
    
    public var body: some View {
        
        ZStack {
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: getUIScreenBounds().width * 0.964, height: 349)
                .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                .cornerRadius(15)
            
            VStack(spacing: 0) {
                
                Spacer().frame(height: 35)
                
                self.currentUserViewModel.mumoryViewModel.reward.image
                    .resizable()
                    .frame(width: getUIScreenBounds().width * 0.287, height: getUIScreenBounds().width * 0.287)
                
                Spacer().frame(height: 21)
                
                Text(self.currentUserViewModel.mumoryViewModel.reward.title)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                
                Spacer().frame(height: 16)
                
                Text(self.currentUserViewModel.mumoryViewModel.reward.subTitle)
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                    .frame(width: 296, alignment: .top)
                    .lineSpacing(2)
                
                Spacer()
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: getUIScreenBounds().width * 0.861, height: 58)
                    .background(Color(red: 0.64, green: 0.51, blue: 0.99))
                    .cornerRadius(35)
                    .overlay(
                        Text("확인")
                            .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 18))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.2)) {
                            self.isShown = false
                        }
                    }
                
                Spacer().frame(height: 28)
            }
        }
        .frame(height: 349)
    }
}

struct RewardBottomSheetViewModifier: ViewModifier {
    
    @Binding var isShown: Bool
    
    @State private var translation: CGSize = .zero
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height > 0 {
                    DispatchQueue.main.async {
                        self.translation.height = value.translation.height
                    }
                }
            }
            .onEnded { value in
                if value.translation.height > 50 {
                    withAnimation(Animation.easeInOut(duration: 0.1)) {
                        self.isShown = false
                    }
                }
                DispatchQueue.main.async {
                    self.translation.height = 0
                }
            }
    }
    
    func body(content: Content) -> some View {
        ZStack {
            Color.clear
            
            content
            
            if isShown {
                Color.black.opacity(0.5)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.2)) {
                            //                            self.isShown = false
                        }
                    }
                
                RewardBottomSheetView(isShown: self.$isShown)
                    .offset(y: self.translation.height)
                //                    .gesture(dragGesture)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                    .padding(.bottom, 27)
            }
        }
        .ignoresSafeArea()
    }
}

public struct LocationInputBottomSheetView: View {
    
    @Binding var locationTitleText: String
    @Binding var isShown: Bool
    
    @State private var searchText: String
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    public init(isShown: Binding<Bool>, locationTitleText: Binding<String>, searchText: String) {
        self._isShown = isShown
        self._locationTitleText = locationTitleText
        self.searchText = searchText
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            
            VStack(spacing: 0) {
                
                Spacer().frame(height: 9)
                
                SharedAsset.dragIndicator.swiftUIImage
                    .resizable()
                    .frame(width: 47, height: 4)
                    .offset(y: 3)
                
                Spacer().frame(height: 31)
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text("선택한 장소의 이름을 직접 입력해주세요")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("해당 장소에 대해 기억하기 쉬운 이름으로 변경해보세요")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 10)
                }
                .padding(.horizontal, 10)
                
                Spacer().frame(height: 29)
                
                ZStack(alignment: .leading) {
                    TextField("가나다라마바사", text: $searchText,
                              prompt: Text("장소명 입력").font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47)))
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .padding(.horizontal, 25)
                    .padding(.trailing, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color(red: 0.24, green: 0.24, blue: 0.24))
                    )
                    .foregroundColor(.white)
                    
                    if !self.searchText.isEmpty {
                        
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                self.searchText = ""
                            }) {
                                SharedAsset.removeButtonSearch.swiftUIImage
                                    .resizable()
                                    .frame(width: 23, height: 23)
                            }
                        }
                        .padding(.trailing, 17)
                    }
                }
                
                Spacer().frame(height: 40)
                
                Button(action: {
                    self.locationTitleText = self.searchText
                    self.searchText = ""
                    
                    withAnimation(.easeInOut(duration: 0.1)) {
                        self.isShown = false
                    }
                }) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(self.searchText.isEmpty ? Color(red: 0.47, green: 0.47, blue: 0.47) : SharedAsset.mainColor.swiftUIColor)
                        .cornerRadius(35)
                        .overlay(
                            Text("완료")
                                .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 18))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black)
                        )
                }
                .disabled(self.searchText.isEmpty)
                .offset(y: -5)
                
                Spacer(minLength: 30)
            }
            .padding(.horizontal, 20)
        }
        .frame(width: UIScreen.main.bounds.width - 14, height: 287)
        .background(Color(red: 0.09, green: 0.09, blue: 0.09))
        .cornerRadius(15)
    }
}
