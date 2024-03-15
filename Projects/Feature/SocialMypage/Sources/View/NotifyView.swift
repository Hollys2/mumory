//
//  NotifyView.swift
//  Feature
//
//  Created by 제이콥 on 3/10/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct NotifyView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
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
                }
                .frame(height: 63)
                .padding(.horizontal, 20)

                
                UnreadText(unreadCount: notifications.filter{!$0.isRead}.count)
                    .padding(.top, 18)
       
                
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
                            
                            Divider()
                                .frame(maxWidth: .infinity)
                                .frame(height: 0.5)
                                .background(ColorSet.subGray)
                        }
               
                    })
                }

            
            })
            .padding(.top, currentUserData.topInset)
        }
        .onAppear{
            Task{
                await getNotification()
            }
        }
    }
    
    private func getNotification() async {
        let query = db.collection("User").document(currentUserData.uid).collection("Notification")
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

struct ContentView_Previews: PreviewProvider {
static var previews: some View {
    NotifyView()
}
}

struct UnreadText: View {
    let unreadCount: Int
    init(unreadCount: Int) {
        self.unreadCount = unreadCount
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 0, content: {
            HStack(alignment: .bottom, spacing: 0){
                Text("\(unreadCount)")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(Color.white)

                Text("개의 알림을 읽지 않았습니다.")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 13))
                    .foregroundStyle(Color(white: 0.52))

            }
            .padding(.leading, 20)
            .padding(.bottom, 20)
        
        Divider()
            .frame(maxWidth: .infinity)
            .frame(height: 0.5)
            .background(ColorSet.A6Gray.opacity(0.7))
            

            
            
        })
 
    }
}

struct NotifyLikeItem: View {
    @EnvironmentObject var currentUserData: CurrentUserData
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
                    SharedAsset.notifyLike.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
            
            AsyncImage(url: notification.artworkURL) { image in
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
                Text("\(notification.friendNickname)님이 \(currentUserData.user.nickname)님의 뮤모리 핀을 공감합니다.")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                    .foregroundStyle(Color.white)
                    .lineLimit(2)
                
                Text(dateToString(date: notification.date))
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                    .foregroundStyle(Color(white: 0.72))

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
        .onTapGesture {
            if !notification.isRead {
                DispatchQueue.global().async {
                    db.collection("User").document(currentUserData.uid).collection("Notification").document(self.notification.id).updateData(["isRead": true])
                    
                }
                self.notification.isRead = true
            }
            //해당 알림과 관련된 페이지로 넘어가기
  
        }
    }
    

}

struct NotifyCommentItem: View {
    @EnvironmentObject var currentUserData: CurrentUserData
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
                    SharedAsset.notifyComment.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
            
            AsyncImage(url: notification.artworkURL) { image in
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
                    Text("\(notification.friendNickname)님이 \(currentUserData.user.nickname)님의 뮤모리에 댓글을 남겼습니다: “\(notification.content)”")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                        .foregroundStyle(Color.white)
                        .lineLimit(2)
                }else {
                    Text("\(notification.friendNickname)님이 \(currentUserData.user.nickname)님의 댓글에 답글 남겼습니다: “\(notification.content)”")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                        .foregroundStyle(Color.white)
                        .lineLimit(2)
                }
                
                Text(dateToString(date: notification.date))
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                    .foregroundStyle(Color(white: 0.72))

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
        .onTapGesture {
            if !notification.isRead {
                DispatchQueue.global().async {
                    db.collection("User").document(currentUserData.uid).collection("Notification").document(self.notification.id).updateData(["isRead": true])
                }
                self.notification.isRead = true
            }
            //해당 알림과 관련된 페이지로 넘어가기
        }
    }
}

struct NotifyFriendItem: View {
    @EnvironmentObject var currentUserData: CurrentUserData
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
                    Text("\(notification.friendNickname)님이 \(currentUserData.user.nickname)님에게 친구요청을 보냈습니다.")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                        .foregroundStyle(Color.white)
                        .lineLimit(2)
                }else {
                    Text("\(notification.friendNickname)님이 \(currentUserData.user.nickname)님의 친구요청을 수락했습니다.")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                        .foregroundStyle(Color.white)
                        .lineLimit(2)
                }
                
                Text(dateToString(date: notification.date))
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                    .foregroundStyle(Color(white: 0.72))

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
            if !notification.isRead {
                DispatchQueue.global().async {
                    db.collection("User").document(currentUserData.uid).collection("Notification").document(self.notification.id).updateData(["isRead": true])
                }
                self.notification.isRead = true
            }
            //해당 알림과 관련된 페이지로 넘어가기
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
    var artworkURL: URL?
    var mumoriId: String = ""
    var content: String = ""
    
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
            guard let artworkURLString = data["artworkURL"] as? String else {return}
            self.artworkURL = URL(string: artworkURLString)
            guard let friendNickname = data["friendNickname"] as? String else {return}
            self.friendNickname = friendNickname
            guard let mumoriId = data["mumoriId"] as? String else {return}
            self.mumoriId = mumoriId
            
        case .comment, .reply:
            guard let artworkURLString = data["artworkURL"] as? String else {return}
            self.artworkURL = URL(string: artworkURLString)
            guard let friendNickname = data["friendNickname"] as? String else {return}
            self.friendNickname = friendNickname
            guard let mumoriId = data["mumoriId"] as? String else {return}
            self.mumoriId = mumoriId
            guard let content = data["content"] as? String else {return}
            self.content = content
            
        case .friendAccept, .friendRequest:
            guard let friendNickname = data["friendNickname"] as? String else {return}
            self.friendNickname = friendNickname
            
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
    formatter.dateFormat = "yyyy년 MM월 dd일 HH:mm"
    return formatter.string(from: date)
}
