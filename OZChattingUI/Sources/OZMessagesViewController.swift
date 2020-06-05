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

public var minTextViewHeight: CGFloat = 56
public var maxTextViewHeight: CGFloat = minTextViewHeight * 3 //120

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
    @IBOutlet weak var inputTextView: OZTextView!
    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var emoticonContainer: UIView!
    @IBOutlet weak var emoticonContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var voiceContainer: UIView!

    public var ozInputContainer = UIView()
    public var ozEmoticonButton = UIButton()
    public var ozMicButton = UIButton()
    public var ozFileButton = UIButton()
    public var ozInputTextView = OZTextView()
    public var ozTextHeightConstraint = NSLayoutConstraint()
    public var ozEmoticonContainer = UIView()
    public var ozEmoticonContainerViewHeight = NSLayoutConstraint()
    public var ozVoiceContainer = UIView()
    
    fileprivate var keyboardHeight: CGFloat = 0.0
    fileprivate var isKeyboardShow: Bool = false

        
    fileprivate var imagePicker = UIImagePickerController()
    
    public var userIdentifier: String?
    public var userProfilePath: String?
    public var isEchoMode: Bool = false
    
    var loading = false
    
    public var dataSource = OZMessageDataProvider(data: [])
    public let animator = OZMessageAnimator()
    
    private var _messagesConfigurations: [OZMessagesConfigurationItem] = []
    public var messagesConfigurations: [OZMessagesConfigurationItem] {
        set { _messagesConfigurations = newValue }
        get {
            if let dele = delegate {
                _messagesConfigurations.append(contentsOf: dele.messageConfiguration(viewController: self))
            }
            return _messagesConfigurations
        }
    }
    
    // MARK: - View did loaded
    override open func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = UIColor(displayP3Red: 228/255, green: 232/255, blue: 232/255, alpha: 1)
        view.backgroundColor = UIColor.white
        view.clipsToBounds = true
        
        setupIBOutlets()
        setupUI()
        
        
        collectionView.delegate = self
        
        let inset = UIEdgeInsets(top: 30, left: 0, bottom: 54, right: -5) // Right(-5px) is max
        collectionView.scrollIndicatorInsets = inset
        collectionView.indicatorStyle = .black
        collectionView.showsHorizontalScrollIndicator = false
        
        setupDataProvider()
        
        if let dele = delegate {
            dele.messageViewLoaded(isLoaded: true)
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadCollectionViewFrame()
    }
        
    // MARK: - Orientations
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        reloadCollectionViewFrame()
        let inset = UIEdgeInsets(top: 30, left: 0, bottom: 54, right: -5) // Right(-5px) is max
        collectionView.scrollIndicatorInsets = inset
        collectionView.indicatorStyle = .black
        for case .collectionViewEdgeInsets(var inset) in self.messagesConfigurations {
            inset.bottom = inset.bottom + minTextViewHeight
            collectionView.contentInset = inset
        }
        collectionView.setNeedsReload()
    }
    
    
    // MARK: - Setup collectionView Frame
    open func reloadCollectionViewFrame() {
        collectionView.frame = view.bounds

        collectionView.frame.origin = CGPoint.zero
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            collectionView.frame.size = CGSize(width: super.view.bounds.height, height: super.view.bounds.width - minTextViewHeight)
        } else {
            print("Portrait")
            collectionView.frame.size = CGSize(width: super.view.bounds.width, height: super.view.bounds.height - minTextViewHeight)
        }
        for case .collectionViewEdgeInsets(var inset) in self.messagesConfigurations {
            inset.bottom = inset.bottom + minTextViewHeight
            collectionView.contentInset = inset //UIEdgeInsets(top: 20, left: 10, bottom: 54, right: 10)
        }
        collectionView.reloadData()
        collectionView.scrollTo(edge: .bottom, animated: false)
    }
    
    
    // MARK: - Setup CollectionKit DataProvider
    public func setupDataProvider(newDataSource: OZMessageDataProvider? = nil) {
        let incomingTextMessageViewSource = ClosureViewSource(viewUpdater: { (view: IncomingTextMessageCell, data: OZMessage, at: Int) in
            view.delegate = self
            view.message = data
        })
        let outgoingTextMessageViewSource = ClosureViewSource(viewUpdater: { (view: OutgoingTextMessageCell, data: OZMessage, at: Int) in
            view.delegate = self
            view.message = data
        })
        let textMessageViewSource = ClosureViewSource(viewUpdater: { (view: TextMessageCell, data: OZMessage, at: Int) in
            view.delegate = self
            view.message = data
        })
        let imagePlusIconMessageViewSource = ClosureViewSource(viewUpdater: { (view: ImagePlusIconMessageCell, data: OZMessage, at: Int) in
            view.delegate = self
            view.message = data
            if data.type == .emoticon { view.imageView.contentMode = .scaleAspectFit }
        })
        let imageMessageViewSource = ClosureViewSource(viewUpdater: { (view: ImageMessageCell, data: OZMessage, at: Int) in
            view.delegate = self
            view.message = data
            if data.type == .emoticon { view.imageView.contentMode = .scaleAspectFit }
            // DONE: Emoticon image contentMode, now emoticon image from example project, i.e. not in framework any more.
//            if let aInt = Int(data.content.digits), let bInt = Int(data.content.digits),
//                aInt > 1000, bInt < 1025 {
//                view.imageView.contentMode = .scaleAspectFit
//            }
        })
        let deviceStatusViewSource = ClosureViewSource(viewUpdater: { (view: IncomingStatusMessageCell, data: OZMessage, at: Int) in
            view.delegate = self
            view.message = data
        })
        let audioPlusIconViewSource = ClosureViewSource(viewUpdater: { (view: AudioPlusIconMessageCell, data: OZMessage, at: Int) in
            view.delegate = self
            view.message = data
        })
        let audioViewSource = ClosureViewSource(viewUpdater: { (view: AudioMessageCell, data: OZMessage, at: Int) in
            view.delegate = self
            view.message = data
        })
        if let newDataSrc = newDataSource {
            dataSource = newDataSrc
        }
        animator.sourceView = ozInputContainer
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
        
        if isKeyboardShow || chatState == .emoticon {
            keyboardShowLayout(differHeight: 0, isPadding: true, animated: false)
        }
        else {
            reloadCollectionViewFrame()
        }
    }
    
    // MARK: - Setup Input TextView Height Constraint
    fileprivate let inputTextContstraintIDs = ["inputTextContainerCenter",
                                               "inputTextContainerWidth",
                                               "inputTextContainerBottom",
                                               "inputTextContainerHeight"]
    
    fileprivate func setupInputTextContainerViewFrame(height: CGFloat = minTextViewHeight) {
        self.removeContraint(fromList: inputTextContstraintIDs)
        self.ozInputContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // centerX
        let containerXCenter: NSLayoutConstraint = NSLayoutConstraint(item: self.ozInputContainer as Any, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        containerXCenter.identifier = inputTextContstraintIDs[0]
        
        // Width
        let containerWidth: NSLayoutConstraint = NSLayoutConstraint(item: self.ozInputContainer as Any, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: 0)
        containerWidth.identifier = inputTextContstraintIDs[1]
        
        // Bottom
        if #available(iOS 11.0, *) {
            ozEmoticonContainerViewHeight = NSLayoutConstraint(item: self.ozInputContainer, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
        } else {
            ozEmoticonContainerViewHeight = NSLayoutConstraint(item: self.ozInputContainer, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
        }
        ozEmoticonContainerViewHeight.identifier = inputTextContstraintIDs[2]
        
        // Vertical Spacing
        ozTextHeightConstraint = self.ozInputContainer.heightAnchor.constraint(equalToConstant: height)
            //NSLayoutConstraint(item: self.ozInputContainer as Any, attribute: .height, relatedBy: .equal, toItem: self.ozInputContainer as Any, attribute: .height, multiplier: 1, constant: height)
        ozTextHeightConstraint.identifier = inputTextContstraintIDs[3]
        
        self.view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: .curveEaseInOut, animations: {
            self.view.addConstraints([self.ozEmoticonContainerViewHeight, containerWidth, containerXCenter, self.ozTextHeightConstraint])
            self.view.layoutIfNeeded()
        }) { (complete) in
            //code
        }
    }
    fileprivate let textViewContstraintIDs = ["textViewLeading", "textViewTrail",
                                               "textViewTop", "textViewBottom"]
    fileprivate func setupTextViewFrame() {
        self.removeContraint(fromList: textViewContstraintIDs)
        self.ozInputTextView.translatesAutoresizingMaskIntoConstraints = false
        
        // Leading
        let textViewLeading = NSLayoutConstraint(item: self.ozInputTextView as Any, attribute: .leading, relatedBy: .equal, toItem: self.ozFileButton as Any, attribute: .trailing, multiplier: 1, constant: 10)
        textViewLeading.identifier = textViewContstraintIDs[0]
        
        // Trailing
        let textViewTrailing = NSLayoutConstraint(item: self.ozInputTextView as Any, attribute: .trailing, relatedBy: .equal, toItem: self.ozInputContainer as Any, attribute: .trailing, multiplier: 1, constant: -10)
        textViewTrailing.identifier = textViewContstraintIDs[1]
        
        // Top
        let textViewTop = NSLayoutConstraint(item: self.ozInputTextView, attribute: .top, relatedBy: .equal, toItem: self.ozInputContainer, attribute: .top, multiplier: 1, constant: 10)
        textViewTop.identifier = textViewContstraintIDs[2]
        
        // Bottom
        let textViewBottom = NSLayoutConstraint(item: self.ozInputTextView as Any, attribute: .bottom, relatedBy: .equal, toItem: self.ozInputContainer as Any, attribute: .bottom, multiplier: 1, constant: -10)
        textViewBottom.identifier = textViewContstraintIDs[3]
        
        self.view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: .curveEaseInOut, animations: {
            self.view.addConstraints([textViewTop, textViewLeading, textViewTrailing, textViewBottom])
            self.view.layoutIfNeeded()
        }) { (complete) in
            //code
        }
    }
    fileprivate let fileButtonContstraintIDs = ["fileButtonLeading", "fileButtonWidth",
                                               "fileButtonHeight", "fileButtonBottom"]
    fileprivate func setupFileButtonFrame() {
        self.removeContraint(fromList: fileButtonContstraintIDs)
        self.ozFileButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Leading
        let fileButtonLeading = NSLayoutConstraint(item: self.ozFileButton as Any, attribute: .leading, relatedBy: .equal, toItem: self.ozInputContainer as Any, attribute: .leading, multiplier: 1, constant: 10)
        fileButtonLeading.identifier = textViewContstraintIDs[0]
        
        // Width
        let fileButtonWidth = self.ozFileButton.widthAnchor.constraint(equalToConstant: 30)
        fileButtonWidth.identifier = textViewContstraintIDs[1]
        
        // Height
        let fileButtonHeight = self.ozFileButton.heightAnchor.constraint(equalToConstant: 30)
        fileButtonHeight.identifier = textViewContstraintIDs[2]
        
        // Bottom
        let fileButtonBottom = NSLayoutConstraint(item: self.ozFileButton as Any, attribute: .bottom, relatedBy: .equal, toItem: self.ozInputContainer as Any, attribute: .bottom, multiplier: 1, constant: -(minTextViewHeight/2 - 15))
        fileButtonBottom.identifier = textViewContstraintIDs[3]
        
        self.view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: .curveEaseInOut, animations: {
            self.view.addConstraints([fileButtonLeading, fileButtonWidth, fileButtonHeight, fileButtonBottom])
            self.view.layoutIfNeeded()
        }) { (complete) in
            //code
        }
    }
    fileprivate let micButtonContstraintIDs = ["micButtonTrail", "micButtonWidth",
                                               "micButtonHeight", "micButtonBottom"]
    fileprivate func setupMicButtonFrame() {
        self.removeContraint(fromList: micButtonContstraintIDs)
        self.ozMicButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Trailing
        let micButtonTrail = NSLayoutConstraint(item: self.ozMicButton as Any, attribute: .trailing, relatedBy: .equal, toItem: self.ozInputContainer as Any, attribute: .trailing, multiplier: 1, constant: -10)
        micButtonTrail.identifier = micButtonContstraintIDs[0]
        
        // Width
        let micButtonWidth = self.ozMicButton.widthAnchor.constraint(equalToConstant: 30)
        micButtonWidth.identifier = micButtonContstraintIDs[1]
        
        // Height
        let micButtonHeight = self.ozMicButton.heightAnchor.constraint(equalToConstant: 30)
        micButtonHeight.identifier = micButtonContstraintIDs[2]
        
        // Bottom
        let micButtonBottom = NSLayoutConstraint(item: self.ozMicButton as Any, attribute: .bottom, relatedBy: .equal, toItem: self.ozInputContainer as Any, attribute: .bottom, multiplier: 1, constant: -(minTextViewHeight/2 - 15))
        micButtonBottom.identifier = micButtonContstraintIDs[3]
        
        self.view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: .curveEaseInOut, animations: {
            self.view.addConstraints([micButtonTrail, micButtonWidth, micButtonHeight, micButtonBottom])
            self.view.layoutIfNeeded()
        }) { (complete) in
            //code
        }
    }
    fileprivate let emoticonButtonContstraintIDs = ["emoticonButtonTrail", "emoticonButtonWidth",
                                               "emoticonButtonHeight", "emoticonButtonBottom"]
    fileprivate func setupEmoticonButtonFrame() {
        self.removeContraint(fromList: emoticonButtonContstraintIDs)
        self.ozEmoticonButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Trailing
        let emoticonButtonTrail = NSLayoutConstraint(item: self.ozEmoticonButton as Any, attribute: .trailing, relatedBy: .equal, toItem: self.ozMicButton as Any, attribute: .leading, multiplier: 1, constant: -10)
        emoticonButtonTrail.identifier = emoticonButtonContstraintIDs[0]
        
        // Width
        let emoticonButtonWidth = self.ozEmoticonButton.widthAnchor.constraint(equalToConstant: 30)
        emoticonButtonWidth.identifier = emoticonButtonContstraintIDs[1]
        
        // Height
        let emoticonButtonHeight = self.ozEmoticonButton.heightAnchor.constraint(equalToConstant: 30)
        emoticonButtonHeight.identifier = emoticonButtonContstraintIDs[2]
        
        // Bottom
        let emoticonButtonBottom = NSLayoutConstraint(item: self.ozEmoticonButton as Any, attribute: .bottom, relatedBy: .equal, toItem: self.ozInputContainer as Any, attribute: .bottom, multiplier: 1, constant: -(minTextViewHeight/2 - 15))
        emoticonButtonBottom.identifier = emoticonButtonContstraintIDs[3]
        
        self.view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: .curveEaseInOut, animations: {
            self.view.addConstraints([emoticonButtonTrail, emoticonButtonWidth, emoticonButtonHeight, emoticonButtonBottom])
            self.view.layoutIfNeeded()
        }) { (complete) in
            //code
        }
    }

    fileprivate func removeContraint(fromList: [String], view: UIView? = nil) {
        for constraint in self.view.constraints {
            if constraint.identifier != nil && fromList.contains(constraint.identifier!) {
                self.view.removeConstraint(constraint)
            }
        }
        if view != nil && (view?.constraints.count)! > 0 {
            for constraint in (view?.constraints)! {
                if constraint.identifier != nil && fromList.contains(constraint.identifier!) {
                    view?.removeConstraint(constraint)
                }
            }
        }
    }

    

    
    // MARK: - Navigation
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "emoticon_view_segue",
            let vc = segue.destination as? OZEmoticonViewController {
            vc.delegate = self
            emoticonViewController = vc
            vc.view.frame = ozEmoticonContainer.bounds
        }
        else if segue.identifier == "record_view_segue",
            let vc = segue.destination as? OZVoiceRecordViewController {
            vc.delegate = self
            voiceViewController = vc
            vc.view.frame = ozVoiceContainer.bounds
            
            var aDuration: TimeInterval = 12
            for case .voiceRecordMaxDuration(let duration) in messagesConfigurations {
                aDuration = duration
            }
            vc.recordMaxDuration = aDuration
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
                sendingMsg = OZMessage(true, image: text, config: self.messagesConfigurations)
            }
            else if type == .emoticon {
                sendingMsg = OZMessage(true, emoticon: text, config: self.messagesConfigurations)
            }
            else if type == .mp3 {
                sendingMsg = OZMessage(true, mp3: text, config: self.messagesConfigurations)
            }
            else if type == .voice {
                sendingMsg = OZMessage(true, voice: text, config: self.messagesConfigurations)
            }
            else if type == .announcement {
                sendingMsg = OZMessage(announcement: text, config: self.messagesConfigurations)
            }
            else if type == .status {
                sendingMsg = OZMessage(true, status: text, config: self.messagesConfigurations)
            }
            else {
                sendingMsg = OZMessage(true, content: text, config: self.messagesConfigurations)
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
            
            self.resetButtons(false)

            if let cb = callback {
                cb(sendingMsg.identifier, sendingMsg.content)
            }
            // Prevent recurring of delegation method here
            if let funcName = caller.components(separatedBy: "(").first,
                funcName == "messageSending" {
                return
            }
            if let dele = self.delegate,
                !dele.messageSending(identifier: sendingMsg.identifier, type: type, data: sendingMsg) {
                if let index = self.dataSource.data.firstIndex(of: sendingMsg) {
                    self.dataSource.data.remove(at: index)
                }
            }
            
            if self.isEchoMode, type.isEchoEnable() {
                var anImgName = self.userProfilePath ?? ""
                let anUserImg = UIImage(named: "nopic")
                if anImgName.count == 0, anUserImg == nil {
                    anImgName = "nopic@2x.png"
                }

                delay(1.0) {
                    if type == .image {
                        self.dataSource.data.append(OZMessage(false, image: text, timestamp: Int(Date().timeIntervalSince1970), iconImage: anImgName.count > 0 ? anImgName : nil, config: self.messagesConfigurations))
                    }
                    else if type == .emoticon {
                        self.dataSource.data.append(OZMessage(false, emoticon: text, timestamp: Int(Date().timeIntervalSince1970), iconImage: anImgName.count > 0 ? anImgName : nil, config: self.messagesConfigurations))
                    }
                    else if type == .voice {
                        self.dataSource.data.append(OZMessage(false, voice: text, duration: 0, timestamp: Int(Date().timeIntervalSince1970), iconImage: anImgName.count > 0 ? anImgName : nil, config: self.messagesConfigurations))
                    }
                    else if type == .mp3 {
                        self.dataSource.data.append(OZMessage(false, mp3: text, duration: 0, timestamp: Int(Date().timeIntervalSince1970), iconImage: anImgName.count > 0 ? anImgName : nil, config: self.messagesConfigurations))
                    }
                    else {
                        self.dataSource.data.append(OZMessage(false, content: text, timestamp: Int(Date().timeIntervalSince1970), iconImage: anImgName.count > 0 ? anImgName : nil, config: self.messagesConfigurations))
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
                self.dataSource.data.append(OZMessage(false, image: text, timestamp: aTimestamp, iconImage: anImgName.count > 0 ? anImgName : nil, config: self.messagesConfigurations))
            }
            else if type == .mp3 {
                self.dataSource.data.append(OZMessage(false, mp3: text, duration: duration, timestamp: aTimestamp, iconImage: anImgName.count > 0 ? anImgName : nil, config: self.messagesConfigurations))
            }
            else if type == .emoticon {
                self.dataSource.data.append(OZMessage(false, emoticon: text, timestamp: aTimestamp, iconImage: anImgName.count > 0 ? anImgName : nil, config: self.messagesConfigurations))
            }
            else if type == .voice {
                self.dataSource.data.append(OZMessage(false, mp3: text, duration: duration, timestamp: aTimestamp, iconImage: anImgName.count > 0 ? anImgName : nil, config: self.messagesConfigurations))
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
                self.dataSource.data.append(OZMessage(deviceStatus: text, statusType: activeType, iconNamed: anIconName, timestamp: aTimestamp, config: self.messagesConfigurations))
            }
            else {
                self.dataSource.data.append(OZMessage(false, content: text, timestamp: aTimestamp, iconImage: anImgName.count > 0 ? anImgName : nil, config: self.messagesConfigurations))
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
    fileprivate func setupIBOutlets() {
        
        /// Input Container
        if let ic = inputContainer {
            ozInputContainer = ic
        }
        else {
            if #available(iOS 11.0, *) {
                let bottomInset: CGFloat = view.safeAreaInsets.bottom
                let origin = CGPoint(x: 0, y: self.view.bounds.height - minTextViewHeight - bottomInset)
                let size = CGSize(width: self.view.bounds.width, height: minTextViewHeight)
                ozInputContainer = UIView(frame: CGRect(origin: origin, size: size))
                ozInputContainer.backgroundColor = .white
                view.addSubview(ozInputContainer)
                
                let guide = view.safeAreaLayoutGuide
                NSLayoutConstraint.activate([
                    ozInputContainer.heightAnchor.constraint(equalToConstant: minTextViewHeight),
                    guide.bottomAnchor.constraint(equalToSystemSpacingBelow: ozInputContainer.bottomAnchor, multiplier: 1.0)
                ])
            } else {
                let origin = CGPoint(x: 0, y: self.view.bounds.height - minTextViewHeight)
                let size = CGSize(width: self.view.bounds.width, height: minTextViewHeight)
                ozInputContainer = UIView(frame: CGRect(origin: origin, size: size))
                ozInputContainer.backgroundColor = .white
                view.addSubview(ozInputContainer)
                
                let standardSpacing: CGFloat = minTextViewHeight
                NSLayoutConstraint.activate([
                    ozInputContainer.heightAnchor.constraint(equalToConstant: standardSpacing),
                    bottomLayoutGuide.topAnchor.constraint(equalTo: ozInputContainer.bottomAnchor, constant: standardSpacing)
                ])
            }
        }
        
        /// File button
        if let fb = fileButton {
            ozFileButton = fb
        }
        else {
            let origin = CGPoint(x: 10, y: 10)
            let size = CGSize(width: 25, height: 25)
            ozFileButton = UIButton(frame: CGRect(origin: origin, size: size))
            ozFileButton.center = CGPoint(x: ozFileButton.center.x, y: ozInputContainer.bounds.midY)
            ozFileButton.setImage(UIImage(named: "addFile"), for: .normal)
            ozInputContainer.addSubview(ozFileButton)
        }
        
        /// Input TextView
        if let itv = inputTextView {
            ozInputTextView = itv
        }
        else {
            let origin = CGPoint(x: ozFileButton.frame.maxX + 10, y: 10)
            let size = CGSize(width: self.view.bounds.width - 10 - origin.x, height: minTextViewHeight * 0.65)
            ozInputTextView = OZTextView(frame: CGRect(origin: origin, size: size))
            ozInputTextView.delegate = self
            ozInputTextView.backgroundColor = UIColor(white: 244/255, alpha: 1.0)
            ozInputContainer.addSubview(ozInputTextView)
        }

        /// Emoticon button
        if let eb = emoticonButton {
            ozEmoticonButton = eb
        }
        else {
            let origin = CGPoint(x: ozInputTextView.frame.maxX - 30*2 - 10*2, y: 10)
            let size = CGSize(width: 30, height: 30)
            ozEmoticonButton = UIButton(frame: CGRect(origin: origin, size: size))
            ozEmoticonButton.center = CGPoint(x: ozEmoticonButton.center.x, y: ozInputContainer.bounds.midY)
            ozEmoticonButton.setImage(UIImage(named: "emo"), for: .normal)
            ozInputContainer.addSubview(ozEmoticonButton)
        }

        /// Mic button
        if let mb = micButton {
            ozMicButton = mb
        }
        else {
            let origin = CGPoint(x: ozInputTextView.frame.maxX - 30 - 10, y: 10)
            let size = CGSize(width: 30, height: 30)
            ozMicButton = UIButton(frame: CGRect(origin: origin, size: size))
            ozMicButton.center = CGPoint(x: ozMicButton.center.x, y: ozInputContainer.bounds.midY)
            ozMicButton.setImage(UIImage(named: "mic"), for: .normal)
            ozInputContainer.addSubview(ozMicButton)
        }
        
        /// AutoLayout Constraints
        if let thc = textHeightConstraint {
            ozTextHeightConstraint = thc
        }
        else {
            setupInputTextContainerViewFrame(height: minTextViewHeight)
            setupTextViewFrame()
            setupFileButtonFrame()
            setupMicButtonFrame()
            setupEmoticonButtonFrame()
        }
    }
    
    func setupUI() {
        let tap = UITapGestureRecognizer()
        tap.delegate = self
        collectionView.addGestureRecognizer(tap)
                
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        /// Input TextView
        ozInputTextView.delegate = self
        ozInputTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 70)
        ozInputTextView.layer.cornerRadius = 18
        ozInputTextView.layer.masksToBounds = true
        ozInputTextView.clipsToBounds = true
        for case .inputTextVerticalAlignment(let alignment) in messagesConfigurations {
            ozInputTextView.verticalAlignment = alignment
        }
        
        // Chatting view related
        ozEmoticonContainer.isHidden = true
        ozVoiceContainer.isHidden = true
        
        // Connect Target
        ozFileButton.addTarget(self, action: #selector(addFileButtonPressed(_:)), for: .touchUpInside)
        ozMicButton.addTarget(self, action: #selector(micContainerButtonPressed(_:)), for: .touchUpInside)
        ozEmoticonButton.addTarget(self, action: #selector(emoticonButtonViewPressed(_:)), for: .touchUpInside)
        
        resetButtons()
        
        // Drop shadow
        ozInputContainer.layer.shadowColor = UIColor.black.cgColor
        ozInputContainer.layer.shadowOffset = CGSize(width: 0, height: -5.0)
        ozInputContainer.layer.shadowRadius = 4.0
        ozInputContainer.layer.shadowOpacity = 0.01
        ozInputContainer.layer.masksToBounds = false
        view.bringSubviewToFront(ozInputContainer)
    }
    
    func reloadAllView(_ state: OZMessagesViewState = .chat, oldState: OZMessagesViewState? = nil) {
        
        if state == .emoticon {
            ozVoiceContainer.isHidden = true
            micButtonToggle()
            UIView.setAnimationsEnabled(false)
            if chatState == oldState {
                ozEmoticonContainer.isHidden = true
                emoticonButtonToggle()
                ozInputTextView.becomeFirstResponder()
                chatState = .chat
            }
            else {
                ozEmoticonContainer.isHidden = false
                self.view.endEditing(true)
                emoticonButtonToggle()
                view.bringSubviewToFront(self.ozEmoticonContainer)
                ozEmoticonContainer.layer.zPosition = CGFloat(MAXFLOAT)
                self.keyboardShowLayout(differHeight: 0, isPadding: true, animated: false)
            }
            UIView.setAnimationsEnabled(true)
        }
        else if state == .voice {
            ozEmoticonContainer.isHidden = true
            emoticonButtonToggle()
            if state == oldState {
                UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
                    self.ozVoiceContainer.alpha = 0.0
                    self.keyboardHideLayout()
                }) { (comp) in
                    self.ozVoiceContainer.isHidden = true
                    self.micButtonToggle()
                }
            }
            else {
                view.endEditing(true)
                self.ozVoiceContainer.alpha = 1.0
                self.ozVoiceContainer.isHidden = false
                view.bringSubviewToFront(ozVoiceContainer)
                ozVoiceContainer.layer.zPosition = CGFloat(MAXFLOAT)
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
            
            var actions: [UIAlertAction] = []
            actions.append(UIAlertAction(title: "Camera".localized, style: .default, handler: { (action) in
                self.handleCameraPermission()
                self.addFileButtonToggle(false)
            }))
            actions.append(UIAlertAction(title: "Album".localized, style: .default, handler: { (action) in
                self.showImagePicker(source: .photoLibrary)
                self.addFileButtonToggle(false)
            }))
            displayActionSheet("Choose file", actions: actions)
        }
        else {
            // Normal chat with text
            resetButtons()
            
            if oldState == .emoticon {
                UIView.setAnimationsEnabled(false)
                ozInputTextView.becomeFirstResponder()
                UIView.setAnimationsEnabled(true)
            }
        }
    }
    
    fileprivate func resetButtons(_ isIncludeEmoticon: Bool = true) {
        ozVoiceContainer.isHidden = true
        micButtonToggle()
        if isIncludeEmoticon {
            ozEmoticonContainer.isHidden = true
            emoticonButtonToggle()
        }
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
        let margin = UIEdgeInsets(top: 0,left: 0, bottom: normalHeight + minTextViewHeight, right: 0)

        if animated, chatState == .chat {
            UIView.animate(withDuration: 0.35, animations: {
                self.ozEmoticonContainerViewHeight.constant = -normalHeight
                self.view.setNeedsUpdateConstraints()
                self.view.layoutIfNeeded()
            }) { (comp) in
                DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
                    self.collectionView.frame = self.view.bounds.inset(by: margin)
                    for case .collectionViewEdgeInsets(var inset) in self.messagesConfigurations {
                        inset.bottom = inset.bottom + minTextViewHeight
                        self.collectionView.contentInset = inset
                        self.collectionView.reloadData()
                    }
                    self.collectionView.scrollTo(edge: UIRectEdge.bottom, animated: false)
                }
            }
        }
        else {
            self.ozEmoticonContainerViewHeight.constant = -normalHeight
            self.view.setNeedsUpdateConstraints()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
                self.collectionView.frame = self.view.bounds.inset(by: margin)
                self.collectionView.scrollTo(edge: UIRectEdge.bottom, animated: false)
            }
        }
        
        if let dele = delegate {
            dele.messageInputTextViewWillShow(insetMarget: margin, keyboardHeight: keyboardHeight)
        }
    }
    fileprivate func keyboardHideLayout() {
        let bottomPadding:CGFloat = 0 //window.safeAreaInsets.bottom
        let margin = UIEdgeInsets(top: 0, left: 0, bottom: bottomPadding + minTextViewHeight, right: 0)

        UIView.animate(withDuration: 0.35, animations: {
            self.ozEmoticonContainerViewHeight.constant = 0
            self.view.setNeedsUpdateConstraints()
            self.view.layoutIfNeeded()
        }) { (comp) in
            self.collectionView.frame = self.view.bounds.inset(by: margin)
            for case .collectionViewEdgeInsets(var inset) in self.messagesConfigurations {
                inset.bottom = inset.bottom + minTextViewHeight
                self.collectionView.contentInset = inset
                self.collectionView.reloadData()
            }
        }
        
        if let dele = delegate {
            dele.messageInputTextViewWillHide(insetMarget: margin, keyboardHeight: keyboardHeight)
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
    @objc func addFileButtonPressed(_ sender: Any) {
        if let dele = delegate,
            dele.messageFileButtonTapped(viewController: self, sender: sender) {
            chatState = .file
        }
    }
    @objc func emoticonButtonViewPressed(_ sender: Any) {
        if let dele = delegate,
            dele.messageEmoticonButtonTapped(viewController: self, sender: sender) {
            chatState = .emoticon
        }
    }
    @objc func micContainerButtonPressed(_ sender: Any) {
        if let dele = delegate,
            dele.messageMicButtonTapped(viewController: self, sender: sender) {
            chatState = .voice
        }
    }

    public func addFileButtonToggle(_ isForceRed: Bool) {
        guard let fbi = ozFileButton.imageView,
            let fileImg = fbi.image else { return }
        
        for case .inputBoxFileButtonTintColor(let color, let selected) in messagesConfigurations {
            //ozFileButton.setImage(fileImg.withRenderingMode(.alwaysTemplate), for: .normal)
            if isForceRed {
                ozFileButton.tintColor = selected
            }
            else {
                ozFileButton.tintColor = color
            }
        }
    }
    fileprivate func micButtonToggle() {
        guard let mbi = ozMicButton.imageView,
            let micImg = mbi.image else { return }
        
        for case .inputBoxMicButtonTintColor(let color, let selected) in messagesConfigurations {
            //ozMicButton.setImage(micImg.withRenderingMode(.alwaysTemplate), for: .normal)
            if chatState == .voice {
                ozMicButton.tintColor = selected
            }
            else {
                ozMicButton.tintColor = color
            }
        }
    }
    fileprivate func emoticonButtonToggle() {
        guard let ebi = ozEmoticonButton.imageView,
            let emotImg = ebi.image else { return }
        
        for case .inputBoxEmoticonButtonTintColor(let color, let selected) in messagesConfigurations {
            //emoticonButton.setImage(emotImg.withRenderingMode(.alwaysTemplate), for: .normal)
            if chatState == .emoticon {
                ozEmoticonButton.tintColor = selected
            }
            else {
                ozEmoticonButton.tintColor = color
            }
        }
    }
}


// MARK: - UITextViewDelegate
extension OZMessagesViewController: UITextViewDelegate {
    public func adjustTextViewHeight(_ textView: UITextView) {
        if textView.text.count <= 0 {
            self.ozTextHeightConstraint.constant = minTextViewHeight
//            self.ozTextHeightConstraint.isActive = true
            self.view.setNeedsUpdateConstraints()
            self.view.layoutIfNeeded()
            return
        }
        
        let width = textView.contentSize.width
        let size = OZMessageCell.sizeForText(textView.text, maxWidth: width,
                                             paddingX: 20.0, paddingY: 20.0)
        
        if self.ozTextHeightConstraint.constant >= maxTextViewHeight {
            UIView.animate(withDuration: 0.35, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: {
                self.ozTextHeightConstraint.constant = maxTextViewHeight
//                self.ozTextHeightConstraint.isActive = true
                self.view.setNeedsUpdateConstraints()
                self.view.layoutIfNeeded()
            }) { (complete) in
            }
        }
        else if self.ozTextHeightConstraint.constant < maxTextViewHeight,
            self.ozTextHeightConstraint.constant < size.height {
            self.ozTextHeightConstraint.constant = size.height
//            self.ozTextHeightConstraint.isActive = true
            self.view.setNeedsUpdateConstraints()
            self.view.layoutIfNeeded()
        }
        else if self.ozTextHeightConstraint.constant < minTextViewHeight {
            self.ozTextHeightConstraint.constant = minTextViewHeight
//            self.ozTextHeightConstraint.isActive = true
            self.view.setNeedsUpdateConstraints()
            self.view.layoutIfNeeded()
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeight(textView)
        
        if let dele = delegate {
            dele.messageTextViewDidChanged(textView: textView)
        }
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        print("textViewDidBeginEditing")
        chatState = .chat
        
        for case .inputTextViewFontColor(let color) in messagesConfigurations {
            textView.textColor = color
        }
        for case .inputTextViewFont(let font) in messagesConfigurations {
            textView.font = font
        }

        if let dele = delegate {
            dele.messageTextViewBeginEditing(textView: textView)
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEditing")
        
        for case .inputTextViewFontColor(let color) in messagesConfigurations {
            textView.textColor = color
        }
        for case .inputTextViewFont(let font) in messagesConfigurations {
            textView.font = font
        }

        if let dele = delegate {
            dele.messageTextViewEndEditing(textView: textView)
        }
    }
    
    // MARK: Send Button Like...!
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var isUsingEnterForSending = false
        for case .inputTextUsingEnterToSend(let yesOrNo) in messagesConfigurations {
            isUsingEnterForSending = yesOrNo
        }
        if isUsingEnterForSending {
            if text == "\n", let fullText = textView.text {
                self.send(msg: fullText)
                self.ozInputTextView.text = ""
                self.adjustTextViewHeight(textView)
                return false;
            }
        }
        
        return true
    }
    
}


// MARK: - UINavigationControllerDelegate & UIImagePickerControllerDelegate
extension OZMessagesViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let chosenImage = info[.editedImage] as? UIImage else { return }
        
        dismiss(animated: true)
        
        guard let imageData = chosenImage.jpegData(compressionQuality: 1) else { return }
        
        if let anImg = UIImage(data: imageData) {
            var imgSize = CGSize(width: 400, height: 400)
            for case .chatImageSize(_, let realSize) in messagesConfigurations {
                imgSize = realSize
            }
            let resizedImage = anImg.resize(width: imgSize.width, height: imgSize.height)
            var maxBytes: Int = 16384
            for case .chatImageMaxNumberOfBytes(let bytes) in messagesConfigurations {
                maxBytes = bytes
            }
            guard let imageData = resizedImage.jpegData(maxNumberOfBytes: maxBytes) else { return }
            saveFile(imageData)
        }
    }

    fileprivate func saveFile(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.5) {
            saveFile(data)
        }
    }
    fileprivate func saveFile(_ data: Data) {
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


extension OZMessagesViewController: OZMessageCellDelegate {
    func messageCellDidSetMessage(cell: OZMessageCell) {
        if let dele = delegate {
            if let currentMessageIndex = dataSource.data.firstIndex(of: cell.message),
                currentMessageIndex - 1 >= 0 {
                let previousMessage = dataSource.data(at: currentMessageIndex - 1)
                dele.messageCellDidSetMessage(cell: cell, previousMessage: previousMessage)
            }
            else {
                dele.messageCellDidSetMessage(cell: cell, previousMessage: OZMessage())
            }
        }
    }
    func messageCellLayoutSubviews(cell: OZMessageCell) {
        if let dele = delegate {
            if let currentMessageIndex = dataSource.data.firstIndex(of: cell.message),
                currentMessageIndex - 1 >= 0 {
                let previousMessage = dataSource.data(at: currentMessageIndex - 1)
                dele.messageCellLayoutSubviews(cell: cell, previousMessage: previousMessage)
            }
            else {
                dele.messageCellLayoutSubviews(cell: cell, previousMessage: OZMessage())
            }
        }
    }
    func messageCellLongMessageFoldingButtons(cell: OZMessageCell) -> [(UIButton, OZMessageFoldState)] {
        var isUsingFold = false
        for case .usingLongMessageFolding(let yesOrNo, _, _, _, _) in messagesConfigurations {
            isUsingFold = yesOrNo
        }
        if isUsingFold {
            for case .usingLongMessageFoldingButtons(let foldButton, let unfoldButton) in messagesConfigurations {
                return [ (foldButton, .fold), (unfoldButton, .unfold)]
            }
        }
        return [(UIButton(), .none)]
    }
    func messageCellLongMessageButtonTapped(cell: OZMessageCell, button: UIButton) {
        /// Long Message Folding Options
        if let aMessage = cell.message,
            aMessage.usingFoldingOption, aMessage.type == .text,
            let index = dataSource.data.firstIndex(of: cell.message) {
            
            aMessage.isFolded.toggle()
            
            dataSource.data[index] = aMessage
            collectionView.setNeedsLayout()
        }

    }
}
