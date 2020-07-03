/*
MIT License

Copyright (c) 2020 OZChattingUI, Henry Kim <neoroman@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
//
//  OZEmoticonCell.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/06.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit

open class OZEmoticonCell: DynamicView {
    var descLabel = UILabel()
    var imageView = UIImageView()
    
    var emoticon: OZEmoticon! {
        didSet {
            if emoticon.name.lowercased().hasPrefix("file"),
                let anUrl = URL(string: emoticon.name),
                let anImage = UIImage(contentsOfFile: anUrl.relativePath) {
                // Local file with fileURL
                imageView.image = anImage
            }
            else if emoticon.name.lowercased().hasPrefix("/"),
                let anImage = UIImage(contentsOfFile: emoticon.name) {
                // Local file with relative path
                imageView.image = anImage
            }
            else if emoticon.name.count > 0, let anImage = UIImage(named: emoticon.name) {
                imageView.image = anImage
            }
            
            imageView.frame = bounds
            imageView.contentMode = .scaleAspectFit
            
            descLabel.frame = bounds
            descLabel.text = emoticon.name
            descLabel.textAlignment = .left
            descLabel.textColor = UIColor.gray.withAlphaComponent(0.5)
            descLabel.font = UIFont.systemFont(ofSize: 12)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFill
        clipsToBounds = false
        addSubview(imageView)
        descLabel.frame = bounds
        #if DEBUG
        addSubview(descLabel)
        #endif
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        descLabel.frame = bounds.inset(by: UIEdgeInsets(top: -50, left: -10, bottom: 0, right: 0))
    }
}

