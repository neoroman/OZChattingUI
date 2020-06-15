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
    
    var isFromStoryboard = false
    
    /// ImageViewer
    var galleryVC: GalleryViewController?
    var chatImageItems: [DataItem] = []
    var selectedImage: UIImage?
    var imageViewerRightButton: UIButton?
    var imageViewerLeftButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isFromStoryboard {
            view.backgroundColor = .groupTableViewBackground
        }

        self.delegate = self
        self.messagesConfigurations = addMessageConfiguration()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.testChats(vc: self)            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .red
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.view.backgroundColor = .red

        DispatchQueue.main.asyncAfter(deadline: .now()+0.35) {
            if self.isViewLoaded, !self.collectionView.hasReloaded  {
                self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 12, bottom: 60, right: 12)
                self.collectionView.reloadData()
            }
        }
    }


    fileprivate func testChats(vc: OZMessagesViewController) {
        // Debug
        vc.isEchoMode = true
        
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
        DispatchQueue.main.asyncAfter(deadline: .now()+0.4) {
            for i in 1...6 {
                vc.send(msg: "\(i)", type: .image)
            }
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
                //vc.send(msg: "Delivered", type: .status, isDeliveredMsg: true)
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

        var configs: [OZMessagesConfigurationItem] = [
            // OZMessageCell
            OZMessagesConfigurationItem.audioProgressColor(.systemPink, .none),
            OZMessagesConfigurationItem.bubbleBackgroundColor(UIColor.red.withAlphaComponent(0.7), .fromCurrent),
            OZMessagesConfigurationItem.bubbleBackgroundColor(UIColor.blue.withAlphaComponent(0.6), .fromOther),
            OZMessagesConfigurationItem.canMessageSelectableByLongPressGesture(true),
            OZMessagesConfigurationItem.cellBackgroundColor(UIColor.green.withAlphaComponent(0.5), [.voice, .mp3]),
            OZMessagesConfigurationItem.cellPadding(15, [.text]),
            OZMessagesConfigurationItem.cellPadding(3, [.emoticon]),
            OZMessagesConfigurationItem.chatEmoticonSize(CGSize(width: 83, height: 83)),
            OZMessagesConfigurationItem.chatImageSize(CGSize(width: 80, height: 100), 7, CGSize(width: 400, height: 400)),
            OZMessagesConfigurationItem.fontColor(.black, [.voice, .mp3], .none),
            OZMessagesConfigurationItem.fontColor(.white, [.text], .fromOther),
            OZMessagesConfigurationItem.fontSize(16.0, [.text, .deviceStatus]),
            OZMessagesConfigurationItem.fontName("AppleSDGothicNeo-Bold", OZMessageType.allTypes()),
            OZMessagesConfigurationItem.profileIconName("Elizaveta Dushechkina", [.text, .mp3, .voice, .image, .emoticon], .fromOther),
            OZMessagesConfigurationItem.profileIconSize(38, OZMessageType.allTypes(), 8),
            OZMessagesConfigurationItem.profileIconSize(30, [.deviceStatus], 10),
            OZMessagesConfigurationItem.roundedCorner(true, [.announcement]),
            OZMessagesConfigurationItem.showTimeLabelForImage(true),
            OZMessagesConfigurationItem.usingPackedImages(true, false),
            OZMessagesConfigurationItem.usingLongMessageFolding(false, 108, foldingButtonSize, .right, .center),
            OZMessagesConfigurationItem.usingLongMessageFoldingButtons(foldButton, unfoldButton),

            // OZMessagesViewController
            OZMessagesConfigurationItem.collectionViewEdgeInsets(UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)),
            OZMessagesConfigurationItem.inputBoxEmoticonButtonTintColor(.systemGray, .systemOrange),
            OZMessagesConfigurationItem.inputBoxMicButtonTintColor(.systemGray, .systemPink),
            OZMessagesConfigurationItem.inputBoxFileButtonTintColor(.systemGray, .systemTeal),
            OZMessagesConfigurationItem.inputBoxFileButtonTintColor(.systemGreen, .systemRed),
            OZMessagesConfigurationItem.inputBoxEmoticonButtonTintColor(.systemGreen, .systemRed),

            // OZTextView
            OZMessagesConfigurationItem.inputTextViewFont(UIFont.boldSystemFont(ofSize: 18)),
            OZMessagesConfigurationItem.inputTextUsingEnterToSend(false),
            OZMessagesConfigurationItem.inputTextViewFontColor(.black),

            // OZEmoticonViewController
            OZMessagesConfigurationItem.emoticonPageIndicatorTintColor(UIColor.magenta.withAlphaComponent(0.3)),
            OZMessagesConfigurationItem.emoticonCurrentPageIndicatorTintColor(UIColor.magenta),

            // OZVoiceRecordViewController
            OZMessagesConfigurationItem.voiceRecordMaxDuration(12.0),
        ]
        
        if !isFromStoryboard {
            configs.append(OZMessagesConfigurationItem.profileIconName("Elizaveta Dushechkina", [.text, .mp3, .voice, .image, .emoticon], .fromCurrent))
            configs.append(OZMessagesConfigurationItem.usingPackedImages(false, false))
        }
        
        return configs
    }
}


extension ExampleViewController: OZMessagesViewControllerDelegate {
    func messageCellTapped(cell: OZMessageCell, index: Int, complete: @escaping OZChatTapCompleteBlock) {
        print("messageCellTapped => index(\(index)), cell(\(cell))")
        
        // Do someting here and callback to OZChattingUI
        if let audioCell = cell as? AudioMessageCell {
            if let aPath = audioCell.message.extra["filePath"] as? String, aPath.count > 0 {
                complete(true, aPath)
            }
            else {
                audioCell.preparePlay(file: "")
                if let aPath = Bundle.main.path(forResource: "test", ofType: "mp3") {
                    DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                        complete(true, aPath)
                    }
                }
            }
        }
        else if let imageCell = cell as? ImageMessageCell {
            if imageCell.message.type == .emoticon {
                // It's emoticon
                return
            }
            selectedImage = imageCell.imageView.image
            makeGalleryItemsFromAllMessages()
            showGalleryImageViewer(identifier: imageCell.message.identifier)
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
    func messageConfiguration(viewController: OZMessagesViewController) -> OZMessagesConfigurations {
        return addMessageConfiguration()
    }

    // View Related
    func messageCellDidSetMessage(cell: OZMessageCell, previousMessage: OZMessage) {
        if cell.message.type == .text {
            if let textCell = cell as? TextMessageCell {
                textCell.textLabel.type = .basic
            }
        }
    }
    
    func messageCellLayoutSubviews(cell: OZMessageCell, previousMessage: OZMessage, nextMessage: OZMessage?) {
        
        if let imageCell = cell as? ImageMessageCell,
            imageCell.iconImage.image != nil,
            imageCell.message.usingPackedImages {
            
            let maxWidth = collectionView.contentSize.width
            let cellFrame = cell.frame
            let lastFrame = OZMessageCell.frameForMessage(previousMessage, containerWidth: maxWidth)
            if previousMessage.type == .image,
                imageCell.message.alignment == previousMessage.alignment {
                
                if imageCell.message.alignment == .left,
                    cellFrame.minX >= lastFrame.maxX,
                    lastFrame.maxX + cellFrame.width + 2 < maxWidth {
                    imageCell.iconImage.isHidden = true
                    let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    imageCell.imageView.frame = imageCell.bounds.inset(by: inset)
                } else if imageCell.message.alignment == .right,
                    cellFrame.maxX <= view.bounds.maxX - lastFrame.width,
                    lastFrame.minX - cellFrame.width - 2 > 0 {
                    imageCell.iconImage.isHidden = true
                    let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    imageCell.imageView.frame = imageCell.bounds.inset(by: inset)
                }
                else {
                    imageCell.iconImage.isHidden = true
                }
            }
            else {
                imageCell.iconImage.isHidden = false
            }
            if let nm = nextMessage, nm.type == .image {
                imageCell.timeLabel.isHidden = true
            }
            else {
                imageCell.timeLabel.isHidden = false
            }
            imageCell.layoutIfNeeded()
        }
    }
    
    func messageViewLoaded(isLoaded: Bool) {
        print("messageViewLoaded...!")
    }
    
    
    func messageTextViewBeginEditing(textView: UITextView) {
        if let ozmb = ozMicButton,
            let aText = textView.text, aText.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
            ozmb.setImage(UIImage(named: "send"), for: .normal)
            ozmb.tag = kSendButtonTag
        }
    }
    func messageTextViewDidChanged(textView: UITextView) {
        guard let ozmb = ozMicButton else { return }

        if let aText = textView.text, aText.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
            ozmb.setImage(UIImage(named: "send"), for: .normal)
            ozmb.tag = kSendButtonTag
        }
        else {
            ozmb.setImage(UIImage(named: "mic"), for: .normal)
            ozmb.tag = kMicButtonTag
        }
    }
    func messageTextViewEndEditing(textView: UITextView) {
        guard let ozmb = ozMicButton else { return }

        if let aText = textView.text, aText.trimmingCharacters(in: .whitespacesAndNewlines).count <= 0 {
            ozmb.setImage(UIImage(named: "mic"), for: .normal)
            ozmb.tag = kMicButtonTag
        }
    }
    func messageMicWillRequestRecordPermission(viewController: OZVoiceRecordViewController) {
        // Do something here just before record permission granted
    }
    func messageMicButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool {

        guard let ozitv = viewController.ozInputTextView else { return false }
        if let button = sender as? UIButton, button.tag == kSendButtonTag,
            let fullText = ozitv.text {

            let trimmed = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.count > 0 {
                viewController.send(msg: trimmed)
            }
            
            ozitv.text = ""
            viewController.adjustTextViewHeight(ozitv)
            
            if let ozmb = viewController.ozMicButton {
                ozmb.setImage(UIImage(named: "mic"), for: .normal)
                ozmb.tag = kMicButtonTag
            }
            return false
        }
        return true
    }
    func messageEmoticonButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool {
        return true
    }
    func messageFileButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool {
        let alert: UIAlertController = UIAlertController(title: "Choose file", message: "", preferredStyle: .actionSheet)
        
        var actions: [UIAlertAction] = []
        actions.append(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            self.handleCameraPermission()
        }))
        actions.append(UIAlertAction(title: "Album", style: .default, handler: { (action) in
            self.showImagePicker(source: .photoLibrary)
        }))
        actions.append(UIAlertAction(title: "MP3 File", style: .default, handler: { (action) in
            let aDocVC = UIDocumentPickerViewController(documentTypes: ["public.mp3"], in: .import)
            aDocVC.delegate = self
            self.present(aDocVC, animated: true) {
            }
        }))

        for anAct in actions {
            alert.addAction(anAct)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            print("Cancel has been choosed...!")
        }
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true) {
            // code
        }

        return false
    }
}

// MARK: - UIDocumentPickerDelegate
extension ExampleViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        saveFile(url: url)
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let sourceURL = urls.first else { return }
        saveFile(url: sourceURL)
    }
    
    func saveFile(url: URL) {
        if let aData = FileManager.default.contents(atPath: url.relativePath) {
            let aPath = String.audioFileSave(aData)
            self.send(msg: aPath, type: .mp3, isDeliveredMsg: false, callback: { (identifier, path) in
                if let window = UIApplication.shared.keyWindow,
                    let rootVC = window.rootViewController,
                    let rvc = rootVC as? UINavigationController,
                    let chatVC = (rvc.viewControllers.filter{$0 is ExampleViewController}).first {
                    if let lastVC = chatVC.presentingViewController {
                        lastVC.dismiss(animated: true, completion: nil)
                    }
                    else if let lastVC = chatVC.presentedViewController {
                        lastVC.dismiss(animated: true, completion: nil)
                    }
                }
            })
        }
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
            
            if let imgCell = self.collectionView.cell(at: dataIndex) as? ImageMessageCell,
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
        
        let frame = CGRect(x: 0, y: 0, width: 200, height: 24)
        let headerView = CounterView(frame: frame, currentIndex: index, count: chatImageItems.count)
        let footerView = CounterView(frame: frame, currentIndex: index, count: chatImageItems.count)
        
        let galleryViewController = GalleryViewController(startIndex: index, itemsDataSource: self, itemsDelegate: self, displacedViewsDataSource: self, configuration: galleryConfiguration())
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

