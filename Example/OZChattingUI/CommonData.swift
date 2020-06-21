//
//  CommonData.swift
//  OZChattingUI_Example
//
//  Created by Henry Kim on 2020/06/05.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import Foundation
import UIKit
import ImageViewer

extension UIImageView: DisplaceableView {}

struct DataItem: Equatable {
    static func == (lhs: DataItem, rhs: DataItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    let identifier: String  // custom
    let timestamp: Int      // custom
    
    let imageView: UIImageView
    let galleryItem: GalleryItem
}
