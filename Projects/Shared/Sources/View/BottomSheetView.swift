//
//  BottomSheetView.swift
//  Shared
//
//  Created by 다솔 on 2024/01/09.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import MusicKit

public enum MumoryBottomSheetType {
    case createMumory
    case mumoryDetailView
    case mumorySocialView
    case mumoryCommentView
    case mumoryCommentMyView(isMe: Bool)
    case mumoryCommentFriendView
    case addFriend
    case myMumory
}

public enum SearchFriendType {
    case addFriend
    case requestFriend
    case cancelRequestFriend
    case unblockFriend
}

public struct MumoryBottomSheet {
    
    @ObservedObject var appCoordinator: AppCoordinator
    @ObservedObject var mumoryDataViewModel: MumoryDataViewModel
    
    public let type: MumoryBottomSheetType
    
    @Binding public var isPublic: Bool
    
    public let mumoryAnnotation: Mumory
    
    public init(appCoordinator: AppCoordinator, mumoryDataViewModel: MumoryDataViewModel, type: MumoryBottomSheetType, mumoryAnnotation: Mumory, isPublic: Binding<Bool>? = nil) {
        self.appCoordinator = appCoordinator
        self.mumoryDataViewModel = mumoryDataViewModel
        
        self.type = type
        self.mumoryAnnotation = mumoryAnnotation
        self._isPublic = isPublic ?? Binding.constant(false)
    }
    
    public var menuOptions: [BottemSheetMenuOption] {
        switch self.type {
        case .createMumory:
            return []
        case .mumoryDetailView:
            return [
                BottemSheetMenuOption(iconImage: SharedAsset.editMumoryDetailMenu.swiftUIImage, title: "뮤모리 수정", action: {
                    self.appCoordinator.isMumoryDetailMenuSheetShown = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.appCoordinator.rootPath.append(MumoryView(type: .editMumoryView, mumoryAnnotation: mumoryAnnotation))
                    }
                }),
                BottemSheetMenuOption(iconImage: mumoryAnnotation.isPublic ? SharedAsset.lockMumoryDetailMenu.swiftUIImage : SharedAsset.unlockMumoryDetailMenu.swiftUIImage, title: mumoryAnnotation.isPublic ? "나만보기" : "전체공개") {
                    mumoryAnnotation.isPublic.toggle()
                    mumoryDataViewModel.updateMumory(mumoryAnnotation) {
                        
                    }
                },
                BottemSheetMenuOption(iconImage: SharedAsset.mapMumoryDetailMenu.swiftUIImage, title: "지도에서 보기") {
                    
                },
                BottemSheetMenuOption(iconImage: SharedAsset.deleteMumoryDetailMenu.swiftUIImage, title: "뮤모리 삭제") {
                    self.appCoordinator.isDeleteMumoryPopUpViewShown = true
                    //                    self.mumoryDataViewModel.deleteMumory(mumoryAnnotation)
                },
                BottemSheetMenuOption(iconImage: SharedAsset.shareMumoryDetailMenu.swiftUIImage, title: "공유하기") {
                    
                },
                BottemSheetMenuOption(iconImage: SharedAsset.complainMumoryDetailMenu.swiftUIImage, title: "신고") {
                }
            ]
        case .mumorySocialView:
            return [
                BottemSheetMenuOption(iconImage: SharedAsset.mumoryButtonSocial.swiftUIImage, title: "뮤모리 보기", action: {
                    mumoryDataViewModel.selectedMumoryAnnotation = mumoryAnnotation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.appCoordinator.rootPath.append(MumoryView(type: .mumoryDetailView, mumoryAnnotation: mumoryAnnotation))
                        self.appCoordinator.isSocialMenuSheetViewShown = false
                    }
                }),
                BottemSheetMenuOption(iconImage: SharedAsset.shareMumoryDetailMenu.swiftUIImage, title: "공유하기") {
                },
                BottemSheetMenuOption(iconImage: SharedAsset.complainMumoryDetailMenu.swiftUIImage, title: "신고") {
                }
            ]
            
        case .mumoryCommentView:
            return []
        case .mumoryCommentMyView(let isMe):
            if isMe {
                return [
                    BottemSheetMenuOption(iconImage: SharedAsset.deleteMumoryDetailMenu.swiftUIImage, title: "댓글 삭제", action: {
                        self.appCoordinator.isDeleteCommentPopUpViewShown = true
                    })
                ]
            } else {
                return [
                    BottemSheetMenuOption(iconImage: SharedAsset.complainMumoryDetailMenu.swiftUIImage, title: "신고", action: {

                    })
                ]
            }
        case .mumoryCommentFriendView:
            return [
                BottemSheetMenuOption(iconImage: SharedAsset.complainMumoryDetailMenu.swiftUIImage, title: "신고", action: {

                })
            ]
        case .addFriend:
            return [
                BottemSheetMenuOption(iconImage: SharedAsset.requestFriendSocial.swiftUIImage, title: "내가 보낸 요청") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.appCoordinator.rootPath.append(SearchFriendType.cancelRequestFriend)
                    }
                },
                
                BottemSheetMenuOption(iconImage: SharedAsset.blockFriendSocial.swiftUIImage, title: "차단친구 관리", action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.appCoordinator.rootPath.append(SearchFriendType.unblockFriend)
                    }
                })]
        case .myMumory:
            return [
                BottemSheetMenuOption(iconImage: SharedAsset.deleteMumoryDetailMenu.swiftUIImage, title: "뮤모리 삭제") {
                    self.appCoordinator.isDeleteMumoryPopUpViewShown = true
                },
                BottemSheetMenuOption(iconImage: SharedAsset.shareMumoryDetailMenu.swiftUIImage, title: "공유하기") {
                    
                }]
        }
    }
}


public struct BottemSheetMenuOption: Identifiable {
    
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
    
    //    typealias UIViewType = UIView
    
    @Binding var isShown: Bool
    let mumoryBottomSheet: MumoryBottomSheet
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    public init(isShown: Binding<Bool>, mumoryBottomSheet: MumoryBottomSheet) {
        self._isShown = isShown
        self.mumoryBottomSheet = mumoryBottomSheet
    }
    
    public func makeUIView(context: Context) -> UIView {
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let topSafeAreaHeight = windowScene.windows.first?.safeAreaInsets.top,
//              let bottomSafeAreaHeight = windowScene.windows.first?.safeAreaInsets.bottom
//        else { return UIView() }
        
        let view = UIView()
        
        let dimmingView = UIView(frame: UIScreen.main.bounds)
        dimmingView.backgroundColor = UIColor.black
        dimmingView.alpha = 0
        view.addSubview(dimmingView)
        
        let newView = UIView()
        newView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: 54 * CGFloat(self.mumoryBottomSheet.menuOptions.count) + 31)
        newView.backgroundColor = .clear
    
        let hostingController = UIHostingController(rootView: BottomSheetView(isShown: $isShown, menuOptions: self.mumoryBottomSheet.menuOptions, action: {
            dimmingView.alpha = 0

            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                newView.frame.origin.y = UIScreen.main.bounds.height
            }) { (_) in
                newView.removeFromSuperview()
                dimmingView.removeFromSuperview()
                self.isShown = false
            }
        }))
        hostingController.view.frame = newView.bounds
        hostingController.view.backgroundColor = .clear
      
        newView.addSubview(hostingController.view)
        view.addSubview(newView)

        dimmingView.alpha = 0.5
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut]) {
            newView.frame.origin.y = UIScreen.main.bounds.height - (54 * CGFloat(self.mumoryBottomSheet.menuOptions.count) + 31) - 27
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTapGesture))
        dimmingView.addGestureRecognizer(tapGestureRecognizer)
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(_:)))
        newView.addGestureRecognizer(panGesture)
        
        context.coordinator.uiView = view
        context.coordinator.newView = newView
        context.coordinator.dimmingView = dimmingView
        
        return view
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    public class Coordinator: NSObject {
        var parent: BottomSheetUIViewRepresentable
        var uiView: UIView?
        var newView: UIView?
        var dimmingView: UIView?
        
        init(parent: BottomSheetUIViewRepresentable) {
            self.parent = parent
        }
        
        @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
            guard let newView = newView, let dimmingView = dimmingView else { return }
            
            var initialPosition: CGPoint = .zero
            
            let translation = gesture.translation(in: newView)
            
            switch gesture.state {
            case .began:
                initialPosition = newView.frame.origin
                
            case .changed:
                if translation.y > Double(0) {
                    let newY = initialPosition.y + translation.y
                    
                    newView.frame.origin.y = newY + UIScreen.main.bounds.height - (54 * CGFloat(parent.mumoryBottomSheet.menuOptions.count) + 31) - 27
                }
                
            case .ended, .cancelled:
                if translation.y > Double(30) {
                    UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseInOut], animations: {
                        newView.frame.origin.y = UIScreen.main.bounds.height
                        dimmingView.alpha = 0
                    }) { value in
                        newView.removeFromSuperview()
                        dimmingView.removeFromSuperview()
                        self.parent.isShown = false
                        
                    }
                } else {
                    UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseInOut]) {
                        newView.frame.origin.y = UIScreen.main.bounds.height - (54 * CGFloat(self.parent.mumoryBottomSheet.menuOptions.count) + 31) - 27
                    }
                }
            default:
                break
            }
        }
        
        @objc func handleTapGesture() {
            guard let newView = newView, let dimmingView = dimmingView else { return }
            
            dimmingView.alpha = 0
            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                newView.frame.origin.y = UIScreen.main.bounds.height
            }) { (_) in
                newView.removeFromSuperview()
                dimmingView.removeFromSuperview()
                self.parent.isShown = false
            }
        }
    }
}


public struct BottomSheetView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @Binding var isShown: Bool
    
    var menuOptions: [BottemSheetMenuOption]
    var action: (() -> Void)?
    
    public init(isShown: Binding<Bool>, menuOptions: [BottemSheetMenuOption], action: (() -> Void)? = nil) {
        self._isShown = isShown
        self.menuOptions = menuOptions
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            
            Image(uiImage: SharedAsset.dragIndicator.image)
                .resizable()
                .frame(width: 47, height: 4)
                .padding(.vertical, 9)
            
            VStack(spacing: 0) {
                
                ForEach(menuOptions) { option in
                    
                    Button(action: {
                        if let action = self.action {
                            action()
                        }
                        option.action()
                    }) {
                        
                        HStack(spacing: 0) {
                            
                            Spacer().frame(width: option.iconImage == SharedAsset.editMumoryDetailMenu.swiftUIImage || option.iconImage == SharedAsset.mapMumoryDetailMenu.swiftUIImage ? 24 : 20)
                            
                            option.iconImage
                                .resizable()
                                .frame(width: option.iconImage == SharedAsset.editMumoryDetailMenu.swiftUIImage || option.iconImage == SharedAsset.mapMumoryDetailMenu.swiftUIImage ? 22 : 30, height: option.iconImage == SharedAsset.editMumoryDetailMenu.swiftUIImage || option.iconImage == SharedAsset.mapMumoryDetailMenu.swiftUIImage ? 22 : 30)
                            
                            Spacer().frame(width: option.iconImage == SharedAsset.editMumoryDetailMenu.swiftUIImage || option.iconImage == SharedAsset.mapMumoryDetailMenu.swiftUIImage ? 14 : 10)
                            
                            Text(option.title)
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                .foregroundColor(option.title.contains("삭제") ? .red : .white)
                                .frame(height: 55)
                            
                            Spacer()
                        }
                    }
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 0.5)
                        .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.4))
                }
                
            }
            .frame(width: UIScreen.main.bounds.width - 14 - 18, height: 54 * CGFloat(menuOptions.count))
            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
            .cornerRadius(15)
            
            Spacer().frame(height: 9)
        }
        .frame(width: UIScreen.main.bounds.width - 14, height: 54 * CGFloat(menuOptions.count) + 31)
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .cornerRadius(15)
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
            Spacer().frame(height: 9)
            
            Image(uiImage: SharedAsset.dragIndicator.image)
                .resizable()
                .frame(width: 47, height: 4)
            
            Spacer().frame(height: 33)
            
            VStack(spacing: 0) {
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text("선택한 장소의 이름을 직접 입력해주세요")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("해당 장소에 대해 기억하기 쉬운 이름으로 변경해보세요")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 10)
                        .padding(.bottom, 33)
                }
                .padding(.horizontal, 10)
                
                ZStack(alignment: .leading) {
                    TextField("가나다라마바사", text: $searchText,
                              prompt: Text("장소명 입력").font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47)))
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .padding(.horizontal, 25)
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
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.trailing, 17)
                    }
                }
                
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
                        .padding(.top, 33)
                }
                .disabled(self.searchText.isEmpty)
                
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .frame(width: UIScreen.main.bounds.width - 14, height: 287)
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .cornerRadius(15)
    }
}


struct BottomSheetViewModifier: ViewModifier {
    
    @Binding var isShown: Bool
    let mumoryBottomSheet: MumoryBottomSheet
    
    func body(content: Content) -> some View {
        
        ZStack {
            
            Color.clear
            
            content
            
            if isShown {
                BottomSheetUIViewRepresentable(isShown: $isShown, mumoryBottomSheet: mumoryBottomSheet)
            }
        }
        .zIndex(1)
        .ignoresSafeArea()
    }
}

extension View {
    
    public func bottomSheet(isShown: Binding<Bool>, mumoryBottomSheet: MumoryBottomSheet) -> some View {
        self.modifier(BottomSheetViewModifier(isShown: isShown, mumoryBottomSheet: mumoryBottomSheet))
    }
}
