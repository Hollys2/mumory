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
}

public struct MumoryBottomSheet {
    
    @ObservedObject var appCoordinator: AppCoordinator
    @ObservedObject var mumoryDataViewModel: MumoryDataViewModel
    
    public let type: MumoryBottomSheetType
    
    @Binding public var isPublic: Bool
    
    public let mumoryAnnotation: MumoryAnnotation
    
    public init(appCoordinator: AppCoordinator, mumoryDataViewModel: MumoryDataViewModel, type: MumoryBottomSheetType, mumoryAnnotation: MumoryAnnotation, isPublic: Binding<Bool>? = nil) {
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.appCoordinator.rootPath.append(MumoryView(type: .editMumoryView, mumoryAnnotation: mumoryAnnotation)) // 추후 파이어스토어 ID로 수정
                        self.appCoordinator.isMumoryDetailMenuSheetShown = false
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
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTapGesture))
        dimmingView.addGestureRecognizer(tapGestureRecognizer)
        
        let newView = UIView()
        newView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: 0)
        newView.backgroundColor = .clear
        view.addSubview(newView)
    
        let hostingController = UIHostingController(rootView: BottomSheetView(isShown: $isShown, menuOptions: self.mumoryBottomSheet.menuOptions, action: {
            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                
                newView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height , width: UIScreen.main.bounds.width, height: 54 * CGFloat(self.mumoryBottomSheet.menuOptions.count) + 31)
                
                dimmingView.alpha = 0
            }) { (_) in
                newView.removeFromSuperview()
                dimmingView.removeFromSuperview()
                self.isShown = false
            }

        }))
        hostingController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 54 * CGFloat(self.mumoryBottomSheet.menuOptions.count) + 31)
        hostingController.view.backgroundColor = .clear
        
        newView.addSubview(hostingController.view)
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut]) {

            newView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - (54 * CGFloat(self.mumoryBottomSheet.menuOptions.count) + 31) - 27, width: UIScreen.main.bounds.width, height: 54 * CGFloat(self.mumoryBottomSheet.menuOptions.count) + 31)
            dimmingView.alpha = 0.5
        }
        
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(_:)))
        //        hostingController.view.addGestureRecognizer(panGesture)
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
                print(".began: \(newView.frame.origin)")
                
                initialPosition = newView.frame.origin
                
            case .changed:
                
                print(".changed")
//                if translation.y > Double(-10) {
                    let newY = initialPosition.y + translation.y
                    
                    newView.frame.origin.y = newY + UIScreen.main.bounds.height - (54 * CGFloat(parent.mumoryBottomSheet.menuOptions.count) + 31) - 27
//                }
                
            case .ended, .cancelled:
                print(".ended")
                
                if translation.y > Double(30) {
                    UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseInOut], animations: {
                        newView.frame.origin.y = UIScreen.main.bounds.height
                        dimmingView.alpha = 0
                    }) { value in
                        
                        print("value: \(value)")
                        
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
            
            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                
                newView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height , width: UIScreen.main.bounds.width, height: 54 * CGFloat(self.parent.mumoryBottomSheet.menuOptions.count) + 31)
                
                dimmingView.alpha = 0
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
                            
                            Spacer().frame(width: 20)
                            
                            option.iconImage
                            //                                .resizable()
                                .frame(width: 30, height: 30)
                            
                            Spacer().frame(width: 10)
                            
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

public struct SecondBottomSheetView: View {
    
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
            SharedAsset.mainColor.swiftUIColor
        
            content
            
            if isShown {
                BottomSheetUIViewRepresentable(isShown: $isShown, mumoryBottomSheet: mumoryBottomSheet)
            }
        }
        .zIndex(1)
    }
}

//struct CommentBottomSheetViewModifier: ViewModifier {
//
//    @Binding var isShown: Bool
//    let mumoryBottomSheet: MumoryBottomSheet
//
//    func body(content: Content) -> some View {
//
//        ZStack {
//            SharedAsset.mainColor.swiftUIColor
//
//            content
//
//            if isShown {
//                CommentBottomSheetUIViewRepresentable(isShown: $isShown, mumoryBottomSheet: mumoryBottomSheet)
//                    .zIndex(5)
//            }
//        }
//        .zIndex(3)
//    }
//}

extension View {
    public func bottomSheet(isShown: Binding<Bool>, mumoryBottomSheet: MumoryBottomSheet) -> some View {
        self.modifier(BottomSheetViewModifier(isShown: isShown, mumoryBottomSheet: mumoryBottomSheet))
    }
    
//    public func commentbottomSheet(isShown: Binding<Bool>, mumoryBottomSheet: MumoryBottomSheet) -> some View {
//        self.modifier(CommentBottomSheetViewModifier(isShown: isShown, mumoryBottomSheet: mumoryBottomSheet))
//    }
}


//struct CommentView: View {
//
//    @State private var isSecretComment: Bool = false
//    @State private var isMenuShown: Bool = false
//    @State private var isSelectedComment: Bool = false
//    @State private var textContent = "주어와 서술어는 호응하지 않고, 문장은 엿가락처럼 길기만 합니다."
//    //    @State private var textContent = "주어와 서술어는 호응하지 않고, 문장은 엿가락처럼 길기만 합니다. 게다가 문맥에 어울리지 않는 한자어를 남발하는 바람에 내용 파악조차 어렵습니다. 서술형 답안을 작성하고, 논술 시험을 대비하는 학생들의 글에서 흔히 발견하는 문제입니다. 앞으로 연재할 글쓰기의 10가지 원칙을 충분히 익힌 뒤 연습문제로 확인하세요. 1회성 연습에 그치지 말고 평소에 글을 읽고 쓸 때도 원칙을 적용해야 합니다. 시간이 없다고요? 매일 보는 교과서를 활용하세요. 공부할 때 글쓰기 원칙에 어긋나는 문장을 발견한다면 원칙에 맞춰 바꿔 써 보세요. 매회 실리는 ‘교과서 ‘옥의 티’’ 꼭지를 참고하면 도움이 될 겁니다. 예문은 초·중등 학생에게 실질적인 도움을 주기 위해 초·중등 대상 신문활용교육(NIE) 매체인 <아하! 한겨레> 누리집(ahahan.co.kr)에 올라온 글 위주로 골랐습니다."
//
//    var body: some View {
//        HStack(alignment: .top,  spacing: 13) {
//            SharedAsset.profileMumoryDetail.swiftUIImage
//                .resizable()
//                .frame(width: 32, height: 32)
//
//            VStack(spacing: 0) {
//                VStack(spacing: 0) {
//                    Spacer().frame(height: 13)
//
//                    HStack(spacing: 0) {
//                        Text("1일 전")
//                            .font(
//                                Font.custom("Pretendard", size: 13)
//                                    .weight(.medium)
//                            )
//                            .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
//
//                        Spacer().frame(width: 5)
//
//                        SharedAsset.commentLockMumoryDetail.swiftUIImage
//                            .resizable()
//                            .frame(width: 15, height: 15)
//
//                        Spacer()
//
//                        Button(action: {
//                            self.isMenuShown = true
//                        }, label: {
//                            SharedAsset.commentMenuMumoryDetail.swiftUIImage
//                                .resizable()
//                                .frame(width: 18, height: 18)
//                        })
//
//                    } // HStack
//
//
//                    Text(isSecretComment ? "비밀 댓글입니다." : textContent)
//                        .lineSpacing(20)
//                        .font(isSecretComment ? Font.custom("Pretendard", size: 14)
//                            .weight(.medium) : Font.custom("Pretendard", size: 14))
//                        .foregroundColor(isSecretComment ? Color(red: 0.64, green: 0.51, blue: 0.99) : .white)
//                        .frame(maxWidth: .infinity, alignment: .topLeading)
//                        .padding(.vertical, 15)
//                    //                        .background(Color.gray.opacity(0.2))
//
//                } // VStack
//                .padding(.horizontal, 15)
//                .background(
//                    Rectangle()
//                        .foregroundColor(.clear)
//                        .background(isSelectedComment ? Color(red: 0.09, green: 0.09, blue: 0.09) : Color(red: 0.12, green: 0.12, blue: 0.12))
//                        .cornerRadius(15)
//                )
//
//                Spacer().frame(height: 15)
//
//                Button(action: {
//                    textContent += "\nMore lines added."
//                }, label: {
//                    Text("답글 달기")
//                        .font(
//                            Font.custom("Pretendard", size: 12)
//                                .weight(.medium)
//                        )
//                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
//                        .background(.black)
//                })
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.leading, 12)
//
//                Spacer().frame(height: 13)
//            } // VStack
//            .background(.blue)
//
//        } // HStack
//        .frame(width: UIScreen.main.bounds.width - 40)
//        .frame(minHeight: 117 - 20)
//        .padding(.top, 12)
//        .background(.pink)
//
//
//        // MARK: Reply
//        Reply()
//
//        Spacer().frame(height: 15)
//
//        Rectangle()
//            .foregroundColor(.clear)
//            .frame(width: UIScreen.main.bounds.width - 10, height: 0.5)
//            .background(Color(red: 0.25, green: 0.25, blue: 0.25))
//
//        Spacer().frame(height: 5)
//    }
//}
//
//struct Reply: View {
//
//    @State private var isSecretComment: Bool = true
//    @State private var isMenuShown: Bool = false
//    @State private var textContent = "주어와 서술어는 호응하지 않고, 문장은 엿가락처럼 길기만 합니다."
//
//    var body: some View {
//        HStack(alignment: .top, spacing: 13) {
//            SharedAsset.profileMumoryDetail.swiftUIImage
//                .resizable()
//                .frame(width: 28, height: 28)
//
//            VStack(spacing: 0) {
//                Spacer().frame(height: 13)
//
//                HStack(spacing: 5) {
//                    Text("닉네임임임임임")
//                        .font(
//                            Font.custom("Pretendard", size: 13)
//                                .weight(.semibold)
//                        )
//                        .foregroundColor(.white)
//
//                    Text("・")
//                        .font(
//                            Font.custom("Pretendard", size: 13)
//                                .weight(.medium)
//                        )
//                        .multilineTextAlignment(.center)
//                        .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
//                        .frame(width: 4, alignment: .bottom)
//
//                    Text("1일 전")
//                        .font(
//                            Font.custom("Pretendard", size: 13)
//                                .weight(.medium)
//                        )
//                        .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
//
//                    SharedAsset.commentLockMumoryDetail.swiftUIImage
//                        .resizable()
//                        .frame(width: 15, height: 15)
//
//                    Spacer()
//
//                    Button(action: {
//                        self.isMenuShown = true
//                    }, label: {
//                        SharedAsset.commentMenuMumoryDetail.swiftUIImage
//                            .resizable()
//                            .frame(width: 18, height: 18)
//                    })
//
//                } // HStack
//
//                Text(isSecretComment ? "비밀 댓글입니다." : textContent)
//                    .lineSpacing(20)
//                    .font(isSecretComment ? Font.custom("Pretendard", size: 14)
//                        .weight(.medium) : Font.custom("Pretendard", size: 14))
//                    .foregroundColor(isSecretComment ? Color(red: 0.64, green: 0.51, blue: 0.99) : .white)
//                    .frame(maxWidth: .infinity, alignment: .topLeading)
//                    .padding(.vertical, 15)
//                //                        .background(Color.gray.opacity(0.2))
//
//            } // VStack
//            .padding(.horizontal, 15)
//            .background(
//                Rectangle()
//                    .foregroundColor(.clear)
//                    .background(Color(red: 0.12, green: 0.12, blue: 0.12))
//                    .cornerRadius(15)
//            )
//        } // HStack
//        .frame(width: UIScreen.main.bounds.width - 40 - 32 - 13)
//        .frame(minHeight: 77)
//        .padding(.top, 10)
//        .padding(.leading, 45)
//        .background(.black)
//
//    }
//}
//
//public struct MumoryDetailCommentSheetView: View {
//
//    @State private var commentText: String = ""
//
//    @EnvironmentObject var appCoordinator: AppCoordinator
//    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
//
//    public init() {}
//
//    public var body: some View {
//        VStack(spacing: 0) {
//            ZStack {
//                Rectangle()
//                    .foregroundColor(.clear)
//                    .frame(height: 72)
//                    .background(Color(red: 0.16, green: 0.16, blue: 0.16))
//                    .cornerRadius(23)
//
//                HStack {
//                    Text("댓글")
//                        .font(
//                            Font.custom("Pretendard", size: 18)
//                                .weight(.semibold)
//                        )
//                        .foregroundColor(.white)
//
//                    Spacer().frame(width: 5)
//
//                    Text("3")
//                        .font(
//                            Font.custom("Pretendard", size: 18)
//                                .weight(.medium)
//                        )
//                        .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
//
//                    Spacer()
//
//                    Button(action: {
//                        withAnimation(Animation.easeInOut(duration: 0.2)) {
//                            appCoordinator.isMumoryDetailCommentSheetViewShown = false
//                        }
//                    }, label: {
//                        SharedAsset.commentCloseButtonMumoryDetail.swiftUIImage
//                            .frame(width: 25, height: 25)
//                    })
//                } // HStack
//                .frame(width: UIScreen.main.bounds.width - 40, height: 72)
//            } // ZStack
//
//            ScrollView {
//                VStack(spacing: 0) {
//                    // MARK: Comment
//                    CommentView()
//                }
//            }
//            .gesture(TapGesture(count: 1))
//
//            ZStack {
//                Rectangle()
//                  .foregroundColor(.clear)
//                  .frame(height: 36)
//                  .background(Color(red: 0.09, green: 0.09, blue: 0.09))
//
//
//                HStack(spacing: 5) {
//                    Text("닉네임임임임임님에게 답글 남기는 중")
//                        .font(
//                            Font.custom("Pretendard", size: 12)
//                                .weight(.medium)
//                        )
//                        .foregroundColor(.white)
//
//                    Text("・")
//                      .font(
//                        Font.custom("Pretendard", size: 13)
//                          .weight(.medium)
//                      )
//                      .multilineTextAlignment(.center)
//                      .foregroundColor(.white)
//                      .frame(width: 4, alignment: .bottom)
//
//                    Button(action: {
//
//                    }, label: {
//                        Text("취소")
//                          .font(
//                            Font.custom("Pretendard", size: 12)
//                              .weight(.medium)
//                          )
//                          .foregroundColor(.white)
//                    })
//
//                }
//            } // ZStack
//
//            ZStack {
//                Rectangle()
//                    .foregroundColor(.clear)
//                    .frame(height: 72)
//                    .background(Color(red: 0.09, green: 0.09, blue: 0.09))
//                    .overlay(
//                        Rectangle()
//                            .frame(height: 0.5)
//                            .foregroundColor(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
//                            .offset(y: -36 - 0.25)
//                    )
//
//
//                HStack(spacing: 0) {
//                    Spacer().frame(width: 16)
//
//                    Button(action: {
//
//                    }, label: {
//                        SharedAsset.commentLockButtonMumoryDetail.swiftUIImage
//                            .frame(width: 35, height: 39)
//                    })
//
//                    Spacer().frame(width: 12)
//
//                    TextField("", text: $commentText, prompt: Text("댓글을 입력하세요.")
//                        .font(Font.custom("Apple SD Gothic Neo", size: 15))
//                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
//                    )
//                    .padding(.leading, 25)
//                    .padding(.trailing, 50)
//                    .background(
//                        ZStack(alignment: .trailing) {
//                            Rectangle()
//                                .foregroundColor(.clear)
//                                .frame(width: UIScreen.main.bounds.width * 0.78, height: 44.99997)
//                                .background(Color(red: 0.24, green: 0.24, blue: 0.24))
//                                .cornerRadius(22.99999)
//
//                            Button(action: {
//
//                            }, label: {
//                                SharedAsset.commentWriteOffButtonMumoryDetail.swiftUIImage
//                                    .frame(width: 20, height: 20)
//                            })
//                            .padding(.trailing, 10)
//                        }
//                    )
//                    .foregroundColor(.white)
//                    .frame(width: UIScreen.main.bounds.width * 0.78)
//                    //                    .onChange(of: searchText){ newValue in
//                    //                        if !searchText.isEmpty {
//                    //                        } else {
//                    //                        }
//                    //                    }
//
//
//                    Spacer().frame(width: 20)
//                }
//                .frame(maxWidth: .infinity)
//
//            } // ZStack
//
//        } // VStack
//        .frame(height: UIScreen.main.bounds.height * 0.84)
//        .background(Color(red: 0.16, green: 0.16, blue: 0.16))
////        .cornerRadius(23, corners: [.topLeft, .topRight])
//        .cornerRadius(23)
//        .onDisappear {
//            self.appCoordinator.isMumoryDetailCommentSheetViewShown = false
//        }
//    }
//}
//
