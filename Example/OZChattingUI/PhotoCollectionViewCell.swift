//
//  PhotoCollectionViewCell.swift
//  OZChattingUI_Example
//
//  Created by 이재은 on 2020/06/02.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Photos

protocol PhotoCellDelegate: class {
    func selectImage(_ isSelect: Bool, image: UIImage, tag: Int)
    func confirmMax(_ isSelect: Bool) -> Bool
    func reloadCollectionView()
}

class PhotoCollectionViewCell: UICollectionViewCell {
    // MARK: - IBOutlet
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var selectView: UIView!
    
    // MARK: - Property
    fileprivate let imageManager = PHImageManager()
    var representedAssetIdentifier: String?
    weak var delegate: PhotoCellDelegate?
    
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
        self.selectView?.layer.borderWidth = 4
        self.selectView?.layer.borderColor = UIColor(red: 44/255, green: 187/255, blue: 182/255, alpha: 1).cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - Targets and Actions
    @IBAction func pressedSelectButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        delegate?.selectImage(sender.isSelected, image: self.photoImageView.image!, tag: photoImageView.tag)
        delegate?.reloadCollectionView()
    }
    
    // MARK: - Function
    func configure(with image: UIImage?, index: Int, selectedNum: Int?) {
        self.photoImageView.image = image
        self.selectButton.tag = index
        self.photoImageView.tag = index
        if selectedNum != nil {
            setSelectedImage(self.selectButton, num: selectedNum!)
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
