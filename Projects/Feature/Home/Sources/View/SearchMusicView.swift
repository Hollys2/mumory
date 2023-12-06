//
//  SearchMusicView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/28.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI

@available(iOS 16.0, *)
struct SearchMusicView: View {
    
    var body: some View {
        Color.yellow
//            .background(Color.clear)
            .cornerRadius(23)
            .navigationBarItems(leading: EmptyView())
            .navigationBarHidden(true)
    }
}


@available(iOS 16.0, *)
struct SearchMusicView_Previews: PreviewProvider {
    static var previews: some View {
        SearchMusicView()
    }
}
