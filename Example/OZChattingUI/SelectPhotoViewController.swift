//
//  SelectPhotoViewController.swift
//  OZChattingUI_Example
//
//  Created by 이재은 on 2020/06/01.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Photos

protocol SelectPhotoDelegate: class {
    func sendImageData(_ paths: [URL])
}

public var maxPhotoSelected = 25

class SelectPhotoViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    // MARK: - Property
    var photoAssets: PHFetchResult<PHAsset>?

    var thumbnailSize = CGSize.zero
    var selectedIndexes = [Int]()
    var selectedImagesPaths = [URL]()
    weak var delegate: SelectPhotoDelegate?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.photoCollectionView.delegate = self
        self.photoCollectionView.dataSource = self
        self.photoCollectionView.allowsMultipleSelection = true
        
        sendButton.isEnabled = false
        
        fetchPhotos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        photoCollectionView.reloadData()
    }
    
    // MARK: - Targets and Actions
    
    @IBAction func pressedSendButton(_ sender: UIBarButtonItem) {
        guard selectedIndexes.count > 0 else { return }

        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat

        for i in 0..<selectedIndexes.count {
            if let asset = photoAssets?[selectedIndexes[i]] {
                PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: requestOptions) { (image, info) in
                    if let anImage = image {
                        self.storeToTemporaryDirectory(anImage, completion: { [weak self] (imagePath, error) in
                            guard let imageURL = imagePath else {
                                return
                            }
                            self?.selectedImagesPaths.append(imageURL)
                        })
                    }
                }
            }
        }
        self.delegate?.sendImageData(selectedImagesPaths)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Function
    
    fileprivate func fetchPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        self.photoAssets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        self.thumbnailSize = CGSize(width: self.view.frame.width - 70, height: 168 * 3)
    }
    
    fileprivate func showToast(controller: UIViewController, message: String, seconds: Double) {
        let toastLabel = UILabel(frame: CGRect(x: 16, y: view.frame.size.height - 52, width: view.frame.size.width * 0.915, height: 40))
        toastLabel.backgroundColor = .black
        toastLabel.alpha = 0.8
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
        toastLabel.layer.cornerRadius = 20
        toastLabel.clipsToBounds = true
        view.addSubview(toastLabel)
        
        UIView.animate(withDuration: seconds, animations: {
            toastLabel.alpha = 0.0
        }, completion:  { _ -> Void in
            self.dismiss(animated: true)
        })
    }
    
    fileprivate func confirmMax(_ isSelect: Bool) -> Bool {
        if selectedIndexes.count >= maxPhotoSelected {
            showToast(controller: self, message: "Can select \(maxPhotoSelected) images max", seconds: 3)
            return true
        }
        return false
    }
    
    fileprivate func selectImage(_ isSelect: Bool, index: Int) {
        if isSelect {
            let isMax = self.confirmMax(isSelect)
            if !isMax {
                selectedIndexes.append(index)
            }
        } else {
            if let sIndex = selectedIndexes.firstIndex(of: index) {
                selectedIndexes.remove(at: sIndex)
            }
        }
        if selectedIndexes.isEmpty {
            sendButton.isEnabled = false
        } else {
            sendButton.isEnabled = true
        }
    }
    
    fileprivate func storeToTemporaryDirectory(_ selectImage: UIImage, completion: @escaping (_ imagePath: URL?, _ error: Error?) -> Void) {
        guard let data = selectImage.jpegData(compressionQuality: 0.5) else { return }
        
        let timestamp = Int(Date().timeIntervalSince1970 + Double(arc4random_uniform(500)))
        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
        let photoPath = tempDirectory.appendingPathComponent("\(timestamp)").appendingPathExtension("jpg")
        
        do {
            try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
            try data.write(to: photoPath, options: Data.WritingOptions.atomic)
            
            completion(photoPath, nil)
        } catch {
            print(error.localizedDescription)
            completion(nil, error)
        }
    }

}

// MARK: - UICollectionViewDataSource
extension SelectPhotoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoAssets?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = photoCollectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as? PhotoCollectionViewCell else { return UICollectionViewCell() }
        
        if let asset = self.photoAssets?[indexPath.item] {
            
            let requestOptions = PHImageRequestOptions()
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.isSynchronous = true
            
            let tSize = CGSize(width: (self.view.frame.width - 70), height: 168 * 3)
            PHImageManager.default().requestImage(for: asset, targetSize: tSize, contentMode: .default, options: requestOptions) { (image, info) in
                var index: Int?
                if let n = self.selectedIndexes.firstIndex(of: indexPath.item) {
                    index = n + 1
                    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                }
                cell.configure(with: image, index: indexPath.item, selectedNum: index)
            }
        }
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension SelectPhotoViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: (self.view.frame.width - 70) / 3, height: 168)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
            if selectedIndexes.count < maxPhotoSelected {
                cell.setSelectedImage(cell.selectButton, num: selectedIndexes.count + 1)
            }
            selectImage(true, index: indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
            cell.setDeselectedImage(cell.selectButton)
            selectImage(false, index: indexPath.item)
            collectionView.reloadItems(at: collectionView.indexPathsForSelectedItems ?? [])
        }
    }
}
