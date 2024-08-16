//
//  BottomSheetModel.swift
//  Shared
//
//  Created by 다솔 on 2024/05/20.
//  Copyright © 2024 hollys. All rights reserved.
//


import Foundation


public enum Sheet2 {
    case createMumory
    case reward
    case socialMenu
    case commentMenu
    case mumoryDetail
    case friendMumoryDetail
    case mumorySocialView
    
    case comment
    case mumoryCommentMyView(isMe: Bool)
    case mumoryCommentFriendView
    
    case addFriend
    case myMumory
    case friendMumory
    case none
}

public enum MumoryBottomSheetType2 {
    case createMumory
    case mumoryDetailView
    case friendMumoryDetailView
    case mumorySocialView
    case mumoryCommentView
    case mumoryCommentMyView(isMe: Bool)
    case mumoryCommentFriendView
    case addFriend
    case myMumory
    case friendMumory
}
