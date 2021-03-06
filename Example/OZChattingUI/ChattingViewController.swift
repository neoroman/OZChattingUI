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
//  ChattingViewController.swift
//  OZChattingUI_Example
//
//  Created by 이재은 on 2020/05/28.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit
import Photos

import OZChattingUI
import ImageViewer

class ChattingViewController: OZMessagesViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var keyboardButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var micMotionButton: UIButton!
    @IBOutlet weak var micCircleView: UIView?
    @IBOutlet weak var loadingImageView: UIImageView!
    
    // MARK: - Property
    var sendingTimerCount: TimeInterval = 0
    var imagePaths: [URL]?
    var isHalfOpacity: Bool = false
    var isCustomFrame: Bool = false
    var receiveTimer: Timer?
    var receiveCount: Int = 0
    
    // MARK: - ImageViewer
    var galleryVC: GalleryViewController?
    var chatImageItems: [DataItem] = []
    var selectedImage: UIImage?
    var imageViewerRightButton: UIButton?
    var imageViewerLeftButton: UIButton?

    // MARK: - Life Cycle
    override func viewDidLoad() {
        // Important !!!, we need to set delegate before calling super.viewDidLoad()
        self.delegate = self

        super.viewDidLoad()
        
        self.messagesConfigurations = addMessageConfiguration()
        
        setUI()
        setDefaultState()
                
        let configuredTestMessages = testMessages.map{ $0.copy(messagesConfigurations, userSide: nil) }
        self.setupDataProvider(newDataSource: OZMessageDataProvider.init(data: configuredTestMessages))
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.isEchoMode = true
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = kMainColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.view.backgroundColor = kMainColor

        DispatchQueue.main.asyncAfter(deadline: .now()+0.35) {
            if self.isViewLoaded, !self.collectionView.hasReloaded {
                self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 12, bottom: 60, right: 12)
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let timer = self.receiveTimer {
            timer.invalidate()
        }
    }

    // MARK: - Targets and Actions
    @objc func switchTapped() {
        isHalfOpacity.toggle()
        
        if isHalfOpacity {
            self.messagesConfigurations.append(OZMessagesConfigurationItem.cellOpacity(0.5, OZMessageType.allTypes()))
            self.collectionView.reloadData()
        }
        else {
            self.messagesConfigurations.append(OZMessagesConfigurationItem.cellOpacity(1.0, OZMessageType.allTypes()))
            self.collectionView.reloadData()
        }
    }
    
    /// Button for sendign message
    @IBAction func pressedSendButton(_ sender: UIButton) {
        guard let ozitv = ozInputTextView else { return }
        
        if let fullText = ozitv.text {
            let trimmed = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.count > 0 {
                rotateLoadingImage(3)
                send(msg: trimmed)                
            }
            ozitv.text.removeAll()
            adjustTextViewHeight(ozitv)
        }
    }
    
    /// Change keyboard input mode
    @IBAction func pressedKeyboardButton(_ sender: UIButton) {
        guard let ozitv = ozInputTextView else { return }

        setDefaultState()
        ozitv.becomeFirstResponder()
    }
    
    
    // MARK: - Function
    /// Set initial look
    fileprivate func setUI() {
        collectionView.backgroundColor = UIColor(red: 228/255, green: 232/255, blue: 232/255, alpha: 1.0)
        
        if let ozitv = ozInputTextView {
            ozitv.textContainerInset = UIEdgeInsets(top: 11, left: 14, bottom: 8, right: 40)
            ozitv.layer.cornerRadius = 12
            ozitv.layer.borderColor = UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 1).cgColor
            ozitv.layer.borderWidth = 1
            ozitv.backgroundColor = .white
            messageTextViewBeginEditing(textView: ozitv)
        }
        keyboardButton.tintColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
        
        
        if self.navigationController != nil {
            let item = UISwitch(frame: .zero)
            item.isOn = false
            if isCustomFrame {
                item.isOn = true
            }
            item.addTarget(self, action: #selector(switchTapped), for: [.touchDragInside, .touchUpInside])
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: item)
        }
        if isCustomFrame {
            switchTapped()
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                self.receiveTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { (timer) in
                    let randomTime = Int(arc4random_uniform(9))
                    let threshold = self.receiveCount % (randomTime > 0 ? randomTime : 1)
                    if threshold == 0, randomTime > 2 {
                        var array: [String] = []
                        while array.count < randomTime {
                            let num = arc4random_uniform(9)
                            var numString = "\(num)"
                            switch num {
                            case 7: numString = "l1"
                            case 8: numString = "l2"
                            case 9: numString = "l3"
                            default: break
                            }
                            if num > 0, !array.contains(numString) {
                                array.append(numString)
                            }
                        }
                        if randomTime % 2 == 0 {
                            self.send(msg: array.joined(separator: "|"), type: .multipleImages, isDeliveredMsg: false, isEchoable: false) { (id, path) in
                            }
                        }
                        else {
                            self.receive(msg: array.joined(separator: "|"), type: .multipleImages, activeType: nil, duration: 0, timestamp: 0, profileIconPath: nil)
                        }
                    }
                    self.receiveCount += 1
                    
                    if Double(self.receiveCount) - 100 >= Float64.infinity {
                        self.receiveCount = 0
                    }
                }
            }
        }
    }
    
    /// Set to default Views and Buttons
    fileprivate func setDefaultState() {
        if let ozitv = ozInputTextView {
            ozitv.textColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1)
            ozitv.tintColor = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1)
            ozitv.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
            ozitv.isEditable = true
            ozitv.text.removeAll()
            adjustTextViewHeight(ozitv)
        }
        
        sendButton.setImage(UIImage(named: "btnCallEnterOn"), for: .normal)
        sendButton.isHidden = false
        sendButton.isEnabled = false
        
        clearButton.isHidden = true
        micMotionButton.isHidden = true
        micCircleView?.isHidden = true
        loadingImageView.isHidden = true
        
        if let ozmb = ozMicButton {
            ozmb.isHidden = false
        }
        keyboardButton.isHidden = true
    }
            
    /// Show loading just before sending message
    @objc private func rotateLoadingImage(_ timeout: TimeInterval = 5) {
        sendButton.isEnabled = false
        sendButton.isHidden = true
        loadingImageView.isHidden = false
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { (timer) in
            self.sendingTimerCount += 1
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: { () -> Void in
                self.loadingImageView.transform = self.loadingImageView.transform.rotated(by: .pi / 2)
            })
            
            if self.sendingTimerCount >= timeout {
                timer.invalidate()
                self.sendingTimerCount = 0
                self.sendButton.isHidden = false
                self.loadingImageView.isHidden = true
                if let ozitv = self.ozInputTextView,
                    let aText = ozitv.text, aText.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
                    self.sendButton.isEnabled = true
                }
            }
        }
    }
    
    
    fileprivate func addMessageConfiguration() -> OZMessagesConfigurations {
        let foldingButtonSize = CGSize(width: 200, height: 30)
        let foldButton = UIButton(type: .custom)
        foldButton.frame = CGRect(origin: .zero, size: foldingButtonSize)
        foldButton.setImage(UIImage(named: "btnCallClose"), for: .normal)
        foldButton.setTitle("Fold", for: .normal)
        foldButton.setTitleColor(UIColor(white: 74/255, alpha: 0.7), for: .normal)
        let unfoldButton = UIButton(type: .custom)
        unfoldButton.frame = CGRect(origin: .zero, size: foldingButtonSize)
        unfoldButton.setImage(UIImage(named: "iconViewAll"), for: .normal)
        unfoldButton.setTitle("Unfold", for: .normal)
        unfoldButton.setTitleColor(UIColor(white: 74/255, alpha: 0.7), for: .normal)

        var configs = [
            // OZMessageCell
            OZMessagesConfigurationItem.audioProgressColor(.systemPink, .none),
            OZMessagesConfigurationItem.chatImageSize(CGSize(width: 100, height: 100), 10, CGSize(width: 800, height: 800)),
            OZMessagesConfigurationItem.fontSize(16.0, [.text, .deviceStatus]),
            OZMessagesConfigurationItem.fontColor(UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1), [.announcement], .none),
            OZMessagesConfigurationItem.cellBackgroundColor(UIColor(white: 204/255, alpha: 1), [.announcement]),
            OZMessagesConfigurationItem.cellBackgroundColor(.white, [.voice, .mp3]),
            OZMessagesConfigurationItem.roundedCorner(true, [.announcement]),
            OZMessagesConfigurationItem.sepratorColor(.clear),
            OZMessagesConfigurationItem.showTimeLabelForImage(true),
            OZMessagesConfigurationItem.timeFontSize(12.0),
            OZMessagesConfigurationItem.timeFontFormat("hh:mm a"),
            OZMessagesConfigurationItem.timeFontColor(UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)),
            OZMessagesConfigurationItem.usingLongMessageFolding(true, 108, foldingButtonSize, .center, .left),
            OZMessagesConfigurationItem.usingLongMessageFoldingButtons(foldButton, unfoldButton),
            OZMessagesConfigurationItem.usingPackedImages(true, false),
            OZMessagesConfigurationItem.multipleImages(4, 5, .white),
            OZMessagesConfigurationItem.canMessageSelectableByLongPressGesture(true),

            // OZMessagesViewController
            //OZMessagesConfigurationItem.autoScrollToBottomBeginTextInput(false, true),
            //OZMessagesConfigurationItem.autoScrollToBottomNewMessageArrived(false),
            OZMessagesConfigurationItem.autoScrollToBottomNewMessageArrived(true),
            OZMessagesConfigurationItem.collectionViewEdgeInsets(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)),
            OZMessagesConfigurationItem.inputBoxMicButtonTintColor(kMainColor, kMainColor),
            OZMessagesConfigurationItem.inputBoxFileButtonTintColor(kMainColor, kMainColor),
            OZMessagesConfigurationItem.inputContainerMinimumHeight(56),
            OZMessagesConfigurationItem.inputContainerMaximumHeight(56*3),
            //OZMessagesConfigurationItem.scrollToBottomButton(.zero, CGSize(width: 40, height: 40), 2, UIColor.white, UIColor.gray, 0.4),
            //OZMessagesConfigurationItem.scrollToBottomNewMessageBadge(true, "AppleSDGothicNeo-Medium", 14, 24, .white, .red),
            OZMessagesConfigurationItem.showTypingIndicator(true, 10, .gray),

            // OZTextView
            OZMessagesConfigurationItem.inputTextViewFont(UIFont.systemFont(ofSize: 16, weight: .light)),
            OZMessagesConfigurationItem.inputTextViewFontColor(UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1)),
            OZMessagesConfigurationItem.inputTextUsingEnterToSend(false),
            
            // OZVoiceRecordViewController
            OZMessagesConfigurationItem.voiceRecordMaxDuration(12.0, 0)
        ]
        
        if isCustomFrame {
            let rect = CGRect(x: 100, y: 0, width: 265, height: 100)
            configs.append(OZMessagesConfigurationItem.customCollectionViewFrame(true, rect, 1))
            configs.append(OZMessagesConfigurationItem.autoScrollToBottomNewMessageArrived(true))
        }
        
        return configs
    }
    

}

// MARK: - OZMessagesViewControllerDelegate
extension ChattingViewController: OZMessagesViewControllerDelegate {
    
    // Data Related
    func messageSending(identifier: String, type: OZMessageType, data: OZMessage) -> Bool {
        if !isCustomFrame {
            // Delivered message here
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.dataSource.data.removeAll(where: { $0.content == "Delivered" })
                self.send(msg: "Delivered", type: .status, isDeliveredMsg: true)
            }
        }
        isTyping = false
        return true
    }
    
    func messageAppend(complete: @escaping OZChatFetchCompleteBlock) {
        let configuredTestMessages = testMessages.map{ $0.copy(messagesConfigurations, userSide: nil) }
        complete(configuredTestMessages)
    }
    
    func messageCellTapped(cell: OZMessageCell, index: Int, complete: @escaping OZChatTapCompleteBlock) {
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
        else if let multiCell = cell as? MultipleImageMessageCell,
            let aLast = multiCell.imageViews.last {
            selectedImage = aLast.image
            let ids = multiCell.message.content.components(separatedBy: "|")
            makeGalleryItemsFromAllMessages(multiCell.imageViews, identifiers: ids)
            if let bLast = ids.last {
                showGalleryImageViewer(identifier: bLast)
            }
        }
    }
    func messageCellMultipleImageTapped(cell: OZMessageCell, image: UIImageView, indexOfImage: Int) -> Bool {
        if let multiCell = cell as? MultipleImageMessageCell {
            selectedImage = image.image
            let ids = multiCell.message.content.components(separatedBy: "|")
            makeGalleryItemsFromAllMessages(multiCell.imageViews, identifiers: ids)
            showGalleryImageViewer(identifier: ids[indexOfImage])
        }
        return true
    }
    
    // View Related
    func messageViewLoaded(isLoaded: Bool) {
        collectionView.scrollTo(edge: .bottom, animated: false)
    }
    func messageVerticalPaddingBetweenMessage(message: OZMessage, previousMessage: OZMessage) -> CGFloat {
        if message.type == .announcement {
            return 16
        }
        if previousMessage.type == .announcement {
            return 16.5
        }
        if message.type == .image || message.type == .multipleImages {
            return 9
        }
        if previousMessage.type == .image || previousMessage.type == .multipleImages {
            return 9
        }
        if message.type == .status {
            return 3
        }
        if message.type == .text, message.type == previousMessage.type,
            message.fromCurrentUser == previousMessage.fromCurrentUser {
            return 8
        }
        return 10
    }
    func messageCellDidSetMessage(cell: OZMessageCell, previousMessage: OZMessage) {
        
        if cell.message.type == .text {
                        
            if let textCell = cell as? TextMessageCell {
                textCell.textLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
                textCell.textLabel.layer.shadowOpacity = 0.04
                textCell.textLabel.layer.shadowRadius = 8
                textCell.textLabel.layer.shadowColor = UIColor.black.cgColor
                textCell.textLabel.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 12).cgPath

                textCell.timeLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
                textCell.timeLabel.layer.shadowOpacity = 0.1
                textCell.timeLabel.layer.shadowRadius = 2
                textCell.timeLabel.layer.shadowColor = UIColor.black.cgColor

                if !isCustomFrame, previousMessage.type == .text,
                    previousMessage.alignment == cell.message.alignment {
                    textCell.textLabel.type = .noDraw
                    textCell.textLabel.layer.cornerRadius = kBubbleRadius
                    textCell.textLabel.layer.masksToBounds = true
                    if textCell.message.alignment == .right {
                        textCell.textLabel.backgroundColor = UIColor(red: 0.000, green: 0.746, blue: 0.718, alpha: 1.000)
                    }
                    else {
                        textCell.textLabel.backgroundColor = .white
                    }
                }
                else {
                    textCell.textLabel.layer.cornerRadius = 0
                    textCell.textLabel.type = .hasOwnDrawing
                    textCell.textLabel.backgroundColor = .clear
                    if textCell.message.alignment == .right {
                        textCell.textLabel.outgoingColor = UIColor(red: 0.000, green: 0.746, blue: 0.718, alpha: 1.000)
                    }
                    else {
                        textCell.textLabel.incomingColor = .white
                    }
                }
            }
            cell.setNeedsLayout()
        }
    }
    
    func messageCellLayoutSubviews(cell: OZMessageCell, previousMessage: OZMessage, nextMessage: OZMessage?) {
        if cell.message.type == .text,
            let textCell = cell as? TextMessageCell {
            var inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            if previousMessage.type == .text,
                previousMessage.alignment == cell.message.alignment {
                if cell.message.alignment == .right {
                    inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: kNotchInsetX)
                }
                else if cell.message.alignment == .left {
                    inset = UIEdgeInsets(top: 0, left: kNotchInsetX, bottom: 0, right: 0)
                }
            }
            textCell.textLabel.frame = textCell.bounds.inset(by: inset)
        }
        else if cell.message.type == .image,
            let imageCell = cell as? ImageMessageCell,
            imageCell.message.usingPackedImages {
            // code
        }
    }
    

    func messageTextViewBeginEditing(textView: UITextView) {
        if let aText = textView.text, aText.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
            sendButton.isEnabled = true
        }
    }
    
    func messageTextViewDidChanged(textView: UITextView) {
        if let aText = textView.text, aText.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
            sendButton.isEnabled = true
            isTyping = true
        }
        else {
            sendButton.isEnabled = false
            isTyping = false
        }
    }
    
    func messageTextViewDidEnterPressed(textView: UITextView) {
        guard let ozitv = ozInputTextView else { return }
        
        if let fullText = ozitv.text {
            let trimmed = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.count > 0 {
                rotateLoadingImage(3)
                send(msg: trimmed)
            }
            ozitv.text.removeAll()
            adjustTextViewHeight(ozitv)
        }
    }
    
    func messageTextViewEndEditing(textView: UITextView) {
        if let aText = textView.text, aText.trimmingCharacters(in: .whitespacesAndNewlines).count <= 0 {
            sendButton.isEnabled = false
            isTyping = false
        }
    }
    
    func messageMicButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool {
        /// 음성 인식 상태로 전환
        setDefaultState()
        keyboardButton.isHidden = false
        if let ozmb = ozMicButton { ozmb.isHidden = true }
        sendButton.isHidden = true
        
        return false
    }
    
    func messageEmoticonButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool {
        return false
    }
    
    func messageConfiguration(viewController: OZMessagesViewController) -> OZMessagesConfigurations {
        return addMessageConfiguration()
    }
    
    func messageFileButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool {
        requestPhotoAuthorization()
        return false
    }
    
    fileprivate func requestPhotoAuthorization() {
        requestPhotoLibraryAuthorization { (result) in
            DispatchQueue.main.async {
                if result {
                    if let vc = UIStoryboard(name: "OZChattingUI2", bundle: Bundle.main).instantiateViewController(withIdentifier: "SelectPhotoViewController") as? SelectPhotoViewController {
                        self.navigationController?.pushViewController(vc, animated: true)
                        vc.delegate = self
                    }
                } else {
                    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                        if let settingUrl = URL(string: UIApplication.openSettingsURLString),
                            UIApplication.shared.canOpenURL(settingUrl) {
                            UIApplication.shared.open(settingUrl, options: [:], completionHandler: nil)
                        }
                    }
                    self.displayMessage("Need a grant to access gallery. Go to settings?", confirm: okAction, cancel: nil, preferredStyle: .alert)
                }
            }
        }
    }
    fileprivate func requestPhotoLibraryAuthorization(completionHandler: @escaping (_ isSuccess: Bool) -> Void) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            completionHandler(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                switch status {
                case .authorized:
                    completionHandler(true)
                default:
                    completionHandler(false)
                }
            }
        case .denied, .restricted:
            completionHandler(false)
        default:
            completionHandler(false)
            break
        }
    }

}

extension ChattingViewController: SelectPhotoDelegate {
    func sendImageData(_ paths: [URL]) {
        self.imagePaths = paths
        guard let imagePaths = imagePaths else { return }
        var iPaths: [String] = []
        for x in imagePaths {
            iPaths.append(x.relativePath)
        }
        let joinedPath = iPaths.joined(separator: "|")
        self.send(msg: joinedPath, type: .multipleImages, isDeliveredMsg: false) { (id, path) in
            //code
        }
    }
}


// MARK: - ImageViewer
extension ChattingViewController {
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
    func makeGalleryItemsFromAllMessages(_ imageViews: [UIImageView]? = nil, identifiers: [String]? = nil) {
        for x in self.dataSource.data {
            if x.type == .emoticon { continue }
            guard let dataIndex = self.dataSource.data.firstIndex(of: x) else { continue }
            
            if let imgCell = self.collectionView.cell(at: dataIndex) as? ImageMessageCell,
                x.type == .image {
                
                makeGalleryItems(cell: imgCell)
            }
        }
        if let ivs = imageViews, let ids = identifiers {
            let ts = Date().timeIntervalSince1970
            for i in 0..<ivs.count {
                var galleryItem: GalleryItem!
                
                guard let image = ivs[i].image else { return }
                galleryItem = GalleryItem.image { $0(image) }
                
                guard !chatImageItems.contains(where: {$0.identifier == ids[i]}) else { return }
                
                chatImageItems.append(DataItem(identifier: ids[i], timestamp: Int(ts), imageView: ivs[i], galleryItem: galleryItem))
            }
        }
    }
    func makeGalleryItems(cell: OZMessageCell) {
        guard let imgCell = cell as? ImageMessageCell else{ return }

        let imageView = imgCell.imageView
        var galleryItem: GalleryItem!
        
        guard let image = imageView.image else { return }
        galleryItem = GalleryItem.image { $0(image) }
        
        guard !chatImageItems.contains(where: { $0.identifier == imgCell.message.identifier }) else { return }
        
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
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "MMM. d, h:mm a"

            headerView.countLabel.text = "\(Date(timeIntervalSince1970: TimeInterval(self.chatImageItems[index].timestamp)))"
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


extension ChattingViewController: GalleryDisplacedViewsDataSource {
    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {
        return index < chatImageItems.count ? chatImageItems[index].imageView : nil
    }
}
extension ChattingViewController: GalleryItemsDataSource {
    func itemCount() -> Int {
        return chatImageItems.count
    }
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return chatImageItems[index].galleryItem
    }
}
extension ChattingViewController: GalleryItemsDelegate {
    func removeGalleryItem(at index: Int) {
        print("remove item at \(index)")
        let imageView = chatImageItems[index].imageView
        imageView.removeFromSuperview()
        chatImageItems.remove(at: index)
    }
}
