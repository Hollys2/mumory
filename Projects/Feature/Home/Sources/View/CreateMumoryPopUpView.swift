//
//  CreateMumoryPopUpView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/24.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Shared

struct CreateMumoryPopUpView: View {
    var body: some View {
        Image(uiImage: SharedAsset.createMumoryPopup.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 146, height: 35)
    }
}

struct CreateMumoryPopUpView_Previews: PreviewProvider {
    static var previews: some View {
        CreateMumoryPopUpView()
    }
}
