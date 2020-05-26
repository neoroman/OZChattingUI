//
//  OZMessagesViewController.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/03.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit
import CollectionKit
import AVFoundation

public enum OZMessagesViewState {
    case chat, voice, emoticon, file
}

public typealias OZChatFetchCompleteBlock = (_ newMessages: [OZMessage]) -> Void
public typealias OZChatTapCompleteBlock = (_ success: Bool, _ path: String) -> Void

public protocol OZMessagesViewControllerDelegate {
    func messageSending(identifier: String, type: OZMessageType, data: OZMessage)
    func messageAppend(complete: @escaping OZChatFetchCompleteBlock)
    func messageCellTapped(cell: OZMessageCell, index: Int, complete: @escaping OZChatTapCompleteBlock)
    func messageViewLoaded(isLoaded: Bool)
}


fileprivate let minTextViewHeight: CGFloat = 56
fileprivate let maxTextViewHeight: CGFloat = minTextViewHeight * 3 //120

open class OZMessagesViewController: CollectionViewController {
    
    public var delegate: OZMessagesViewControllerDelegate?
    public var voiceViewController: OZVoiceRecordViewController?
    public var emoticonViewController: OZEmoticonViewController?

    public var chatState: OZMessagesViewState = .chat {
        didSet {
            self.reloadAllView(chatState, oldState: oldValue)
            
            if chatState == .voice { self.collectionView.isUserInteractionEnabled = false }
            else { self.collectionView.isUserInteractionEnabled = true }
        }
    }
    
    @IBOutlet weak var inputContainer: UIView!
    @IBOutlet weak var emoticonButton: UIButton!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var fileButton: UIButton!
    
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
    fileprivate var keyboardHeight: CGFloat = 0.0
    fileprivate var isKeyboardShow: Bool = false

    @IBOutlet weak var emoticonContainer: UIView!
    @IBOutlet weak var emoticonContainerViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var voiceContainer: UIView!
    
    public var fileChoosePopup: OZChoosePopup?
    public var fileChoosePopupDelegate: OZChoosePopupDelegate?
    
    fileprivate var imagePicker = UIImagePickerController()
    
    public var userIdentifier: String?
    public var userProfilePath: String?
    public var isEchoMode: Bool = false
    
    var loading = false
    
    public var dataSource = OZMessageDataProvider(data: [])
    public let animator = OZMessageAnimator()
    
    // MARK: - View did loaded
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.clipsToBounds = true
        self.setupUI()
        view.bringSubviewToFront(inputContainer)
        
        
        collectionView.delegate = self
        reloadCollectionViewFrame()
        
        let inset = UIEdgeInsets(top: 30, left: 0, bottom: 54, right: -5) // Right(-5px) is max
        collectionView.scrollIndicatorInsets = inset
        collectionView.indicatorStyle = .black
        
        setupDataProvider()
        
        if let dele = delegate {
            dele.messageViewLoaded(isLoaded: true)
        }
    }
    
    // MARK: - Orientations
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        reloadCollectionViewFrame()
        let inset = UIEdgeInsets(top: 30, left: 0, bottom: 54, right: -5) // Right(-5px) is max
        collectionView.scrollIndicatorInsets = inset
        collectionView.indicatorStyle = .black
        collectionView.reloadData()
    }
    
    
    // MARK: - Setup collectionView Frame
    open func reloadCollectionViewFrame() {
        collectionView.frame = view.bounds

        collectionView.frame.origin = CGPoint.zero
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            collectionView.frame.size = CGSize(width: super.view.bounds.height, height: super.view.bounds.width)
        } else {
            print("Portrait")
            collectionView.frame.size = CGSize(width: super.view.bounds.width, height: super.view.bounds.height)
        }
        collectionView.contentInset = UIEdgeInsets(top: 30, left: 10, bottom: 54, right: 10)
    }
    
    
    // MARK: - Setup CollectionKit DataProvider
    open func setupDataProvider(newDataSource: OZMessageDataProvider? = nil) {
        let incomingTextMessageViewSource = ClosureViewSource(viewUpdater: { (view: IncomingTextMessageCell, data: OZMessage, at: Int) in
            view.message = data
        })
        let outgoingTextMessageViewSource = ClosureViewSource(viewUpdater: { (view: OutgoingTextMessageCell, data: OZMessage, at: Int) in
            view.message = data
        })
        let textMessageViewSource = ClosureViewSource(viewUpdater: { (view: TextMessageCell, data: OZMessage, at: Int) in
            view.message = data
        })
        let imagePlusIconMessageViewSource = ClosureViewSource(viewUpdater: { (view: ImagePlusIconMessageCell, data: OZMessage, at: Int) in
            view.message = data
            if data.type == .emoticon { view.imageView.contentMode = .scaleAspectFit }
        })
        let imageMessageViewSource = ClosureViewSource(viewUpdater: { (view: ImageMessageCell, data: OZMessage, at: Int) in
            view.message = data
            if data.type == .emoticon { view.imageView.contentMode = .scaleAspectFit }
            // DONE: Emoticon image contentMode, now emoticon image from example project, i.e. not in framework any more.
//            if let aInt = Int(data.content.digits), let bInt = Int(data.content.digits),
//                aInt > 1000, bInt < 1025 {
//                view.imageView.contentMode = .scaleAspectFit
//            }
        })
        let deviceStatusViewSource = ClosureViewSource(viewUpdater: { (view: IncomingStatusMessageCell, data: OZMessage, at: Int) in
            view.message = data
        })
        let audioPlusIconViewSource = ClosureViewSource(viewUpdater: { (view: AudioPlusIconMessageCell, data: OZMessage, at: Int) in
            view.message = data
        })
        let audioViewSource = ClosureViewSource(viewUpdater: { (view: AudioMessageCell, data: OZMessage, at: Int) in
            view.message = data
        })
        if let newDataSrc = newDataSource {
            dataSource = newDataSrc
        }
        animator.sourceView = inputContainer
        animator.dataSource = dataSource

        let visibleFrameInsets = UIEdgeInsets(top: -200, left: 0, bottom: -200, right: 0)
        self.provider = BasicProvider(
            identifier: "OZChat2020",
            dataSource: dataSource,
            viewSource: ComposedViewSource(viewSourceSelector: { data in
                switch data.type {
                case .image, .emoticon:
                    if data.alignment == .left {
                        return imagePlusIconMessageViewSource
                    }
                    else {
                        return imageMessageViewSource
                    }
                case .text:
                    if data.alignment == .left {
                        return incomingTextMessageViewSource
                    }
                    else {
                        return outgoingTextMessageViewSource
                    }
                case .deviceStatus:
                    return deviceStatusViewSource
                case .mp3, .voice:
                    if data.alignment == .left {
                        return audioPlusIconViewSource
                    }
                    else {
                        return audioViewSource
                    }
                default:
                    return textMessageViewSource
                }
            }),
            layout: OZMessageLayout().insetVisibleFrame(by: visibleFrameInsets),
            animator: animator,
            // MARK: ******** Cell Tap Handler here *******
            tapHandler: { [weak self] context in
                //self?.cellTapped(data: context.data, view: context.view) // Not Available, unless context generic understood by Henry on 2020.05.06 => error as 'Generic parameter 'Data' could not be inferred'
                self?.cellTapped(context: context) // Not Available, unless context generic understood by Henry on 2020.05.06
                
                let aMessage = context.data
                
                if let dele = self?.delegate, let ozCell = context.view as? OZMessageCell {
                    dele.messageCellTapped(cell: ozCell, index: context.index) { (success, path) in
                        if success {
                            if let cell = ozCell as? AudioMessageCell,
                                (aMessage.type == .mp3 || aMessage.type == .voice) {
                                context.data.extra["filePath"] = path
                                if !FileManager.default.isReadableFile(atPath: context.data.content),
                                    FileManager.default.isReadableFile(atPath: path) {
                                    context.data.content = path
                                }
                                cell.playOrStop(named: context.data.content)
                            }
                        }
                    }
                }
            }
        )
    }
    
    // MARK: - View did layout subviews
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let isAtBottom = collectionView.contentOffset.y >= collectionView.offsetFrame.maxY - 10
        if !collectionView.hasReloaded, !collectionView.isReloading {
            UIView.setAnimationsEnabled(false)
            collectionView.reloadData() { // 1st call
                return CGPoint(x: self.collectionView.contentOffset.x,
                               y: self.collectionView.offsetFrame.maxY)
            }
            UIView.setAnimationsEnabled(true)
        }
        if isAtBottom, !collectionView.hasReloaded, !collectionView.isReloading {
            collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x,
                                                    y: collectionView.offsetFrame.maxY), animated: false)
        }
        
        if isKeyboardShow || chatState == .emoticon{
            keyboardShowLayout(differHeight: 0, isPadding: true, animated: false)
        }
        else {
            reloadCollectionViewFrame()
        }
    }
    
    // MARK: - Navigation
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "emoticon_view_segue",
            let vc = segue.destination as? OZEmoticonViewController {
            vc.delegate = self
            emoticonViewController = vc
            vc.view.frame = emoticonContainer.bounds
        }
        else if segue.identifier == "record_view_segue",
            let vc = segue.destination as? OZVoiceRecordViewController {
            vc.delegate = self
            voiceViewController = vc
            vc.view.frame = voiceContainer.bounds
        }
    }
}

// MARK: - For sending new messages
extension OZMessagesViewController {
    
    @objc fileprivate func cellTapped(context: Any? = nil) {
        // N/A: move it into viewDidLoaded()
        print("cellTapped:::context ===> \(String(describing: context))")
    }
    
    fileprivate func cellTapped(data: OZMessage, view: OZMessageCell) {
        // N/A: move it into viewDidLoaded()
        // TODO: Not Available, unless context generic understood by Henry on 2020.05.06 => error as 'Generic parameter 'Data' could not be inferred'
        if let cell = view as? AudioMessageCell,
            data.type == .mp3 {
            cell.playOrStop(named: data.content)
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: - ***** Send Message Here !!!! *****
    ////////////////////////////////////////////////////////////////////////////
    // MARK: Message Sending
    /// Message Writer for Sender
    /// - Important: Voice file format is AMR as default, but AMR format is no longer supported by Apple (since iOS 4.3).
    /// - Author: Henry Kim (a.k.a. neoroman)
    /// - Date: 2020.05.09 Sat
    /// - Warning: Use storyboard and delegate such as example source below
    ///  ```
    ///    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    ///        if segue.identifier == "segue_family_chat",
    ///            let vc = segue.destination as? OZMessagesViewController {
    ///
    ///            vc.delegate = self
    ///            chatContainerVC = vc
    ///
    ///            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
    ///                // User Profile Image
    ///                if let anUser = self.user {
    ///                    let imgId = anUser.file.id
    ///                    vc.userImage?.setImageFromUrl(downloader: UserManager.shared.downloader, fileId: imgId, placeHolder: "nopic", isThumb: true)
    ///                }
    ///                else if let cUser = self.campUser {
    ///                    let imgId = cUser.file.id
    ///                    vc.userImage?.setImageFromUrl(downloader: UserManager.shared.downloader, fileId: imgId, placeHolder: "nopic", isThumb: true)
    ///                }
    ///
    ///                #if DEBUG
    ///                // for debugging
    ///                vc.isEchoMode = true
    ///                #endif
    ///
    ///                let today = Date().toString(DateFormat.custom("EEE, MMM d, yyyy"), timeZone: .local)
    ///                vc.send(msg: today, type: .announcement)
    ///                vc.receive(msg: "Welcome to OZChattingUI", type: .text, profileIconPath: "grBi.png")
    ///            }
    ///        }
    ///    }
    ///  ```
    /// - Parameter msg: (mandatory) {String} Text is string, Image and Sound would by local path
    /// - Parameter type: (mandatory) {OZMessageType} Type of message, .text, .image, .status, .mp3, .announcement, .deviceStatus
    /// - Parameter isDeliveredMsg: (optional) {Bool} If it's true, only show "Deliverd" message on right side, default is false
    /// - Parameter callback: (optional) {completeBlock} allback closure.
    /// - Returns:  identifier {String) prevent echo
    open func send(caller: String = #function,
                   msg: String? = nil,
                   type: OZMessageType = .text,
                   isDeliveredMsg: Bool = false,
                   callback: ((_ identifier: String, _ sendingContentPath: String) -> Void)? = nil) {
        guard let text = msg, text.count > 0 else { return }
        
        var sendingMsg: OZMessage!
        DispatchQueue.main.async {
            //self.animator.sendingMessage = true
            if type == .image {
                sendingMsg = OZMessage(true, image: text)
            }
            else if type == .emoticon {
                sendingMsg = OZMessage(true, emoticon: text)
            }
            else if type == .mp3 {
                sendingMsg = OZMessage(true, mp3: text)
            }
            else if type == .voice {
                sendingMsg = OZMessage(true, voice: text)
            }
            else if type == .announcement {
                sendingMsg = OZMessage(announcement: text)
            }
            else if type == .status {
                sendingMsg = OZMessage(true, status: text)
            }
            else {
                sendingMsg = OZMessage(true, content: text)
            }
            if isDeliveredMsg,
                let lastRightMsg = (self.dataSource.data.filter{ $0.alignment == .right }).last,
                let lastRightIndex = self.dataSource.data.firstIndex(of: lastRightMsg) {
                self.dataSource.data.insert(sendingMsg, at: lastRightIndex + 1)
            }
            else {
                self.dataSource.data.append(sendingMsg)
            }
            self.collectionView.reloadData() //send
            self.collectionView.scrollTo(edge: .bottom, animated:true)
            //self.animator.sendingMessage = false

            if let cb = callback {
                cb(sendingMsg.identifier, sendingMsg.content)
            }
            // Prevent recurring of delegation method here
            if let funcName = caller.components(separatedBy: "(").first,
                funcName == "messageSending" {
                return
            }
            if let dele = self.delegate {
                dele.messageSending(identifier: sendingMsg.identifier, type: type, data: sendingMsg)
            }
            
            if self.isEchoMode, type.isEchoEnable() {
                var anImgName = self.userProfilePath ?? ""
                let anUserImg = UIImage(named: "nopic")
                if anImgName.count == 0, anUserImg == nil {
                    anImgName = "nopic@2x.png"
                }

                delay(1.0) {
                    if type == .image {
                        self.dataSource.data.append(OZMessage(false, image: text, timestamp: Int(Date().timeIntervalSince1970), iconImage: anImgName.count > 0 ? anImgName : nil))
                    }
                    else if type == .emoticon {
                        self.dataSource.data.append(OZMessage(false, emoticon: text, timestamp: Int(Date().timeIntervalSince1970), iconImage: anImgName.count > 0 ? anImgName : nil))
                    }
                    else if type == .voice {
                        self.dataSource.data.append(OZMessage(false, voice: text, duration: 0, timestamp: Int(Date().timeIntervalSince1970), iconImage: anImgName.count > 0 ? anImgName : nil))
                    }
                    else if type == .mp3 {
                        self.dataSource.data.append(OZMessage(false, mp3: text, duration: 0, timestamp: Int(Date().timeIntervalSince1970), iconImage: anImgName.count > 0 ? anImgName : nil))
                    }
                    else {
                        self.dataSource.data.append(OZMessage(false, content: text, timestamp: Int(Date().timeIntervalSince1970), iconImage: anImgName.count > 0 ? anImgName : nil))
                    }
                    self.collectionView.reloadData() // send echo (for debugging)
                    self.collectionView.scrollTo(edge: .bottom, animated:true)
                }
            }
        }
    }
    
    // MARK: - ***** Receive Message Here !!!! *****
    open func receive(msg: String? = nil,
                      type: OZMessageType = .text,
                      activeType: OZMessageDeviceType? = .call,
                      duration: Int = 0,
                      timestamp: Int = 0,
                      profileIconPath: String? = nil) {
        guard let text = msg else { return }

        DispatchQueue.main.async {
            self.animator.sendingMessage = true
            let anUserImg = UIImage(named: "nopic")
            var anImgName = ""
            if let piPath = profileIconPath {
                anImgName = piPath
            }
            else if anUserImg == nil {
                anImgName = "nopic@2x.png"
            }
            
            let aTimestamp = timestamp > 0 ? timestamp : Int(Date().timeIntervalSince1970)
            if type == .image {
                self.dataSource.data.append(OZMessage(false, image: text, timestamp: aTimestamp, iconImage: anImgName.count > 0 ? anImgName : nil))
            }
            else if type == .mp3 {
                self.dataSource.data.append(OZMessage(false, mp3: text, duration: duration, timestamp: aTimestamp, iconImage: anImgName.count > 0 ? anImgName : nil))
            }
            else if type == .emoticon {
                self.dataSource.data.append(OZMessage(false, emoticon: text, timestamp: aTimestamp, iconImage: anImgName.count > 0 ? anImgName : nil))
            }
            else if type == .voice {
                self.dataSource.data.append(OZMessage(false, mp3: text, duration: duration, timestamp: aTimestamp, iconImage: anImgName.count > 0 ? anImgName : nil))
            }
            else if type == .deviceStatus, let aType = activeType {
                var anIconName = ""
                switch aType {
                case .call:
                    anIconName = "icChatCall"
                case .campaign:
                    anIconName = "icChatCampaign"
                case .step:
                    anIconName = "icChatStep"
                case .watchOff:
                    anIconName = "icChatWatch"
                }
                self.dataSource.data.append(OZMessage(deviceStatus: text, statusType: activeType, iconNamed: anIconName, timestamp: aTimestamp))
            }
            else {
                self.dataSource.data.append(OZMessage(false, content: text, timestamp: aTimestamp, iconImage: anImgName.count > 0 ? anImgName : nil))
            }
            self.collectionView.reloadData() //receive
            self.collectionView.scrollTo(edge: .bottom, animated:true)
            self.animator.sendingMessage = false
        }
    }
}


// MARK: - UIScrollViewDelegate for CollectionKit
extension OZMessagesViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // PULL TO LOAD MORE
        // load more messages if we scrolled to the top
        if dataSource.data.count > 0,
            let datum = dataSource.data.first,
            datum.content.count > 0 {
            if collectionView.hasReloaded,
                scrollView.contentOffset.y < 500,
                !loading, let dele = delegate {
                loading = true
                delay(0.5) { // Simulate network request
                    dele.messageAppend { (newMessages) in
                        if newMessages.count > 0 {
                            if let aMsg = newMessages.first, aMsg.type == .announcement,
                                aMsg.content == "OZPLACEHOLDER" {
                                // 테스트를 위한 메세지인 경우 추가 안함 by Henry on 2020.05.07
                                self.loading = false
                                return
                            }
                            self.dataSource.data = newMessages + self.dataSource.data
                            let oldContentHeight = self.collectionView.offsetFrame.maxY - self.collectionView.contentOffset.y
                            self.collectionView.reloadData() { //adding new data
                                return CGPoint(x: self.collectionView.contentOffset.x,
                                               y: self.collectionView.offsetFrame.maxY - oldContentHeight)
                            }
                        }
                        self.loading = false
                    }
                }
            }
        }
    }
}


// MARK: - Setup UI
extension OZMessagesViewController {
    func setupUI() {
        let tap = UITapGestureRecognizer()
        tap.delegate = self
        collectionView.addGestureRecognizer(tap)
                
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        inputTextView.delegate = self
        inputTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 70)
        inputTextView.layer.cornerRadius = 18
        inputTextView.layer.masksToBounds = true
        inputTextView.clipsToBounds = true

        
        // Drop shadow
        inputContainer.layer.shadowColor = UIColor.black.cgColor
        inputContainer.layer.shadowOffset = CGSize(width: 0, height: -5.0)
        inputContainer.layer.shadowRadius = 4.0
        inputContainer.layer.shadowOpacity = 0.01
        inputContainer.layer.masksToBounds = false
        
        // Chatting view related
        emoticonContainer.isHidden = true
        voiceContainer.isHidden = true

        resetButtons()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.35) {
            self.collectionView.reloadData() { // 1st call
                return CGPoint(x: self.collectionView.contentOffset.x,
                               y: self.collectionView.offsetFrame.maxY)
            }
            // DO NOT USE BELOW!, UPPER IS BETTER
            //self.collectionView.scrollTo(edge: .bottom, animated:false)
            //self.view.layoutIfNeeded()
        }
    }
    
    func reloadAllView(_ state: OZMessagesViewState = .chat, oldState: OZMessagesViewState? = nil) {
        
        if state == .emoticon {
            voiceContainer.isHidden = true
            micButtonToggle()
            UIView.setAnimationsEnabled(false)
            if chatState == oldState {
                emoticonContainer.isHidden = true
                emoticonButtonToggle()
                inputTextView.becomeFirstResponder()
                chatState = .chat
            }
            else {
                emoticonContainer.isHidden = false
                self.view.endEditing(true)
                emoticonButtonToggle()
                view.bringSubviewToFront(self.emoticonContainer)
                emoticonContainer.layer.zPosition = CGFloat(MAXFLOAT)
                self.keyboardShowLayout(differHeight: 0, isPadding: true, animated: false)
            }
            UIView.setAnimationsEnabled(true)
        }
        else if state == .voice {
            emoticonContainer.isHidden = true
            emoticonButtonToggle()
            if state == oldState {
                UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
                    self.voiceContainer.alpha = 0.0
                    self.keyboardHideLayout()
                }) { (comp) in
                    self.voiceContainer.isHidden = true
                    self.micButtonToggle()
                }
            }
            else {
                view.endEditing(true)
                self.voiceContainer.alpha = 1.0
                self.voiceContainer.isHidden = false
                view.bringSubviewToFront(voiceContainer)
                voiceContainer.layer.zPosition = CGFloat(MAXFLOAT)
                UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
                    self.keyboardHideLayout()
                }) { (comp) in
                    self.micButtonToggle()
                }
            }
        }
        else if state == .file {
            addFileButtonToggle(true)
            resetButtons()
            keyboardHideLayout()
            view.endEditing(true)
            
            fileChoosePopup = OZChoosePopup.initialize()
            if let aPopup = fileChoosePopup {
                if let dele = fileChoosePopupDelegate { aPopup.delegate = dele }
                else { aPopup.delegate = self }
                    
                aPopup.setButtons(contents: [.album, .camera, .file])
                aPopup.show()
            }
        }
        else {
            // Normal chat with text
            resetButtons()
            
            if oldState == .emoticon {
                UIView.setAnimationsEnabled(false)
                inputTextView.becomeFirstResponder()
                UIView.setAnimationsEnabled(true)
            }
        }
    }
    
    fileprivate func resetButtons() {
        voiceContainer.isHidden = true
        micButtonToggle()
        
        emoticonContainer.isHidden = true
        emoticonButtonToggle()
        
        addFileButtonToggle(false)
    }
    
    // MARK: - Bottom button above keyboard
    fileprivate func keyboardShowLayout(differHeight: CGFloat = 0, isPadding: Bool = true, animated: Bool = true) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        var bottomPadding: CGFloat = 0
        if #available(iOS 11.0, *) {
             bottomPadding = window.safeAreaInsets.bottom
        }
        if !isPadding {
            bottomPadding = 0
        }
        
        var normalHeight = keyboardHeight - bottomPadding
        if differHeight > 0 {
            normalHeight = differHeight
        }
        else if normalHeight < 10 {
            if #available(iOS 11.0, *),
                let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom, bottomPadding > 0 {
                // isiPhoneX top and bottom padding exist
                normalHeight = 336 - bottomPadding
            }
            else {
                normalHeight = 250
            }
        }
        let margin = UIEdgeInsets(top: self.insetMarginTop,
                                  left: self.insetMarginX,
                                  bottom: normalHeight + minTextViewHeight + self.insetMarginBottom,
                                  right: self.insetMarginX)

        if animated, chatState == .chat {
            UIView.animate(withDuration: 0.35, animations: {
                self.emoticonContainerViewHeight.constant = normalHeight
                self.view.layoutIfNeeded()
            }) { (comp) in
                DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
                    self.collectionView.frame = self.view.bounds.inset(by: margin)
                    self.collectionView.scrollTo(edge: UIRectEdge.bottom, animated: false)
                }
            }
        }
        else {
            self.emoticonContainerViewHeight.constant = normalHeight
            DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
                self.collectionView.frame = self.view.bounds.inset(by: margin)
                self.collectionView.scrollTo(edge: UIRectEdge.bottom, animated: false)
            }
        }
    }
    fileprivate func keyboardHideLayout() {
        let bottomPadding:CGFloat = 0 //window.safeAreaInsets.bottom
        let margin = UIEdgeInsets(top: self.insetMarginTop,
                                  left: self.insetMarginX,
                                  bottom: bottomPadding + minTextViewHeight + self.insetMarginBottom,
                                  right: self.insetMarginX)

        UIView.animate(withDuration: 0.35, animations: {
            self.emoticonContainerViewHeight.constant = 0
            self.view.layoutIfNeeded()
        }) { (comp) in
            self.collectionView.frame = self.view.bounds.inset(by: margin)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            
            isKeyboardShow = true
            keyboardShowLayout()
            resetButtons()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        isKeyboardShow = false
        keyboardHideLayout()
    }
    
    public func showImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            imagePicker.delegate = self
            imagePicker.sourceType = source
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            // TODO: Handle source no availabe
        }
    }
    
    public func showNeedCameraPermissionAlert() {
        print("camera_permission_check_alert")
    }
    
    public func checkCameraPermission(requestCompletion: @escaping (Bool) -> Void) -> AVAuthorizationStatus {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .authorized:
            return .authorized
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: requestCompletion)
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }
    
    public func handleCameraPermission() {
        func handleRequestCompletion(_ granted: Bool) { if granted { DispatchQueue.main.async { self.showCamera() } } }
        
        
        switch checkCameraPermission(requestCompletion: handleRequestCompletion) {
        case .denied, .restricted:  showNeedCameraPermissionAlert()
        case .authorized:           showCamera()
        case .notDetermined:        ()
        @unknown default:           ()
        }
    }
    
    public func showCamera() {
        showImagePicker(source: .camera)
    }
    
    
    // MARK: - Actions
    @IBAction func addFileButtonPressed(_ sender: Any) {
        chatState = .file
    }
    @IBAction func emoticonButtonViewPressed(_ sender: Any) {
        chatState = .emoticon
    }
    @IBAction func micContainerButtonPressed(_ sender: Any) {
        chatState = .voice
    }

    public func addFileButtonToggle(_ isForceRed: Bool) {
        guard let fileImg = fileButton.imageView?.image else { return }
        
        if isForceRed {
            fileButton.setImage(fileImg.withRenderingMode(.alwaysTemplate), for: .normal)
            fileButton.tintColor = UIColor.red
            UIView.animate(withDuration: 0.25) {
                self.fileButton.layer.transform = CATransform3DMakeRotation(.pi / 4, 0, 0, 1)
            }
        }
        else {
            fileButton.setImage(fileImg.withRenderingMode(.alwaysTemplate), for: .normal)
            fileButton.tintColor = UIColor.black
            UIView.animate(withDuration: 0.25) {
                self.fileButton.layer.transform = CATransform3DIdentity
            }
        }
    }
    fileprivate func micButtonToggle() {
        guard let micImg = micButton.imageView?.image else { return }
        
        if chatState == .voice {
            micButton.setImage(micImg.withRenderingMode(.alwaysTemplate), for: .normal)
            micButton.tintColor = UIColor.red
        }
        else {
            micButton.setImage(micImg.withRenderingMode(.alwaysTemplate), for: .normal)
            micButton.tintColor = UIColor.black
        }
    }
    fileprivate func emoticonButtonToggle() {
        guard let emotImg = emoticonButton.imageView?.image else { return }
        
        if chatState == .emoticon {
            emoticonButton.setImage(emotImg.withRenderingMode(.alwaysTemplate), for: .normal)
            emoticonButton.tintColor = UIColor.red
        }
        else {
            emoticonButton.setImage(emotImg.withRenderingMode(.alwaysTemplate), for: .normal)
            emoticonButton.tintColor = UIColor.black
        }
    }
}


// MARK: - UITextViewDelegate
extension OZMessagesViewController: UITextViewDelegate {
    func adjustTextViewHeight(_ textView: UITextView) {
        if textView.text.count <= 0 {
            self.textHeightConstraint.constant = minTextViewHeight
            inputContainer.backgroundColor = .white
            return
        }
        
        let width = textView.contentSize.width
        let size = OZMessageCell.sizeForText(textView.text, maxWidth: width,
                                             paddingX: 20.0, paddingY: 20.0)
        
        if self.textHeightConstraint.constant > maxTextViewHeight {
            UIView.animate(withDuration: 0.2, delay: 0.15, options: .curveEaseInOut, animations: {
                self.textHeightConstraint.constant = maxTextViewHeight
            }) { (complete) in
                //
            }
        }
        else if self.textHeightConstraint.constant < size.height {
            self.textHeightConstraint.constant = size.height
        }
        else if self.textHeightConstraint.constant < minTextViewHeight {
            self.textHeightConstraint.constant = minTextViewHeight
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeight(textView)
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        print("textViewDidBeginEditing")
        chatState = .chat
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEditing")
    }
    
    // MARK: Send Button Like...!
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n", let fullText = textView.text {
            self.send(msg: fullText)
            self.inputTextView.text = ""
            self.adjustTextViewHeight(textView)
            return false;
        }
        
        return true
    }
    
}



// MARK: - OZChoosePopupDelegate
extension OZMessagesViewController: OZChoosePopupDelegate {
    public func chooseButtonClick(_ sender: Any, type: OZChooseContentType) {
        switch type {
        case .album:
            self.showImagePicker(source: .photoLibrary)
        case .camera:
            self.handleCameraPermission()
        case .file:
            // TODO: do something here by Henry on 2020.05.08
            self.showImagePicker(source: .photoLibrary)
        default:
            print("do nothing...!")
        }
        
        self.addFileButtonToggle(false)
    }
}



// MARK: - UINavigationControllerDelegate & UIImagePickerControllerDelegate
extension OZMessagesViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let chosenImage = info[.editedImage] as? UIImage else { return }
        
        dismiss(animated: true)
        
        guard let imageData = chosenImage.jpegData(compressionQuality: 1) else { return }
        
        if let anImg = UIImage(data: imageData) {
            fileUpload(anImg)
        }
    }
    
    func fileUpload(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.5) {
            let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let filename = path.appendingPathComponent("ozimg-\(String.randomFileName(length: 10)).jpg")
            
            try? data.write(to: filename)
            
            while !FileManager.default.isReadableFile(atPath: filename.relativePath) {
                // wait here
            }
            
            if FileManager.default.isReadableFile(atPath: filename.relativePath) {
                print("filename.relativePath=\(filename.relativePath)")
                send(msg: filename.relativePath, type: .image)
            }
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}


extension OZMessagesViewController: UIGestureRecognizerDelegate {
    // MARK: UIGestureRecognizerDelegate methods, You need to set the delegate of the recognizer
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if touch.view == gestureRecognizer.view {
            self.view.endEditing(true)
            
            UIView.animate(withDuration: 0.2) {
                self.chatState = .chat
            }
            
            return true
        }
        
        return false
    }
}
