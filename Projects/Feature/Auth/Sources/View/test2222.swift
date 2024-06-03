//
//  test2222.swift
//  Feature
//
//  Created by 제이콥 on 3/6/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

public struct test2222: View {
    @State var id: String = "default"
    @State var sum = 0
    public var body: some View {
        VStack{
            Button {
                Task {
                    let Firebase = FirebaseManager.shared
                    let db = Firebase.db
                    let auth = Firebase.auth
                    
                    
                    
                    if let result = try? await db.collection("User").document("tester2").getDocument(){
                        guard let id = result.data()!["id"] as? String else {
                            print("no id")
                            return
                        }
                        print("okok \(id)")
                        self.sum += 1
                        self.id = id
                    }else {
                        print("no internet")
                    }
                }
                
            } label: {
                Text("test@@@!!!!")
            }
            
            Text("\(id) \(sum)")

        }
    }
}

//#Preview {
//    test2222()
//}
