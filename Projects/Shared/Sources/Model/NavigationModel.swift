//
//  NavigationModel.swift
//  Shared
//
//  Created by 다솔 on 2024/03/15.
//  Copyright © 2024 hollys. All rights reserved.
//


import Foundation

public enum MumoryViewType: Equatable, Hashable {
    case mumoryDetailView
    case editMumoryView
    case myMumoryView(MumoriUser)
    case regionMyMumoryView(MumoriUser)
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .mumoryDetailView:
            hasher.combine(0)
        case .editMumoryView:
            hasher.combine(1)
        case .myMumoryView(let user):
            hasher.combine(2)
            hasher.combine(user)
        case .regionMyMumoryView(let user):
            hasher.combine(3)
            hasher.combine(user)
        }
    }
}

public struct MumoryView: Hashable {
    
    public let type: MumoryViewType
    public let user: MumoriUser?
    public let mumoryAnnotation: Mumory
    public let region: String?
    public let mumorys: [Mumory]?
//    public let songID: MusicItemID?
    
    public init(type: MumoryViewType, user: MumoriUser? = nil, mumoryAnnotation: Mumory, region: String? = nil, mumorys: [Mumory]? = nil) {
        self.type = type
        self.user = user
        self.mumoryAnnotation = mumoryAnnotation
        self.region = region
        self.mumorys = mumorys
    }
    
    public static func == (lhs: MumoryView, rhs: MumoryView) -> Bool {
        lhs.type == rhs.type &&
        lhs.user == rhs.user &&
        lhs.mumoryAnnotation == rhs.mumoryAnnotation &&
        lhs.region == rhs.region &&
        lhs.mumorys == rhs.mumorys
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(user)
        hasher.combine(mumoryAnnotation)
        hasher.combine(region)
        hasher.combine(mumorys)
    }
}
