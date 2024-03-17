//
//  NavigationModel.swift
//  Shared
//
//  Created by 다솔 on 2024/03/15.
//  Copyright © 2024 hollys. All rights reserved.
//


import Foundation

public enum MumoryViewType {
    case mumoryDetailView
    case editMumoryView
}

public struct MumoryView: Hashable {
    
    public let type: MumoryViewType
    public let mumoryAnnotation: Mumory
//    public let songID: MusicItemID?
    
    public init(type: MumoryViewType, mumoryAnnotation: Mumory) {
        self.type = type
        self.mumoryAnnotation = mumoryAnnotation
    }
}
