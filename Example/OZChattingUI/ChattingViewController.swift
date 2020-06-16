//
//  ChattingViewController.swift
//  OZChattingUI_Example
//
//  Created by 이재은 on 2020/05/28.
//  Copyright © 2020 CocoaPods. All rights reserved.
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
    var successToSend: Bool = true
    var needsToMic: Bool = false
    var stopLoading: Bool = false
    var sendingTimerCount: TimeInterval = 0
    var imagePaths: [URL]?
    var isHalfOpacity: Bool = false
    var isCustomFrame: Bool = false
    
    // MARK: - ImageViewer
    var galleryVC: GalleryViewController?
    var chatImageItems: [DataItem] = []
    var selectedImage: UIImage?
    var imageViewerRightButton: UIButton?
    var imageViewerLeftButton: UIButton?

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Important !!!
        self.delegate = self
        self.messagesConfigurations = addMessageConfiguration()
        
        setUI()
        setDefaultState()
//        if !needsToMic {
//            micButton.isHidden = true
//            keyboardButton.isHidden = true
//            micMotionButton.isHidden = true
//            expandInputView()
//        }
        
        let configuredTestMessages = testMessages.map{ $0.copy(messagesConfigurations, userSide: nil) }
        self.setupDataProvider(newDataSource: OZMessageDataProvider.init(data: configuredTestMessages))
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            //self.collectionView.scrollTo(edge: .bottom, animated: false)
            self.isEchoMode = true
        }
        if self.navigationController != nil {
            let item = UISwitch(frame: .zero)
            item.isOn = false
            item.addTarget(self, action: #selector(switchTapped), for: [.touchDragInside, .touchUpInside])
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: item)
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
    
    /// 메시지 전송
    @IBAction func pressedSendButton(_ sender: UIButton) {
        guard let ozitv = ozInputTextView else { return }
        
        if let fullText = ozitv.text {
            let trimmed = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.count > 0 {
                stopLoading = false
                rotateLoadingImage(3)
                send(msg: trimmed)                
            }
            ozitv.text.removeAll()
            adjustTextViewHeight(ozitv)
        }
//                        setFailToSending()
    }
    
    /// 텍스트 입력 상태로 전환
    @IBAction func pressedKeyboardButton(_ sender: UIButton) {
        guard let ozitv = ozInputTextView else { return }

        setDefaultState()
        ozitv.becomeFirstResponder()
    }
    
    /// 입력한 텍스트 삭제
    @IBAction func pressedClearButton(_ sender: UIButton) {
        setDefaultState()
    }
    
    ///
    @IBAction func pressedMicMotionButton(_ sender: UIButton) {
        
    }
    
    // MARK: - Function
    /// 최초 UI 설정
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
    }
    
    /// View, Button의 default 상태 설정
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
        
        successToSend = true // 임시
    }
    
    /// mic 기능 없는 inputView에 대한 설정
    fileprivate func expandInputView() {
        guard let ozitv = ozInputTextView, let ozmb = ozMicButton else { return }

        ozmb.isHidden = true
        ozitv.trailingAnchor.constraint(equalTo: ozmb.trailingAnchor).isActive = true
        sendButton.trailingAnchor.constraint(equalTo: ozmb.trailingAnchor).isActive = true
    }
    
    /// 메시지 전송 실패 뷰 설정
    fileprivate func setFailToSending() {
        guard let ozitv = ozInputTextView else { return }

        if successToSend {
            ozitv.text += "\nFail to send"
            let attr = NSMutableAttributedString(string: ozitv.text)
            attr.addAttribute(NSAttributedString.Key.foregroundColor,
                              value: UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1),
                              range: NSMakeRange(0, ozitv.text.count - 4))
            attr.addAttribute(NSAttributedString.Key.init(kCTFontAttributeName as String),
                              value: UIFont(name:"AppleSDGothicNeo-Regular", size: 16) as Any,
                              range: NSMakeRange(0, ozitv.text.count - 4))
            attr.addAttribute(NSAttributedString.Key.foregroundColor,
                              value: UIColor(red: 248/255, green: 72/255, blue: 94/255, alpha: 1),
                              range: (ozitv.text as NSString).range(of: "Fail to send"))
            attr.addAttribute(NSAttributedString.Key.init(kCTFontAttributeName as String),
                              value: UIFont(name:"AppleSDGothicNeo-Regular", size: 12) as Any,
                              range: (ozitv.text as NSString).range(of: "Fail to send"))
            
            ozitv.attributedText = attr
            successToSend = false
        }
        
        sendButton.setImage(UIImage(named: "btnCallCancel"), for: .normal)
        clearButton.isHidden = false
        ozitv.isEditable = false
        ozitv.tintColor = .clear
        adjustTextViewHeight(ozitv)
    }
    
    /// 음성 인식 가능한 상태 뷰 설정
    fileprivate func setSuccessToMic() {
        setMicGuideText("Speech recognizer not implemented.")
        micMotionButton.isHidden = false
        
        micCircleView?.isHidden = false
        micCircleView?.layer.cornerRadius = 15
        micCircleView?.clipsToBounds = true
        
        if let ozitv = ozInputTextView {
            ozitv.isEditable = false
        }
    }
    
    /// 음성 인식 불가한 상태 뷰 설정
    fileprivate func setFailToMic() {
        setMicGuideText("Cannot use microphone.")
        micMotionButton.isHidden = false
        micMotionButton.isEnabled = false
        sendButton.isHidden = true
        
        if let ozitv = ozInputTextView {
            ozitv.resignFirstResponder()
            ozitv.isEditable = false
        }
    }
    
    /// 마이크 상태에 대한 안내 문구 설정
    /// - Parameter text: 안내 문구 텍스트
    fileprivate func setMicGuideText(_ text: String) {
        if let ozitv = ozInputTextView {
            ozitv.text.removeAll()
            adjustTextViewHeight(ozitv)
            ozitv.text = text
            ozitv.font = UIFont(name:"AppleSDGothicNeo-Medium", size: 12)
            ozitv.textColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
        }
    }
    
    /// 메세지 전송시 로딩 표시
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
            OZMessagesConfigurationItem.timeFontFormat("hh:mm"),
            OZMessagesConfigurationItem.timeFontColor(UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)),
            OZMessagesConfigurationItem.usingLongMessageFolding(true, 108, foldingButtonSize, .center, .left),
            OZMessagesConfigurationItem.usingLongMessageFoldingButtons(foldButton, unfoldButton),
            OZMessagesConfigurationItem.usingPackedImages(true, false),

            // OZMessagesViewController
            OZMessagesConfigurationItem.autoScrollToBottomBeginTextInput(false, true),
            OZMessagesConfigurationItem.collectionViewEdgeInsets(UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)),
            OZMessagesConfigurationItem.inputBoxMicButtonTintColor(kMainColor, kMainColor),
            OZMessagesConfigurationItem.inputBoxFileButtonTintColor(kMainColor, kMainColor),
            OZMessagesConfigurationItem.inputContainerMinimumHeight(56),
            OZMessagesConfigurationItem.inputContainerMaximumHeight(56*3),
            OZMessagesConfigurationItem.scrollToBottomButton(.zero, CGSize(width: 40, height: 40), 5, UIColor.white.withAlphaComponent(0.6), UIColor.gray.withAlphaComponent(0.6), 0.5),

            // OZTextView
            OZMessagesConfigurationItem.inputTextViewFontColor(UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1)),
            OZMessagesConfigurationItem.inputTextUsingEnterToSend(false),
            
            // OZVoiceRecordViewController
            OZMessagesConfigurationItem.voiceRecordMaxDuration(12.0)
        ]
        
        if isCustomFrame {
            let rect = CGRect(x: 100, y: 0, width: 265, height: 100)
            configs.append(OZMessagesConfigurationItem.customCollectionViewFrame(true, rect, 1))
        }
        
        return configs
    }
    

}

// MARK: - OZMessagesViewControllerDelegate
extension ChattingViewController: OZMessagesViewControllerDelegate {
    
    // Data Related
    func messageSending(identifier: String, type: OZMessageType, data: OZMessage) -> Bool {
        // Delivered message here
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.dataSource.data.removeAll(where: { $0.content == "Delivered" })
            self.send(msg: "Delivered", type: .status, isDeliveredMsg: true)
        }
        return true
    }
    
    func messageAppend(complete: @escaping OZChatFetchCompleteBlock) {
        // code
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
        else if let multiCell = cell as? MultipleImageMessageCell {
            if let aLast = multiCell.imageViews.last {
                selectedImage = aLast.image
                let ids = multiCell.message.content.components(separatedBy: "|")
                makeGalleryItemsFromAllMessages(multiCell.imageViews, identifiers: ids)
                if let bLast = ids.last {
                    showGalleryImageViewer(identifier: bLast)
                }
            }
        }
    }
    
    // View Related
    func messageViewLoaded(isLoaded: Bool) {
        collectionView.scrollTo(edge: .bottom, animated: false)
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
        }
        else {
            sendButton.isEnabled = false
        }
    }
    
    func messageTextViewEndEditing(textView: UITextView) {
        if let aText = textView.text, aText.trimmingCharacters(in: .whitespacesAndNewlines).count <= 0 {
            sendButton.isEnabled = false
        }
    }
    
    func messageMicButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool {
        /// 음성 인식 상태로 전환
        setDefaultState()
        keyboardButton.isHidden = false
        if let ozmb = ozMicButton { ozmb.isHidden = true }
        sendButton.isHidden = true
        
        setSuccessToMic()
        //setFailToMic()
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
        /*
        for i in 0..<imagePaths.count {
            let imagePath = imagePaths[i].absoluteString
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.send(msg: imagePath, type: .image) { (id, content) in
                    print("senddd: \(id), \(content)")
                }
            }
        }
         */
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
        if let ivs = imageViews, let ids = identifiers, ivs.count == ids.count {
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

