//
//  AuthCoordinator.swift
//  Shared
//
//  Created by 제이콥 on 6/4/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation

public class AuthCoordinator: ObservableObject {
    // MARK: - Object lifecycle
    public init() {}
    
    // MARK: - Propoerties
    @Published public var path: [AuthPage] = []
    
    
    // MARK: - Methods
    public func push(destination: AuthPage) {
        self.path.append(destination)
    }
    
    public func pop() {
        _ = path.popLast()
    }
}
