//
//  ActivityListView.swift
//  Feature
//
//  Created by 제이콥 on 3/11/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

enum ActivityType {
    case all
    case like
    case comment
    case friend
}
struct Activity: Hashable{
    let type: String
    let songId: String
    let mumoryId: String
    let friendNickname: String
    let myNickname: String
    var content: String = ""
    let activityText: String
    let commentId: String
    
    init(type: String, songId: String, mumoryId: String, friendNickname: String, myNickname: String, content: String, commentId: String) {
        self.type = type
        self.songId = songId
        self.mumoryId = mumoryId
        self.friendNickname = friendNickname
        self.myNickname = myNickname
        self.content = content
        self.commentId = commentId
        
        if type == "like" {
            activityText = "\(myNickname)님이 \(friendNickname)님의 뮤모리 를 공감합니다."
        }else if type == "comment" {
            activityText = "\(myNickname)님이 \(friendNickname)님의 뮤모리에 댓글을 남겼습니다: “\(content)”"
        }else if type == "reply" {
            activityText = "\(myNickname)님이 \(friendNickname)님의 댓글에 답글을 남겼습니다: “\(content)”"
        }else {
            activityText = "USER ACIVITY ISSUE"
        }
    }
}
struct ActivityListView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    
    @State var selection: ActivityType = .all
    @State var date: Date = Date()
    @State var isPresentDatePicker: Bool = false
    @State var activityList: [String: [Activity]] = [:]
    @State var isLoadig: Bool = false
    
    let db = FirebaseManager.shared.db
    
    @State var pagingCursor: FirebaseManager.Document?
    
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0, content: {
                HStack(spacing: 0, content: {
                    SharedAsset.back.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            appCoordinator.rootPath.removeLast()
                        }
                    Spacer()
                    Text("활동 내역")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundStyle(Color.white)
                        
                    Spacer()
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 30, height: 30)
                })
                .padding(.horizontal, 20)
                .frame(height: 65)
                
                HStack(spacing: 6, content: {
                    SelectionButtonView(type: .all, title: "전체", selection: $selection)
                    SelectionButtonView(type: .like, title: "좋아요", selection: $selection)
                    SelectionButtonView(type: .comment, title: "댓글", selection: $selection)
                })
                .padding(.leading, 20)
                .padding(.bottom, 31)
                .onChange(of: selection) { newValue in
                    pagingCursor = nil
                    Task {
                        await getActivity(type: newValue, date: self.date, pagingCorsor: self.$pagingCursor, isLoading: $isLoadig)
                    }
                }
                
                Divider05()
                    
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0, content: {
                            ForEach(activityList.keys.sorted(by: > ), id: \.self) { date in
                                Section {
                                    ForEach((activityList[date]) ?? [] , id: \.self) { activity in
                                        ActivityItem(activity: activity, activityList: $activityList)
                                    }
                                } header: {
                                    Text(date)
                                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                        .foregroundStyle(Color.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 12)
                                        .frame(height: 60)
                                                 
                                    Divider03()
                                }
                            }
                            
                            if isLoadig {
                                ActivitySkeletonView()
                            }else {
                                
                                if activityList.isEmpty {
                                    Text("활동 내역이 없습니다")
                                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                        .foregroundStyle(ColorSet.subGray)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.top, getUIScreenBounds().height * 0.15)
                                }
                            }
                            
                        })
                        .padding(.top, 55)
                    }
                    .refreshable {
                        pagingCursor = nil
                        Task {
                            await getActivity(type: self.selection, date: self.date, pagingCorsor: self.$pagingCursor, isLoading: $isLoadig)
                        }
                    }
                    .scrollIndicators(.hidden)
                    .overlay {
                        
                        VStack(spacing: 0){
                            HStack(spacing: 6){
                                Text(DateText(date: date))
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                                    .foregroundStyle(Color.white)
                                
                                SharedAsset.downArraowCircle.swiftUIImage
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                
                                Spacer()
                            }
                            .padding(.leading, 20)
                            .frame(height: 55)
                            .background(ColorSet.background.opacity(0.9))
                            .background(.ultraThinMaterial)
                            .onTapGesture {
                                UIView.setAnimationsEnabled(false)
                                isPresentDatePicker.toggle()
                            }
                            .onChange(of: date, perform: { value in
                                pagingCursor = nil
                                Task {
                                    await getActivity(type: selection, date: value, pagingCorsor: self.$pagingCursor, isLoading: $isLoadig)
                                }
                            })
                            
                            Divider03()
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                }
            
            })
        }
        .preferredColorScheme(.dark)
        .onAppear{
            let calendar = Calendar.current
            let components: Set<Calendar.Component> = [.year, .month]
            let originDate = calendar.dateComponents(components, from: self.date)
            
            var resetDate = DateComponents()
            resetDate.year = originDate.year
            resetDate.month = originDate.month
            
            self.date = calendar.date(from: resetDate) ?? Date()
        }
        .fullScreenCover(isPresented: $isPresentDatePicker, content: {
            BottomSheetWrapper(isPresent: $isPresentDatePicker) {
                DatePickerView(date: $date)
            }
            .background(TransparentBackground())
        })
    }
    
    private func DateText(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월"
        let calendar = Calendar.current
        let nowYear = calendar.component(.year, from: Date())
        let selectYear = calendar.component(.year, from: date)
        
        if nowYear == selectYear {
            return "\(calendar.component(.month, from: date))월"
        }else {
            return "\(selectYear)년 \(calendar.component(.month, from: date))월"
        }
    }
    
    private func DateHeaderText(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: date)
    }
    
    private func getActivity(type: ActivityType, date: Date, pagingCorsor: Binding<FirebaseManager.Document?>, isLoading: Binding<Bool>) async {
        isLoading.wrappedValue = true
        if pagingCorsor.wrappedValue == nil {
            activityList.removeAll()
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        guard let targetDate = Calendar.current.date(byAdding: .month, value: 1, to: date) else {
            return
        }
        
        Task {
            var query = db.collection("User").document(currentUserViewModel.user.uId).collection("Activity")
                .whereField("date", isLessThan: targetDate)
                .order(by: "date", descending: true)
            
            if type == .like {
                query = query
                        .whereField("type", isEqualTo: "like")
            }else if type == .comment {
                query = query
                        .whereField("type", in: ["comment", "reply"])
            }
            
            guard let snapshots = try? await query.getDocuments() else {
                print("error1")
                return
            }
            
            snapshots.documents.forEach { document in
                let data = document.data()

                guard let date = (data["date"] as? FirebaseManager.Timestamp)?.dateValue() else {return}
                guard let type = data["type"] as? String else {return}
                guard let friendNickname = data["friendNickname"] as? String else {return}
                guard let songId = data["songId"] as? String else {return}
                guard let mumoryId = data["mumoryId"] as? String else {return}
                let content = (data["content"] as? String) ?? ""
                let dateString = formatter.string(from: date)
                let commentId = data["commentId"] as? String ?? ""
                
                if !self.activityList.keys.contains(dateString) {
                    self.activityList[dateString] = []
                }
                self.activityList[dateString]?.append(Activity(type: type, songId: songId, mumoryId: mumoryId, friendNickname: friendNickname, myNickname: currentUserViewModel.user.nickname, content: content, commentId: commentId))
            }
            isLoading.wrappedValue = false
            
        }
        
    }
    
    
}

struct SelectionButtonView: View {
    let type: ActivityType
    let title: String
    @Binding var selection: ActivityType
    
    init(type: ActivityType, title: String, selection: Binding<ActivityType>) {
        self.title = title
        self._selection = selection
        self.type = type
    }
    var body: some View {
        Text(title)
            .font(selection == type ? SharedFontFamily.Pretendard.bold.swiftUIFont(size: 13) : SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
            .foregroundStyle(selection == type ? Color.black : ColorSet.D0Gray)
            .padding(.horizontal, 16)
            .frame(height: 33)
            .background(selection == type ? ColorSet.mainPurpleColor : ColorSet.darkGray)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
            .onTapGesture {
                self.selection = self.type
            }
        
    }
}

struct DatePickerView: View {
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var date: Date
    @State var dateArray: [Date] = []
    @State var selectDate: Date = Date()
    
    init(date: Binding<Date>){
        self._date = date
  
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0, content: {
                Picker("date", selection: $selectDate) {
                    ForEach(dateArray, id: \.self){ date in
                        Text(DateText(date: date))
                            .foregroundStyle(Color.white)
                    }
                }
                .pickerStyle(.wheel)
                
                MumorySimpleButton(title: "완료", isEnabled: true, showShadow: false)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    .onTapGesture {
                        date = selectDate
                        dismiss()
                    }
            })
      
        }
        .onAppear {
            let calendar = Calendar.current
            
            let components: Set<Calendar.Component> = [.year, .month]
            let originDate = calendar.dateComponents(components, from: self.date)
            let thisMonthDate = calendar.dateComponents(components, from: Date())
            let signUpDate = calendar.dateComponents(components, from: currentUserViewModel.user.signUpDate)
            
            let startDateComponents = DateComponents(year: signUpDate.year, month: signUpDate.month)
            let endDateComponents = DateComponents(year: thisMonthDate.year, month: thisMonthDate.month)
            let originComponents = DateComponents(year: originDate.year, month: originDate.month)
            
            guard let startDate = calendar.date(from: startDateComponents),
                  let endDate = calendar.date(from: endDateComponents) else {
                return
            }
            
            var currentDate = startDate
            
            while currentDate <= endDate {
                dateArray.append(currentDate)
                currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
            }
            
            selectDate = date
        }
 
    }
    
    private func DateText(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월"
        return dateFormatter.string(from: date)
    }
}

struct ActivityItem: View {
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @State var isPresentBottomSheet: Bool = false
    @State var isPresentDeletedMumoryPopup: Bool = false
    @State var song: Song?
    @Binding var activityList: [String: [Activity]]
    @State var isLoading: Bool = false
    let activity: Activity
    init(activity: Activity, activityList: Binding<[String: [Activity]]>) {
        self.activity = activity
        self._activityList = activityList
    }
    
    var body: some View {
        HStack(spacing: 0, content: {
            Circle()
                .fill(ColorSet.Gray34)
                .frame(width: 38, height: 38)
                .overlay {
                    //타입이 좋아요인지 댓글인지에 따라 다른 아이콘
                    if activity.type == "like" {
                        SharedAsset.notifyLike.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }else if activity.type == "comment" || activity.type == "reply" {
                        SharedAsset.notifyComment.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
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
            
            Text(activity.activityText)
                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                .foregroundStyle(Color.white)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 15)
            
            SharedAsset.menu.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .padding(.leading, 10)
                .onTapGesture {
                    UIView.setAnimationsEnabled(false)
                    isPresentBottomSheet.toggle()
                }
        })
        .padding(.horizontal, 15)
        .frame(height: 90)
        .frame(maxWidth: .infinity)
        .background(ColorSet.background)
        .onAppear{
            Task {
                self.song = await fetchSong(songID: activity.songId)
            }
        }
        .fullScreenCover(isPresented: $isPresentBottomSheet, content: {
            BottomSheetDarkGrayWrapper(isPresent: $isPresentBottomSheet) {
                ActivityBottomSheet(activity: activity, activityList: $activityList, isLoading: $isLoading)
            }
            .background(TransparentBackground())
        })
        .onTapGesture {
            if self.activity.type == "like" || self.activity.type == "comment" || self.activity.type == "reply" {
                Task{
                    let mumory = await mumoryDataViewModel.fetchMumory(documentID: activity.mumoryId)
                    if mumory.id == "DELETE" {
                        UIView.setAnimationsEnabled(false)
                        isPresentDeletedMumoryPopup.toggle()
                        return}
                    appCoordinator.rootPath.append(MumoryView(type: .mumoryDetailView, mumoryAnnotation: mumory))
                }
            }
        }
        .fullScreenCover(isPresented: $isPresentDeletedMumoryPopup, content: {
            OneButtonOnlyConfirmPopupView(title: "삭제된 게시물입니다")
                .background(TransparentBackground())
        })
    }
}

struct ActivityBottomSheet: View {
    let activity: Activity
    let functions = FirebaseManager.shared.functions
    @Binding var activityList: [String: [Activity]]
    @Binding var isLoading: Bool
    @State var isPresentConfimPopup: Bool = false
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @Environment(\.dismiss) var dismiss
    
    init(activity: Activity, activityList: Binding<[String: [Activity]]>, isLoading: Binding<Bool>) {
        self.activity = activity
        self._activityList = activityList
        self._isLoading = isLoading
    }
    var body: some View {
        HStack {
            if activity.type == "like" {
                BottomSheetItem(image: SharedAsset.deleteMumoryDetailMenu.swiftUIImage, title: "좋아요 취소", type: .warning)
                    .onTapGesture {
                        UIView.setAnimationsEnabled(false)
                        isPresentConfimPopup.toggle()
                    }
            }else if activity.type == "comment" {
                BottomSheetItem(image: SharedAsset.deleteMumoryDetailMenu.swiftUIImage, title: "댓글 삭제", type: .warning)
                    .onTapGesture {
                        UIView.setAnimationsEnabled(false)
                        isPresentConfimPopup.toggle()
                    }
            } else if activity.type == "reply" {
                BottomSheetItem(image: SharedAsset.deleteMumoryDetailMenu.swiftUIImage, title: "댓글 삭제", type: .warning)
                    .onTapGesture {
                        UIView.setAnimationsEnabled(false)
                        isPresentConfimPopup.toggle()
                    }
            }
        }
        .overlay(content: {
            LoadingAnimationView(isLoading: $isLoading)
        })
        .fullScreenCover(isPresented: $isPresentConfimPopup, content: {
            TwoButtonPopupView(title: "해당 활동 내역을 삭제하시겠습니까?", positiveButtonTitle: "확인") {
                if activity.type == "like" {
                    isLoading = true
                    dismiss()
                    functions.httpsCallable("like").call(["mumoryId": activity.mumoryId]) { result, error in
                        guard error == nil else {return}
                        for element in activityList {
                            let key = element.key
                            guard let index = element.value.firstIndex(where: {$0.type == self.activity.type
                                && $0.mumoryId == self.activity.mumoryId
                                && $0.songId == self.activity.songId}) else {continue}
                            activityList[key]?.remove(at: index)
                        }
                        self.isLoading = false
                    }
                } else if activity.type == "reply" || activity.type == "comment" {
                    self.isLoading = true
                    dismiss()
                    self.mumoryDataViewModel.deleteComment(comment: Comment(id: self.activity.commentId, uId: "", nickname: "", parentId: "", mumoryId: self.activity.mumoryId, date: Date(), content: "", isPublic: false)) { comments in
                        Task {
                            let mumory = await mumoryDataViewModel.fetchMumory(documentID: self.activity.mumoryId)
                            mumory.commentCount -= 1
                            mumoryDataViewModel.updateMumory(mumory) {
                                for element in activityList {
                                    let key = element.key
                                    guard let index = element.value.firstIndex(where: {$0.type == self.activity.type
                                        && $0.mumoryId == self.activity.mumoryId
                                        && $0.songId == self.activity.songId}) else {continue}
                                    activityList[key]?.remove(at: index)
                                }
                                self.isLoading = false
               
                            }
                        }
                    }
                }
            }
            
            .background(TransparentBackground())
          
        })
        .disabled(isLoading)
    }
    
    
    
    private func deleteComment(commentId: String, mumoryId: String) async {
        let db = FirebaseManager.shared.db
        guard let deleteResult = try? await db.collection("Mumory").document(mumoryId).collection("Comment").document(commentId).delete() else {return}
        let query = db.collection("Mumory").document(mumoryId).collection("Comment")
            .whereField("parentId", isEqualTo: commentId)
        
        guard let snapshots = try? await query.getDocuments() else {return}
        snapshots.documents.forEach { doc in
            doc.reference.delete()
        }
    }
}

struct ActivitySkeletonView: View {
    @State var startAnimation: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            Header
            
            ActivitySkeletonItem
            ActivitySkeletonItem
            ActivitySkeletonItem
            ActivitySkeletonItem
            ActivitySkeletonItem
            ActivitySkeletonItem
            ActivitySkeletonItem
            ActivitySkeletonItem
            ActivitySkeletonItem

        }
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: startAnimation)
        .onAppear {
            startAnimation.toggle()
        }
    }
    
    var Header: some View {
        VStack(alignment: .leading, spacing: 0) {
            RoundedRectangle(cornerRadius: 5, style: .circular)
                .fill(startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                .frame(width: 125, height: 14)
                .padding(.leading, 12)
                .frame(height: 60)
            
            Divider03()

        }
    }
    
    var ActivitySkeletonItem: some View {
        HStack(spacing: 0) {
            Circle()
                .fill(startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                .frame(width: 38, height: 38)
                .padding(.leading, 15)
                .padding(.trailing, 12)
            
            RoundedRectangle(cornerRadius: 5, style: .circular)
                .fill(startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                .frame(width: 56, height: 56)
                .padding(.trailing, 15)

            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 5, style: .circular)
                    .fill(startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                    .frame(width: 207, height: 14)
                RoundedRectangle(cornerRadius: 5, style: .circular)
                    .fill(startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                    .frame(width: 160, height: 14)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 90)
    }
}
