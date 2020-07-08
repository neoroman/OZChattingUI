/*
MIT License

Copyright (c) 2020 OZChattingUI, Henry Kim <neoroman@gmail.com>

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

let minTextViewHeight: CGFloat = 56
let maxTextViewHeight: CGFloat = minTextViewHeight * 3
fileprivate let kTypingBubbleViewTag = 1717259

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
    
    @IBOutlet private weak var inputContainer: UIView!
    @IBOutlet private weak var emoticonButton: UIButton!
    @IBOutlet private weak var micButton: UIButton!
    @IBOutlet private weak var fileButton: UIButton!
    @IBOutlet private weak var inputTextView: OZTextView!
    @IBOutlet private weak var textHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var emoticonContainer: UIView!
    @IBOutlet private weak var emoticonContainerViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var voiceContainer: UIView!

    public var ozInputContainer: UIView?
    public var ozEmoticonButton: UIButton?
    public var ozMicButton: UIButton?
    public var ozFileButton: UIButton?
    public var ozInputTextView: OZTextView?
    public var ozTextHeightConstraint: NSLayoutConstraint?
    public var ozEmoticonContainer: UIView?
    public var ozEmoticonContainerViewHeight: NSLayoutConstraint?
    public var ozVoiceContainer: UIView?
    
    fileprivate var keyboardHeight: CGFloat = 0.0
    fileprivate var keyboardAnimationDuration: TimeInterval = 2.5
    fileprivate var isKeyboardShow: Bool = false
    fileprivate var imagePicker = UIImagePickerController()
    fileprivate var scrollToBottomButton = OZToBottomButton()
    fileprivate var cachedImages: [String: UIImage] = [:]
    fileprivate var visibleRow: Int = 0
    
    public var userIdentifier: String?
    public var isEchoMode: Bool = false
    
    public private(set) var loading = false
    
    public var dataSource = OZMessageDataProvider(data: [])
    public var animator = Animator() {
        didSet {
            if animator is OZMessageAnimator {
                self.setupDataProvider(newDataSource: OZMessageDataProvider(data: dataSource.data))
            }
        }
    }
    private var typingMessageId: String = ""
    private var typingCanVisible: Bool = false
    private var typingBubbleHeight: CGFloat = 0
    private var typingBubbleColor: UIColor = .clear
    private var typingIsVisible: Bool = false {
        willSet {
            for case .showTypingIndicator(let yesOrNo, let height, let color) in messagesConfigurations {
                if yesOrNo {
                    typingCanVisible = true
                    typingBubbleHeight = height
                    typingBubbleColor = color
                }
            }
        }
        didSet {
            guard typingCanVisible, typingIsVisible != oldValue else { return }
            if typingIsVisible {
                let typeMessage = getTypingIndicatorMessage()
                dataSource.data.append(typeMessage)
                collectionView.setNeedsReload()
            }
            else if let typeIndex = dataSource.data.firstIndex(where: {$0.identifier == typingMessageId}) {
                dataSource.data.remove(at: typeIndex)
                collectionView.setNeedsReload()
            }
        }
    }
    public var isTyping: Bool = false {
        didSet {
            guard isTyping != oldValue else { return }
            typingIsVisible = isTyping
        }
    }

    // DONE(2020.06.26): handle with OZChattingDefaultConfiguration.defaulMessageConfiguration()
    private var _messagesConfig: [OZMessagesConfigurationItem] = []
    public var messagesConfigurations: [OZMessagesConfigurationItem] {
        set { _messagesConfig = OZChattingDefaultConfiguration.refineMessegeConfiguration(from: newValue) }
        get {
            if _messagesConfig.count == 0, let dele = delegate {
                _messagesConfig = OZChattingDefaultConfiguration.refineMessegeConfiguration(from: dele.messageConfiguration(viewController: self))
            }
            return _messagesConfig
        }
    }
    
    fileprivate var isChatViewFirstLoaded = false
    
    // MARK: - View did loaded
    override open func viewDidLoad() {
        super.viewDidLoad()

        guard delegate != nil else {
            fatalError("Important !!!, we need to set delegate before calling super.viewDidLoad()")
        }
        
        view.clipsToBounds = true
        setupIBOutlets()
        setupUI()

        collectionView.delegate = self

        let inset = UIEdgeInsets(top: 30, left: 0, bottom: 54, right: -5) // Right(-5px) is max
        collectionView.scrollIndicatorInsets = inset
        collectionView.indicatorStyle = .black
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alpha = 0.3
        setupDataProvider()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadCollectionViewFrame(nil, forceReload: true)

        if !isChatViewFirstLoaded, let dele = delegate {
            isChatViewFirstLoaded = true
            dele.messageViewLoaded(isLoaded: isViewLoaded)
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                self.collectionView.alpha = 1.0
            }) { (complete) in
                    self.animator = OZMessageAnimator()
            }

            if !isViewLoaded {
                delay(0.2) {
                    dele.messageViewLoaded(isLoaded: self.isViewLoaded)
                    self.animator = OZMessageAnimator()
                }
            }
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        for i in 0..<dataSource.data.count {
            guard let anAudioCell = collectionView.cell(at: i) as? AudioMessageCell else { continue }
            if anAudioCell.isPlaying {
                anAudioCell.playOrStop()
            }
        }
    }
        
    // MARK: - Orientations
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let inset = UIEdgeInsets(top: 30, left: 0, bottom: 54, right: -5) // Right(-5px) is max
        collectionView.scrollIndicatorInsets = inset
        collectionView.indicatorStyle = .black

        reloadCollectionViewFrame(size, forceReload: true)
    }
    
    
    // MARK: - Setup collectionView Frame
    open func getSafeInsetBottom(isBottomOnly: Bool = false) -> CGFloat {
        var safeInsetBottom: CGFloat = 0
        if #available(iOS 11.0, *) {
            safeInsetBottom = super.view.safeAreaInsets.bottom + (isBottomOnly ? 0 : super.view.safeAreaInsets.top)
            if safeInsetBottom < view.safeAreaInsets.bottom + (isBottomOnly ? 0 : view.safeAreaInsets.top) {
                safeInsetBottom = view.safeAreaInsets.bottom + (isBottomOnly ? 0 : view.safeAreaInsets.top)
            }
        } else {
            // Fallback on earlier versions
        }
        return safeInsetBottom
    }
    open func getBoundsBySaferArea(givenSize: CGSize? = .zero) -> CGRect {
        var sBounds = super.view.bounds
        let width: CGFloat = min(UIScreen.main.bounds.height, UIScreen.main.bounds.width)

        if UIDevice.current.orientation.isLandscape {
            if sBounds.width < sBounds.height {
                let temp = sBounds.width
                sBounds.size.width = sBounds.height
                sBounds.size.height = temp
            }
            sBounds.origin.x = getSafeInsetBottom()
            if sBounds.width < width {
                sBounds.size.width = width - (getSafeInsetBottom(isBottomOnly: true) * 2)
            }
        }
        else if UIDevice.current.orientation.isPortrait,
            let size = givenSize, size != .zero,
            size.width < super.view.bounds.width {
            sBounds.size.width = size.width
            sBounds.size.height = size.height - getSafeInsetBottom()
            sBounds.origin.x = 0
            if sBounds.width < width {
                sBounds.size.width = width
            }
        }
        else {
            if sBounds.width > sBounds.height {
                let temp = sBounds.height
                sBounds.size.height = sBounds.width
                sBounds.size.width = temp
            }
            sBounds.origin.x = 0
            sBounds.size.height = sBounds.size.height - getSafeInsetBottom()
            if sBounds.width < width {
                sBounds.size.width = width
            }
        }
        return sBounds
    }
    
    open func reloadCollectionViewFrame(_ to: CGSize? = nil, forceReload: Bool = false, bottomInset: CGFloat = 0) {
        
        var boInset: CGFloat = minTextViewHeight
        for case .inputContainerMinimumHeight(let height) in messagesConfigurations {
            boInset = height
        }
        if isKeyboardShow, keyboardHeight > 0 {
            boInset += keyboardHeight
        }
        if bottomInset != 0, bottomInset > boInset {
            boInset = bottomInset
        }
        
        var isCustomFrame = false
        var bounds = getBoundsBySaferArea().inset(by: UIEdgeInsets(top: 0, left: 0, bottom: boInset, right: 0))
        for case .customCollectionViewFrame(let yesOrNo, let rect, let row) in self.messagesConfigurations {
            if yesOrNo {
                isCustomFrame = yesOrNo
                bounds = rect
                visibleRow = row
                
                let height = self.getHeightOfFrame(rect: rect, row: row)
                if rect.height < height {
                    bounds.size.height = height
                }
            }
        }
        print("collectionViewFrame = \(bounds)")
        collectionView.frame = bounds
        
        if forceReload {
            for case .collectionViewEdgeInsets(let inset) in self.messagesConfigurations {
                if !isCustomFrame { self.collectionView.contentInset = inset }
                else {
                    let originInset = self.collectionView.contentInset
                    let newInset = UIEdgeInsets(top: originInset.top, left: inset.left,
                                                bottom: originInset.bottom, right: inset.right)
                    self.collectionView.contentInset = newInset
                }
            }
            
            collectionView.reloadData() { // 1st call
                return CGPoint(x: self.collectionView.contentOffset.x,
                               y: self.collectionView.offsetFrame.maxY)
            }
        }
        else {
            collectionView.setNeedsReload()
            var isAutoScrollToBottom = true
            for case .autoScrollToBottomNewMessageArrived(let yesOrNo) in messagesConfigurations {
                isAutoScrollToBottom = false
                if yesOrNo {
                    collectionView.scrollTo(edge: .bottom, animated: false)
                }
            }
            if isAutoScrollToBottom {
                collectionView.scrollTo(edge: .bottom, animated: false)
            }
        }
    }
    
    
    // MARK: - Setup Images in CollectionView
    fileprivate func setupImageView(path: String) -> UIImage? {
        if path.count > 0 {
            var image: UIImage? = nil
            
            if path.lowercased().hasPrefix("file"),
                let anUrl = URL(string: path),
                FileManager.default.isReadableFile(atPath: anUrl.relativePath),
                let data = FileManager.default.contents(atPath: anUrl.relativePath),
                let anImage = UIImage(data: data) {
                // Local file with fileURL
                image = anImage
            }
            else if path.hasPrefix("/"),
                FileManager.default.isReadableFile(atPath: path),
                let data = FileManager.default.contents(atPath: path),
                let anImage = UIImage(data: data) {
                // Local file with relative path
                image = anImage
            }
            else {
                image = UIImage(named: path)
            }
            
            return image
        }
        return nil
    }
    fileprivate func getImage(identifier: String, message: OZMessage) -> UIImage? {
        guard let cachedImage = cachedImages[identifier] else {
            if let image = setupImageView(path: message.content) {
                cachedImages[message.identifier] = image
                return image
            }
            return nil
        }
        return cachedImage
    }
    fileprivate func getMultipleImages(message: OZMessage) -> [UIImage] {
        let pathArray = message.content.components(separatedBy: "|")
        var images: [UIImage] = []
        for index in 0..<pathArray.count {
            if let anImage = cachedImages[pathArray[index]] {
                images.append(anImage)
            }
            else if let anImage = setupImageView(path: pathArray[index]) {
                cachedImages[pathArray[index]] = anImage
                images.append(anImage)
            }
        }
        return images
    }

    
    // MARK: - Setup CollectionKit DataProvider
    public func setupDataProvider(newDataSource: OZMessageDataProvider? = nil) {
        let textMessageViewSource = ClosureViewSource(viewUpdater: { (view: TextMessageCell, data: OZMessage, at: Int) in
            view.delegate = self
            view.message = data
        })
        let statusMessageViewSource = ClosureViewSource(viewUpdater: { (view: StatusMessageCell, data: OZMessage, at: Int) in
            view.delegate = self
            view.message = data
        })
        let imageMessageViewSource = ClosureViewSource(viewUpdater: { (view: ImageMessageCell, data: OZMessage, at: Int) in
            view.delegate = self
            view.message = data
            if data.type == .emoticon {
                view.imageView.contentMode = .scaleAspectFit
                view.imageView.image = UIImage(named: data.content)
            }
            else if let anImage = self.getImage(identifier: data.identifier, message: data) {
                view.imageView.contentMode = .scaleAspectFill
                view.imageView.image = anImage
                data.imageSize = anImage.size
            }
        })
        let multipleImagesMessageViewSource = ClosureViewSource(viewUpdater: { (view: MultipleImageMessageCell, data: OZMessage, at: Int) in
            view.delegate = self
            view.message = data
            
            var imageViews: [UIImageView] = []
            var count: CGFloat = 0
            for anImage in self.getMultipleImages(message: data) {
                let anImageView = UIImageView()
                anImageView.contentMode = .scaleAspectFill
                anImageView.image = anImage
                imageViews.append(anImageView)
                count += 1
            }
            view.imageViews = imageViews
            
            let rows: CGFloat = count / 3 + 1
            let height = max(data.cellHeight, data.chatImageSize.height) * rows
            var paddingX = data.alignment == .left ? data.cellLeftPadding : data.cellPadding
            if data.alignment == .right {
                paddingX = data.cellRightPadding
            }
            data.imageSize = CGSize(width: self.collectionView.contentSize.width - paddingX, height: height)
        })
        let deviceStatusViewSource = ClosureViewSource(viewUpdater: { (view: IncomingStatusMessageCell, data: OZMessage, at: Int) in
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
        if let anim = animator as? OZMessageAnimator {
            anim.sourceView = ozInputContainer
            anim.dataSource = dataSource
        }

        let visibleFrameInsets = UIEdgeInsets(top: -200, left: 0, bottom: -200, right: 0)
        self.provider = BasicProvider(
            identifier: "OZChat2020",
            dataSource: dataSource,
            viewSource: ComposedViewSource(viewSourceSelector: { data in
                data.delegate = self
                switch data.type {
                case .image, .emoticon:
                    return imageMessageViewSource
                case .text:
                    return textMessageViewSource
                case .deviceStatus:
                    return deviceStatusViewSource
                case .mp3, .voice:
                    return audioViewSource
                case .multipleImages:
                    return multipleImagesMessageViewSource
                default:
                    return statusMessageViewSource
                }
            }),
            layout: OZMessageLayout().insetVisibleFrame(by: visibleFrameInsets),
            animator: animator,
            // MARK: ******** Cell Tap Handler here *******
            tapHandler: { [weak self] context in
                if let dele = self?.delegate, let ozCell = context.view as? OZMessageCell {
                    //self?.cellTapped(data: context.data, view: context.view) // Not Available, unless context generic understood by Henry on 2020.05.06 => error as 'Generic parameter 'Data' could not be inferred'
                    self?.cellTapped(context: context) // Not Available, unless context generic understood by Henry on 2020.05.06
                    
                    let aMessage = context.data
                    
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
            collectionView.reloadData() { // 1st call
                return CGPoint(x: self.collectionView.contentOffset.x,
                               y: self.collectionView.offsetFrame.maxY)
            }
        }
        if isAtBottom, !collectionView.hasReloaded, !collectionView.isReloading {
            collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x,
                                                    y: collectionView.offsetFrame.maxY), animated: false)
        }
        if isKeyboardShow || chatState == .emoticon {
            keyboardShowLayout(isPadding: true, animated: false)
        }
    }
    
    // MARK: - Navigation
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "emoticon_view_segue",
            let vc = segue.destination as? OZEmoticonViewController {
            vc.delegate = self
            emoticonViewController = vc
            if let evc = ozEmoticonContainer {
                vc.view.frame = evc.bounds
            }
        }
        else if segue.identifier == "record_view_segue",
            let vc = segue.destination as? OZVoiceRecordViewController {
            vc.delegate = self
            voiceViewController = vc
            if let aVoiceContainer = ozVoiceContainer {
                vc.view.frame = aVoiceContainer.bounds
            }
        }
    }

    
    // MARK: - Setup Input TextView Height Constraint
    fileprivate let inputTextContstraintIDs = ["inputTextContainerCenter",
                                               "inputTextContainerWidth",
                                               "inputTextContainerBottom",
                                               "inputTextContainerHeight"]
    
    fileprivate func setupInputTextContainerViewFrame(height: CGFloat = minTextViewHeight) {
        guard let ic = ozInputContainer else {return}
        
        self.removeContraint(fromList: inputTextContstraintIDs)
        ic.translatesAutoresizingMaskIntoConstraints = false
        
        // centerX
        let containerXCenter: NSLayoutConstraint = NSLayoutConstraint(item: ic as Any, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        containerXCenter.identifier = inputTextContstraintIDs[0]
        
        // Width
        let containerWidth: NSLayoutConstraint = NSLayoutConstraint(item: ic as Any, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: 0)
        containerWidth.identifier = inputTextContstraintIDs[1]
        
        // Bottom
        if #available(iOS 11.0, *) {
            ozEmoticonContainerViewHeight = NSLayoutConstraint(item: ic, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
        } else {
            ozEmoticonContainerViewHeight = NSLayoutConstraint(item: ic, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
        }
        ozEmoticonContainerViewHeight?.identifier = inputTextContstraintIDs[2]
        
        // Vertical Spacing
        var minHeight = height
        for case .inputContainerMinimumHeight(let height) in messagesConfigurations {
            minHeight = height
        }
        ozTextHeightConstraint = ic.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight)
        ozTextHeightConstraint?.identifier = inputTextContstraintIDs[3]
        
        self.view.setNeedsUpdateConstraints()
        
        guard let ecvh = ozEmoticonContainerViewHeight else {return}
        guard let thc = ozTextHeightConstraint else {return}
        
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: .curveEaseInOut, animations: {
            self.view.addConstraints([ecvh, containerWidth, containerXCenter, thc])
            self.view.layoutIfNeeded()
        }) { (complete) in
            //code
        }
    }
    fileprivate let textViewContstraintIDs = ["textViewLeading", "textViewTrail",
                                               "textViewTop", "textViewBottom"]
    fileprivate func setupTextViewFrame() {
        guard let ic = ozInputContainer, let itv = ozInputTextView, let fb = ozFileButton else {return}

        self.removeContraint(fromList: textViewContstraintIDs)
        itv.translatesAutoresizingMaskIntoConstraints = false
        
        // Leading
        let textViewLeading = NSLayoutConstraint(item: itv as Any, attribute: .leading, relatedBy: .equal, toItem: fb as Any, attribute: .trailing, multiplier: 1, constant: 10)
        textViewLeading.identifier = textViewContstraintIDs[0]
        
        // Trailing
        let textViewTrailing = NSLayoutConstraint(item: itv as Any, attribute: .trailing, relatedBy: .equal, toItem: ic as Any, attribute: .trailing, multiplier: 1, constant: -10)
        textViewTrailing.identifier = textViewContstraintIDs[1]
        
        // Top
        let textViewTop = NSLayoutConstraint(item: itv, attribute: .top, relatedBy: .equal, toItem: ic, attribute: .top, multiplier: 1, constant: 10)
        textViewTop.identifier = textViewContstraintIDs[2]
        
        // Bottom
        let textViewBottom = NSLayoutConstraint(item: itv as Any, attribute: .bottom, relatedBy: .equal, toItem: ic as Any, attribute: .bottom, multiplier: 1, constant: -10)
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
        guard let ic = ozInputContainer, let fb = ozFileButton else {return}

        self.removeContraint(fromList: fileButtonContstraintIDs)
        fb.translatesAutoresizingMaskIntoConstraints = false
        
        // Leading
        let fileButtonLeading = NSLayoutConstraint(item: fb as Any, attribute: .leading, relatedBy: .equal, toItem: ic as Any, attribute: .leading, multiplier: 1, constant: 10)
        fileButtonLeading.identifier = textViewContstraintIDs[0]
        
        // Width
        let fileButtonWidth = fb.widthAnchor.constraint(equalToConstant: 30)
        fileButtonWidth.identifier = textViewContstraintIDs[1]
        
        // Height
        let fileButtonHeight = fb.heightAnchor.constraint(equalToConstant: 30)
        fileButtonHeight.identifier = textViewContstraintIDs[2]
        
        // Bottom
        var minHeight = minTextViewHeight
        for case .inputContainerMinimumHeight(let height) in messagesConfigurations {
            minHeight = height
        }
        let fileButtonBottom = NSLayoutConstraint(item: fb as Any, attribute: .bottom, relatedBy: .equal, toItem: ic as Any, attribute: .bottom, multiplier: 1, constant: -(minHeight/2 - 15))
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
        guard let ic = ozInputContainer, let mb = ozMicButton else {return}

        self.removeContraint(fromList: micButtonContstraintIDs)
        mb.translatesAutoresizingMaskIntoConstraints = false
        
        // Trailing
        let micButtonTrail = NSLayoutConstraint(item: mb as Any, attribute: .trailing, relatedBy: .equal, toItem: ic as Any, attribute: .trailing, multiplier: 1, constant: -15)
        micButtonTrail.identifier = micButtonContstraintIDs[0]
        
        // Width
        let micButtonWidth = mb.widthAnchor.constraint(equalToConstant: 30)
        micButtonWidth.identifier = micButtonContstraintIDs[1]
        
        // Height
        let micButtonHeight = mb.heightAnchor.constraint(equalToConstant: 30)
        micButtonHeight.identifier = micButtonContstraintIDs[2]
        
        // Bottom
        var minHeight = minTextViewHeight
        for case .inputContainerMinimumHeight(let height) in messagesConfigurations {
            minHeight = height
        }
        let micButtonBottom = NSLayoutConstraint(item: mb as Any, attribute: .bottom, relatedBy: .equal, toItem: ic as Any, attribute: .bottom, multiplier: 1, constant: -(minHeight/2 - 15))
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
        guard let ic = ozInputContainer, let eb = ozEmoticonButton, let mb = ozMicButton else {return}

        self.removeContraint(fromList: emoticonButtonContstraintIDs)
        eb.translatesAutoresizingMaskIntoConstraints = false
        
        // Trailing
        let emoticonButtonTrail = NSLayoutConstraint(item: eb as Any, attribute: .trailing, relatedBy: .equal, toItem: mb as Any, attribute: .leading, multiplier: 1, constant: -10)
        emoticonButtonTrail.identifier = emoticonButtonContstraintIDs[0]
        
        // Width
        let emoticonButtonWidth = eb.widthAnchor.constraint(equalToConstant: 30)
        emoticonButtonWidth.identifier = emoticonButtonContstraintIDs[1]
        
        // Height
        let emoticonButtonHeight = eb.heightAnchor.constraint(equalToConstant: 30)
        emoticonButtonHeight.identifier = emoticonButtonContstraintIDs[2]
        
        // Bottom
        var minHeight = minTextViewHeight
        for case .inputContainerMinimumHeight(let height) in messagesConfigurations {
            minHeight = height
        }
        let emoticonButtonBottom = NSLayoutConstraint(item: eb as Any, attribute: .bottom, relatedBy: .equal, toItem: ic as Any, attribute: .bottom, multiplier: 1, constant: -(minHeight/2 - 15))
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

    fileprivate func setupScrollToBottomButton(_ isShow: Bool = false) {
        guard let ozic = self.ozInputContainer, !ozic.isHidden else { return }

        var myOrigin = CGPoint.zero
        var mySize = CGSize.zero
        for case .scrollToBottomButton(let origin, let size, let width, let stroke, let fill, let alpha) in messagesConfigurations {
            var height: CGFloat = 36
            
            if size != .zero {
                mySize = size
                height = size.height
            }
            else {
                mySize = CGSize(width: height, height: height)
            }
            if origin != .zero {
                myOrigin = origin
            }
            else {
                myOrigin = CGPoint(x: ozic.frame.maxX - height - 5, y: ozic.frame.minY - height - 5)
            }
            scrollToBottomButton.alpha = isShow ? 1 : 0 //alpha
            scrollToBottomButton.fillColor = fill.withAlphaComponent(alpha)
            scrollToBottomButton.strokeWidth = width
            scrollToBottomButton.strokeColor = stroke.withAlphaComponent(alpha)
        }
        scrollToBottomButton.frame = CGRect(origin: myOrigin, size: mySize)
        
        if scrollToBottomButton.superview == nil {
            scrollToBottomButton.addTarget(self, action: #selector(self.scrollToBottomButtonTapped), for: .touchUpInside)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.view.addSubview(self.scrollToBottomButton)
            }) { (success) in
            }
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
                   isEchoable: Bool? = nil,
                   callback: ((_ identifier: String, _ sendingContentPath: String) -> Void)? = nil) {
        guard let text = msg, text.count > 0 else { return }
        
        var sendingMsg: OZMessage!
        
        var anImgName = ""
        for case .profileIconName(let name, _, let userType) in self.messagesConfigurations {
            if userType == .fromCurrent {
                anImgName = name
            }
        }

        DispatchQueue.main.async {
            if type == .image {
                sendingMsg = OZMessage(true, image: text, iconImage: anImgName, config: self.messagesConfigurations)
            }
            else if type == .multipleImages {
                sendingMsg = OZMessage(true, multipleImages: text, iconImage: anImgName, config: self.messagesConfigurations)
            }
            else if type == .emoticon {
                sendingMsg = OZMessage(true, emoticon: text, iconImage: anImgName, config: self.messagesConfigurations)
            }
            else if type == .mp3 {
                sendingMsg = OZMessage(true, mp3: text, iconImage: anImgName, config: self.messagesConfigurations)
            }
            else if type == .voice {
                sendingMsg = OZMessage(true, voice: text, iconImage: anImgName, config: self.messagesConfigurations)
            }
            else if type == .announcement {
                sendingMsg = OZMessage(announcement: text, config: self.messagesConfigurations)
            }
            else if type == .status {
                sendingMsg = OZMessage(true, status: text, iconImage: anImgName, config: self.messagesConfigurations)
            }
            else {
                sendingMsg = OZMessage(true, content: text, iconImage: anImgName, config: self.messagesConfigurations)
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
            
            delay(1.0) {
                var isEchoEnabled = self.isEchoMode
                if let echo = isEchoable {
                    isEchoEnabled = echo
                }
                if isEchoEnabled, type.isEchoEnable() {
                    var anImgName = ""
                    for case .profileIconName(let name, _, let userType) in self.messagesConfigurations {
                        if userType == .fromOther {
                            anImgName = name
                        }
                    }
                    
                    self.dataSource.data.append(sendingMsg.copy(self.messagesConfigurations, userSide: !sendingMsg.fromCurrentUser, userProfile: anImgName))
                    self.collectionView.reloadData() // send echo (for debugging)
                    var isAutoScrollToBottom = true
                    for case .autoScrollToBottomNewMessageArrived(let yesOrNo) in self.messagesConfigurations {
                        isAutoScrollToBottom = false
                        if yesOrNo {
                            self.collectionView.scrollTo(edge: .bottom, animated:true)
                        }
                    }
                    if isAutoScrollToBottom {
                        self.collectionView.scrollTo(edge: .bottom, animated:true)
                    }
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

        var anImgName = ""
        for case .profileIconName(let name, _, let userType) in self.messagesConfigurations {
            if userType == .fromOther {
                anImgName = name
            }
        }

        DispatchQueue.main.async {
            if let anim = self.animator as? OZMessageAnimator {
                anim.sendingMessage = true
            }
            
            let aTimestamp = timestamp > 0 ? timestamp : Int(Date().timeIntervalSince1970)
            if type == .image {
                self.dataSource.data.append(OZMessage(false, image: text, timestamp: aTimestamp, iconImage: anImgName, config: self.messagesConfigurations))
            }
            else if type == .multipleImages {
                 self.dataSource.data.append(OZMessage(false, multipleImages: text, iconImage: anImgName, config: self.messagesConfigurations))
            }
            else if type == .mp3 {
                self.dataSource.data.append(OZMessage(false, mp3: text, duration: duration, timestamp: aTimestamp, iconImage: anImgName, config: self.messagesConfigurations))
            }
            else if type == .emoticon {
                self.dataSource.data.append(OZMessage(false, emoticon: text, timestamp: aTimestamp, iconImage: anImgName, config: self.messagesConfigurations))
            }
            else if type == .voice {
                self.dataSource.data.append(OZMessage(false, mp3: text, duration: duration, timestamp: aTimestamp, iconImage: anImgName, config: self.messagesConfigurations))
            }
            else if type == .deviceStatus, let aType = activeType {
                self.dataSource.data.append(OZMessage(deviceStatus: text, statusType: aType, iconNamed: nil, timestamp: aTimestamp, config: self.messagesConfigurations))
            }
            else {
                self.dataSource.data.append(OZMessage(false, content: text, timestamp: aTimestamp, iconImage: anImgName, config: self.messagesConfigurations))
            }
            
            if self.typingCanVisible {
                self.isTyping = false
            }

            self.collectionView.reloadData() //receive
            
            var isAutoScrollToBottom = true
            for case .autoScrollToBottomNewMessageArrived(let yesOrNo) in self.messagesConfigurations {
                // TODO: do something here on 2020.06.27
//                if self.getThresholdOfScrollToBottomButtonShow() > self.collectionView.contentSize.height {
//                    isAutoScrollToBottom = false
//                }
                isAutoScrollToBottom = false
                if yesOrNo {
                    self.collectionView.scrollTo(edge: .bottom, animated:true)
                }
            }
            if isAutoScrollToBottom {
                self.collectionView.scrollTo(edge: .bottom, animated:true)
            }
            else {
                for case .scrollToBottomNewMessageBadge(
                    let showBadge, let fontName,
                    let fontSize, let height,
                    let textColor, let bgColor) in self.messagesConfigurations {
                        if showBadge {
                            for case .autoScrollToBottomBeginTextInput(_, let showButton) in self.messagesConfigurations {
                                if showButton {
                                    let count = self.scrollToBottomButton.badgeCount + 1
                                    self.scrollToBottomButton.showBadge(count: count, fontName: fontName, fontSize: fontSize, height: height, textColor: textColor, backgroundColor: bgColor)
                                }
                            }
                        }
                }
            }
            if let anim = self.animator as? OZMessageAnimator {
                anim.sendingMessage = false
            }
        }
    }
}


// MARK: - UIScrollViewDelegate for CollectionKit
extension OZMessagesViewController: UIScrollViewDelegate {
    public func getHeightOfFrame(rect: CGRect, row: Int) -> CGFloat {
        var height: CGFloat = 0

        if row > 0 {
            let startIndex = dataSource.data.count - row
            if startIndex >= 0, startIndex < dataSource.data.count {
                for i in startIndex..<dataSource.data.count {
                    height += OZMessageCell.frameForMessage(dataSource.data[i], containerWidth: collectionView.contentSize.width).height
                }
                if rect.height > height {
                    height = rect.height
                }
            }
        }
        return height
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // PULL TO LOAD MORE
        // load more messages if we scrolled to the top
        if dataSource.data.count > 0,
            let datum = dataSource.data.first,
            datum.content.count > 0 {
            
            if collectionView.hasReloaded, !loading, visibleRow > 0 {
                loading = true
                for case .customCollectionViewFrame(let isCustom, let rect, _) in messagesConfigurations {
                    if isCustom {
                        collectionView.frame.size.height = getHeightOfFrame(rect: rect, row: visibleRow)
                        collectionView.contentInset.bottom = 0
                        return
                    }
                }
                loading = false
            }
            
            if collectionView.hasReloaded,
                scrollView.contentOffset.y < 500,
                !loading, let dele = delegate {
                loading = true
                delay(0.5) { // Simulate network request
                    dele.messageAppend { (newMessages) in
                        if newMessages.count > 0 {
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
            
            let threshold = getThresholdOfScrollToBottomButtonShow()
            if  threshold > collectionView.contentSize.height,
                scrollToBottomButton.superview != nil {
                UIView.animate(withDuration: 0.25, animations: {
                    self.scrollToBottomButton.alpha = 0
                }) { (success) in
                    self.scrollToBottomButton.badgeCount = 0
                    self.scrollToBottomButton.removeFromSuperview()
                }
            }
            else if threshold <= collectionView.contentSize.height {
                for case .autoScrollToBottomBeginTextInput(_, let isShow) in self.messagesConfigurations {
                    if isShow {
                        self.setupScrollToBottomButton(true)
                    }
                    else {
                        self.scrollToBottomButton.alpha = 0
                    }
                }
            }
        }
    }
    
    func getThresholdOfScrollToBottomButtonShow() -> CGFloat {
        return collectionView.contentOffset.y + collectionView.bounds.height + 50
    }
}


// MARK: - Setup UI
extension OZMessagesViewController {
    fileprivate func setupIBOutlets() {
        
        var minHeight = minTextViewHeight
        for case .inputContainerMinimumHeight(let height) in messagesConfigurations {
            minHeight = height
        }

        /// Input Container
        if let ic = inputContainer {
            ozInputContainer = ic
        }
        else {
            if #available(iOS 11.0, *) {
                let bottomInset: CGFloat = view.safeAreaInsets.bottom
                let origin = CGPoint(x: 0, y: self.view.bounds.height - minHeight - bottomInset)
                let size = CGSize(width: self.view.bounds.width, height: minHeight)
                ozInputContainer = UIView(frame: CGRect(origin: origin, size: size))
                guard let ic = ozInputContainer else {return}
                
                ic.backgroundColor = .white
                view.addSubview(ic)
                
                let guide = view.safeAreaLayoutGuide
                NSLayoutConstraint.activate([
                    ic.heightAnchor.constraint(equalToConstant: minHeight),
                    guide.bottomAnchor.constraint(equalToSystemSpacingBelow: ic.bottomAnchor, multiplier: 1.0)
                ])
            } else {
                let origin = CGPoint(x: 0, y: self.view.bounds.height - minHeight)
                let size = CGSize(width: self.view.bounds.width, height: minHeight)
                ozInputContainer = UIView(frame: CGRect(origin: origin, size: size))
                guard let ic = ozInputContainer else {return}

                ic.backgroundColor = .white
                view.addSubview(ic)
                
                let standardSpacing: CGFloat = minHeight
                NSLayoutConstraint.activate([
                    ic.heightAnchor.constraint(equalToConstant: standardSpacing),
                    bottomLayoutGuide.topAnchor.constraint(equalTo: ic.bottomAnchor, constant: standardSpacing)
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
            guard let fb = ozFileButton else {return}
            guard let ic = ozInputContainer else {return}

            fb.center = CGPoint(x: fb.center.x, y: ic.bounds.midY)
            fb.setImage(UIImage(named: "addFile"), for: .normal)
            ic.addSubview(fb)
        }
        
        /// Input TextView
        if let itv = inputTextView {
            ozInputTextView = itv
        }
        else {
            guard let fb = ozFileButton else {return}

            let origin = CGPoint(x: fb.frame.maxX + 10, y: 10)
            let size = CGSize(width: self.view.bounds.width - 10 - origin.x, height: minHeight * 0.65)
            ozInputTextView = OZTextView(frame: CGRect(origin: origin, size: size))
            guard let itv = ozInputTextView else {return}
            guard let ic = ozInputContainer else {return}

            itv.delegate = self
            itv.backgroundColor = UIColor(white: 244/255, alpha: 1.0)
            ic.addSubview(itv)
        }

        /// Emoticon button
        if let eb = emoticonButton {
            ozEmoticonButton = eb
        }
        else {
            guard let itv = ozInputTextView else {return}

            let origin = CGPoint(x: itv.frame.maxX - 30*2 - 10*2, y: 10)
            let size = CGSize(width: 30, height: 30)
            ozEmoticonButton = UIButton(frame: CGRect(origin: origin, size: size))
            guard let eb = ozEmoticonButton else {return}
            guard let ic = ozInputContainer else {return}

            eb.center = CGPoint(x: eb.center.x, y: ic.bounds.midY)
            eb.setImage(UIImage(named: "emo"), for: .normal)
            ic.addSubview(eb)
        }

        /// Mic button
        if let mb = micButton {
            ozMicButton = mb
        }
        else {
            guard let itv = ozInputTextView else {return}

            let origin = CGPoint(x: itv.frame.maxX - 30 - 10, y: 10)
            let size = CGSize(width: 30, height: 30)
            ozMicButton = UIButton(frame: CGRect(origin: origin, size: size))
            guard let mb = ozMicButton else {return}
            guard let ic = ozInputContainer else {return}

            mb.center = CGPoint(x: mb.center.x, y: ic.bounds.midY)
            mb.setImage(UIImage(named: "mic"), for: .normal)
            ic.addSubview(mb)
        }
        
        /// Emoticon Container View
        if let ecv = emoticonContainer {
            ozEmoticonContainer = ecv
        }
        else {
            print("Need to implement emoticon container view")
        }
        
        /// Mic Container View
        if let mcv = voiceContainer {
            ozVoiceContainer = mcv
        }
        else {
            print("Need to implement mic container view")
        }

        /// AutoLayout Constraints
        if let thc = textHeightConstraint, let ehc = emoticonContainerViewHeight {
            ozTextHeightConstraint = thc
            ozEmoticonContainerViewHeight = ehc
        }
        else {
            setupInputTextContainerViewFrame(height: minHeight)
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
        if let itv = ozInputTextView {
            itv.delegate = self
            itv.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 70)
            itv.layer.cornerRadius = 18
            itv.layer.masksToBounds = true
            itv.clipsToBounds = true
            for case .inputTextVerticalAlignment(let alignment) in messagesConfigurations {
                itv.verticalAlignment = alignment
            }
        }
        
        // Chatting view related
        if let ec = ozEmoticonContainer {
            ec.isHidden = true
        }
        if let vc = ozVoiceContainer {
            vc.isHidden = true
        }
        
        // Connect Target
        if let fb = ozFileButton {
            fb.addTarget(self, action: #selector(addFileButtonPressed(_:)), for: .touchUpInside)
            setColorOfFileButton()
        }
        if let mb = ozMicButton {
            mb.addTarget(self, action: #selector(micContainerButtonPressed(_:)), for: .touchUpInside)
            setColorOfMicButton()
        }
        if let eb = ozEmoticonButton {
            eb.addTarget(self, action: #selector(emoticonButtonViewPressed(_:)), for: .touchUpInside)
            setColorOfEmoticonButton()
        }
        
        resetButtons()
        
        // Drop shadow
        if let ic = ozInputContainer {
            ic.layer.shadowColor = UIColor.black.cgColor
            ic.layer.shadowOffset = CGSize(width: 0, height: -5.0)
            ic.layer.shadowRadius = 4.0
            ic.layer.shadowOpacity = 0.01
            ic.layer.masksToBounds = false
            view.bringSubviewToFront(ic)
        }
    }

    func reloadAllView(_ state: OZMessagesViewState = .chat, oldState: OZMessagesViewState? = nil) {
        
        if state == .emoticon {
            if let vc = ozVoiceContainer {
                vc.isHidden = true
                micButtonToggle()
            }
            
            guard let ec = ozEmoticonContainer else {return}
            UIView.setAnimationsEnabled(false)
            if chatState == oldState {
                ec.isHidden = true
                emoticonButtonToggle()
                if let itv = ozInputTextView {
                    itv.becomeFirstResponder()
                }
                chatState = .chat
            }
            else {
                ec.isHidden = false
                self.view.endEditing(true)
                emoticonButtonToggle()
                view.bringSubviewToFront(ec)
                ec.layer.zPosition = CGFloat(MAXFLOAT)
                self.keyboardShowLayout(isPadding: true, animated: false)
            }
            UIView.setAnimationsEnabled(true)
        }
        else if state == .voice {
            if let ec = ozEmoticonContainer {
                ec.isHidden = true
                emoticonButtonToggle()
            }
            
            guard let vc = ozVoiceContainer else {return}
            if state == oldState {
                UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
                    vc.alpha = 0.0
                    self.keyboardHideLayout()
                }) { (comp) in
                    vc.isHidden = true
                    self.micButtonToggle()
                }
            }
            else {
                view.endEditing(true)
                vc.alpha = 1.0
                vc.isHidden = false
                view.bringSubviewToFront(vc)
                vc.layer.zPosition = CGFloat(MAXFLOAT)
                UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
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
            
            if oldState == .emoticon, let itv = ozInputTextView {
                UIView.setAnimationsEnabled(false)
                itv.becomeFirstResponder()
                UIView.setAnimationsEnabled(true)
            }
        }
    }
    
    fileprivate func resetButtons(_ isIncludeEmoticon: Bool = true) {
        if let vc = ozVoiceContainer {
            vc.isHidden = true
            micButtonToggle()
        }
        if isIncludeEmoticon, let ec = ozEmoticonContainer {
            ec.isHidden = true
            emoticonButtonToggle()
        }
        addFileButtonToggle(false)
    }
    
    fileprivate func setColorOfFileButton() {
        if let fb = ozFileButton, let fbi = fb.imageView, let fileImg = fbi.image {
            for case .inputBoxFileButtonTintColor(let color, _) in messagesConfigurations {
                fb.setImage(fileImg.withRenderingMode(.alwaysTemplate), for: .normal)
                fb.tintColor = color
            }
        }
    }
    
    fileprivate func setColorOfMicButton() {
        if let mb = ozMicButton, let mbi = mb.imageView, let micImg = mbi.image {
            for case .inputBoxMicButtonTintColor(let color, _) in messagesConfigurations {
                mb.setImage(micImg.withRenderingMode(.alwaysTemplate), for: .normal)
                mb.tintColor = color
            }
        }
    }
    
    fileprivate func setColorOfEmoticonButton() {
        if let eb = ozEmoticonButton, let ebi = eb.imageView, let emotImg = ebi.image {
            for case .inputBoxEmoticonButtonTintColor(let color, _) in messagesConfigurations {
                eb.setImage(emotImg.withRenderingMode(.alwaysTemplate), for: .normal)
                eb.tintColor = color
            }
        }
    }
    
    
    // MARK: - Typing Indicator Related
    func getTypingIndicatorMessage() -> OZMessage {
        var anImgName = ""
        for case .profileIconName(let name, _, let userType) in messagesConfigurations {
            if userType == .fromOther {
                anImgName = name
            }
        }
        let typeMessage = OZMessage(false, content: "typing", timestamp: Int(Date().timeIntervalSince1970), iconImage: anImgName, config: messagesConfigurations)
        typingMessageId = typeMessage.identifier
        
        return typeMessage
    }
    
    func setupTypingBubble(cell: TextMessageCell) {
        func resetTypingBubble(textCell: TextMessageCell, bubble: OZTypingBubble) {
            let offsetX = (textCell.textLabel.type != OZBubbleLabelType.noDraw ? textCell.textLabel.notchInsetX : 0)
            bubble.center.x = textCell.textLabel.bounds.midX + offsetX
            bubble.center.y = textCell.textLabel.bounds.midY
            textCell.textLabel.textColor = .clear
            textCell.timeLabel.isHidden = true
            bubble.startAnimating()
        }
        
        if let tBubble = cell.textLabel.viewWithTag(kTypingBubbleViewTag) as? OZTypingBubble {
            resetTypingBubble(textCell: cell, bubble: tBubble)
            return
        }
        let rect = cell.textLabel.bounds.insetBy(dx: 10, dy: 15)
        let typingBubble = OZTypingBubble(frame: rect)
        typingBubble.frame.size = CGSize(width: typingBubbleHeight * 3 + 5 * 2, height: typingBubbleHeight)
        typingBubble.dotColor = typingBubbleColor
        typingBubble.tag = kTypingBubbleViewTag
        cell.textLabel.addSubview(typingBubble)
        resetTypingBubble(textCell: cell, bubble: typingBubble)
        
        collectionView.scrollTo(edge: .bottom, animated: true)
    }
    

    
    // MARK: - Bottom button above keyboard
    fileprivate func keyboardShowLayout(isPadding: Bool = true, animated: Bool = true) {
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
        
        var isBottom = false
        if abs(Int(collectionView.contentOffset.y + collectionView.frame.height) - Int(collectionView.contentSize.height)) < 15 {
            isBottom = true
        }
        
        var normalHeight = keyboardHeight - bottomPadding
        if normalHeight < 10 {
            if #available(iOS 11.0, *),
                let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom, bottomPadding > 0 {
                // isiPhoneX top and bottom padding exist
                normalHeight = 336 - bottomPadding
            }
            else {
                normalHeight = 250
            }
        }
        var minHeight = minTextViewHeight
        for case .inputContainerMinimumHeight(let height) in messagesConfigurations {
            minHeight = height
            if let thc = ozTextHeightConstraint,
                minHeight < thc.constant {
                minHeight = thc.constant
                var isMaxHeightDeclared = false
                for case .inputContainerMaximumHeight(let height) in messagesConfigurations {
                    isMaxHeightDeclared = true
                    if minHeight > height {
                        minHeight = height
                    }
                }
                if !isMaxHeightDeclared {
                    fatalError("inputContainerMaximumHeight configuration not declared...")
                }
            }
        }

        let margin = UIEdgeInsets(top: 0,left: 0, bottom: normalHeight + minHeight, right: 0)

        guard let ecvh = ozEmoticonContainerViewHeight else {return}
        if animated, chatState == .chat {
            UIView.animate(withDuration: keyboardAnimationDuration, animations: {
                if ecvh.identifier == "inputTextContainerBottom" {
                    normalHeight = -normalHeight
                }
                ecvh.constant = normalHeight
                self.view.setNeedsUpdateConstraints()
                self.view.layoutIfNeeded()
            }) { (comp) in
                delay(0.05) {
                    var bounds = self.getBoundsBySaferArea().inset(by: margin)
                    var isCustomFrame = false
                    for case .customCollectionViewFrame(let yesOrNo, let rect, let row) in self.messagesConfigurations {
                        if yesOrNo {
                            isCustomFrame = yesOrNo
                            bounds = rect
                            let height = self.getHeightOfFrame(rect: rect, row: row)
                            if rect.height < height {
                                bounds.size.height = height
                            }
                        }
                    }
                    self.collectionView.frame = bounds

                    for case .collectionViewEdgeInsets(let inset) in self.messagesConfigurations {
                        if !isCustomFrame { self.collectionView.contentInset = inset }
                        else {
                            let originInset = self.collectionView.contentInset
                            let newInset = UIEdgeInsets(top: originInset.top, left: inset.left,
                                                        bottom: originInset.bottom, right: inset.right)
                            self.collectionView.contentInset = newInset
                        }
                        self.collectionView.reloadData()
                    }
                        
                    if isBottom {
                        self.collectionView.scrollTo(edge: UIRectEdge.bottom, animated: false)
                    }
                    else {
                        var isNotCase = true
                        for case .autoScrollToBottomBeginTextInput(let autoScrollToBottom, let isShow) in self.messagesConfigurations {
                            isNotCase = false
                            if autoScrollToBottom {
                                self.collectionView.scrollTo(edge: UIRectEdge.bottom, animated: false)
                            }
                            if isShow,
                                self.getThresholdOfScrollToBottomButtonShow() <= self.collectionView.contentSize.height {
                                self.setupScrollToBottomButton(true)
                            }
                            else {
                                self.scrollToBottomButton.alpha = 0
                            }
                        }
                        if isNotCase {
                            self.collectionView.scrollTo(edge: UIRectEdge.bottom, animated: false)
                        }
                    }
                }
            }
        }
        else {
            if ecvh.identifier == "inputTextContainerBottom" {
                normalHeight = -normalHeight
            }
            ecvh.constant = normalHeight
            self.view.setNeedsUpdateConstraints()
            delay(0.05) {
                var bounds = self.getBoundsBySaferArea().inset(by: margin)
                for case .customCollectionViewFrame(let yesOrNo, let rect, let row) in self.messagesConfigurations {
                    if yesOrNo {
                        bounds = rect
                        let height = self.getHeightOfFrame(rect: rect, row: row)
                        if rect.height < height {
                            bounds.size.height = height
                        }
                    }
                }
                self.collectionView.frame = bounds

                var isNotCase = true
                for case .autoScrollToBottomBeginTextInput(let autoScrollToBottom, _) in self.messagesConfigurations {
                    isNotCase = false
                    if autoScrollToBottom {
                        self.collectionView.scrollTo(edge: UIRectEdge.bottom, animated: false)
                    }
                }
                if isNotCase {
                    self.collectionView.scrollTo(edge: UIRectEdge.bottom, animated: false)
                }
            }
        }
        
        if let dele = delegate {
            dele.messageInputTextViewWillShow(insetMarget: margin, keyboardHeight: keyboardHeight)
        }
    }
    fileprivate func keyboardHideLayout() {
        guard let ecvh = ozEmoticonContainerViewHeight else {return}

        var minHeight = minTextViewHeight
        for case .inputContainerMinimumHeight(let height) in messagesConfigurations {
            minHeight = height
        }
        if let ozic = ozInputTextView, ozic.isHidden {
            minHeight = 0
        }
        let margin = UIEdgeInsets(top: 0, left: 0, bottom: minHeight, right: 0)

        for case .autoScrollToBottomBeginTextInput(_, let isShow) in self.messagesConfigurations {
            if isShow,
                self.getThresholdOfScrollToBottomButtonShow() <= self.collectionView.contentSize.height {
                self.scrollToBottomButton.alpha = 1
            }
        }

        var isCustomFrame = false
        UIView.animate(withDuration: keyboardAnimationDuration, animations: {
            ecvh.constant = 0
            self.view.setNeedsUpdateConstraints()
            self.view.layoutIfNeeded()
            
            var bounds = self.getBoundsBySaferArea().inset(by: margin)
            for case .customCollectionViewFrame(let yesOrNo, let rect, let row) in self.messagesConfigurations {
                if yesOrNo {
                    isCustomFrame = yesOrNo
                    bounds = rect
                    let height = self.getHeightOfFrame(rect: rect, row: row)
                    if rect.height < height {
                        bounds.size.height = height
                    }
                }
            }
            
            for case .autoScrollToBottomBeginTextInput(_, let isShow) in self.messagesConfigurations {
                if isShow,
                    self.getThresholdOfScrollToBottomButtonShow() <= self.collectionView.contentSize.height {
                    self.setupScrollToBottomButton(true)
                }
                else {
                    self.scrollToBottomButton.alpha = 0
                }
            }

            self.collectionView.frame = bounds
        }) { (comp) in

            for case .collectionViewEdgeInsets(let inset) in self.messagesConfigurations {
                if !isCustomFrame { self.collectionView.contentInset = inset }
                else {
                    let originInset = self.collectionView.contentInset
                    let newInset = UIEdgeInsets(top: originInset.top, left: inset.left,
                                                bottom: originInset.bottom, right: inset.right)
                    self.collectionView.contentInset = newInset
                }
                self.collectionView.reloadData()
            }
        }
        
        if let dele = delegate {
            dele.messageInputTextViewWillHide(insetMarget: margin, keyboardHeight: keyboardHeight)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            keyboardAnimationDuration = duration
        }
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            
            isKeyboardShow = true
            keyboardShowLayout()
            resetButtons()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            keyboardAnimationDuration = duration
        }

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
            if let ozvvc = voiceViewController {
                var aDuration: TimeInterval = 12
                for case .voiceRecordMaxDuration(let duration, let displayMax) in messagesConfigurations {
                    aDuration = duration
                    ozvvc.displayMaxDuration = TimeInterval(displayMax)
                }
                for case .voiceRecordAMRFormat(let format) in messagesConfigurations {
                    ozvvc.amrFormatEncodeMode = format
                }
                ozvvc.recordMaxDuration = aDuration
                ozvvc.showFakeRecordDuration()
            }
        }
    }

    public func addFileButtonToggle(_ isForceRed: Bool) {
        guard let fb = ozFileButton, let fbi = fb.imageView,
            let fileImg = fbi.image else { return }
        
        for case .inputBoxFileButtonTintColor(let color, let selected) in messagesConfigurations {
            fb.setImage(fileImg.withRenderingMode(.alwaysTemplate), for: .normal)
            if isForceRed {
                fb.tintColor = selected
            }
            else {
                fb.tintColor = color
            }
        }
    }
    fileprivate func micButtonToggle() {
        guard let mb = ozMicButton, let mbi = mb.imageView,
            let micImg = mbi.image else { return }
        
        for case .inputBoxMicButtonTintColor(let color, let selected) in messagesConfigurations {
            mb.setImage(micImg.withRenderingMode(.alwaysTemplate), for: .normal)
            if chatState == .voice {
                mb.tintColor = selected
            }
            else {
                mb.tintColor = color
            }
        }
    }
    fileprivate func emoticonButtonToggle() {
        guard let eb = ozEmoticonButton, let ebi = eb.imageView,
            let emotImg = ebi.image else { return }
        
        for case .inputBoxEmoticonButtonTintColor(let color, let selected) in messagesConfigurations {
            eb.setImage(emotImg.withRenderingMode(.alwaysTemplate), for: .normal)
            if chatState == .emoticon {
                eb.tintColor = selected
            }
            else {
                eb.tintColor = color
            }
        }
    }
    @objc fileprivate func scrollToBottomButtonTapped() {
        collectionView.scrollTo(edge: .bottom, animated: true)
        scrollToBottomButton.badgeCount = 0
    }
}


// MARK: - UITextViewDelegate
extension OZMessagesViewController: UITextViewDelegate {
    public func adjustTextViewHeight(_ textView: UITextView) {
        guard let thc = ozTextHeightConstraint else {return}
        
        var minHeight = minTextViewHeight
        for case .inputContainerMinimumHeight(let height) in messagesConfigurations {
            minHeight = height
        }
        if textView.text.count <= 0 {
            thc.constant = minHeight
            self.view.setNeedsUpdateConstraints()
            self.view.layoutIfNeeded()
            return
        }
        
        let width = textView.contentSize.width
        let size = OZMessageCell.sizeForText(textView.text, maxWidth: width,
                                             paddingX: 20.0, paddingY: 20.0)
        
        var maxHeight = maxTextViewHeight
        for case .inputContainerMaximumHeight(let height) in messagesConfigurations {
            maxHeight = height
        }
                
        if thc.constant > maxHeight {
            UIView.animate(withDuration: 0.35, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: {
                thc.constant = maxHeight
                self.view.setNeedsUpdateConstraints()
                //self.view.layoutIfNeeded()
            }) { (complete) in
            }
        }
        else if thc.constant <= maxHeight, thc.constant != size.height {
            thc.constant = size.height
            self.view.setNeedsUpdateConstraints()
            //self.view.layoutIfNeeded()
        }
        else if thc.constant < minHeight {
            thc.constant = minHeight
            self.view.setNeedsUpdateConstraints()
            //self.view.layoutIfNeeded()
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeight(textView)
        
        if let dele = delegate {
            dele.messageTextViewDidChanged(textView: textView)
        }
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
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
        for case .inputTextViewFontColor(let color) in messagesConfigurations {
            textView.textColor = color
        }
        for case .inputTextViewFont(let font) in messagesConfigurations {
            textView.font = font
        }

        if let dele = delegate {
            dele.messageTextViewEndEditing(textView: textView)
        }
        
        // TODO: find more elegant way to do it...by Henry on 2020.07.08
        DispatchQueue.main.asyncAfter(deadline: .now()+0.15) {
            if self.collectionView.frame.height < super.view.bounds.height - 200 {
                self.keyboardHideLayout()
            }
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
                if let itv = ozInputTextView {
                    itv.text = ""
                }
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
            for case .chatImageSize(_, _, let realSize) in messagesConfigurations {
                imgSize = realSize
            }
            let resizedImage = anImg.resize(width: imgSize.width, height: imgSize.height)
            var maxBytes: Int = 16384
            for case .chatImageMaxNumberOfBytes(let bytes) in messagesConfigurations {
                maxBytes = bytes
            }
            guard let imageData = resizedImage.jpegData(maxNumberOfBytes: maxBytes) else {
                saveFile(resizedImage)
                return
            }
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
    func cellDidSetMessage(cell: OZMessageCell) {
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
    func cellLayoutSubviews(cell: OZMessageCell) {
        
        /// for typing message
        if typingCanVisible, let tCell = cell as? TextMessageCell {
            if isTyping, cell.message.type == .text, cell.message.alignment == .left,
                cell.message.identifier == typingMessageId {
                
                if let typeIndex = dataSource.data.firstIndex(where: {$0.identifier == typingMessageId}),
                    typeIndex < dataSource.data.count - 1 {
                    dataSource.data.remove(at: typeIndex)
                    let typeMessage = getTypingIndicatorMessage()
                    dataSource.data.append(typeMessage)
                    collectionView.setNeedsReload()
                }
                
                setupTypingBubble(cell: tCell)
            }
            else if let tBubble = tCell.textLabel.viewWithTag(kTypingBubbleViewTag) {
                tBubble.removeFromSuperview()
            }
        }

        if let dele = delegate {
            if let currentMessageIndex = dataSource.data.firstIndex(of: cell.message),
                currentMessageIndex - 1 >= 0 {
                let previousMessage = dataSource.data(at: currentMessageIndex - 1)
                var nextMessage: OZMessage? = nil
                if dataSource.data.count > currentMessageIndex + 1 {
                    nextMessage = dataSource.data(at: currentMessageIndex + 1)
                }
                dele.messageCellLayoutSubviews(cell: cell, previousMessage: previousMessage, nextMessage: nextMessage)
            }
            else {
                dele.messageCellLayoutSubviews(cell: cell, previousMessage: OZMessage(), nextMessage: nil)
            }
        }
    }
    func cellLongMessageFoldingButtons(cell: OZMessageCell) -> [(UIButton, OZMessageFoldState)] {
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
    func cellLongMessageButtonTapped(cell: OZMessageCell, view: UIView) {
        /// Long Message Folding Options
        if let aMessage = cell.message,
            aMessage.usingFoldingOption, aMessage.type == .text,
            let index = dataSource.data.firstIndex(of: cell.message) {
            
            aMessage.isFolded.toggle()
            dataSource.data[index] = aMessage
            collectionView.layoutIfNeeded()

            if let dele = self.delegate,
                dele.messageCellLongMessageButtonTapped(cell: cell, view: view, isFolded: aMessage.isFolded) {
                
                if !aMessage.isFolded, cell.frame.maxY > collectionView.contentOffset.y {
                    // Unfolded
                    delay(0.15) {
                        let rect = cell.frame.inset(by: UIEdgeInsets(top: cell.frame.height * 0.95, left: 10, bottom: 0, right: 10))
                        self.collectionView.scrollRectToVisible(rect, animated: false)
                    }
                }
                else if aMessage.isFolded, cell.frame.minY < collectionView.contentOffset.y {
                    // folded
                    delay(0.15) {
                        let rect = cell.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
                        self.collectionView.scrollRectToVisible(rect, animated: false)
                    }
                }
            }
        }
    }
    func cellMultipleImageTapped(cell: OZMessageCell, view: UIImageView, index: Int) {
        // Multiple image tapped
        if let dele = self.delegate,
            dele.messageCellMultipleImageTapped(cell: cell, image: view, indexOfImage: index) {
            // currently there're nothing to do
        }
    }
}

extension OZMessagesViewController: OZMessageDelegate {
    func verticalPaddingBetweenMessage(message: OZMessage, previousMessage: OZMessage) -> CGFloat {
        if let dele = self.delegate {
            let padding = dele.messageVerticalPaddingBetweenMessage(message: message, previousMessage: previousMessage)
            return padding
        }
        return 0
    }
}
