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
    
    init(type: String, songId: String, mumoryId: String, friendNickname: String, myNickname: String, content: String) {
        self.type = type
        self.songId = songId
        self.mumoryId = mumoryId
        self.friendNickname = friendNickname
        self.myNickname = myNickname
        self.content = content
        
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
    @EnvironmentObject var currentUserData: CurrentUserData
    @State var selection: ActivityType = .all
    @State var date: Date = Date()
    @State var isPresentDatePicker: Bool = false
    @State var activityList: [String: [Activity]] = [:]
    
    let db = FBManager.shared.db
    
    @State var pagingCursor: FBManager.Document?
    
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
                .frame(height: 63)
                HStack(spacing: 6, content: {
                    SelectionButtonView(type: .all, title: "전체", selection: $selection)
                    SelectionButtonView(type: .like, title: "좋아요", selection: $selection)
                    SelectionButtonView(type: .comment, title: "댓글", selection: $selection)
                    SelectionButtonView(type: .friend, title: "친구", selection: $selection)
                })
                .padding(.leading, 20)
                .padding(.bottom, 31)
                .onChange(of: selection) { newValue in
                    pagingCursor = nil
                    Task {
                        await getActivity(type: newValue, date: self.date, pagingCorsor: self.$pagingCursor)
                    }
                }
                
                Divider()
                    .frame(maxWidth: .infinity)
                    .frame(height: 0.5)
                    .background(ColorSet.subGray)
                    
                HStack(spacing: 6){
                    Text(DateText(date: date))
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                        .foregroundStyle(Color.white)
                    
                    SharedAsset.downArraowCircle.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                }
                .padding(.leading, 20)
                .frame(height: 55)
                .onTapGesture {
                    UIView.setAnimationsEnabled(false)
                    isPresentDatePicker = true
                }
                .fullScreenCover(isPresented: $isPresentDatePicker, content: {
                    BottomSheetWrapper(isPresent: $isPresentDatePicker) {
                        DatePickerView(date: $date)
                    }
                    .background(TransparentBackground())
                })
                .onChange(of: date, perform: { value in
                    pagingCursor = nil
                    Task {
                        await getActivity(type: selection, date: value, pagingCorsor: self.$pagingCursor)
                    }
                })
                
                Divider()
                    .frame(maxWidth: .infinity)
                    .frame(height: 0.5)
                    .background(ColorSet.subGray)
                
                ScrollView {
                    VStack(spacing: 0, content: {
                        ForEach(activityList.keys.sorted(by: > ), id: \.self) { date in
                            Section {
                                ForEach((activityList[date]) ?? [] , id: \.self) { activity in
                                   ActivityTestItem(activity: activity)
                                }
                            } header: {
                                Text(date)
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                    .foregroundStyle(Color.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 12)
                                    .frame(height: 60)
                                
                                Divider()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 0.5)
                                    .background(ColorSet.subGray)
                            }

                        }

                    })
                }
            })
        }
        .onAppear{
            let calendar = Calendar.current
            let components: Set<Calendar.Component> = [.year, .month]
            let originDate = calendar.dateComponents(components, from: self.date)
            
            var resetDate = DateComponents()
            resetDate.year = originDate.year
            resetDate.month = originDate.month
            
            self.date = calendar.date(from: resetDate) ?? Date()
        }
    }
    
    private func DateText(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월"
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
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter.string(from: date)
    }
    
    private func getActivity(type: ActivityType, date: Date, pagingCorsor: Binding<FBManager.Document?>) async {
        if pagingCorsor.wrappedValue == nil {
            activityList.removeAll()
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        guard let targetDate = Calendar.current.date(byAdding: .month, value: 1, to: date) else {
            return
        }
        
        Task {
            var query = db.collection("User").document(currentUserData.uId).collection("Activity")
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

                guard let date = (data["date"] as? FBManager.TimeStamp)?.dateValue() else {return}
                guard let type = data["type"] as? String else {return}
                guard let friendNickname = data["friendNickname"] as? String else {return}
                guard let songId = data["songId"] as? String else {return}
                guard let mumoryId = data["mumoryId"] as? String else {return}
                let content = (data["content"] as? String) ?? ""
                let dateString = formatter.string(from: date)
                
                if !self.activityList.keys.contains(dateString) {
                    self.activityList[dateString] = []
                }
                self.activityList[dateString]?.append(Activity(type: type, songId: songId, mumoryId: mumoryId, friendNickname: friendNickname, myNickname: currentUserData.user.nickname, content: content))
            }
            
        }
        
    }
    
    
}

//#Preview {
//    ActivityListView()
//}

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
            .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 13))
            .foregroundStyle(selection == type ? Color.black : Color.white)
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
    @Environment(\.dismiss) var dismiss
    @Binding var date: Date
    var dateArray: [Date] = []
    @State var selectDate: Date = Date()
    init(date: Binding<Date>){
        self._date = date
        self.selectDate = Date()
        
        let calendar = Calendar.current
        let startDateComponents = DateComponents(year: 2023, month: 1)
        let endDateComponents = DateComponents(year: 2026, month: 12)
        
        guard let startDate = calendar.date(from: startDateComponents),
              let endDate = calendar.date(from: endDateComponents) else {
            return
        }
        
        var currentDate = startDate
        
        while currentDate <= endDate {
            dateArray.append(currentDate)
            currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
        }
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
                
                WhiteButton(title: "완료", isEnabled: true, showShadow: false)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    .onTapGesture {
                        date = selectDate
                        dismiss()
                    }
            })
      
        }
 
    }
    
    private func DateText(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        return dateFormatter.string(from: date)
    }
}

struct ActivityTestItem: View {
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserData: CurrentUserData
    let activity: Activity
    init(activity: Activity) {
        self.activity = activity
    }
    @State var song: Song?
    
    var body: some View {
        VStack(spacing: 0, content: {
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
            })
            .padding(.horizontal, 15)
            .frame(height: 90)
            .frame(maxWidth: .infinity)
            .background(ColorSet.background)
            
            Divider()
                .frame(maxWidth: .infinity)
                .frame(height: 0.5)
                .background(ColorSet.subGray)
        })
        .onAppear{
            Task {
                self.song = await fetchSong(songID: activity.songId)
            }
        }
        .onTapGesture {
            if self.activity.type == "like" || self.activity.type == "comment" || self.activity.type == "reply" {
                Task{
                    let mumory = await mumoryDataViewModel.fetchMumory(documentID: activity.mumoryId)
                    appCoordinator.rootPath.append(MumoryView(type: .mumoryDetailView, mumoryAnnotation: mumory))
                }
            }
        }


    }
    

}