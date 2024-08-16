//
//  AppCoordinator.swift
//  Shared
//
//  Created by 다솔 on 2023/12/01.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Combine
import MapKit
import MusicKit
import Firebase


public enum AppNavigationType {
    case auth
    case mumory
}

public enum Tab: Int {
    case home = 0
    case social
    case createMumroy
    case library
    case notification
}

public class AppCoordinator: ObservableObject {
    
    var anyCancellable: AnyCancellable? = nil
    var cancellables = Set<AnyCancellable>()
    
    public init() {
        anyCancellable = localSearchViewModel.objectWillChange
            .sink { [weak self] (_) in
                self?.objectWillChange.send()
            }
    }
    
    @Published public var test: Int = -1
    
    @Published public var localSearchViewModel: LocalSearchViewModel = .init()
    
    @Published public var rootPath: NavigationPath = NavigationPath()
    @Published public var authPath: [AuthPage] = []
    @Published public var selectedTab: Tab = .social
    
    @Published public var createdMumoryRegion: MKCoordinateRegion?
    
    @Published public var offsetY: CGFloat = .zero
    
    @Published public var sheet: Sheet = .none {
        didSet {
            print("FUCK Sheet updated to: \(sheet)")
        }
    }
    
    @Published public var isCreateMumorySheetShown: Bool = false {
        didSet {
            if isCreateMumorySheetShown {
                self.selectedDate = Date()
            }
        }
    }
    @Published public var isCommentSheetShown: (Bool, Mumory?) = (false, nil)
    @Published public var isMumoryMapViewShown: Bool = false
    
    
    @Published public var isMumoryDetailShown = false
    @Published public var isNavigationBarColored = false
    @Published public var isReactionBarShown = true
    //    @Published public var isMumoryDetailMenuSheetShown = false
    //    @Published public var isSocialMenuSheetViewShown = false
    @Published public var isMumoryDetailCommentSheetViewShown = false
    @Published public var isSocialCommentSheetViewShown: Bool = false
    @Published public var isCommentBottomSheetShown = false
    @Published public var isMyMumoryBottomSheetShown = false
    @Published public var isDeleteCommentPopUpViewShown = false
    @Published public var isAddFriendViewShown = false
    @Published public var isDeleteMumoryPopUpViewShown = false
    @Published public var isFirstSocialTabTapped: Bool = false
    @Published public var isRewardPopUpShown: Bool = false
    
    @Published public var isDatePickerShown: Bool = false
    @Published public var selectedDate: Date = Date() {
        didSet {
            print("FUCK selectedDate: \(selectedDate)")
        }
    }
    
    @Published public var draftMumorySong: SongModel? = nil
    @Published public var draftMumoryLocation: LocationModel? = nil
    
    //    @Published public var selectedMumory: Mumory = Mumory()
    @Published public var selectedComment: Comment = Comment()
    
    @Published public var page: Int = 1
    
    @Published public var isSplashViewShown: Bool = true
    @Published public var isMyPageViewShown = false
    @Published public var isHomeViewShown: Bool = false
    @Published public var isLoginViewShown: Bool = false
    @Published public var isOnboardingShown: Bool = UserDefaults.standard.value(forKey: "SignInHistory") == nil
    @Published public var isLoading: Bool = false
    @Published public var isRefreshing: Bool = false
    @Published public var isSocialLoading: Bool = false
    @Published public var isScrollToTop: Bool = false
    
    @Published public var isFirstUserLocation: Bool = false
    
    public func push<T>(destination: T) {
        if let dst = destination as? AuthPage {
            authPath.append(dst)
        } else if let dst = destination as? MumoryPage {
            rootPath.append(dst)
        }
    }
    
    public func pop(target: AppNavigationType) {
        switch target {
        case .auth:
            _ = authPath.popLast()
        case .mumory:
            rootPath.removeLast()
        }
    }
    
    //    private func hasSignInHistory() -> Bool {
    //        return UserDefaults.standard.value(forKey: "SignInHistory") == nil
    //    }
    
    private func hasCurrentUser() -> Bool {
        let auth = FirebaseManager.shared.auth
        return auth.currentUser != nil
    }
    
    //    public func setupInitialScreen() {
    //        DispatchQueue.main.async {
    //            self.isOnboardingShown = self.hasSignInHistory()
    //            self.isHomeViewShown = self.hasCurrentUser()
    //        }
    //    }
}



