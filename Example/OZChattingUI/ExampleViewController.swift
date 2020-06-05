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

fileprivate let kMicButtonTag = 17172008
fileprivate let kSendButtonTag = kMicButtonTag + 1004

class ExampleViewController: OZMessagesViewController {
    
    var galleryVC: GalleryViewController?
    var chatImageItems: [DataItem] = []
    var selectedImage: UIImage?
    var imageViewerRightButton: UIButton?
    var imageViewerLeftButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.delegate = self
        self.fileChoosePopupDelegate = self
        self.messagesConfigurations = addMessageConfiguration()

        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.testChats(vc: self)
        }
    }

    fileprivate func testChats(vc: OZMessagesViewController) {
        // Debug
        vc.isEchoMode = true
        vc.userProfilePath = Bundle.main.path(forResource: "TaylorSwift", ofType: "jpg")
        
        // Message send and receive
        vc.send(msg: "\(Date())", type: .announcement)
        vc.receive(msg: "Welcome to OZChattingUI", type: .text, timestamp: 0, profileIconPath: "TaylorSwift.jpg")

        let aTimestamp = Int(Date().timeIntervalSince1970)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            vc.receive(msg: "Sally called with you for 11minutes.", type: .deviceStatus, activeType: .call, timestamp: aTimestamp-600)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            vc.receive(msg: "test.mp3", type: .mp3, activeType: nil, timestamp: aTimestamp-400, profileIconPath: "TaylorSwift.jpg")
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            vc.receive(msg: "Viviana joined special event.", type: .deviceStatus, activeType: .campaign, timestamp: aTimestamp-300)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            vc.receive(msg: "Watch off", type: .deviceStatus, activeType: .watchOff, timestamp: aTimestamp-100)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.6) {
            vc.receive(msg: "Seal walked 1,004 steps, burned 14kcal", type: .deviceStatus, activeType: .step, timestamp: aTimestamp-50)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            vc.send(msg: "Hi... OZChattingUI!", type: .text) { (id, content) in
                vc.dataSource.data.removeAll(where: { $0.content == "Delivered" })
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

    
    fileprivate func addMessageConfiguration() -> OZMessagesConfigurations {
        let foldingButtonSize: CGSize = CGSize(width: 200, height: 30)
        let foldButton = UIButton(type: .custom)
        foldButton.frame = CGRect(origin: .zero, size: foldingButtonSize)
        foldButton.setImage(UIImage(named: "btnCallClose"), for: .normal)
        foldButton.setTitle("Fold Messages", for: .normal)
        foldButton.setTitleColor(UIColor(white: 74/255, alpha: 0.7), for: .normal)
        let unfoldButton = UIButton(type: .custom)
        unfoldButton.frame = CGRect(origin: .zero, size: foldingButtonSize)
        unfoldButton.setImage(UIImage(named: "iconViewAll"), for: .normal)
        unfoldButton.setTitle("Unfold Message", for: .normal)
        unfoldButton.setTitleColor(UIColor(white: 74/255, alpha: 0.7), for: .normal)

        return [
            // OZMessageCell
            OZMessagesConfigurationItem.fontSize(16.0, [.text, .deviceStatus]),
            OZMessagesConfigurationItem.roundedCorner(true, [.announcement]),
            OZMessagesConfigurationItem.bubbleBackgroundColor(UIColor.red.withAlphaComponent(0.7), .fromCurrent),
            OZMessagesConfigurationItem.bubbleBackgroundColor(UIColor.blue.withAlphaComponent(0.6), .fromOther),
            OZMessagesConfigurationItem.fontName("AppleSDGothicNeo-Bold", OZMessageType.allTypes()),
            OZMessagesConfigurationItem.fontColor(.white, [.text], .fromOther),
            OZMessagesConfigurationItem.emoticonPageIndicatorTintColor(UIColor.cyan.withAlphaComponent(0.3)),
            OZMessagesConfigurationItem.emoticonCurrentPageIndicatorTintColor(UIColor.cyan),
            OZMessagesConfigurationItem.usingPackedImages(false),
            OZMessagesConfigurationItem.showTimeLabelForImage(true),
            OZMessagesConfigurationItem.chatImageSize(CGSize(width: 240, height: 160), CGSize(width: 400, height: 400)),
            OZMessagesConfigurationItem.usingLongMessageFolding(true, 108, foldingButtonSize, .right, .center),
            OZMessagesConfigurationItem.usingLongMessageFoldingButtons(foldButton, unfoldButton),
            OZMessagesConfigurationItem.canMessageSelectableByLongPressGesture(true),

            // OZMessagesViewController
            OZMessagesConfigurationItem.inputBoxEmoticonButtonTintColor(.systemGray, .systemOrange),
            OZMessagesConfigurationItem.inputBoxMicButtonTintColor(.systemGray, .systemPink),
            OZMessagesConfigurationItem.inputBoxFileButtonTintColor(.systemGray, .systemTeal),
            OZMessagesConfigurationItem.addFileButtonItems([.camera, .album]),
            // OZTextView
            OZMessagesConfigurationItem.inputTextViewFont(UIFont.boldSystemFont(ofSize: 18)),
            OZMessagesConfigurationItem.inputTextUsingEnterToSend(false),
            OZMessagesConfigurationItem.inputTextViewFontColor(.black),
            // OZVoiceRecordViewController
            OZMessagesConfigurationItem.voiceRecordMaxDuration(12.0),
        ]
    }
}


extension ExampleViewController: OZMessagesViewControllerDelegate {
    func messageCellTapped(cell: OZMessageCell, index: Int, complete: @escaping OZChatTapCompleteBlock) {
        print("messageCellTapped => index(\(index)), cell(\(cell))")
        
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
    
    func messageSending(identifier: String, type: OZMessageType, data: OZMessage) -> Bool {
        print("messageSending(id:\(identifier)):::::Sending(Type: \(type)) ==> contentPath: \(data.content)")
            
        // Delivered message here
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.dataSource.data.removeAll(where: { $0.content == "Delivered" })
            self.send(msg: "Delivered", type: .status)
        }
        
        return true
    }
    
    // View Related
    func messageCellDidSetMessage(cell: OZMessageCell, previousMessage: OZMessage) {
        if cell.message.type == .text {
            if let incomingCell = cell as? IncomingTextMessageCell {
                incomingCell.textLabel.type = .basic
            }
            else if let outgoingCell = cell as? OutgoingTextMessageCell {
                outgoingCell.textLabel.type = .basic
            }
        }
        //        cell.setNeedsLayout()
        //        if cell.message.type == .text || cell.message.type == .image {
        //            cell.layer.shadowOffset = CGSize(width: 5, height: 5)
        //            cell.layer.shadowOpacity = 0.05
        //            cell.layer.shadowRadius = 5
        //            cell.layer.shadowColor = cell.message.shadowColor.cgColor
        //            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.layer.cornerRadius).cgPath
        //        }
    }
    
    func messageCellLayoutSubviews(cell: OZMessageCell, previousMessage: OZMessage) {
        if cell.message.alignment == .left {
            switch cell.message.type {
            case .text:
                guard let incomingCell = cell as? IncomingTextMessageCell else { return }
                incomingCell.iconImage.isHidden = true
                let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                incomingCell.textLabel.frame = incomingCell.bounds.inset(by: inset)
            case .image, .emoticon:
                guard let incomingCell = cell as? ImageMessageCell else { return }
                incomingCell.iconImage.isHidden = true
                let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                incomingCell.imageView.frame = incomingCell.bounds.inset(by: inset)
            case .voice, .mp3:
                guard let incomingCell = cell as? AudioPlusIconMessageCell else { return }
                incomingCell.iconImage.isHidden = true
                let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                incomingCell.backView.frame = incomingCell.bounds.inset(by: inset)
            default:
                print(".....\(cell.message.type), prevMsg(\(String(describing: previousMessage))).....")
            }
        }
    }
    
    func messageViewLoaded(isLoaded: Bool) {
        print("messageViewLoaded...!")
    }
    
    
    func messageTextViewBeginEditing(textView: UITextView) {
        if let aText = textView.text, aText.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
            self.micButton.setImage(UIImage(named: "send"), for: .normal)
            self.micButton.tag = kSendButtonTag
        }
    }
    func messageTextViewDidChanged(textView: UITextView) {
        if let aText = textView.text, aText.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
            self.micButton.setImage(UIImage(named: "send"), for: .normal)
            self.micButton.tag = kSendButtonTag
        }
        else {
            self.micButton.setImage(UIImage(named: "mic"), for: .normal)
            self.micButton.tag = kMicButtonTag
        }
    }
    func messageTextViewEndEditing(textView: UITextView) {
        if let aText = textView.text, aText.trimmingCharacters(in: .whitespacesAndNewlines).count <= 0 {
            self.micButton.setImage(UIImage(named: "mic"), for: .normal)
            self.micButton.tag = kMicButtonTag
        }
    }
    func messageMicWillRequestRecordPermission(viewController: OZVoiceRecordViewController) {
        // Do something here just before record permission granted
    }
    func messageMicButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool {
        if let button = sender as? UIButton, button.tag == kSendButtonTag,
            let fullText = viewController.inputTextView.text {
            
            let trimmed = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.count > 0 {
                viewController.send(msg: trimmed)
            }
            
            viewController.inputTextView.text = ""
            viewController.adjustTextViewHeight(viewController.inputTextView)
            
            viewController.micButton.setImage(UIImage(named: "mic"), for: .normal)
            viewController.micButton.tag = kMicButtonTag
            return false
        }
        return true
    }
    func messageEmoticonButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool {
        return true
    }
    func messageFileButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool {
        return true
    }
    func messageConfiguration(viewController: OZMessagesViewController) -> OZMessagesConfigurations {
        return addMessageConfiguration()
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
        for x in self.dataSource.data {
            if x.type == .emoticon { continue }
            guard let dataIndex = self.dataSource.data.firstIndex(of: x) else { continue }
            
            if x.content.hasPrefix("/") {
                makeGalleryItems(path: x.content, data: x)
            }
            else if let imgCell = self.collectionView.cell(at: dataIndex) as? ImageMessageCell,
                x.type == .image {
                
                makeGalleryItems(cell: imgCell)
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

