//
//  RewardConstant.swift
//  Shared
//
//  Created by 다솔 on 2024/03/28.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI


public enum Reward {
    
    case attendance(Int)
    case record(Int)
    case location(Int)
    case like(Int)
    case comment(Int)
    case none
    
    public var images: [Image] {
        switch self {
        case .attendance:
            return [
                SharedAsset._1AttendanceReward.swiftUIImage,
                SharedAsset._3AttendanceReward.swiftUIImage,
                SharedAsset._7AttendanceReward.swiftUIImage,
                SharedAsset._14AttendanceReward.swiftUIImage,
                SharedAsset._30AttendanceReward.swiftUIImage
            ]
        case .record:
            return [
                SharedAsset._1RecordReward.swiftUIImage,
                SharedAsset._3RecordReward.swiftUIImage,
                SharedAsset._7RecordReward.swiftUIImage,
                SharedAsset._14RecordReward.swiftUIImage,
                SharedAsset._30RecordReward.swiftUIImage
            ]
        case .location:
            return [
                SharedAsset._1LocationReward.swiftUIImage,
                SharedAsset._3LocationReward.swiftUIImage,
                SharedAsset._7LocationReward.swiftUIImage,
                SharedAsset._14LocationReward.swiftUIImage,
                SharedAsset._30LocationReward.swiftUIImage
            ]
        case .like:
            return [
                SharedAsset._1LikeReward.swiftUIImage,
                SharedAsset._3LikeReward.swiftUIImage,
                SharedAsset._7LikeReward.swiftUIImage,
                SharedAsset._14LikeReward.swiftUIImage,
                SharedAsset._30LikeReward.swiftUIImage
            ]
        case .comment:
            return [
                SharedAsset._1CommentReward.swiftUIImage,
                SharedAsset._3CommentReward.swiftUIImage,
                SharedAsset._7CommentReward.swiftUIImage,
                SharedAsset._14CommentReward.swiftUIImage,
                SharedAsset._30CommentReward.swiftUIImage
            ]
        case .none:
            return []
        }
    }
    
    public var titles: [String] {
        switch self {
        case .attendance:
            return ["첫 출석", "3일 연속 출석", "1주 연속 출석", "2주 연속 출석", "30일 연속 출석"]
        case .record:
            return ["뮤모리 1개 기록", "뮤모리 5개 기록", "뮤모리 10개 기록", "뮤모리 20개 기록", "뮤모리 50개 기록"]
        case .location:
            return ["지역 2곳 기록", "지역 3곳 기록", "지역 5곳 기록", "지역 10곳 기록", "지역 15곳 기록"]
        case .like:
            return ["첫 좋아요", "좋아요 5개", "좋아요 15개", "좋아요 30개", "좋아요 50개"]
        case .comment:
            return ["첫 댓글", "댓글 5개", "댓글 10개", "댓글 20개", "댓글 40개"]
        case .none:
            return []
        }
    }
    
    public var subTitles: [String] {
        switch self {
        case .attendance:
            return [
                "뮤모리 출석 1일차 입니다. 꾸준히 출석해서 리워드를 받아보세요!",
                "뮤모리에 3일 연속 출석하셨네요. 꾸준히 출석해서 리워드를 받아보세요!",
                "와! 7일 동안 열심히 출석하셨네요. 뮤모리를 꾸준히 즐기며 음악과 그 순간을 기록하세요!",
                "대단해요! 14일 동안 열심히 출석했습니다. 나만의 뮤모리를 더 많이 남겨보세요!",
                "놀라운 업적! 30일 동안 열심히 출석했습니다. 더 많은 순간을 뮤모리와 함께하세요!"
            ]
        case .record:
            return [
                "처음으로 뮤모리를 기록하셨네요. 뮤모리를 꾸준히 작성하고 리워드를 받아보세요!",
                "지금까지 뮤모리를 5개 기록하셨네요. 나만의 뮤모리를 더 많이 남겨보세요!",
                "훌륭해요! 뮤모리 10개 기록을 완료하셨습니다. 나의 순간을 더욱 특별하게 만들어보세요!",
                "와우! 뮤모리 20개 기록 달성. 계속 달려보세요!",
                "축하합니다! 50개의 뮤모리를 기록하셨습니다. 기록을 계속 이어가세요!"
            ]
        case .location:
            return [
                "지역 2곳에 뮤모리를 기록하셨군요. 계속해서 새로운 곳에서 음악을 즐겨보세요!",
                "지역 3곳에서 나만의 뮤모리 기록을 남겼습니다. 꾸준히 즐기며 음악과 그 순간을 기록하세요!",
                "5곳의 새로운 지역에서 뮤모리를 기록하셨군요. 더 많은 지역에서 나의 뮤모리 기록을 남겨보세요!",
                "대단해요! 새로운 지역 10곳에서 뮤모리를 기록하셨어요. 해외에서도 나의 뮤모리를 남겨보세요!",
                "당신은 뮤모리 탐험가, 지역 15곳에서 뮤모리를 기록하셨어요. 뮤모리를 더 깊이 탐험해보세요!"
            ]
        case .like:
            return [
                "처음으로 친구 뮤모리에 좋아요를 누르셨어요. 나만의 뮤모리로 친구들과 서로의 음악 취향을 알아가보세요!",
                "친구 뮤모리에 5개 좋아요를 누르셨어요. 친구들과 열심히 음악 취향을 공유해보세요!",
                "친구 뮤모리에 좋아요 15개를 누르셨습니다. 뮤모리에서 더 많은 음악과 재미를 찾아보세요!",
                "당신은 공감왕! 친구 뮤모리에 30개의 좋아요를 누르셨어요.",
                "50개의 좋아요 달성. 정말 대단해요! 당신의 활발한 참여가 모두에게 큰 힘을 줍니다!"
            ]
        case .comment:
            return [
                "친구 뮤모리에 첫 댓글을 다셨어요. 친구 게시물에 더 많은 댓글을 달고 리워드를 받아보세요!",
                "친구 뮤모리에 5개의 댓글 작성 완료. 계속해서 친구들과 소통해보세요!",
                "우와! 10개의 댓글 작성하셨군요. 꾸준히 친구들과 음악을 공유하며 소통해보세요!",
                "친구 뮤모리에 20개의 댓글을 다셨어요! 계속해서 활발한 소통을 이어가주세요.",
                "축하합니다! 친구 뮤모리에 40개의 댓글을 다셨어요. 앞으로도 멋진 활동을 계속해주세요!"
            ]
        case .none:
            return []
        }
    }
    
    public var image: Image {
        switch self {
        case .attendance(let index):
            return self.images[index]
        case .record(let index):
            return self.images[index]
        case .location(let index):
            return self.images[index]
        case .like(let index):
            return self.images[index]
        case .comment(let index):
            return self.images[index]
        case .none:
            return Image(systemName: "xmark")
        }
    }
    
    public var title: String {
        switch self {
        case .attendance(let index):
            return self.titles[index]
        case .record(let index):
            return self.titles[index]
        case .location(let index):
            return self.titles[index]
        case .like(let index):
            return self.titles[index]
        case .comment(let index):
            return self.titles[index]
        case .none:
            return ""
        }
    }
    
    public var subTitle: String {
        switch self {
        case .attendance(let index):
            return self.subTitles[index]
        case .record(let index):
            return self.subTitles[index]
        case .location(let index):
            return self.subTitles[index]
        case .like(let index):
            return self.subTitles[index]
        case .comment(let index):
            return self.subTitles[index]
        case .none:
            return ""
        }
    }
}
