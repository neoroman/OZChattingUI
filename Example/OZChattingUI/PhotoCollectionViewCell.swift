/*
MIT License

Copyright (c) 2020 OZChattingUI, Pilvi(Jae-eun) <je6752@gmail.com>

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
//  PhotoCollectionViewCell.swift
//  OZChattingUI_Example
//
//  Created by 이재은 on 2020/06/02.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit
import Photos

class PhotoCollectionViewCell: UICollectionViewCell {
    // MARK: - IBOutlet
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var selectView: UIView!
    
    // MARK: - Property
    fileprivate let imageManager = PHImageManager()
    var representedAssetIdentifier: String?
    
    var thumbnailSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: (UIScreen.main.bounds.width - 64) / 3 * scale, height: 168 * scale)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.photoImageView.contentMode = UIView.ContentMode.scaleAspectFill
        self.selectButton.layer.cornerRadius = selectButton.frame.width / 2
        self.selectButton.layer.borderColor = UIColor.init(white: 1, alpha: 0.4).cgColor
        self.selectButton.layer.borderWidth = 2
        self.selectButton.isSelected = false
        self.selectButton.isUserInteractionEnabled = false
        self.selectView?.layer.borderWidth = 4
        self.selectView?.layer.borderColor = UIColor(red: 44/255, green: 187/255, blue: 182/255, alpha: 1).cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - Function
    func configure(with image: UIImage?, index: Int, selectedNum: Int?) {
        self.photoImageView.image = image
        if let selectedNum = selectedNum {
            setSelectedImage(self.selectButton, num: selectedNum)
        } else {
            setDeselectedImage(self.selectButton)
        }
    }
    
    func setSelectedImage(_ button: UIButton, num: Int) {
        button.isSelected = true
        button.layer.borderWidth = 0
        button.backgroundColor = UIColor(red: 44/255, green: 187/255, blue: 182/255, alpha: 1)
        button.setTitle("\(num)", for: .selected)
        selectView?.isHidden = false
    }
    
    func setDeselectedImage(_ button: UIButton) {
        button.isSelected = false
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.init(white: 1, alpha: 0.4).cgColor
        button.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
        selectView?.isHidden = true
    }
}
