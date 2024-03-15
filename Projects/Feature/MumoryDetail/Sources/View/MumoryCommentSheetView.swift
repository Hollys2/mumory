//
//  MumoryDetailCommentSheetView.swift
//  Feature
//
//  Created by 다솔 on 2023/12/28.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Shared


struct CommentView: View {
    
    let index: Int
    let comment: Comment
    
    var isFocused: FocusState<Bool>.Binding
    
    @Binding var isWritingReply: Bool
    @Binding var selectedIndex: Int
    @Binding var commentDocumentID: String
    
    @State private var isSecretComment: Bool = false
    @State private var isSelectedComment: Bool = false
    @State private var textContent = "주어와 서술어는 호응하지 않고, 문장은 엿가락처럼 길기만 합니다."
    //    @State private var textContent = "주어와 서술어는 호응하지 않고, 문장은 엿가락처럼 길기만 합니다. 게다가 문맥에 어울리지 않는 한자어를 남발하는 바람에 내용 파악조차 어렵습니다. 서술형 답안을 작성하고, 논술 시험을 대비하는 학생들의 글에서 흔히 발견하는 문제입니다. 앞으로 연재할 글쓰기의 10가지 원칙을 충분히 익힌 뒤 연습문제로 확인하세요. 1회성 연습에 그치지 말고 평소에 글을 읽고 쓸 때도 원칙을 적용해야 합니다. 시간이 없다고요? 매일 보는 교과서를 활용하세요. 공부할 때 글쓰기 원칙에 어긋나는 문장을 발견한다면 원칙에 맞춰 바꿔 써 보세요. 매회 실리는 ‘교과서 ‘옥의 티’’ 꼭지를 참고하면 도움이 될 겁니다. 예문은 초·중등 학생에게 실질적인 도움을 주기 위해 초·중등 대상 신문활용교육(NIE) 매체인 <아하! 한겨레> 누리집(ahahan.co.kr)에 올라온 글 위주로 골랐습니다."
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    var body: some View {
        
        HStack(alignment: .top,  spacing: 13) {
            
            SharedAsset.profileMumoryDetail.swiftUIImage
                .resizable()
                .frame(width: 32, height: 32)
            
            VStack(spacing: 0) {
                
                VStack(spacing: 0) {
                    
                    Spacer().frame(height: 13)
                    
                    HStack(spacing: 0) {

                        Text(DateManager.formattedCommentDate(date: comment.date))
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                            .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                        
                        if !comment.isPublic {
                            Spacer().frame(width: 5)
                            
                            SharedAsset.commentLockMumoryDetail.swiftUIImage
                                .resizable()
                                .frame(width: 15, height: 15)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            appCoordinator.isCommentBottomSheetShown = true
                        }, label: {
                            SharedAsset.commentMenuMumoryDetail.swiftUIImage
                                .resizable()
                                .frame(width: 18, height: 18)
                        })
                        
                    } // HStack
                    
                    
                    Text(isSecretComment ? "비밀 댓글입니다." : comment.content)
                        .lineSpacing(20)
                        .font(isSecretComment ? Font.custom("Pretendard", size: 14)
                            .weight(.medium) : Font.custom("Pretendard", size: 14))
                        .foregroundColor(isSecretComment ? Color(red: 0.64, green: 0.51, blue: 0.99) : .white)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(.vertical, 15)
                    //                        .background(Color.gray.opacity(0.2))
                    
                } // VStack
                .padding(.horizontal, 15)
                .background(
                    Rectangle()
                        .foregroundColor(.clear)
                        .background(isSelectedComment ? Color(red: 0.09, green: 0.09, blue: 0.09) : Color(red: 0.12, green: 0.12, blue: 0.12))
                        .cornerRadius(15)
                )
                
                Spacer().frame(height: 15)
                
                Button(action: {
                    selectedIndex = index
                    isFocused.wrappedValue = true
                    commentDocumentID = comment.id
                    isWritingReply = true
                }, label: {
                    Text("답글 달기")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 12)
                
                Spacer().frame(height: 13)
            } // VStack
        } // HStack
        .frame(width: UIScreen.main.bounds.width - 40)
        .frame(minHeight: 117 - 20)
        .padding(.top, 12)
        
        
        // MARK: Reply
        
//        ForEach(self.comment.replies, id: \.self) { reply in
//            Reply(comment: reply)
//            Spacer().frame(height: 10)
//        }
        
        Spacer().frame(height: 5)
        
        Rectangle()
            .foregroundColor(.clear)
            .frame(width: UIScreen.main.bounds.width - 10, height: 0.5)
            .background(Color(red: 0.25, green: 0.25, blue: 0.25))
        
        Spacer().frame(height: 5)
    }
}

struct Reply: View {
    
    let comment: Comment
    
    @State private var isSecretComment: Bool = false
    @State private var isMenuShown: Bool = false
    @State private var textContent = "주어와 서술어는 호응하지 않고, 문장은 엿가락처럼 길기만 합니다."
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 13) {
            
            SharedAsset.profileMumoryDetail.swiftUIImage
                .resizable()
                .frame(width: 28, height: 28)
            
            VStack(spacing: 0) {
                
                Spacer().frame(height: 13)
                
                HStack(spacing: 5) {
                    Text("\(comment.userDocumentID)")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                        .foregroundColor(.white)
                    
                    Text("・")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                        .frame(width: 4, alignment: .bottom)
                    
                    Text(DateManager.formattedCommentDate(date: comment.date))
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                        .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                    
                    if !comment.isPublic {
                        SharedAsset.commentLockMumoryDetail.swiftUIImage
                            .resizable()
                            .frame(width: 15, height: 15)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.isMenuShown = true
                    }, label: {
                        SharedAsset.commentMenuMumoryDetail.swiftUIImage
                            .resizable()
                            .frame(width: 18, height: 18)
                    })
                    
                } // HStack
                
                Text(isSecretComment ? "비밀 댓글입니다." : comment.content)
                    .lineSpacing(20)
                    .font(isSecretComment ? Font.custom("Pretendard", size: 14)
                        .weight(.medium) : Font.custom("Pretendard", size: 14))
                    .foregroundColor(isSecretComment ? Color(red: 0.64, green: 0.51, blue: 0.99) : .white)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.vertical, 15)
                //                        .background(Color.gray.opacity(0.2))
                
            } // VStack
            .padding(.horizontal, 15)
            .background(
                Rectangle()
                    .foregroundColor(.clear)
                    .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                    .cornerRadius(15)
            )
        } // HStack
        .frame(width: UIScreen.main.bounds.width - 40 - 32 - 13)
        .frame(minHeight: 77)
        .padding(.top, 10)
        .padding(.leading, 45)
    }
}

public struct MumoryCommentSheetView: View {
    
    @Binding var isSheetShown: Bool
    @Binding var offsetY: CGFloat

    @Binding var mumoryAnnotation: Mumory
    @State var comments: [Comment] = []
    @State var replies: [Comment] = []
    
    @State private var commentText: String = ""
    @State private var replyText: String = ""
    @State private var isWritingReply: Bool = false
    @State private var selectedIndex: Int = -1
    @State private var commentId: String = ""
    
    @State private var isPublic: Bool = false

    @GestureState private var dragState = DragState.inactive
    
    @FocusState private var isTextFieldFocused: Bool
    
    let maxHeight = CGFloat(16)
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject private var keyboardResponder: KeyboardResponder
    
    public init(isSheetShown: Binding<Bool>, offsetY: Binding<CGFloat>, mumory: Binding<Mumory>) {
        self._isSheetShown = isSheetShown
        self._offsetY = offsetY
        self._mumoryAnnotation = mumory
    }
    
    public var body: some View {
        
        let drag = DragGesture()
            .updating($dragState) { drag, state, transaction in
                var newTranslation = drag.translation
                if self.offsetY + newTranslation.height < -maxHeight {  // 최대치를 넘지 않도록 제한
                    newTranslation.height = -maxHeight - self.offsetY
                }
                state = .dragging(translation: newTranslation)
                //                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)
        
        return ZStack(alignment: .bottom) {
            
            if isSheetShown {
                
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeIn(duration: 0.1)) {
                            self.appCoordinator.isMumoryDetailCommentSheetViewShown = false
                        }
                    }
                
                VStack(spacing: 0) {
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: 72)
                            .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                            .cornerRadius(23)
                        
                        HStack {
                            Text("댓글")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                                .foregroundColor(.white)
                            
                            Spacer().frame(width: 5)
                            
//                            Text("\(self.comments.count)")
                            Text("\(self.mumoryAnnotation.commentCount)")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                                .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(Animation.easeInOut(duration: 0.2)) {
                                    appCoordinator.isMumoryDetailCommentSheetViewShown = false
                                }
                            }, label: {
                                SharedAsset.commentCloseButtonMumoryDetail.swiftUIImage
                                    .frame(width: 25, height: 25)
                            })
                        } // HStack
                        .frame(width: UIScreen.main.bounds.width - 40, height: 72)
                    } // ZStack
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // MARK: Comment
                            ForEach(Array(self.comments.enumerated()), id: \.element) { index, comment in
                                CommentView(index: index, comment: comment, isFocused: $isTextFieldFocused, isWritingReply: $isWritingReply, selectedIndex: $selectedIndex, commentDocumentID: $commentId)
                            }
                        }
                    }
                    .simultaneousGesture(DragGesture().onChanged { i in
                        print("simultaneousGesture DragGesture")
                        isWritingReply = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    })
                    .gesture(TapGesture(count: 1).onEnded {
                        print("gesture TapGesture")
                        isWritingReply = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    })
                    
                    ZStack(alignment: .bottom) {
                            
                        HStack(spacing: 0) {
                            
                            Spacer().frame(width: 16)
                            
                            Button(action: {
                                self.isPublic.toggle()
                            }, label: {
                                self.isPublic ?
                                SharedAsset.commentUnlockButtonMumoryDetail.swiftUIImage
                                    .resizable()
                                    .frame(width: 35, height: 39)
                                : SharedAsset.commentLockButtonMumoryDetail.swiftUIImage
                                    .resizable()
                                    .frame(width: 35, height: 39)
                            })
                            
                            Spacer().frame(width: 12)
                            
                            TextField("", text: $commentText, prompt: Text("댓글을 입력하세요.")
                                .font(Font.custom("Apple SD Gothic Neo", size: 15))
                                .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                            )
                            .padding(.leading, 25)
                            .padding(.trailing, 50)
                            .background(
                                ZStack(alignment: .trailing) {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: UIScreen.main.bounds.width * 0.78, height: 44.99997)
                                        .background(Color(red: 0.24, green: 0.24, blue: 0.24))
                                        .cornerRadius(22.99999)
                                    
                                    Button(action: {
//                                        mumoryDataViewModel.createComment(mumoryAnnotation: mumoryDataViewModel.selectedMumoryAnnotation ?? Mumory(), loginUserID: "tester", comment: Comment(author: "tester", date: Date(), content: commentText, isPublic: self.isPublic))
                                        commentText = ""
                                    }, label: {
                                        commentText.isEmpty ?
                                        SharedAsset.commentWriteOffButtonMumoryDetail.swiftUIImage
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        : SharedAsset.commentWriteOnButtonMumoryDetail.swiftUIImage
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                    })
                                    .padding(.trailing, 10)
                                }
                            )
                            .foregroundColor(.white)
                            .frame(width: UIScreen.main.bounds.width * 0.78)
                            .focused($isTextFieldFocused)
                            
                            Spacer().frame(width: 20)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 72)
                        .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                        .overlay(
                            Rectangle()
                                .fill(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                                .frame(height: 0.5)
                            , alignment: .top
                        )
                        .padding(.bottom, 23)

                            
                        if isWritingReply {

                            VStack(spacing: 0) {

                                HStack(spacing: 5) {

                                    Text("\(appCoordinator.currentUser.nickname)")
                                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                        .foregroundColor(.white) +
                                    Text("님에게 답글 남기는 중")
                                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                        .foregroundColor(Color(red: 0.761, green: 0.761, blue: 0.761))

                                    Text("・")
                                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(Color(red: 0.761, green: 0.761, blue: 0.761))
                                        .frame(width: 4, alignment: .bottom)

                                    Button(action: {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }, label: {
                                        Text("취소")
                                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                            .foregroundColor(Color(red: 0.761, green: 0.761, blue: 0.761))
                                    })

                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 36)
                                .background(Color(red: 0.09, green: 0.09, blue: 0.09))

                                HStack(spacing: 0) {

                                    Spacer().frame(width: 16)

                                    Button(action: {
                                        self.isPublic.toggle()
                                    }, label: {
                                        self.isPublic ?
                                        SharedAsset.commentUnlockButtonMumoryDetail.swiftUIImage
                                            .resizable()
                                            .frame(width: 35, height: 39)
                                        : SharedAsset.commentLockButtonMumoryDetail.swiftUIImage
                                            .resizable()
                                            .frame(width: 35, height: 39)
                                    })

                                    Spacer().frame(width: 12)

                                    TextField("", text: $replyText, prompt: Text("답글을 입력하세요.")
                                        .font(Font.custom("Apple SD Gothic Neo", size: 15))
                                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                    )
                                    .padding(.leading, 25)
                                    .padding(.trailing, 50)
                                    .background(
                                        ZStack(alignment: .trailing) {
                                            RoundedRectangle(cornerRadius: 22.99999)
                                                .stroke(Color(red: 0.651, green: 0.651, blue: 0.651), lineWidth: replyText.isEmpty ? 0 : 1)
                                                .foregroundColor(.clear)
                                                .frame(width: UIScreen.main.bounds.width * 0.78, height: 44.99997)
                                                .background(Color(red: 0.24, green: 0.24, blue: 0.24))
                                                .cornerRadius(22.99999)

                                            Button(action: {
//                                                mumoryDataViewModel.createReply(mumoryAnnotation: mumoryAnnotation, loginUserID: "tester", parentCommentIndex: selectedIndex, reply: Comment(author: "tester", date: Date(), content: replyText, isPublic: self.isPublic))
                                                
                                                if let m = mumoryDataViewModel.selectedMumoryAnnotation {
                                                    mumoryDataViewModel.createReply(mumoryId: m.id, commentId: commentId, reply: Comment(id: "", userDocumentID: appCoordinator.currentUser.documentID, date: Date(), content: replyText, isPublic: self.isPublic))
                                                }
                                                replyText = ""
                                            }, label: {
                                                replyText.isEmpty ?
                                                SharedAsset.commentWriteOffButtonMumoryDetail.swiftUIImage
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                : SharedAsset.commentWriteOnButtonMumoryDetail.swiftUIImage
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                            })
                                            .padding(.trailing, 10)
                                        }
                                    )
                                    .foregroundColor(.white)
                                    .frame(width: UIScreen.main.bounds.width * 0.78)
//                                    .focused($isTextFieldFocused)

                                    Spacer().frame(width: 20)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 72)
                                .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                                .overlay(
                                    Rectangle()
                                        .frame(height: 0.5)
                                        .foregroundColor(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                                        .offset(y: -36)
                                )
                            }
                            .offset(y: 72 + 36)
                            .offset(y: self.keyboardResponder.isKeyboardHiddenButtonShown ? -self.keyboardResponder.keyboardHeight - 72 - 36 : 0)
                        } else {

                            HStack(spacing: 0) {

                                Spacer().frame(width: 16)

                                Button(action: {
                                    self.isPublic.toggle()
                                }, label: {
                                    self.isPublic ?
                                    SharedAsset.commentUnlockButtonMumoryDetail.swiftUIImage
                                        .resizable()
                                        .frame(width: 35, height: 39)
                                    : SharedAsset.commentLockButtonMumoryDetail.swiftUIImage
                                        .resizable()
                                        .frame(width: 35, height: 39)
                                })

                                Spacer().frame(width: 12)

                                
//                                TextEditor(text: $commentText)
//                                    .scrollContentBackground(.hidden)
//                                    .foregroundColor(.white)
//                                    .font(Font.custom("Apple SD Gothic Neo", size: 18))
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .background(.orange)
////                                    .overlay(
////                                        Text("자유롭게 내용을 입력하세요.")
////                                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
////                                            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
////                                            .offset(y: 3)
////                                            .opacity(self.commentText.isEmpty ? 1 : 0)
////                                            .allowsHitTesting(false)
////                                        , alignment: .topLeading
////                                    )
                                TextField("", text: $commentText, prompt: Text("댓글을 입력하세요.")
                                    .font(Font.custom("Apple SD Gothic Neo", size: 15))
                                    .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                )
                                .padding(.leading, 25)
                                .padding(.trailing, 50)
                                .background(
                                    ZStack(alignment: .trailing) {
                                        RoundedRectangle(cornerRadius: 22.99999)
                                            .stroke(Color(red: 0.651, green: 0.651, blue: 0.651), lineWidth: commentText.isEmpty ? 0 : 1)
                                            .foregroundColor(.clear)
                                            .frame(width: UIScreen.main.bounds.width * 0.78, height: 44.99997)
                                            .background(Color(red: 0.24, green: 0.24, blue: 0.24))
                                            .cornerRadius(22.99999)
                                            

                                        Button(action: {
//                                            mumoryDataViewModel.createComment(mumoryAnnotation: mumoryDataViewModel.selectedMumoryAnnotation ?? Mumory(), loginUserID: "tester", comment: Comment(author: "tester", date: Date(), content: commentText, isPublic: self.isPublic))
                                            Task {
                                                guard let mumory = mumoryDataViewModel.selectedMumoryAnnotation else {
                                                    print("mumoryDataViewModel.selectedMumoryAnnotation is nil!")
                                                    return
                                                }
                                                
                                                mumoryDataViewModel.createComment(mumoryDocumentID: mumory.id, comment: Comment(id: "", userDocumentID: appCoordinator.currentUser.documentID, date: Date(), content: commentText, isPublic: self.isPublic))
                                                commentText = ""
                                                
                                                self.comments = await MumoryDataViewModel.fetchComment(mumoryId: mumory.id) ?? []
                                                
                                                mumoryAnnotation.commentCount = self.comments.count
                                                
                                                mumoryDataViewModel.fetchEveryMumory()
                                                
                                            }
                                        }, label: {
                                            commentText.isEmpty ?
                                            SharedAsset.commentWriteOffButtonMumoryDetail.swiftUIImage
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            : SharedAsset.commentWriteOnButtonMumoryDetail.swiftUIImage
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                        })
                                        .padding(.trailing, 10)
                                    }
                                )
                                .foregroundColor(.white)
                                .frame(width: UIScreen.main.bounds.width * 0.78)

                                Spacer().frame(width: 20)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 72)
                            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                            .overlay(
                                Rectangle()
                                    .fill(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                                    .frame(height: 0.5)
                                , alignment: .top
                            )
                            .offset(y: 72)
                            .offset(y: self.keyboardResponder.isKeyboardHiddenButtonShown ? -self.keyboardResponder.keyboardHeight - 72 : 0)
                        }
                    } // ZStack
                } // VStack
//                .frame(height: UIScreen.main.bounds.height * 0.84)
                .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                .cornerRadius(23, corners: [.topLeft, .topRight])
                .padding(.top, UIScreen.main.bounds.height * 0.16)
                .offset(y: self.offsetY + self.dragState.translation.height)
                .gesture(drag)
                .gesture(TapGesture(count: 1).onEnded {
//                    print("TapGesture")
//                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                })
                .transition(.move(edge: .bottom))
                .zIndex(1)
                .background(
                    GeometryReader{ g in
                        Color.clear
                            .onAppear {
//                                print("g.size.width: \(g.size.width)")
                            }
                    }
                )
                .onAppear {
                    if let m = mumoryDataViewModel.selectedMumoryAnnotation {
                        Task {
                            let x = await MumoryDataViewModel.fetchComment(mumoryId: m.id) ?? []
                            for i in x {
                                if i.parentDocumentID == nil {
                                    self.comments.append(i)
                                } else {
                                    self.replies.append(i)
                                }
                            }
                        }
                    }
                }
                .onDisappear {
                    self.comments = []
                    self.replies = []
                    self.appCoordinator.isMumoryDetailCommentSheetViewShown = false
                }
            }
        }
    }
    
    private func onDragEnded(drag: DragGesture.Value) {
//        print("drag.translation.height: \(drag.translation.height)")
        //        let verticalDirection = drag.predictedEndLocation.y - drag.location.y
        let cardDismiss = drag.translation.height > 100
        let offset = cardDismiss ? drag.translation.height : 0
        
        self.offsetY = CGFloat(offset)
        
        if cardDismiss {
            withAnimation(.spring(response: 0.1)) {
                
                self.isSheetShown = false
            }
        }
    }
}
