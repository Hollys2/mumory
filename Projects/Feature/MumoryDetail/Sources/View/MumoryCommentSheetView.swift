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
    let replies: [Comment]
    
    var isFocused: FocusState<Bool>.Binding
    
    @Binding var isWritingReply: Bool
    @Binding var selectedIndex: Int
    @Binding var commentDocumentID: String
    
    @State private var user: MumoriUser = MumoriUser()
    @State private var isSecretComment: Bool = false
    @State private var isSelectedComment: Bool = false
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    var body: some View {
        
        HStack(alignment: .top,  spacing: 13) {
            
            AsyncImage(url: self.user.profileImageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                default:
                    Color(red: 0.184, green: 0.184, blue: 0.184)
                }
            }
            .frame(width: 32, height: 32)
            .mask {Circle()}
            
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
                            mumoryDataViewModel.selectedComment = self.comment
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
        .onAppear {
            Task {
                self.user = await MumoriUser(uId: comment.userDocumentID)
            }
        }
        
        
        // MARK: Reply
        ForEach(self.replies, id: \.self) { reply in
            if reply.parentId == comment.id {
                Reply(comment: reply)
                Spacer().frame(height: 10)
            }
        }
        
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
    
    @State private var user: MumoriUser = MumoriUser()
    @State private var isSecretComment: Bool = false
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 13) {
            
            AsyncImage(url: self.user.profileImageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                default:
                    Color(red: 0.184, green: 0.184, blue: 0.184)
                }
            }
            .frame(width: 28, height: 28)
            .mask {Circle()}
            
            VStack(spacing: 0) {
                
                Spacer().frame(height: 13)
                
                HStack(spacing: 5) {
                    Text("\(comment.nickname)")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
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
                        mumoryDataViewModel.selectedComment = self.comment
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
                    .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                    .cornerRadius(15)
            )
        } // HStack
        .frame(width: UIScreen.main.bounds.width - 40 - 32 - 13)
        .frame(minHeight: 77)
        .padding(.top, 10)
        .padding(.leading, 45)
        .onAppear {
            Task {
                self.user = await MumoriUser(uId: comment.userDocumentID)
            }
        }
    }
}

public struct MumoryCommentSheetView: View {
    
    @Binding var isSheetShown: Bool
    @Binding var offsetY: CGFloat

    @State var mumory: Mumory = Mumory()
    @State var comments: [Comment] = []
    @State var replies: [Comment] = []
    
    @State private var commentText: String = ""
    @State private var replyText: String = ""
    @State private var isWritingReply: Bool = false
    @State private var selectedIndex: Int = -1
    @State private var commentId: String = ""
    @State private var isButtonDisabled: Bool = false
    
    @State private var isPublic: Bool = false

    @GestureState private var dragState = DragState.inactive
    
    @FocusState private var isTextFieldFocused: Bool
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject private var keyboardResponder: KeyboardResponder
    
    public init(isSheetShown: Binding<Bool>, offsetY: Binding<CGFloat>) {
        self._isSheetShown = isSheetShown
        self._offsetY = offsetY
    }
    
    public var body: some View {
        
        let dragGesture = DragGesture()
            .updating($dragState) { drag, state, transaction in
                var newTranslation = drag.translation
                if self.offsetY + newTranslation.height < 0 {
                    newTranslation.height = -self.offsetY
                }
                state = .dragging(translation: newTranslation)
            }
            .onEnded(onDragEnded)
        
        return ZStack(alignment: .bottom) {
            
            if isSheetShown {
                
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            self.isSheetShown = false
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
                            
                            Text("\(self.mumory.commentCount)")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                                .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(Animation.easeInOut(duration: 0.1)) {
                                    self.isSheetShown = false
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
                                CommentView(index: index, comment: comment, replies: self.replies, isFocused: $isTextFieldFocused, isWritingReply: $isWritingReply, selectedIndex: $selectedIndex, commentDocumentID: $commentId)
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
                            
                            TextField("", text: $commentText,
                                      prompt: Text("댓글을 입력하세요.")
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
                                                let isWhitespace = replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                                if !isWhitespace {
                                                    isButtonDisabled = true
                                                    
                                                    Task {
                                                        mumoryDataViewModel.createReply(mumoryId: mumory.id, reply: Comment(id: "", uId: appCoordinator.currentUser.uId, nickname: appCoordinator.currentUser.nickname, parentId: commentId, mumoryId: mumory.id, date: Date(), content: replyText, isPublic: self.isPublic)) { result in
                                                            replyText = ""
                                                            switch result {
                                                            case .success(let replies):
                                                                self.replies = replies
                                                            case .failure(let error):
                                                                print(error)
                                                            }
                                                        }
                                                    }
                                                    isButtonDisabled = false
                                                }
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
                                            let isWhitespace = commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                            if !isWhitespace {
                                                isButtonDisabled = true
                                                
                                                Task {
                                                    mumoryDataViewModel.createComment(mumoryDocumentID: mumory.id, comment: Comment(id: "", uId: appCoordinator.currentUser.uId, nickname: appCoordinator.currentUser.nickname, parentId: "", mumoryId: mumory.id, date: Date(), content: commentText, isPublic: self.isPublic)) { comments in
                                                        commentText = ""
                                                        self.comments = comments
                                                        isButtonDisabled = false
                                                    }
                                                    mumory.commentCount = await MumoryDataViewModel.fetchCommentCount(mumoryId: mumory.id)
                                                }
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
                                        .disabled(isButtonDisabled)
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
                .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                .cornerRadius(23, corners: [.topLeft, .topRight])
                .padding(.top, UIScreen.main.bounds.height * 0.16)
                .offset(y: self.offsetY + self.dragState.translation.height)
                .gesture(dragGesture)
                .transition(.move(edge: .bottom))
                .zIndex(1)
                .onAppear {
                    Task {
                        self.mumory = await mumoryDataViewModel.fetchMumory(documentID: mumoryDataViewModel.selectedMumoryAnnotation.id)
                        
                        let commentAndReply = await MumoryDataViewModel.fetchComment(mumoryId: self.mumory.id) ?? []
                        for i in commentAndReply {
                            if i.parentId == "" {
                                self.comments.append(i)
                            } else {
                                self.replies.append(i)
                            }
                        }
                    }
                }
                .onDisappear {
                    self.comments = []
                    self.replies = []
                }
                .popup(show: $appCoordinator.isDeleteCommentPopUpViewShown) {
                    PopUpView(isShown: $appCoordinator.isDeleteCommentPopUpViewShown, type: .twoButton, title: "나의 댓글을 삭제하시겠습니까?", buttonTitle: "댓글 삭제", buttonAction: {
                        self.mumoryDataViewModel.deleteComment(comment: mumoryDataViewModel.selectedComment) { comments in
                            Task {
                                self.comments = []
                                self.replies = []
                                for i in comments {
                                    if i.parentId == "" {
                                        self.comments.append(i)
                                    } else {
                                        self.replies.append(i)
                                    }
                                }
                                appCoordinator.isDeleteCommentPopUpViewShown = false
                            }
                        }

                    })
                }
            }
        }
    }
    
    private func onDragEnded(drag: DragGesture.Value) {
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
