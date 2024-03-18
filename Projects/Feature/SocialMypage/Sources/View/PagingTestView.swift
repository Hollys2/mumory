//
//  PagingTestView.swift
//  Feature
//
//  Created by 제이콥 on 3/13/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import FirebaseFunctions

public struct PagingTestView: View {
    @State var titles: [String] = []
    @State var cursor: FBManager.Document?
    let db = FBManager.shared.db
    public init(){}
    public var body: some View {
        VStack{
            Button(action: {
                lazy var functions = Functions.functions()
                //친구 요청 보낼때, uId에 상대방 uId넣기
                functions.httpsCallable("friendAcceptNotification").call(["uId": "jRc5GsRl77Mu3gwbGcuHdgyvBqz2"]) { result, error in
                    if let result = result {
                        print(result.description)
                    }else if let error = error {
                        print(error.localizedDescription)
                    }
                }
                
                functions.httpsCallable("like").call(["mumoryId": "뮤모리아이디변수"]) { result, error in
                    if let result = result {
                        print(result.description)
                    }else if let error = error {
                        print(error.localizedDescription)
                    }
                }
                
                //친구 수락할 때, uId에 상대방 uId넣기
//                functions.httpsCallable("friendAcceptNotification").call(["uId": "jRc5GsRl77Mu3gwbGcuHdgyvBqz2"]) { result, error in
//                    if let result = result {
//                        print(result.description)
//                    }else if let error = error {
//                        print(error.localizedDescription)
//                    }
//                }
                
            
                
            }, label: {
                Text("Button")
            })
            ScrollView{
                ForEach(titles, id:\.self){ title in
                    Text(title)
                }
            }
        }
        .onAppear(perform: {
            getDocs()
        })
        
    }
    
    private func getDocs() {
        let query = db.collection("FunctionTest").document("test").collection("PagingTest")
            .order(by: "title")
            .limit(to: 2)
        
        
        if let cursor = self.cursor {
            print("no empty")
            Task {
                let newQuery = query
                                .start(afterDocument: cursor)
                
                guard let docs = try? await newQuery.getDocuments().documents else {
                    print("no docs")
                    return
                }
                
                self.cursor = docs.last
                docs.forEach { doc in
                    titles.append((doc.data()["title"] as? String) ?? "no title")
                }
            }
 
        }else {
            print("empty")
            Task{
                guard let docs = try? await query.getDocuments().documents else {
                    return
                }
                self.cursor = docs.last
                docs.forEach { doc in
                    titles.append((doc.data()["title"] as? String) ?? "no title")
                }
            }
        }
    }
}
