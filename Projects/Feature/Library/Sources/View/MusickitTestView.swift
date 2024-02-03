//
//  MusickitTestView.swift
//  Feature
//
//  Created by 제이콥 on 2/3/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import MusicKit

struct MusickitTestView: View {
    var body: some View {
        Button {
            genreCheck()
        } label: {
            Text("Button")
        }

    }
    
    private func genreCheck(){
        let genreRequest = MusicCatalogResourceRequest<Genre>(matching: \.id, equalTo: "1153")
//        genreRequest.
//        MusicCatalogResourceRequest(matching: , equalTo: Value)
//        genreRequest.
        Task{
            let response = try await genreRequest.response()
            print(response.items)
        }
    }
    private func MusicTest() {
        var index = 1
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            index += 1
            if index == 2000 {
                timer.invalidate()
            }
            
            let musicItemID = MusicItemID(rawValue: String(index))
            let request = MusicCatalogResourceRequest<Genre>(matching: \.id, equalTo: musicItemID)
            Task{
                let response = try await request.response()
                if let genre = response.items.first {
                    print("genre id: \(genre.id), name: \(genre.name)")
                }else {
                    print("no genre")
                }
            }
            
        }
    }
}

#Preview {
    MusickitTestView()
}
