//
//  NotifyView.swift
//  Feature
//
//  Created by 제이콥 on 3/10/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import MusicKit
import Shared

struct NotifyView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @StateObject var notificationViewModel: NotificationViewModel = NotificationViewModel()
    private let notificationQueue = DispatchQueue(label: "notificationQueue")
    //observableobject를 만들면 너무 불필요한 게 되는데....음음음음음음
    //binding으로 2단계 아래로 넘기자니 오히려 더 지저분함
    let db = FBManager.shared.db


    var body: some View {
            ZStack(alignment: .top) {
                ColorSet.background.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0, content: {
                    //상단바
                    HStack{
                        Text("알림")
                            .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 24))
                            .foregroundStyle(Color.white)
                    
                        Spacer()
                        
                        SharedAsset.set.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                appCoordinator.rootPath.append(MyPage.notification(iconHidden: true))
                            }
                    }
                    .frame(height: 63)
                    .padding(.horizontal, 20)
                    
                    HStack{
                        UnreadText(notifications: $notificationViewModel.notifications)
                        Spacer()
                        ReadAllButton(notifications: $notificationViewModel.notifications)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 20)
                    
                    if notificationViewModel.notifications.isEmpty {
                        Text("최근 알림이 없습니다.")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(ColorSet.subGray)
                            .padding(.top, getUIScreenBounds().height * 0.25)
                    } else {
                        
                        ScrollView {
                            LazyVStack(spacing: 0, content: {
                                ForEach(notificationViewModel.notifications.indices, id: \.self) { index in
                                    switch(notificationViewModel.notifications[index].type) {
                                    case .like:
                                        NotifyLikeItem(notification: $notificationViewModel.notifications[index])
                                            .environmentObject(notificationViewModel)
                                    case .comment, .reply:
                                        NotifyCommentItem(notification: $notificationViewModel.notifications[index])
                                            .environmentObject(notificationViewModel)
                                    case .friendAccept, .friendRequest:
                                        NotifyFriendItem(notification: $notificationViewModel.notifications[index])
                                            .environmentObject(notificationViewModel)
                                    case .none:
                                        EmptyView()
                                    }
                                    
                                }
                            })
                            
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 90)
                        }
                        .refreshable {
                            await getNotification()
                        }
                        .scrollIndicators(.hidden)
                    }
                
                })
                .padding(.top, currentUserData.topInset)
            }
            .onAppear{
                playerViewModel.setPlayerVisibilityWithoutAnimation(isShown: true, moveToBottom: false)
                playerViewModel.isShownMiniPlayerInLibrary = false
                Task{
                    await getNotification()
                }
                AnalyticsManager.shared.setScreenLog(screenTitle: "NotifyView")
                UIRefreshControl.appearance().tintColor = UIColor(white: 0.47, alpha: 1)
            }
    }
    
    private func getNotification() {
        Task {
            do {
                let result = try await db.collection("User").document(currentUserData.uId).collection("Notification")
                    .order(by: "date", descending: true)
                    .getDocuments()
                
                DispatchQueue.main.async {
                    CATransaction.begin()
                    notificationViewModel.notifications.removeAll()
                    result.documents.forEach { snapshot in
                        notificationViewModel.notifications.append(Notification(id: snapshot.documentID, data: snapshot.data()))
                    }
                    CATransaction.setCompletionBlock {
                        print("알림받기 끝")
                    }
                    CATransaction.commit()
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }

}

//struct ContentView_Previews: PreviewProvider {
//static var previews: some View {
//    NotifyView()
//}
//}

struct UnreadText: View {
    @Binding var notifications: [Notification]
    init(notifications: Binding<[Notification]>) {
        self._notifications = notifications
    }
    
    var body: some View {
            HStack(alignment: .bottom, spacing: 0){
                Text("\(notifications.filter({!$0.isRead}).count)")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(Color.white)

                Text("개의 알림을 읽지 않았습니다.")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 14))
                    .foregroundStyle(Color(white: 0.52))
            }
    }
}

struct NotifyLikeItem: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @Binding var notification: Notification
    @State var isPresentDeleteMumoryPopup: Bool = false
    init(notification: Binding<Notification>) {
        self._notification = notification

    }
    let db = FBManager.shared.db
    @State var song: Song?
    
    var body: some View {
        HStack(spacing: 0, content: {
            Circle()
                .fill(ColorSet.Gray34)
                .frame(width: 38, height: 38)
                .overlay {
                    SharedAsset.notifyLike.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
            
            AsyncImage(url: self.song?.artwork?.url(width: 300, height: 300)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
            }
            .frame(width: 57, height: 57)
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
            .padding(.leading, 12)
            
            VStack(alignment: .leading, spacing: 7, content: {
                Text("\(notification.friendNickname)님이 회원님의 뮤모리 핀을 공감합니다.")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(Color.white)
                    .lineLimit(2)
                
                Text(dateToString(date: notification.date))
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 13))
                    .foregroundStyle(ColorSet.subGray)

            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 57)
            .padding(.leading, 15)


            NotifyMenuBotton(notification: self.notification)
                .environmentObject(notificationViewModel)

        })
        .padding(.horizontal, 15)
        .frame(height: 90)
        .frame(maxWidth: .infinity)
        .background(notification.isRead ? ColorSet.background : ColorSet.moreDeepGray)
        .onAppear{
            if song == nil {
                Task {
                    self.song = await fetchSong(songID: notification.songId)
                }
            }
        }
        .onTapGesture {
            Task{
                let mumory = await mumoryDataViewModel.fetchMumory(documentID: notification.mumoriId)
                if mumory.id == "DELETE" {
                    UIView.setAnimationsEnabled(false)
                    isPresentDeleteMumoryPopup.toggle()
                }else {
                    appCoordinator.rootPath.append(MumoryView(type: .mumoryDetailView, mumoryAnnotation: mumory))
                }
            }
            if !notification.isRead {
                DispatchQueue.global().async {
                    db.collection("User").document(currentUserData.uId).collection("Notification").document(self.notification.id).updateData(["isRead": true])
                    
                }
                self.notification.isRead = true
            }
        }
        .fullScreenCover(isPresented: $isPresentDeleteMumoryPopup, content: {
            OneButtonOnlyConfirmPopupView(title: "삭제된 게시물입니다")
                .background(TransparentBackground())
        })
    }
    

}

struct NotifyCommentItem: View {
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @Binding var notification: Notification
    @State var isPresentDeleteMumoryPopup: Bool = false
    init(notification: Binding<Notification>) {
        self._notification = notification
    }
    let db = FBManager.shared.db
    @State var song: Song?

    var body: some View {
        HStack(spacing: 0, content: {
            Circle()
                .fill(ColorSet.Gray34)
                .frame(width: 38, height: 38)
                .overlay {
                    SharedAsset.notifyComment.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
            
            AsyncImage(url: self.song?.artwork?.url(width: 300, height: 300)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
            }
            .frame(width: 57, height: 57)
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
            .padding(.leading, 12)
            
            VStack(alignment: .leading, spacing: 7, content: {
                if notification.type == .comment {
                    Text("\(notification.friendNickname)님이 회원님의 뮤모리에 댓글을 남겼습니다: “\(notification.content)”")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundStyle(Color.white)
                        .lineLimit(2)
                }else {
                    Text("\(notification.friendNickname)님이 회원님의 댓글에 답글 남겼습니다: “\(notification.content)”")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundStyle(Color.white)
                        .lineLimit(2)
                }
                
                Text(dateToString(date: notification.date))
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 13))
                    .foregroundStyle(ColorSet.subGray)

            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 57)
            .padding(.leading, 15)


            NotifyMenuBotton(notification: self.notification)
                .environmentObject(notificationViewModel)
        })
        .padding(.horizontal, 15)
        .frame(height: 90)
        .background(notification.isRead ? ColorSet.background : ColorSet.moreDeepGray)
        .onAppear{
            if self.song == nil {
                Task {
                    self.song = await fetchSong(songID: notification.songId)
                }
            }
        }
        .onTapGesture {
            Task{
                let mumory = await mumoryDataViewModel.fetchMumory(documentID: notification.mumoriId)
                if mumory.id == "DELETE" {
                    UIView.setAnimationsEnabled(false)
                    isPresentDeleteMumoryPopup.toggle()
                }else {
                    appCoordinator.rootPath.append(MumoryView(type: .mumoryDetailView, mumoryAnnotation: mumory))
                }
            }
            if !notification.isRead {
                DispatchQueue.global().async {
                    db.collection("User").document(currentUserData.uId).collection("Notification").document(self.notification.id).updateData(["isRead": true])
                }
                self.notification.isRead = true
            }
            //해당 알림과 관련된 페이지로 넘어가기
        }
        .fullScreenCover(isPresented: $isPresentDeleteMumoryPopup, content: {
            OneButtonOnlyConfirmPopupView(title: "삭제된 게시물입니다")
                .background(TransparentBackground())
        })
    }
}

struct NotifyFriendItem: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @Binding var notification: Notification
    init(notification: Binding<Notification>) {
        self._notification = notification
    }
    let db = FBManager.shared.db
    
    var body: some View {
        HStack(spacing: 0, content: {
            Circle()
                .fill(ColorSet.Gray34)
                .frame(width: 38, height: 38)
                .overlay {
                    SharedAsset.notifyFriend.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }

            
            VStack(alignment: .leading, spacing: 7, content: {
                if notification.type == .friendRequest {
                    Text("\(notification.friendNickname)님이 회원님에게 친구요청을 보냈습니다.")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundStyle(Color.white)
                        .lineLimit(2)
                }else {
                    Text("\(notification.friendNickname)님이 회원님의 친구요청을 수락했습니다.")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundStyle(Color.white)
                        .lineLimit(2)
                }
                
                Text(dateToString(date: notification.date))
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 13))
                    .foregroundStyle(ColorSet.subGray)

            })
            .padding(.leading, 12)
            .frame(maxWidth: .infinity, alignment: .leading)


            NotifyMenuBotton(notification: self.notification)
                .environmentObject(notificationViewModel)
        })
        .padding(.horizontal, 15)
        .frame(height: 90)
        .background(notification.isRead ? ColorSet.background : ColorSet.moreDeepGray)
        .onTapGesture {
            print("friend")
            Task {
                let friend = await MumoriUser(uId: notification.friendUId)
                appCoordinator.rootPath.append(MumoryPage.friend(friend: friend))
            }
            if !notification.isRead {
                DispatchQueue.global().async {
                    db.collection("User").document(currentUserData.uId).collection("Notification").document(self.notification.id).updateData(["isRead": true])
                }
                self.notification.isRead = true
            }
        }
    }
}

struct NotifyPostItem: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @Binding var notification: Notification
    init(notification: Binding<Notification>) {
        self._notification = notification
    }
    let db = FBManager.shared.db
    
    var body: some View {
        HStack(spacing: 0, content: {
            Circle()
                .fill(ColorSet.Gray34)
                .frame(width: 38, height: 38)
                .overlay {
                    SharedAsset.notifyPost.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
            
            
            VStack(alignment: .leading, spacing: 7, content: {
                
                Text("지금까지 \(10)개의 뮤모리가 기록되었습니다. 매일매일 나만의 장소에서 음악을 기록해 보세요!")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(Color.white)
                    .lineLimit(2)
                
                Text(dateToString(date: notification.date))
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 13))
                    .foregroundStyle(ColorSet.subGray)
                
            })
            .padding(.leading, 12)
            .frame(maxWidth: .infinity, alignment: .leading)


            NotifyMenuBotton(notification: self.notification)
                .environmentObject(notificationViewModel)
        })
        .padding(.horizontal, 15)
        .frame(height: 90)
        .background(notification.isRead ? ColorSet.background : ColorSet.moreDeepGray)
        .onTapGesture {
            
        }
    }
}

enum NotificationType {
    case like
    case comment
    case friendRequest
    case friendAccept
    case reply
    case none
}

struct Notification {
    var id: String
    var type: NotificationType
    var date: Date
    var isRead: Bool
    var friendNickname: String = ""
    var songId: String = ""
    var mumoriId: String = ""
    var content: String = ""
    var friendUId: String = ""
    var mumoryCount: Int = 0
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.date = (data["date"] as? FBManager.TimeStamp)?.dateValue() ?? Date()
        self.isRead = (data["isRead"] as? Bool) ?? false
        
        switch((data["type"] as? String) ?? "") {
        case "like": self.type = .like
        case "comment": self.type = .comment
        case "reply": self.type = .reply
        case "friendRequest": self.type = .friendRequest
        case "friendAccept": self.type = .friendAccept
        default: self.type = .none
        }
        
        switch(self.type){
        case .like:
            guard let songId = data["songId"] as? String else {return}
            self.songId = songId
            guard let friendNickname = data["friendNickname"] as? String else {return}
            self.friendNickname = friendNickname
            guard let mumoriId = data["mumoryId"] as? String else {return}
            self.mumoriId = mumoriId
            
        case .comment, .reply:
            guard let songId = data["songId"] as? String else {return}
            self.songId = songId
            guard let friendNickname = data["friendNickname"] as? String else {return}
            self.friendNickname = friendNickname
            guard let mumoriId = data["mumoryId"] as? String else {return}
            self.mumoriId = mumoriId
            guard let content = data["content"] as? String else {print("error");return}
            self.content = content
            print(content)
        case .friendAccept, .friendRequest:
            guard let friendNickname = data["friendNickname"] as? String else {return}
            guard let friendUId = data["friendUId"] as? String else {return}
            self.friendNickname = friendNickname
            self.friendUId = friendUId
            
        case .none: return

        }
    }
}


private func dateToString(date: Date) -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy년 M월 d일 HH:mm"
    return formatter.string(from: date)
}



struct ReadAllButton: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var snackBarViewModel: SnackBarViewModel
    @Binding var notifications: [Notification]
    init(notifications: Binding<[Notification]>) {
        self._notifications = notifications
    }
    var body: some View {
        Text("모두읽음")
            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
            .foregroundStyle(notifications.filter({!$0.isRead}).count > 0 ? ColorSet.mainPurpleColor : ColorSet.subGray)
            .padding(.horizontal, 12)
            .frame(height: 30)
            .background(ColorSet.darkGray)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .circular))
            .onTapGesture {
                if notifications.filter({!$0.isRead}).count > 0 {
                    let db = FBManager.shared.db
                    let query = db.collection("User").document(currentUserData.uId).collection("Notification")
                        .whereField("isRead", isEqualTo: false)
                    query.getDocuments { snapshot, error in
                        guard let snapshot = snapshot else {return}
                        snapshot.documents.forEach { document in
                            document.reference.updateData(["isRead": true])
                        }
                    }
                    notifications = notifications.map { notification in
                        var updatedNotification = notification
                        updatedNotification.isRead = true
                        return updatedNotification
                    }
                }else {
                    snackBarViewModel.setSnackBar(type: .readAllNotification, status: .failure)
                }
            }
    }
}

struct NotifyMenuBotton: View {
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
    @State var isPresentBottomSheet: Bool = false
    @State var isPresentPopup: Bool = false
    let notification: Notification
    let db = FBManager.shared.db
    init(notification: Notification) {
        self.notification = notification
    }
    var body: some View {
        Button(action: {
            UIView.setAnimationsEnabled(false)
            isPresentBottomSheet.toggle()
        }, label: {
            SharedAsset.menu.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 22, alignment: .trailing)
        })
        .padding(.leading, 10)
        .fullScreenCover(isPresented: $isPresentBottomSheet) {
            BottomSheetDarkGrayWrapper(isPresent: $isPresentBottomSheet) {
                BottomSheetItem(image: SharedAsset.deleteMumoryDetailMenu.swiftUIImage, title: "알림 삭제", type: .warning)
                    .onTapGesture {
                        isPresentBottomSheet = false
                        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { timer in
                            UIView.setAnimationsEnabled(false)
                            isPresentPopup = true
                        }
                    }
            }
            .background(TransparentBackground())
        }
        .fullScreenCover(isPresented: $isPresentPopup) {
            TwoButtonPopupView(title: "해당 알림을 삭제하시겠습니까?", positiveButtonTitle: "확인") {
                let query = db.collection("User").document(currentUserData.uId).collection("Notification").document(notification.id)
                query.delete()
                notificationViewModel.notifications.removeAll(where: {$0.id == self.notification.id})
            }
            .background(TransparentBackground())
        }
    }
}


class NotificationViewModel: ObservableObject {
    @Published var notifications: [Notification] = []
    @Published var isPresentDeletedMumoryPopup: Bool = false
    @Published var isPresentDeleteBottomSheet: Bool = false
}
