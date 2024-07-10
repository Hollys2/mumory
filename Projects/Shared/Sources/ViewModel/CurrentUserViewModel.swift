//
//  currentUserViewModel.swift
//  Feature
//
//  Created by 제이콥 on 2/10/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import Core
import Firebase
import Combine

@MainActor
public class CurrentUserViewModel: ObservableObject {
    // MARK: - Object lifecycle
    public init(){
        friendViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        playlistViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    

    // MARK: - Propoerties
    @Published public var user: UserProfile = .init()
    @Published public var friendViewModel: FriendViewModel = .init()
    @Published public var playlistViewModel: PlaylistViewModel = .init()
    @Published public var existUnreadNotification: Bool = false
    @Published public var reward: Reward = .none
    var notificationListener: ListenerRegistration?
    var cancellables = Set<AnyCancellable>()

    
    // MARK: - Methods
    public func initializeUserData() async {
        guard let currentUser = FirebaseManager.shared.auth.currentUser else {return}
        let uId = currentUser.uid
        self.user = await FetchManager.shared.fetchUser(uId: uId)
        friendViewModel = .init(uId: uId)
        playlistViewModel = .init(uId: uId)
        NotificationListener(uId: uId)

        friendViewModel.FriendUpdateListener()
        friendViewModel.FriendRequestListener()
        playlistViewModel.savePlaylist()
    }
    
    private func NotificationListener(uId: String) {
        let db = FirebaseManager.shared.db
        let query = db.collection("User").document(uId).collection("Notification")
            .whereField("isRead", isEqualTo: false)
        
        DispatchQueue.main.async {
            self.notificationListener = query.addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {return}
                self.existUnreadNotification = (snapshot.count > 0)
            }
        }
    }
    
    public func removeAllData(){
        user = UserProfile()
        existUnreadNotification = false
        notificationListener?.remove()
    }
}
