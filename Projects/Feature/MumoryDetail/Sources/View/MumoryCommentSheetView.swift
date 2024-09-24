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
    
    @Binding var isWritingReply: Bool
    @Binding var selectedComment: Comment
    
    @State private var commentUser: UserProfile = UserProfile()
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    
    let comment: Comment
    let replies: [Comment]
    let mumory: Mumory
    var isFocused: FocusState<Bool>.Binding
    let deleteCommentAction: () -> Void
    var scrollToComment: () -> Void
    
    var body: some View {
        HStack(alignment: .top,  spacing: 13) {
            if currentUserViewModel.friendViewModel.blockFriends.contains(where: {$0.uId == comment.uId}) ||  self.commentUser.nickname == "탈퇴계정" {
                commentUser.defaultProfileImage
                    .resizable()
                    .frame(width: 28, height: 28)
                    .mask { Circle() }
            } else if mumory.uId != currentUserViewModel.user.uId && !currentUserViewModel.friendViewModel.friends.contains(where: { $0.uId == comment.uId }) && currentUserViewModel.user.uId != comment.uId {
                commentUser.defaultProfileImage
                    .resizable()
                    .frame(width: 28, height: 28)
                    .mask { Circle() }
                    .onTapGesture {
                        appCoordinator.rootPath.append(MumoryPage.friend(friend: self.commentUser))
                    }
            } else if mumory.uId != currentUserViewModel.user.uId && currentUserViewModel.user.uId != comment.uId && !comment.isPublic {
                commentUser.defaultProfileImage
                    .resizable()
                    .frame(width: 28, height: 28)
                    .mask { Circle() }
                    .onTapGesture {
                        appCoordinator.rootPath.append(MumoryPage.friend(friend: self.commentUser))
                    }
            } else if mumory.uId == currentUserViewModel.user.uId && !currentUserViewModel.friendViewModel.friends.contains(where: { $0.uId == comment.uId }) && comment.uId != currentUserViewModel.user.uId {
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
                        currentUserViewModel.user.defaultProfileImage
                            .resizable()
                    }
                }
                .scaledToFill()
                .frame(width: 28, height: 28)
                .mask { Circle() }
                .onTapGesture {
                    if commentUser.uId == currentUserViewModel.user.uId {
                        appCoordinator.rootPath.append(MumoryPage.myPage)
                    } else {
                        appCoordinator.rootPath.append(MumoryPage.friend(friend: self.commentUser))
                    }
                }
            }
            
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    HStack(spacing: 5) {
                        if currentUserViewModel.friendViewModel.blockFriends.contains(where: {$0.uId == comment.uId}) {
                            EmptyView()
                        } else if mumory.uId != currentUserViewModel.user.uId && !currentUserViewModel.friendViewModel.friends.contains(where: { $0.uId == comment.uId }) && comment.isPublic && currentUserViewModel.user.uId != comment.uId && self.commentUser.nickname != "탈퇴계정" {
                            Text(StringManager.maskString(self.commentUser.nickname))
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            Text("・")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                                .frame(width: 4, alignment: .bottom)
                        } else if mumory.uId != currentUserViewModel.user.uId && !comment.isPublic && currentUserViewModel.user.uId != comment.uId && self.commentUser.nickname != "탈퇴계정" {
                            EmptyView()
                        } else if mumory.uId == currentUserViewModel.user.uId && !currentUserViewModel.friendViewModel.friends.contains(where: { $0.uId == comment.uId }) && comment.uId != currentUserViewModel.user.uId {
                            Text(StringManager.maskString(self.commentUser.nickname))
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            Text("・")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                                .frame(width: 4, alignment: .bottom)
                            
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
                        
                        if !currentUserViewModel.friendViewModel.blockFriends.contains(where: {$0.uId == comment.uId}) {
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
                            self.appCoordinator.selectedComment = self.comment
                            self.appCoordinator.sheet = .commentMenu(mumory: self.mumory, isOwn: self.appCoordinator.selectedComment.uId == self.currentUserViewModel.user.uId, action: self.deleteCommentAction)
                        }, label: {
                            SharedAsset.commentMenuMumoryDetail.swiftUIImage
                                .resizable()
                                .frame(width: 18, height: 18)
                        })
                        .disabled(currentUserViewModel.friendViewModel.blockFriends.contains(where: {$0.uId == comment.uId}))
                        
                    } // HStack
                    .padding(.vertical, !currentUserViewModel.friendViewModel.blockFriends.contains(where: {$0.uId == comment.uId}) ? 9 : 14)
                    
                    if !currentUserViewModel.friendViewModel.blockFriends.contains(where: {$0.uId == comment.uId}) {
                        Text(mumory.uId != currentUserViewModel.user.uId && !comment.isPublic && comment.uId != currentUserViewModel.user.uId ? "비밀 댓글입니다." : comment.content)
                            .font(mumory.uId != currentUserViewModel.user.uId && !comment.isPublic && comment.uId != currentUserViewModel.user.uId ? SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14) : SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                            .foregroundColor(mumory.uId != currentUserViewModel.user.uId && !comment.isPublic && comment.uId != currentUserViewModel.user.uId ? Color(red: 0.64, green: 0.51, blue: 0.99) : .white)
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
                
                if !currentUserViewModel.friendViewModel.blockFriends.contains(where: {$0.uId == comment.uId}) {
                    Button(action: {
                        withAnimation {
                            scrollToComment()
                        }
                        isFocused.wrappedValue = true
                        selectedComment = comment
                        isWritingReply = true
                        
                    }, label: {
                        Text("답글 달기")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                    })
                    .disabled(mumory.uId != currentUserViewModel.user.uId && !comment.isPublic && comment.uId != currentUserViewModel.user.uId)
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
            if self.comment.uId != self.currentUserViewModel.user.uId {
                Task {
                    self.commentUser = await FetchManager.shared.fetchUser(uId: comment.uId)
                }
            } else {
                self.commentUser = self.currentUserViewModel.user
            }
        }
        
        // MARK: Reply
        ForEach(self.replies, id: \.self) { reply in
            if reply.parentId == comment.id {
                ReplyView(comment: reply, mumory: self.mumory, deleteCommentAction: self.deleteCommentAction)
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

struct ReplyView: View {
    
    let comment: Comment
    let mumory: Mumory
    let deleteCommentAction: () -> Void
    
    @State private var commentUser: UserProfile = UserProfile()
    @State private var isMyComment: Bool = false
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            if currentUserViewModel.friendViewModel.blockFriends.contains(where: {$0.uId == comment.uId}) {
                commentUser.defaultProfileImage
                    .resizable()
                    .frame(width: 28, height: 28)
                    .mask { Circle() }
            } else if mumory.uId != currentUserViewModel.user.uId && !currentUserViewModel.friendViewModel.friends.contains(where: { $0.uId == comment.uId }) && currentUserViewModel.user.uId != comment.uId {
                commentUser.defaultProfileImage
                    .resizable()
                    .frame(width: 28, height: 28)
                    .mask { Circle() }
                    .onTapGesture {
                        appCoordinator.rootPath.append(MumoryPage.friend(friend: self.commentUser))
                    }
            } else if mumory.uId != currentUserViewModel.user.uId && currentUserViewModel.user.uId != comment.uId && !comment.isPublic && !self.isMyComment {
                commentUser.defaultProfileImage
                    .resizable()
                    .frame(width: 28, height: 28)
                    .mask { Circle() }
                    .onTapGesture {
                        appCoordinator.rootPath.append(MumoryPage.friend(friend: self.commentUser))
                    }
            } else if mumory.uId == currentUserViewModel.user.uId && !currentUserViewModel.friendViewModel.friends.contains(where: { $0.uId == comment.uId }) && comment.uId != currentUserViewModel.user.uId {
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
                        currentUserViewModel.user.defaultProfileImage
                            .resizable()
                    }
                }
                .scaledToFill()
                .frame(width: 28, height: 28)
                .mask { Circle() }
                .onTapGesture {
                    if commentUser.uId == currentUserViewModel.user.uId {
                        appCoordinator.rootPath.append(MumoryPage.myPage)
                    } else {
                        appCoordinator.rootPath.append(MumoryPage.friend(friend: self.commentUser))
                    }
                }
            }
            
            VStack(spacing: 0) {
                
                HStack(spacing: 5) {
                    if currentUserViewModel.friendViewModel.blockFriends.contains(where: {$0.uId == comment.uId}) {
                        EmptyView()
                    } else if mumory.uId != currentUserViewModel.user.uId && !currentUserViewModel.friendViewModel.friends.contains(where: { $0.uId == comment.uId }) && comment.isPublic && currentUserViewModel.user.uId != comment.uId && self.commentUser.nickname != "탈퇴계정" {
                        Text(StringManager.maskString(self.commentUser.nickname))
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text("・")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                            .frame(width: 4, alignment: .bottom)
                    } else if mumory.uId != currentUserViewModel.user.uId && !currentUserViewModel.friendViewModel.friends.contains(where: { $0.uId == comment.uId }) && !comment.isPublic && currentUserViewModel.user.uId != comment.uId &&  self.isMyComment && self.commentUser.nickname != "탈퇴계정" {
                        Text(StringManager.maskString(self.commentUser.nickname))
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text("・")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                            .frame(width: 4, alignment: .bottom)
                    } else if mumory.uId == currentUserViewModel.user.uId && !currentUserViewModel.friendViewModel.friends.contains(where: { $0.uId == comment.uId }) && comment.uId != currentUserViewModel.user.uId {
                        Text(StringManager.maskString(self.commentUser.nickname))
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text("・")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                            .frame(width: 4, alignment: .bottom)
                    } else if mumory.uId != currentUserViewModel.user.uId && !comment.isPublic && currentUserViewModel.user.uId != comment.uId && !self.isMyComment && self.commentUser.nickname != "탈퇴계정" {
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
                    
                    if !currentUserViewModel.friendViewModel.blockFriends.contains(where: {$0.uId == comment.uId}) {
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
                        self.appCoordinator.selectedComment = self.comment
                        self.appCoordinator.sheet = .commentMenu(mumory: self.mumory, isOwn: self.appCoordinator.selectedComment.uId == self.currentUserViewModel.user.uId, action: self.deleteCommentAction)
                    }, label: {
                        SharedAsset.commentMenuMumoryDetail.swiftUIImage
                            .resizable()
                            .frame(width: 18, height: 18)
                    })
                } // HStack
                .padding(.vertical, !currentUserViewModel.friendViewModel.blockFriends.contains(where: {$0.uId == comment.uId}) ? 9 : 14)
                
                if !currentUserViewModel.friendViewModel.blockFriends.contains(where: {$0.uId == comment.uId}) {
                    Text(mumory.uId != currentUserViewModel.user.uId && !comment.isPublic && comment.uId != currentUserViewModel.user.uId && !self.isMyComment ? "비밀 답글입니다." : comment.content)
                        .font(mumory.uId != currentUserViewModel.user.uId && !comment.isPublic && comment.uId != currentUserViewModel.user.uId && !self.isMyComment ? SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14) : SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundColor(mumory.uId != currentUserViewModel.user.uId && !comment.isPublic && comment.uId != currentUserViewModel.user.uId && !self.isMyComment ? Color(red: 0.64, green: 0.51, blue: 0.99) : .white)
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
            if self.comment.uId != self.currentUserViewModel.user.uId {
                Task {
                    self.commentUser = await FetchManager.shared.fetchUser(uId: comment.uId)
                }
            } else {
                self.commentUser = self.currentUserViewModel.user
            }

            Task {
                self.isMyComment = await currentUserViewModel.mumoryViewModel.checkIsMyComment(mumoryId: mumory.id ?? "", reply: comment, currentUser: currentUserViewModel.user)
            }
        }
    }
}

public struct MumoryCommentSheetView: View {
    
    @State private var mumory: Mumory = .init()
    @State private var comments: [Comment] = []
    @State private var replies: [Comment] = []
    @State private var selectedCommentUser: UserProfile = UserProfile()
    @State private var commentText: String = ""
    @State private var isWritingReply: Bool = false
    @State private var selectedIndex: Int = -1
    @State private var selectedComment: Comment = Comment()
    @State private var isButtonDisabled: Bool = false
    @State private var isPublic: Bool = false
    @State private var commentYOffset: CGFloat = .zero
    @State private var isPopUpShown: Bool = true
    
    @FocusState private var isTextFieldFocused: Bool
    
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject private var keyboardResponder: KeyboardResponder
    @EnvironmentObject private var playerViewModel: PlayerViewModel
    
    let mumoryId: String
    
    public init(mumoryId: String) {
        self.mumoryId = mumoryId
        UIRefreshControl.appearance().tintColor = UIColor(white: 0.47, alpha: 1)
    }
    
    public var body: some View {
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
                        self.appCoordinator.isCommentSheetShown = (false, nil)
                    }, label: {
                        SharedAsset.commentCloseButtonMumoryDetail.swiftUIImage
                            .resizable()
                            .frame(width: 25, height: 25)
                    })
                } // HStack
                .frame(width: UIScreen.main.bounds.width - 40, height: 72)
            } // ZStack
            .frame(height: 72)
            
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    ZStack(alignment: .top) {
                        Color.clear
                        
                        if self.comments.isEmpty {
                            if !self.appCoordinator.isRefreshing && !self.appCoordinator.isLoading {
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
                        }
                        
                        VStack(spacing: 0) {
                            ForEach(Array(self.comments.enumerated()), id: \.element) { index, comment in
                                CommentView(isWritingReply: self.$isWritingReply, selectedComment: self.$selectedComment, comment: comment, replies: self.replies, mumory: self.mumory, isFocused: self.$isTextFieldFocused, deleteCommentAction: self.deleteCommentAction) {
                                    withAnimation {
                                        proxy.scrollTo(index, anchor: .top)
                                    }
                                }
                                .id(index)
                            }
                            
                            Spacer(minLength: 0)
                        }
                        .frame(minHeight: keyboardResponder.keyboardHeight == .zero ? getUIScreenBounds().height - 72 - getSafeAreaInsets().bottom - 72 - (UIScreen.main.bounds.height * 0.16) : getUIScreenBounds().height * 10)
                    }
                }
                .refreshable {
                    self.appCoordinator.isRefreshing = true
                    self.commentText = ""
                    self.isWritingReply = false
                    self.selectedComment = Comment()
                    self.comments = []
                    self.replies = []
                    
                    Task {
                        self.mumory = try await FetchManager.shared.fetchMumory(documentID: self.mumory.id)
                    }
                    
                    Task {
                        let commentAndReply = try await FetchManager.shared.fetchCommentAndReply(DocumentID: self.mumory.id)
                        for i in commentAndReply {
                            if i.parentId.isEmpty {
                                self.comments.append(i)
                            } else {
                                self.replies.append(i)
                            }
                        }
                        self.appCoordinator.isRefreshing = false
                    }
                }
                .onAppear {
                    UIScrollView.appearance().bounces = true
                }
            }
            
            BottomBar
                .padding(.bottom, keyboardResponder.keyboardHeight == .zero ? .zero : keyboardResponder.keyboardHeight - self.getSafeAreaInsets().bottom)
                .animation(Animation.easeInOut(duration: 0.2), value: keyboardResponder.keyboardHeight)
        } // VStack
        .background(ColorSet.darkGray)
        .onAppear {
            self.mumory.id = self.mumoryId
            
            self.appCoordinator.isLoading = true
            
            Task {
                await withTaskGroup(of: Void.self) { group in
                    group.addTask { @MainActor in
                        do {
                            self.mumory = try await FetchManager.shared.fetchMumory(documentID: self.mumoryId)
                        } catch {
                            print("ERROR fetchMumory: \(error)")
                        }
                    }
                    
                    group.addTask { @MainActor in
                        do {
                            let commentAndReply = try await FetchManager.shared.fetchCommentAndReply(DocumentID: self.mumoryId)
                            for i in commentAndReply {
                                if i.parentId.isEmpty {
                                    self.comments.append(i)
                                } else {
                                    self.replies.append(i)
                                }
                                self.comments.sort { $0.date < $1.date }
                                self.replies.sort { $0.date < $1.date }
                            }
                        } catch {
                            print("ERROR fetchComment: \(error)")
                        }
                    }
                    
                    await group.waitForAll()
                    
                    self.appCoordinator.isLoading = false
                }
            }
        }
        .onDisappear {
            print("FUCK MumoryCommentSheetView onDisappear")
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    var BottomBar: some View {
        VStack(spacing: 0) {
            if self.isWritingReply {
                HStack(spacing: 5) {
                    Text(selectedComment.uId != currentUserViewModel.user.uId && !currentUserViewModel.friendViewModel.friends.contains(where: { $0.uId == selectedComment.uId }) ? StringManager.maskString(self.selectedCommentUser.nickname) : "\(self.selectedCommentUser.nickname)")
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
                        self.selectedCommentUser = await FetchManager.shared.fetchUser(uId: self.selectedComment.uId)
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
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
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

                            if !isWhitespace {
                                self.appCoordinator.isLoading = true
                                self.isButtonDisabled = true
                                
                                let comment: Comment = Comment(uId: self.currentUserViewModel.user.uId, nickname: self.currentUserViewModel.user.nickname, parentId: self.isWritingReply ? self.selectedComment.id ?? "" : "", mumoryId: self.mumory.id ?? "", date: Date(), content: self.commentText, isPublic: self.isPublic)
                                
                                self.currentUserViewModel.mumoryViewModel.createComment(documentId: self.mumory.id, comment: comment) { result in
                                    switch result {
                                    case .success(_):
                                        print("SUCCESS createComment")
                                        
                                        Task {
                                            if let comments = try? await FetchManager.shared.fetchCommentAndReply(DocumentID: mumory.id) {
                                                var tempComments: [Comment] = []
                                                var tempReplies: [Comment] = []
                                                for comment in comments {
                                                    if comment.parentId.isEmpty {
                                                        tempComments.append(comment)
                                                    } else {
                                                        tempReplies.append(comment)
                                                    }
                                                }
                                                self.comments = tempComments
                                                self.replies = tempReplies
                                                self.mumory.commentCount = comments.count
                                            }
                                        }
                                    case .failure(let error):
                                        print("ERROR createComment: \(error)")
                                    }
                                    
                                    commentText = ""
                                    isButtonDisabled = false
                                    self.appCoordinator.isLoading = false
                                }
                            }
                            
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
                Group {
                    SharedAsset.commentInitialPopup.swiftUIImage
                        .resizable()
                        .frame(width: 246, height: 42)
                        .offset(x: 10, y: -49)
                        .opacity(UserDefaults.standard.value(forKey: "commentPopUp2") == nil ? 1 : 0)
                        .onTapGesture {
                            self.isPopUpShown = false
                            UserDefaults.standard.set(Date(), forKey: "commentPopUp2")
                        }
                }
                    .opacity(self.isPopUpShown ? 1: 0)
                , alignment: .topLeading
            )
            .overlay(
                Rectangle()
                    .fill(Color(red: 0.651, green: 0.651, blue: 0.651, opacity: 0.698))
                    .frame(height: 1)
                , alignment: .top
            )
        }
        .frame(height: self.isWritingReply ? 72 + 36 : 72)
        .background(Color(red: 0.09, green: 0.09, blue: 0.09))
    }
    
    func deleteCommentAction() {
        self.appCoordinator.isLoading = true
        
        self.currentUserViewModel.mumoryViewModel.deleteComment(comment: self.appCoordinator.selectedComment) { result in
            switch result {
            case .success(let comments):
                self.comments = []
                self.replies = []
                for comment in comments {
                    if comment.parentId == "" {
                        self.comments.append(comment)
                    } else {
                        self.replies.append(comment)
                    }
                }
                
                Task {
                    mumory.commentCount = await MumoryViewModel.fetchCommentCount(mumoryId: self.mumoryId)
                    
                    self.currentUserViewModel.mumoryViewModel.updateMumory(mumoryId: self.mumoryId, mumory: self.mumory) { result in
                        switch result {
                        case .success():
                            print("SUCCESS updateMumory")
                        case .failure(let error):
                            print("ERROR updateMumory: \(error.localizedDescription)")
                        }
                    }
                }
            case .failure(let error):
                print("ERROR deleteComment: \(error)")
            }
            
            self.appCoordinator.popUp = .none
            self.appCoordinator.isLoading = false
        }
    }
}

public struct CommentSheetUIViewRepresentable: UIViewRepresentable {
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    
    let mumoryId: String
    
    public init(mumoryId: String) {
        self.mumoryId = mumoryId
    }
    
    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let dimmingView = UIView(frame: UIScreen.main.bounds)
        dimmingView.backgroundColor = UIColor.black
        dimmingView.alpha = 0
        view.addSubview(dimmingView)
        
        let newView = UIView()
        newView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.84)
        newView.backgroundColor = UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1)
        
        let corners: UIRectCorner = [.topLeft, .topRight]
        let maskPath = UIBezierPath(roundedRect: newView.bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: 23.0, height: 23.0))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        newView.layer.mask = maskLayer
        
        let hostingController = UIHostingController(rootView: MumoryCommentSheetView(mumoryId: self.mumoryId))
        hostingController.view.frame = newView.bounds
        hostingController.view.backgroundColor = .clear
        newView.addSubview(hostingController.view)

        view.addSubview(newView)
        
        dimmingView.alpha = 0.5
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut]) {
            newView.frame.origin.y = UIScreen.main.bounds.height * 0.16
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
    
    public func updateUIView(_ uiView: UIView, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    public class Coordinator: NSObject {
        var parent: CommentSheetUIViewRepresentable
        var uiView: UIView?
        var newView: UIView?
        var dimmingView: UIView?
        
        init(parent: CommentSheetUIViewRepresentable) {
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
                    
                    newView.frame.origin.y = newY + UIScreen.main.bounds.height * 0.16
                }
                
            case .ended, .cancelled:
                if translation.y > Double(30) {
                    UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseInOut], animations: {
                        newView.frame.origin.y = UIScreen.main.bounds.height
                        dimmingView.alpha = 0
                    }) { value in
                        newView.removeFromSuperview()
                        dimmingView.removeFromSuperview()
                        self.parent.appCoordinator.isCommentSheetShown = (false, nil)
                        
                    }
                } else {
                    UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseInOut]) {
                        newView.frame.origin.y = UIScreen.main.bounds.height * 0.16
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
                self.parent.appCoordinator.isCommentSheetShown = (false, nil)
            }
        }
    }
}
