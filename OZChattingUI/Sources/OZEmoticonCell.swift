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

