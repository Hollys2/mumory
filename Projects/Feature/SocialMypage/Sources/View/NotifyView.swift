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
    
    @State var notifications: [Notification] = []
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
                                appCoordinator.rootPath.append(MyPage.notification)
                            }
                    }
                    .frame(height: 63)
                    .padding(.horizontal, 20)
                    
                    HStack{
                        UnreadText(notifications: $notifications)
                        Spacer()
                        ReadAllButton(notifications: $notifications)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 20)
                    
                    Divider05()
                    
                    ScrollView {
                        LazyVStack(spacing: 0, content: {
                            ForEach(notifications.indices, id: \.self) { index in
                                switch(notifications[index].type) {
                                case .like:
                                    NotifyLikeItem(notification: $notifications[index])
                                case .comment, .reply:
                                    NotifyCommentItem(notification: $notifications[index])
                                case .friendAccept, .friendRequest:
                                    NotifyFriendItem(notification: $notifications[index])
                                case .none:
                                    EmptyView()
                                }
                                
                            }
                        })
                    }
                    .refreshable {
                        await getNotification()
                    }
                    
                    
                })
                .padding(.top, currentUserData.topInset)
            }
            .onAppear{
                Task{
                    await getNotification()
                }
                AnalyticsManager.shared.setScreenLog(screenTitle: "NotifyView")
                UIRefreshControl.appearance().tintColor = UIColor(white: 0.47, alpha: 1)
            }
    }
    
    private func getNotification() async {
        self.notifications.removeAll()
        let query = db.collection("User").document(currentUserData.uId).collection("Notification")
            .order(by: "date", descending: true)
        
        //페이징기능 만들기
        //페이징기능때문에 안 본 알림이 몇개인지 알 수 있기는 한가..? 고민해보기
        
        guard let result = try? await query.getDocuments() else {
            print("no data")
            return
        }
        
        result.documents.forEach { snapshot in
            self.notifications.append(Notification(id: snapshot.documentID, data: snapshot.data()))
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
    @Binding var notification: Notification
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


            SharedAsset.menu.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .padding(.leading, 10)
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
                appCoordinator.rootPath.append(MumoryView(type: .mumoryDetailView, mumoryAnnotation: mumory))
            }
            if !notification.isRead {
                DispatchQueue.global().async {
                    db.collection("User").document(currentUserData.uId).collection("Notification").document(self.notification.id).updateData(["isRead": true])
                    
                }
                self.notification.isRead = true
            }
            //해당 알림과 관련된 페이지로 넘어가기
  
        }
    }
    

}

struct NotifyCommentItem: View {
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserData: CurrentUserData
    @Binding var notification: Notification
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


            SharedAsset.menu.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .padding(.leading, 10)
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
                print(mumory.imageURLs)
                appCoordinator.rootPath.append(MumoryView(type: .mumoryDetailView, mumoryAnnotation: mumory))
            }
            if !notification.isRead {
                DispatchQueue.global().async {
                    db.collection("User").document(currentUserData.uId).collection("Notification").document(self.notification.id).updateData(["isRead": true])
                }
                self.notification.isRead = true
            }
            //해당 알림과 관련된 페이지로 넘어가기
        }
    }
}

struct NotifyFriendItem: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var appCoordinator: AppCoordinator
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


            SharedAsset.menu.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .padding(.leading, 10)
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

//struct NotifyItem: View {
//    let notification: Notification
//    init(notification: Notification) {
//        self.notification = notification
//    }
//    
//    var body: some View {
//        switch(notification.type) {
//        case .like:
//            NotifyLikeItem(notification: self.notification)
//        case .comment, .reply:
//            NotifyCommentItem(notification: self.notification)
//        case .friendAccept, .friendRequest:
//            NotifyFriendItem(notification: self.notification)
//        case .none:
//            EmptyView()
//        }
//    }
//}

private func dateToString(date: Date) -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy년 M월 d일 HH:mm"
    return formatter.string(from: date)
}

public func fetchSong(songID: String) async -> Song? {
    let musicItemID = MusicItemID(rawValue: songID)
    var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
    guard let response = try? await request.response() else {
        return nil
    }
    guard let song = response.items.first else {
        return nil
    }
    return song
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
