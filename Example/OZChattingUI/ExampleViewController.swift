//
//  ExampleViewController.swift
//  OZChatExample
//
//  Created by Henry Kim on 2020/05/07.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit
import OZChattingUI
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


class ExampleViewController: UIViewController {
    
    var chatViewController: OZMessagesViewController?

    var galleryVC: GalleryViewController?
    var chatImageItems: [DataItem] = []
    var selectedImage: UIImage?
    var imageViewerRightButton: UIButton?
    var imageViewerLeftButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    fileprivate func testChats(vc: OZMessagesViewController) {
        // Debug
        vc.isEchoMode = true
        
        // Message send and receive
        vc.send(msg: "\(Date())", type: .announcement)
        vc.receive(msg: "Welcome to OZChattingUI", type: .text, timestamp: 0, profileIconPath: "TaylorSwift.jpg")

        let aTimestamp = Int(Date().timeIntervalSince1970)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            vc.receive(msg: "Cindy called with Alice for 11minutes.", type: .deviceStatus, activeType: .call, timestamp: aTimestamp-600)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            vc.receive(msg: "test.mp3", type: .mp3, activeType: nil, timestamp: aTimestamp-400, profileIconPath: "TaylorSwift.jpg")
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            vc.receive(msg: "Marco joined SID campaign.", type: .deviceStatus, activeType: .campaign, timestamp: aTimestamp-300)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            vc.receive(msg: "Watch off", type: .deviceStatus, activeType: .watchOff, timestamp: aTimestamp-100)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.6) {
            vc.receive(msg: "Jidkdhjn walked 10,000 steps, burned 110kcal", type: .deviceStatus, activeType: .step, timestamp: aTimestamp-50)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            vc.send(msg: "Hi... OZChattingUI!", type: .text) { (id, content) in
                vc.send(msg: "Delivered", type: .status, isDeliveredMsg: true)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            vc.send(msg: "You can test it here..., Good luck and have a nice day", type: .text) { (id, content) in
                vc.dataSource.data.removeAll(where: { $0.content == "Delivered" })
                vc.send(msg: "Delivered", type: .status, isDeliveredMsg: true)
            }
        }
    }

    @IBAction func buttonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "OZChattingUI", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "OZChattingUI") as? OZMessagesViewController {
            if chatViewController == nil {
                chatViewController = vc
            }
            vc.delegate = self
            vc.fileChoosePopupDelegate = self
            
            #if USING_AS_MODAL
            let nc = UINavigationController(rootViewController: vc)
            self.present(nc, animated: true) {
                self.testChats(vc: vc)
                if #available(iOS 13.0, *) {
                    vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.closeChatView))
                } else {
                    vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "ClosE", style: .done, target: self, action: #selector(self.closeChatView))
                }
            }
            #else
            if let nc = self.navigationController {
                nc.pushViewController(vc, animated: true)
                self.testChats(vc: vc)
            }
            #endif
        }
    }
    
    
    @IBAction func testButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "OZChattingUI", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "OZChattingUI") as? OZMessagesViewController {
            if chatViewController == nil {
                chatViewController = vc
            }
            vc.delegate = self
            vc.fileChoosePopupDelegate = self
            if #available(iOS 11.0, *) {
            } else {
//                vc.fileChoosePopup.setButton
            }

            #if USING_AS_MODAL
            self.present(nc, animated: true) {
                let nc = UINavigationController(rootViewController: vc)
                nc.isNavigationBarHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                    vc.setupDataProvider(newDataSource: OZMessageDataProvider.init(data: testMessages))
                    vc.collectionView.reloadData()
                    vc.collectionView.scrollTo(edge: .bottom, animated:true)
                    if #available(iOS 13.0, *) {
                        vc.isModalInPresentation = true
                        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.closeChatView))
                    } else {
                        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "ClosE", style: .done, target: self, action: #selector(self.closeChatView))
                    }
                }
            }
            #else
            if let nc = self.navigationController {
                nc.pushViewController(vc, animated: true)
                vc.setupDataProvider(newDataSource: OZMessageDataProvider.init(data: testMessages))
                vc.collectionView.reloadData()
                vc.collectionView.scrollTo(edge: .bottom, animated:true)
            }
            #endif
        }
    }

    
    @objc func closeChatView() {
        self.dismiss(animated: true, completion: nil)
    }
}


extension ExampleViewController: OZMessagesViewControllerDelegate {
    func messageCellDidSetMessage(cell: OZMessageCell, previousMessage: OZMessage) {
        let shadowColor = UIColor.black
        if cell.message.type == .text {
            if let incomingCell = cell as? IncomingTextMessageCell {
                
                incomingCell.textLabel.layer.shadowOffset = CGSize(width: 0, height: 3)
                incomingCell.textLabel.layer.shadowOpacity = 0.2
                incomingCell.textLabel.layer.shadowRadius = 8
                incomingCell.textLabel.layer.shadowColor = shadowColor.cgColor
                incomingCell.textLabel.layer.shadowPath = UIBezierPath(roundedRect: incomingCell.textLabel.bounds, cornerRadius: 12).cgPath
            }
            else if let outgoingCell = cell as? OutgoingTextMessageCell {
                
                outgoingCell.textLabel.layer.shadowOffset = CGSize(width: 0, height: 3)
                outgoingCell.textLabel.layer.shadowOpacity = 0.2
                outgoingCell.textLabel.layer.shadowRadius = 8
                outgoingCell.textLabel.layer.shadowColor = shadowColor.cgColor
                outgoingCell.textLabel.layer.shadowPath = UIBezierPath(roundedRect: outgoingCell.textLabel.bounds, cornerRadius: 12).cgPath
            }
        }
        cell.setNeedsLayout()
    }
    
    func messageCellLayoutSubviews(cell: OZMessageCell, previousMessage: OZMessage) {
//        if cell.message.alignment == .left {
//            switch cell.message.type {
//            case .text:
//                guard let incomingCell = cell as? IncomingTextMessageCell else { return }
//                incomingCell.iconImage.isHidden = true
//                let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//                incomingCell.textLabel.frame = incomingCell.bounds.inset(by: inset)
//            case .image, .emoticon:
//                guard let incomingCell = cell as? ImageMessageCell else { return }
//                incomingCell.iconImage.isHidden = true
//                let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//                incomingCell.imageView.frame = incomingCell.bounds.inset(by: inset)
//            case .voice, .mp3:
//                guard let incomingCell = cell as? AudioPlusIconMessageCell else { return }
//                incomingCell.iconImage.isHidden = true
//                let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//                incomingCell.backView.frame = incomingCell.bounds.inset(by: inset)
//            default:
//                print(".....\(cell.message.type), prevMsg(\(String(describing: previousMessage))).....")
//            }
//        }
    }
    func messageViewLoaded(isLoaded: Bool) {
        print("messageViewLoaded...!")
    }
    
    func messageCellTapped(cell: OZMessageCell, index: Int, complete: @escaping OZChatTapCompleteBlock) {
        print("messageCellTapped => index(%d), cell(%@)", index, cell)
        
        // Do someting here and callback to OZChattingUI
        if let aCell = cell as? AudioMessageCell {
            if let aPath = aCell.message.extra["filePath"] as? String, aPath.count > 0 {
                complete(true, aPath)
            }
            else {
                aCell.preparePlay(file: "")
                if let aPath = Bundle.main.path(forResource: "test", ofType: "mp3") {
                    DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                        complete(true, aPath)
                    }
                }
            }
        }
        else if let aCell = cell as? ImageMessageCell {
            if aCell.message.type == .emoticon {
                // It's emoticon
                return
            }
            selectedImage = aCell.imageView.image
            makeGalleryItemsFromAllMessages()
            showGalleryImageViewer(identifier: aCell.message.identifier)
        }
    }
    
    func messageAppend(complete: @escaping OZChatFetchCompleteBlock) {
        print("messageAppend...!")
    }
    
    func messageSending(identifier: String, type: OZMessageType, data: OZMessage) {
        print("messageSending(id:\(identifier)):::::Sending(Type: \(type)) ==> contentPath: \(data.content)")
        
        guard let chatVC = chatViewController else { return }
        
        // Delivered message here
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            chatVC.dataSource.data.removeAll(where: { $0.content == "Delivered" })
            chatVC.send(msg: "Delivered", type: .status)
        }
    }
}

// MARK: - UIDocumentBrowserViewControllerDelegate
// Thanks to https://www.appcoda.com/files-app-integration/
@available(iOS 11.0, *)
extension ExampleViewController: UIDocumentBrowserViewControllerDelegate {
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let newDocumentURL: URL? = nil
        
        if newDocumentURL != nil {
            importHandler(newDocumentURL, .copy)
        } else {
            importHandler(nil, .none)
        }
    }
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        presentDocument(at: sourceURL)
    }
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        presentDocument(at: destinationURL)
    }
    
    func presentDocument(at documentURL: URL) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let documentViewController = storyBoard.instantiateViewController(withIdentifier: "DocumentViewController") as! DocumentViewController
        
        documentViewController.document = Document(fileURL: documentURL)
        
        if let nc = self.navigationController {
            nc.pushViewController(documentViewController, animated: true)
        }
        else {
            present(documentViewController, animated: true, completion: nil)
        }
    }

    @objc func closeDocumentViewController() {
        self.dismiss(animated: true, completion: nil)
    }
}




// MARK: - ImageViewer
extension ExampleViewController {
    // MARK: - Targets and Actions
    @objc func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            self.selectedImage = nil
            self.galleryVC = nil
        }
    }
    @objc func fileDownButtonTapped(_ sender: Any) {
        if let gvc = galleryVC,
            let anImage = self.selectedImage  {
            let activityVC = UIActivityViewController(activityItems: [anImage], applicationActivities: nil)
            gvc.present(activityVC, animated: true)
        }
    }
    func makeGalleryItemsFromAllMessages() {
        if let ccv = chatViewController {
            for x in ccv.dataSource.data {
                if x.type == .emoticon { continue }
                guard let dataIndex = ccv.dataSource.data.firstIndex(of: x) else { continue }
                
                if x.content.hasPrefix("/") {
                    makeGalleryItems(path: x.content, data: x)
                }
                else if let imgCell = ccv.collectionView.cell(at: dataIndex) as? ImageMessageCell,
                    x.type == .image {

                    makeGalleryItems(cell: imgCell)
                }
            }
        }
    }
    func makeGalleryItems(cell: OZMessageCell) {
        guard let imgCell = cell as? ImageMessageCell else{ return }

        let imageView = imgCell.imageView
        var galleryItem: GalleryItem!
        
        guard let image = imageView.image else { return }
        galleryItem = GalleryItem.image { $0(image) }
        
        guard !chatImageItems.contains(where: { (a) -> Bool in
            return a.identifier == imgCell.message.identifier
        }) else { return }
        chatImageItems.append(DataItem(identifier: imgCell.message.identifier, timestamp: imgCell.message.timestamp, imageView: imageView, galleryItem: galleryItem))
        chatImageItems.sort { (a, b) -> Bool in
            return a.timestamp < b.timestamp
        }
    }
    func makeGalleryItems(path: String, data: OZMessage) {
        guard let anImage = UIImage(contentsOfFile: path) else{ return }

        var galleryItem: GalleryItem!
        galleryItem = GalleryItem.image { $0(anImage) }
        
        guard !chatImageItems.contains(where: { (a) -> Bool in
            return a.identifier == data.identifier
        }) else { return }
        let anImageView = UIImageView(image: anImage)
        chatImageItems.append(DataItem(identifier: data.identifier, timestamp: data.timestamp, imageView: anImageView, galleryItem: galleryItem))
        chatImageItems.sort { (a, b) -> Bool in
            return a.timestamp < b.timestamp
        }
    }
    func showGalleryImageViewer(identifier: String) {
        for x in chatImageItems {
            if x.identifier == identifier, let anIndex = chatImageItems.firstIndex(of: x) {
                showGalleryImageViewer(index: anIndex)
                break
            }
        }
    }
    func showGalleryImageViewer(index: Int = 0) {
        
        var anIndex = index
        if anIndex == 0, chatImageItems.count > 0 {
            anIndex = chatImageItems.count - 1
        }
        
        let frame = CGRect(x: 0, y: 0, width: 200, height: 24)
        let headerView = CounterView(frame: frame, currentIndex: anIndex, count: chatImageItems.count)
        let footerView = CounterView(frame: frame, currentIndex: anIndex, count: chatImageItems.count)
        
        let galleryViewController = GalleryViewController(startIndex: anIndex, itemsDataSource: self, itemsDelegate: self, displacedViewsDataSource: self, configuration: galleryConfiguration())
        galleryViewController.headerView = headerView
        galleryViewController.footerView = footerView
        galleryVC = galleryViewController
        
        galleryViewController.launchedCompletion = {
            print("LAUNCHED")
            if let aRightButton = self.imageViewerRightButton {
                aRightButton.removeTarget(galleryViewController, action: nil, for: .allEvents)
                aRightButton.setTitle("Share", for: .normal)
                aRightButton.setTitleColor(.gray, for: .normal)
                aRightButton.addTarget(self,
                                       action: #selector(self.fileDownButtonTapped(_:)),
                                       for: .touchUpInside)
            }
            if let aLeftButton = self.imageViewerLeftButton {
                aLeftButton.center = CGPoint(x: 20, y: 20)
                aLeftButton.removeTarget(galleryViewController, action: nil, for: .allEvents)
                aLeftButton.setTitle("Close", for: .normal)
                aLeftButton.setTitleColor(.gray, for: .normal)
                aLeftButton.addTarget(self,
                                       action: #selector(self.backButtonTapped(_:)),
                                       for: .touchUpInside)
                galleryViewController.view.addSubview(aLeftButton)
            }
        }
        galleryViewController.closedCompletion = { print("CLOSED") }
        galleryViewController.swipedToDismissCompletion = { print("SWIPE-DISMISSED") }
        galleryViewController.landedPageAtIndexCompletion = { index in
            print("LANDED AT INDEX: \(index)")
            self.selectedImage = self.chatImageItems[index].imageView.image
            
            // headerView.count = self.chatImageItems.count
            // headerView.currentIndex = index

            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "MMM. d, h:mm a"

            headerView.countLabel.text = "\(Date(timeIntervalSince1970: TimeInterval(self.chatImageItems[index].timestamp)))"
            headerView.isHidden = false // by Henry on 2020.05.13
            footerView.count = self.chatImageItems.count
            footerView.currentIndex = index
        }
        self.presentImageGallery(galleryViewController)
    }
    
    func galleryConfiguration() -> GalleryConfiguration {
        if imageViewerRightButton == nil {
            imageViewerRightButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
        }
        if imageViewerLeftButton == nil {
            imageViewerLeftButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
        }
        return [
            GalleryConfigurationItem.closeButtonMode(.custom(imageViewerRightButton!)),
            GalleryConfigurationItem.deleteButtonMode(.none),
            GalleryConfigurationItem.seeAllCloseButtonMode(.none),
            GalleryConfigurationItem.thumbnailsButtonMode(.custom(imageViewerLeftButton!)),

            GalleryConfigurationItem.pagingMode(.standard),
            GalleryConfigurationItem.presentationStyle(.displacement),
            GalleryConfigurationItem.hideDecorationViewsOnLaunch(false),
            
            GalleryConfigurationItem.swipeToDismissMode(.vertical),
            GalleryConfigurationItem.toggleDecorationViewsBySingleTap(true),
            GalleryConfigurationItem.activityViewByLongPress(true),
                        
            GalleryConfigurationItem.overlayColor(UIColor(white: 238/255, alpha: 1)),
            GalleryConfigurationItem.overlayColorOpacity(1),
            GalleryConfigurationItem.overlayBlurOpacity(1),
            GalleryConfigurationItem.overlayBlurStyle(UIBlurEffect.Style.light),
            
            GalleryConfigurationItem.videoControlsColor(.white),
            
            GalleryConfigurationItem.maximumZoomScale(8),
            GalleryConfigurationItem.swipeToDismissThresholdVelocity(300),//(500),
            
            GalleryConfigurationItem.doubleTapToZoomDuration(0.15),
            
            GalleryConfigurationItem.blurPresentDuration(0.5),
            GalleryConfigurationItem.blurPresentDelay(0),
            GalleryConfigurationItem.colorPresentDuration(0.25),
            GalleryConfigurationItem.colorPresentDelay(0),
            
            GalleryConfigurationItem.blurDismissDuration(0.1),
            GalleryConfigurationItem.blurDismissDelay(0.4),
            GalleryConfigurationItem.colorDismissDuration(0.45),
            GalleryConfigurationItem.colorDismissDelay(0),
            
            GalleryConfigurationItem.itemFadeDuration(0.3),
            GalleryConfigurationItem.decorationViewsFadeDuration(0.15),
            GalleryConfigurationItem.rotationDuration(0.15),
            
            GalleryConfigurationItem.displacementDuration(0.55),
            GalleryConfigurationItem.reverseDisplacementDuration(0.25),
            GalleryConfigurationItem.displacementTransitionStyle(.springBounce(0.7)),
            GalleryConfigurationItem.displacementTimingCurve(.linear),
            
            GalleryConfigurationItem.statusBarHidden(true),
            GalleryConfigurationItem.displacementKeepOriginalInPlace(false),
            GalleryConfigurationItem.displacementInsetMargin(50),
            
            GalleryConfigurationItem.rotationMode(.applicationBased)
        ]
    }
}


extension ExampleViewController: GalleryDisplacedViewsDataSource {
    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {
        return index < chatImageItems.count ? chatImageItems[index].imageView : nil
    }
}
extension ExampleViewController: GalleryItemsDataSource {
    func itemCount() -> Int {
        return chatImageItems.count
    }
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return chatImageItems[index].galleryItem
    }
}
extension ExampleViewController: GalleryItemsDelegate {
    func removeGalleryItem(at index: Int) {
        print("remove item at \(index)")
        let imageView = chatImageItems[index].imageView
        imageView.removeFromSuperview()
        chatImageItems.remove(at: index)
    }
}


// MARK: - OZChattingUI choosing image, camera, file here
extension ExampleViewController: OZChoosePopupDelegate {
    func chooseButtonClick(_ sender: Any, type: OZChooseContentType) {
        guard let cvc = chatViewController else { return }
        switch type {
        case .album:
            cvc.showImagePicker(source: .photoLibrary)
        case .camera:
            self.handleCameraPermission()
        case .file:
            if #available(iOS 11.0, *) {
                let aDocVC = UIDocumentBrowserViewController(forOpeningFilesWithContentTypes: ["public.mp3"])
                aDocVC.delegate = self
                aDocVC.allowsPickingMultipleItems = false
                if #available(iOS 13.0, *) {
                    self.present(aDocVC, animated: true)
                }
                else {
                    let nc = UINavigationController(rootViewController: aDocVC)
                    nc.navigationBar.isHidden = false
                    nc.isNavigationBarHidden = false
                    self.present(nc, animated: true) {
                        let aBarButton = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(self.closeDocumentViewController))
                        aBarButton.tintColor = .black
                        aDocVC.navigationItem.setRightBarButton(aBarButton, animated: true)
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        default:
            print("OZChoosePopupDelegate: default choosed")
        }

        cvc.addFileButtonToggle(false)
    }
    
    func handleCameraPermission() {
        guard let cvc = chatViewController else { return }
        func handleRequestCompletion(_ granted: Bool) { if granted { DispatchQueue.main.async { cvc.showCamera() } } }
        
        switch cvc.checkCameraPermission(requestCompletion: handleRequestCompletion) {
        case .denied, .restricted:  showNeedCameraPermissionAlert()
        case .authorized:           cvc.showCamera()
        case .notDetermined:        ()
        @unknown default:           ()
        }
    }
    
    func showNeedCameraPermissionAlert() {
        let alert = UIAlertController(title: nil, message: "Camera(video) access denied", preferredStyle: .alert)
        if let settings = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settings) {
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
                
                UIApplication.shared.open(settings)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
        })
        present(alert, animated: true)
    }
}
