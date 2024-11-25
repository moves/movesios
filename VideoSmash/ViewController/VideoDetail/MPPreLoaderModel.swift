//
//  MPPreLoaderModel.swift
// //
//
//  Created by Joshua Hollis on 14/06/2021.
//

import UIKit
import KTVHTTPCache

class MPPreLoaderModel: Equatable {
    static func == (lhs: MPPreLoaderModel, rhs: MPPreLoaderModel) -> Bool {
        return lhs.url == rhs.url && lhs.loader == rhs.loader
    }
    var url: String?
    var loader: KTVHCDataLoader?
    init(url: String, loader: KTVHCDataLoader) {
        self.url = url
        self.loader = loader
    }
    
    
}
