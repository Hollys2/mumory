//
//  HomeView.swift
//  Feature
//
//  Created by Dasol on 2023/11/08.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Core


public struct AuthView: View {
    
    let db = FirebaseManager.shared.db
    
    public init() {
    }
    
    public var body: some View {
        HStack{
            Text("This is Auth")
            Button("Load Songs", action: loadSongs)
        }
    }
    
    private func loadSongs() {
        db.collection("favorite").document("musicIDs").getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
            } else if let document = document, document.exists {
                if let musicIDs = document.data()?["IDs"] as? [String] {
                    print("Music IDs: \(musicIDs)")
                } else {
                    print("No Music IDs")
                }
            } else {
                print("Document does not exist")
            }
        }
    }
}

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
