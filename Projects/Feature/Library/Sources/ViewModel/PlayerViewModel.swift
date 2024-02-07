//
//  Feature
//
//  Created by 제이콥 on 11/27/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import Foundation
import MusicKit

public class PlayerViewModel: ObservableObject {
    public init() {
    }
    
    @Published var song: Song?
}
