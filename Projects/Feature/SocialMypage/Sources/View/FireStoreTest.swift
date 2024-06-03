//
//  FireStoreTest.swift
//  Feature
//
//  Created by 제이콥 on 2/6/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

public struct FireStoreTest: View {
    public init(){}
    public var body: some View {
        Text("Hello, World!")
            .onTapGesture {
                test()
            }
    }
    
    private func test(){
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        let auth = Firebase.auth
        
        let data:[String: Any] = [
            "uid": "testUID"
        ]
        let id = "ididid"
        
        db.collection("Playlist")
        
//        db.collection("User").document(uid).collection("UserInfo")
     
        
        db.collection("UserInfo").whereField("id", isEqualTo: id).getDocuments { snapshot, error in
            if let snapshot = snapshot {
                print("docs count: \(snapshot.documents.count)")
            }
        }
        
//        db.collection("User").document("testUID").collection("UserInfo").addDocument(data: data) { error in
//            if let error = error {
//                print("add documnet error: \(error)")
//            }else {
//                print("good")
//            }
//        }

    
//        if let user = auth.currentUser {
//            
//       
//            
//            db.collection("User").document(user.uid).getDocument { snapshot, error in
//                if let snapshot = snapshot {
//                    if snapshot.exists {
//                        guard let data = snapshot.data() else {print("no data");return}
//                        guard let id = data["id"] as? String else {
//                            print("no id")
//                            return
//                        }
//                        print(id)
//                    }
//                }
//            }
//        }
    }
}

//#Preview {
//    FireStoreTest()
//}
