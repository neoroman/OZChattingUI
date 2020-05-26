//
//  OZEmoticons.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/06.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit

open class OZEmoticon {
    var identifier: String = UUID().uuidString
    var name = ""
    var title = ""
    var ext = "png"
    
    init(_ name: String, title: String = "", ext: String = "") {
        self.name = name
        self.title = title
        self.ext = ext
    }
}
