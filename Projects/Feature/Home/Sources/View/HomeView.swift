//
//  HomeView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/08.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import MapKit
import MusicKit
import Core

public struct HomeView: View {
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    public init(){
        
    }
    
    public var body: some View {
        HStack{
            Text("This is Home")
            Button("Load Songs", action: loadSongs)
            Map(coordinateRegion: $region)
        }
    }
    
    //    let db = Firestore.firestore()
    let db = FirebaseManager.shared.db
    
    
    private func saveMusic() {
        let musicIDs = ["hello", "1487778081", "1712044358", "1590067123", "1651802560", "1534525138",
                        "1436905366", "1441164589", "1441164738"]
        
        db.collection("favorite").document("musicIDs").setData(["IDs": musicIDs]) { error in
            if let error = error {
                print("파베 에러: \(error)")
            } else {
                print("파베 성공")
            }
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

//struct HomeVIew_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeVIew()
//    }
//}
