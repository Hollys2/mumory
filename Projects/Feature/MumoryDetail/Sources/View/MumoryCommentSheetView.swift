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
    
    let comment: Comment
    let replies: [Comment]
    let mumory: Mumory
    
    var isFocused: FocusState<Bool>.Binding
    
    @Binding var isWritingReply: Bool
    @Binding var selectedComment: Comment
    
    var scrollToComment: () -> Void
    
    @State private var commentUser: MumoriUser = MumoriUser()
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var currentUserData: CurrentUserData

    var body: some View {
        
        HStack(alignment: .top,  spacing: 13) {
            if currentUserData.blockFriends.contains(where: {$0.uId == comment.uId}) {
                commentUser.defaultProfileImage
                    .resizable()
                    .frame(width: 28, height: 28)
                    .mask { Circle() }
            } else if mumory.uId != currentUserData.user.uId && !currentUserData.friends.contains(where: { $0.uId == comment.uId }) && currentUserData.user.uId != comment.uId {
                commentUser.defaultProfileImage
                    .resizable()
                    .frame(width: 28, height: 28)
                    .mask { Circle() }
                    .onTapGesture {
                        appCoordinator.rootPath.append(MumoryPage.friend(friend: self.commentUser))
                    }
            } else if mumory.uId != currentUserData.user.uId && currentUserData.user.uId != comment.uId && !comment.isPublic {
                commentUser.defaultProfileImage
                    .resizable()
                    .frame(width: 28, height: 28)
                    .mask { Circle() }
                    .onTapGesture {
                        appCoordinator.rootPath.append(MumoryPage.friend(friend: self.commentUser))
                    }
            } else {
                AsyncImage(url: commentUser.profileImageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                    default:
                        Color(red: 0.184, green: 0.184, blue: 0.184)
                    }
                }
                .frame(width: 28, height: 28)
                .mask { Circle() }
                .onTapGesture {
                    if commentUser.uId == currentUserData.user.uId {
                        appCoordinator.rootPath.append(MyPage.myPage)
                    } else {
                        appCoordinator.rootPath.append(MumoryPage.friend(friend: self.commentUser))
                    }
                }
            }
            
            VStack(spacing: 0) {
                
                VStack(spacing: 0) {
                    
                    HStack(spacing: 5) {
                        if currentUserData.blockFriends.contains(where: {$0.uId == comment.uId}) {
                            EmptyView()
                        } else if mumory.uId != currentUserData.user.uId && !currentUserData.friends.contains(where: { $0.uId == comment.uId }) && comment.isPublic && currentUserData.user.uId != comment.uId && self.commentUser.nickname != "탈퇴계정" {
                            Text(StringManager.maskString(self.commentUser.nickname))
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            Text("・")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                                .frame(width: 4, alignment: .bottom)
                        } else if mumory.uId != currentUserData.user.uId && !comment.isPublic && currentUserData.user.uId != comment.uId && self.commentUser.nickname != "탈퇴계정" {
                            EmptyView()
                        } else {
                            Text("\(self.commentUser.nickname)")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                                .foregroundColor(self.commentUser.nickname == "탈퇴계정" ? Color(red: 0.475, green: 0.475, blue: 0.475) : .white)
                                .lineLimit(1)
                            
                            Text("・")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                                .frame(width: 4, alignment: .bottom)
                        }
                        
                        if !currentUserData.blockFriends.contains(where: {$0.uId == comment.uId}) {
                            Text(DateManager.formattedCommentDate(date: comment.date))
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                                .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                            
                            if !comment.isPublic {
                                SharedAsset.commentLockMumoryDetail.swiftUIImage
                                    .resizable()
                                    .frame(width: 15, height: 15)
                            }
                        } else {
                            Text("차단된 사용자의 댓글입니다.")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                .foregroundColor(Color(red: 0.475, green: 0.475, blue: 0.475))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            mumoryDataViewModel.selectedComment = self.comment
                            appCoordinator.isCommentBottomSheetShown = true
                        }, label: {
                            SharedAsset.commentMenuMumoryDetail.swiftUIImage
                                .resizable()
                                .frame(width: 18, height: 18)
                        })
                        .disabled(currentUserData.blockFriends.contains(where: {$0.uId == comment.uId}))
                        
                    } // HStack
                    .padding(.vertical, !currentUserData.blockFriends.contains(where: {$0.uId == comment.uId}) ? 9 : 14)
                
                    if !currentUserData.blockFriends.contains(where: {$0.uId == comment.uId}) {
                        Text(mumory.uId != currentUserData.uId && !comment.isPublic && comment.uId != currentUserData.user.uId ? "비밀 댓글입니다." : comment.content)
                            .font(mumory.uId != currentUserData.user.uId && !comment.isPublic && comment.uId != currentUserData.user.uId ? SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14) : SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                            .foregroundColor(mumory.uId != currentUserData.user.uId && !comment.isPublic && comment.uId != currentUserData.user.uId ? Color(red: 0.64, green: 0.51, blue: 0.99) : .white)
                            .lineSpacing(1)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .padding(.bottom, 12)
                    }
                } // VStack
                .padding(.horizontal, 15)
                .background(
                    Rectangle()
                        .foregroundColor(.clear)
                        .background(self.selectedComment.id == self.comment.id ? Color(red: 0.09, green: 0.09, blue: 0.09) : Color(red: 0.12, green: 0.12, blue: 0.12))
                        .cornerRadius(15)
                )
                
                Spacer().frame(height: 15)
                
                if !currentUserData.blockFriends.contains(where: {$0.uId == comment.uId}) {
                    
                    Button(action: {
                        withAnimation {
                            scrollToComment()
                        }
                        isFocused.wrappedValue = true
                        selectedComment = comment
                        print("selectedComment: \(selectedComment)")
                        isWritingReply = true
                        
                    }, label: {
                        Text("답글 달기")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                    })
                    .disabled(mumory.uId != currentUserData.uId && !comment.isPublic && comment.uId != currentUserData.user.uId)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 12)
                }
                
                Spacer().frame(height: 13)
            } // VStack
        } // HStack
        .frame(width: UIScreen.main.bounds.width - 40)
        .frame(minHeight: 117 - 20)
        .padding(.top, 12)
        .onAppear {
            Task {
                self.commentUser = await MumoriUser(uId: comment.uId)
            }
        }
        
        // MARK: Reply
        ForEach(self.replies, id: \.self) { reply in
            if reply.parentId == comment.id {
                Reply(comment: reply, mumory: self.mumory)
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
    let mumory: Mumory
    
    @State private var commentUser: MumoriUser = MumoriUser()
    @State private var isMyComment: Bool = false
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 13) {
            if currentUserData.blockFriends.contains(where: {$0.uId == comment.uId}) {
                commentUser.defaultProfileImage
                    .resizable()
                    .frame(width: 28, height: 28)
                    .mask { Circle() }
            } else if mumory.uId != currentUserData.user.uId && !currentUserData.friends.contains(where: { $0.uId == comment.uId }) && currentUserData.user.uId != comment.uId {
                commentUser.defaultProfileImage
                    .resizable()
                    .frame(width: 28, height: 28)
                    .mask { Circle() }
                    .onTapGesture {
                        appCoordinator.rootPath.append(MumoryPage.friend(friend: self.commentUser))
                    }
            } else if mumory.uId != currentUserData.user.uId && currentUserData.user.uId != comment.uId && !comment.isPublic && !self.isMyComment {
                commentUser.defaultProfileImage
                    .resizable()
                    .frame(width: 28, height: 28)
                    .mask { Circle() }
                    .onTapGesture {
                        appCoordinator.rootPath.append(MumoryPage.friend(friend: self.commentUser))
                    }
            } else {
                AsyncImage(url: commentUser.profileImageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                    default:
                        Color(red: 0.184, green: 0.184, blue: 0.184)
                    }
                }
                .frame(width: 28, height: 28)
                .mask { Circle() }
                .onTapGesture {
                    if commentUser.uId == currentUserData.user.uId {
                        appCoordinator.rootPath.append(MyPage.myPage)
                    } else {
                        appCoordinator.rootPath.append(MumoryPage.friend(friend: self.commentUser))
                    }
                }
            }
            
            VStack(spacing: 0) {
                
                HStack(spacing: 5) {
                    if currentUserData.blockFriends.contains(where: {$0.uId == comment.uId}) {
                        EmptyView()
                    } else if mumory.uId != currentUserData.user.uId && !currentUserData.friends.contains(where: { $0.uId == comment.uId }) && comment.isPublic && currentUserData.user.uId != comment.uId && self.commentUser.nickname != "탈퇴계정" {
                        Text(StringManager.maskString(self.commentUser.nickname))
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text("・")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                            .frame(width: 4, alignment: .bottom)
                    } else if mumory.uId != currentUserData.user.uId && !currentUserData.friends.contains(where: { $0.uId == comment.uId }) && !comment.isPublic && currentUserData.user.uId != comment.uId &&  self.isMyComment && self.commentUser.nickname != "탈퇴계정" {
                        Text(StringManager.maskString(self.commentUser.nickname))
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text("・")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                            .frame(width: 4, alignment: .bottom)
                    } else if mumory.uId != currentUserData.user.uId && !comment.isPublic && currentUserData.user.uId != comment.uId && !self.isMyComment && self.commentUser.nickname != "탈퇴계정" {
                        EmptyView()
                    } else {
                        Text("\(self.commentUser.nickname)")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                            .foregroundColor(self.commentUser.nickname == "탈퇴계정" ? Color(red: 0.475, green: 0.475, blue: 0.475) : .white)
                            .lineLimit(1)
                        
                        Text("・")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                            .frame(width: 4, alignment: .bottom)
                    }
                    
                    if !currentUserData.blockFriends.contains(where: {$0.uId == comment.uId}) {
                        Text(DateManager.formattedCommentDate(date: comment.date))
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                            .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                        
                        if !comment.isPublic {
                            SharedAsset.commentLockMumoryDetail.swiftUIImage
                                .resizable()
                                .frame(width: 15, height: 15)
                        }
                    } else {
                        Text("차단된 사용자의 답글입니다.")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                            .foregroundColor(Color(red: 0.475, green: 0.475, blue: 0.475))
                    }
                    
                    
                    Spacer()
                    
                    Button(action: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        mumoryDataViewModel.selectedComment = self.comment
                        appCoordinator.isCommentBottomSheetShown = true
                    }, label: {
                        SharedAsset.commentMenuMumoryDetail.swiftUIImage
                            .resizable()
                            .frame(width: 18, height: 18)
                    })
                } // HStack
                .padding(.vertical, !currentUserData.blockFriends.contains(where: {$0.uId == comment.uId}) ? 9 : 14)
            
                if !currentUserData.blockFriends.contains(where: {$0.uId == comment.uId}) {
                    Text(mumory.uId != currentUserData.uId && !comment.isPublic && comment.uId != currentUserData.user.uId && !self.isMyComment ? "비밀 답글입니다." : comment.content)
                        .font(mumory.uId != currentUserData.uId && !comment.isPublic && comment.uId != currentUserData.user.uId && !self.isMyComment ? SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14) : SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundColor(mumory.uId != currentUserData.uId && !comment.isPublic && comment.uId != currentUserData.user.uId && !self.isMyComment ? Color(red: 0.64, green: 0.51, blue: 0.99) : .white)
                        .lineSpacing(1)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(.bottom, 12)
                }
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
                self.commentUser = await MumoriUser(uId: comment.uId)
                self.isMyComment = await mumoryDataViewModel.checkIsMyComment(mumoryId: mumory.id, reply: comment, currentUser: currentUserData.user)
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
    @State var selectedCommentUser: MumoriUser = MumoriUser()
    
    @State private var commentText: String = ""
    //    @State private var replyText: String = ""
    @State private var isWritingReply: Bool = false
    @State private var selectedIndex: Int = -1
    @State private var selectedComment: Comment = Comment()
    @State private var isButtonDisabled: Bool = false
    
    @State private var isPublic: Bool = false
    
    @State private var commentYOffset: CGFloat = .zero
    
    @GestureState private var dragState = DragState.inactive
    
    @FocusState private var isTextFieldFocused: Bool
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject private var keyboardResponder: KeyboardResponder
    @EnvironmentObject var playerViewModel: PlayerViewModel

    
    public init(isSheetShown: Binding<Bool>, offsetY: Binding<CGFloat>) {
        self._isSheetShown = isSheetShown
        self._offsetY = offsetY
    }
    
    public var body: some View {
        let dragGesture = DragGesture()
            .updating($dragState) { value, state, transaction in
                var newTranslation = value.translation
                print("updating")
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
                        playerViewModel.setPlayerVisibilityWithoutAnimation(isShown: true)
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
                        
                        SharedAsset.dragIndicator.swiftUIImage
                            .resizable()
                            .frame(width: 47, height: 4)
                            .offset(y: -24)
                        
                        HStack {
                            
                            Text("댓글")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                                .foregroundColor(.white)
                            
                            
                            if self.mumory.commentCount > 0 {
                                Spacer().frame(width: 5)
                                
                                Text("\(self.mumory.commentCount)")
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                                    .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                playerViewModel.setPlayerVisibilityWithoutAnimation(isShown: true)
                                withAnimation(Animation.easeInOut(duration: 0.1)) {
                                    self.isSheetShown = false
                                }
                            }, label: {
                                SharedAsset.commentCloseButtonMumoryDetail.swiftUIImage
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            })
                        } // HStack
                        .frame(width: UIScreen.main.bounds.width - 40, height: 72)
                    } // ZStack
                    .frame(height: 72)
                    .gesture(TapGesture(count: 1).onEnded {
                        print("gesture TapGesture")
                        isWritingReply = false
                        selectedComment = Comment()
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    })
                    
                    ScrollViewReader { proxy in
                        
                        ScrollView(showsIndicators: false) {
                            
                            ZStack(alignment: .top) {
                                
                                Color.clear
                                
                                if self.comments.isEmpty {
                                    VStack(spacing: 21) {
                                        
                                        Text("아직 댓글이 없어요")
                                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                        
                                        Text("가장 먼저 댓글을 달아 친구들과 소통해보세요 !")
                                            .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 14))
                                            .foregroundColor(Color(red: 0.761, green: 0.761, blue: 0.761))
                                            .lineSpacing(3)
                                            .fixedSize(horizontal: true, vertical: true)
                                    }
                                    .offset(y: 130)
                                }
                                
                                VStack(spacing: 0) {
                                    
                                    ForEach(Array(self.comments.enumerated()), id: \.element) { index, comment in
                                        CommentView(comment: comment, replies: self.replies, mumory: self.mumory, isFocused: $isTextFieldFocused, isWritingReply: $isWritingReply, selectedComment: self.$selectedComment) {
                                            withAnimation {
                                                proxy.scrollTo(index, anchor: .top)
                                            }
                                        }
                                        .id(index)
                                    }
                                    
                                    Spacer(minLength: 0)
                                }
                                .frame(minHeight: keyboardResponder.keyboardHeight == .zero ? getUIScreenBounds().height - 72 - appCoordinator.safeAreaInsetsBottom - 72 - (UIScreen.main.bounds.height * 0.16) : getUIScreenBounds().height * 10)
                            }
                        }
                        .refreshable {
                            self.commentText = ""
                            self.isWritingReply = false
                            self.selectedComment = Comment()
                            
                            mumory.commentCount = 0
                            self.comments = []
                            self.replies = []
                            
                            Task {
                                self.mumory = await mumoryDataViewModel.fetchMumory(documentID: mumoryDataViewModel.selectedMumoryAnnotation.id)
                                
                                let commentAndReply = await MumoryDataViewModel.fetchComment(mumoryId: self.mumory.id) ?? []
                                for i in commentAndReply {
                                    if i.parentId == "" {
                                        self.comments.append(i)
                                    } else {
                                        self.replies.append(i)
                                    }
                                    self.comments.sort { $0.date < $1.date }
                                    self.replies.sort { $0.date < $1.date }
                                }
                                
                                mumory.commentCount = await MumoryDataViewModel.fetchCommentCount(mumoryId: mumory.id)
                            }
                        }
                        .onAppear {
                            UIRefreshControl.appearance().tintColor = UIColor(white: 0.47, alpha: 1)
                        }
                    }
                    .simultaneousGesture(DragGesture().onEnded { _ in
                        print("simultaneousGesture DragGesture")
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    })
                    .gesture(TapGesture(count: 1).onEnded {
                        print("gesture TapGesture")
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    })
                    
                    VStack(spacing: 0) {
                        
                        if self.isWritingReply {
                            
                            HStack(spacing: 5) {
                                
                                Text(selectedComment.uId != currentUserData.user.uId && !currentUserData.friends.contains(where: { $0.uId == selectedComment.uId }) ? StringManager.maskString(self.selectedCommentUser.nickname) : "\(self.selectedCommentUser.nickname)")
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
                                    self.isWritingReply = false
                                    self.selectedComment = Comment()
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
                            .onAppear {
                                Task {
                                    self.selectedCommentUser = await MumoriUser(uId: self.selectedComment.uId)
                                }
                            }
                        }
                        
                        HStack(spacing: 0) {
                            
                            Spacer().frame(width: 16)
                            
                            Image(uiImage: self.isPublic ? SharedAsset.commentUnlockButtonMumoryDetail.image : SharedAsset.commentLockButtonMumoryDetail.image)
                                .resizable()
                                .frame(width: 35, height: 39)
                                .onTapGesture {
                                    self.isPublic.toggle()
                                }
                            
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
                                        let isWhitespace = commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                        
                                        if !isWhitespace, self.isWritingReply {
                                            isButtonDisabled = true
                                            
                                            Task {
                                                mumoryDataViewModel.createReply(mumoryId: mumory.id, reply: Comment(id: "", uId: currentUserData.user.uId, nickname: currentUserData.user.nickname, parentId: self.selectedComment.id, mumoryId: mumory.id, date: Date(), content: self.commentText, isPublic: self.isPublic)) { result in
                                                    self.commentText = ""
                                                    switch result {
                                                    case .success(let replies):
                                                        self.replies = replies
                                                    case .failure(let error):
                                                        print(error)
                                                    }
                                                }
                                            }
                                            isButtonDisabled = false
                                        } else {
                                            isButtonDisabled = true
                                            
                                            Task {
                                                mumoryDataViewModel.createComment(mumoryDocumentID: mumory.id, comment: Comment(id: "", uId: currentUserData.user.uId, nickname: currentUserData.user.nickname, parentId: "", mumoryId: mumory.id, date: Date(), content: commentText, isPublic: self.isPublic)) { comments in
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
                                    .disabled(isButtonDisabled || commentText.isEmpty)
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
                        .overlay(
                            Rectangle()
                                .fill(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                                .frame(height: 0.5)
                            , alignment: .top
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: self.isWritingReply ? 72 + 36 : 72)
                    .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                    .padding(.bottom, appCoordinator.safeAreaInsetsBottom)
                    .offset(y: self.keyboardResponder.isKeyboardHiddenButtonShown ? -self.keyboardResponder.keyboardHeight + appCoordinator.safeAreaInsetsBottom : 0)
                    
                } // VStack
                .onAppear {
                    mumory.commentCount = 0
                    self.comments = []
                    self.replies = []
                    
                    Task {
                        self.mumory = await mumoryDataViewModel.fetchMumory(documentID: mumoryDataViewModel.selectedMumoryAnnotation.id)
                        
                        let commentAndReply = await MumoryDataViewModel.fetchComment(mumoryId: self.mumory.id) ?? []
                        for i in commentAndReply {
                            if i.parentId == "" {
                                self.comments.append(i)
                            } else {
                                self.replies.append(i)
                            }
                            self.comments.sort { $0.date < $1.date }
                            self.replies.sort { $0.date < $1.date }
                        }
                        
                        mumory.commentCount = await MumoryDataViewModel.fetchCommentCount(mumoryId: mumory.id)
//                        mumory.commentCount = comments.count
                    }
                }
                .onDisappear {
                    self.commentText = ""
                    self.isWritingReply = false
                    self.selectedComment = Comment()
                }
                .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                .cornerRadius(23, corners: [.topLeft, .topRight])
                .padding(.top, UIScreen.main.bounds.height * 0.16)
                .offset(y: self.offsetY + self.dragState.translation.height)
                .gesture(dragGesture)
                .transition(.move(edge: .bottom))
                .zIndex(1)
                .popup(show: $appCoordinator.isDeleteCommentPopUpViewShown) {
                    PopUpView(isShown: $appCoordinator.isDeleteCommentPopUpViewShown, type: .twoButton, title: "나의 댓글을 삭제하시겠습니까?", buttonTitle: "댓글 삭제", buttonAction: {
                        mumoryDataViewModel.isUpdating = true
                        
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
                                
                                mumory.commentCount = await MumoryDataViewModel.fetchCommentCount(mumoryId: mumory.id)
                                
                                mumoryDataViewModel.updateMumory(mumory) {
                                    mumoryDataViewModel.isUpdating = false
                                    appCoordinator.isDeleteCommentPopUpViewShown = false
                                }
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
        
        withAnimation(.spring(response: 0.1)) {
            self.offsetY = CGFloat(offset)
        }
        
        if cardDismiss {
            playerViewModel.setPlayerVisibilityWithoutAnimation(isShown: true)
            withAnimation(.spring(response: 0.1)) {
                self.offsetY = .zero
                self.isSheetShown = false
            }
        }
    }
}
