//
//  OZMessageCell.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/03.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit
import CollectionKit
import NVActivityIndicatorView

public var kTextFont = UIFont(name: "AppleSDGothicNeo-Medium", size: 16)

// MARK: - TextMessageCell
open class TextMessageCell: OZMessageCell {
    public var textLabel = OZBubbleLabel()
    public var iconImage = UIImageView()
    public var timeLabel = UILabel()
    
    public var buttonContainer = UIView()

    override public var message: OZMessage! {
        didSet {
            var textFont = kTextFont
            if message.fontName.count > 0, message.fontSize > 0 {
                textFont = UIFont(name: message.fontName, size: message.fontSize)
            }
            textLabel.attributedText = NSAttributedString(string: message.content, attributes: [ NSAttributedString.Key.font: textFont as Any ])
            textLabel.textColor = message.textColor
            textLabel.font = textFont
            if message.alignment == .left {
                textLabel.incomingColor = message.bubbleColor
                textLabel.isIncoming = true
            }
            else {
                textLabel.outgoingColor = message.bubbleColor
                textLabel.isIncoming = false
            }
            if message.canMessageSelectable {
                textLabel.isUserInteractionEnabled = true
                textLabel.addGestureRecognizer(UILongPressGestureRecognizer(target: textLabel, action: #selector(textLabel.handleLongPress(_:))))
            }
            
            if message.iconImage.count > 0 {
                iconImage.image = profileImage(path: message.iconImage)
            }
            else {
                iconImage.image = nil
            }
            
            timeLabel.textColor = message.timeFontColor
            timeLabel.font = UIFont(name: message.fontName, size: message.timeFontSize)
            timeLabel.frame.size = CGSize(width: 50, height: 12)
            if message.alignment == .left {
                timeLabel.textAlignment = .left
            }
            else {
                timeLabel.textAlignment = .right
            }
            if message.timestamp > 0 {
                timeLabel.text = "\(Date.formDateForChat(timestamp: message.timestamp, format: message.timeFontFormat))"
            }
            else {
                #if DEBUG
                timeLabel.text = "3:52 PM"
                #endif
            }
            
            buttonContainer.isHidden = true
            buttonContainerHandler(message: message, textLabel: textLabel, buttonContainer: buttonContainer)

            if message.cellOpacity <= 1.0 {
                for x in self.subviews {
                    x.alpha = message.cellOpacity
                }
            }
            // Callback to delegate
            if let dele = delegate {
                dele.cellDidSetMessage(cell: self)
            }
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textLabel.frame = frame
        textLabel.numberOfLines = 0
        addSubview(textLabel)
        addSubview(iconImage)
        timeLabel.frame = frame
        addSubview(timeLabel)
        buttonContainer.frame = frame
        addSubview(buttonContainer)
        buttonContainer.isHidden = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        iconImage.layer.cornerRadius = message.iconSize/2
        iconImage.layer.masksToBounds = true

        if iconImage.image != nil {
            iconImage.isHidden = false
        }
        else {
            iconImage.isHidden = true
        }
        let timeLabelOriginY = self.bounds.maxY - timeLabel.font.pointSize * 1.3
        if message.alignment == .left {
            timeLabel.frame.origin = CGPoint(x: self.bounds.maxX+5, y: timeLabelOriginY)
            let leftInset = message.iconImage.count > 0 ? message.cellLeftPadding : 0
            textLabel.frame = bounds.inset(by: UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: 0))
            
            iconImage.frame.origin = CGPoint(x: 0, y: -message.iconSize / 2)
            iconImage.frame.size = CGSize(width: message.iconSize, height: message.iconSize)
        }
        else {
            timeLabel.frame.origin = CGPoint(x: self.bounds.minX-55, y: timeLabelOriginY)
            let rightInset = message.iconImage.count > 0 ? message.cellRightPadding : 0
            textLabel.frame = bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: rightInset))
            
            iconImage.frame.origin = CGPoint(x: bounds.maxX-message.iconSize, y: bounds.maxY-message.iconSize/2)
            iconImage.frame.size = CGSize(width: message.iconSize, height: message.iconSize)
        }

        layoutButtonContainer(message: message, textLabel: textLabel, buttonContainer: buttonContainer)

        /// Call back to delegate
        if let dele = delegate {
            dele.cellLayoutSubviews(cell: self)
        }
    }
}

// MARK: - StatusMessageCell
open class StatusMessageCell: OZMessageCell {
    var textLabel = UILabel()
    var seperator = UIImageView()
    
    override public var message: OZMessage! {
        didSet {
            textLabel.text = message.content
            textLabel.textColor = message.textColor
            textLabel.font = UIFont(name: message.fontName, size: message.fontSize)
            textLabel.backgroundColor = message.backgroundColor
            if message.type == .announcement {
                textLabel.textAlignment = .center
                seperator.isHidden = false
                seperator.backgroundColor = message.seperatorColor
            }
            else {
                seperator.isHidden = true
            }
            
            if message.cellOpacity <= 1.0 {
                for x in self.subviews {
                    x.alpha = message.cellOpacity
                }
            }
            // Callback to delegate
            if let dele = delegate {
                dele.cellDidSetMessage(cell: self)
            }
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        seperator.frame = frame
        addSubview(seperator)
        textLabel.frame = frame
        textLabel.numberOfLines = 0
        addSubview(textLabel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        textLabel.frame = bounds.insetBy(dx: message.cellPadding, dy: message.cellPadding)
        if message.type == .announcement {
            seperator.isHidden = false
            seperator.frame.size.width = UIScreen.main.bounds.width * message.bubbleWidthRatio
            seperator.frame.size.height = 1.0
            seperator.center = bounds.center
        }
        else if message.alignment == .right {
            textLabel.textAlignment = .right
        }
        else if message.alignment == .left {
            textLabel.textAlignment = .left
        }
        
        /// Call back to delegate
        if let dele = delegate {
            dele.cellLayoutSubviews(cell: self)
        }
    }
}

// MARK: - IncomingStatusMessageCell
open class IncomingStatusMessageCell: OZMessageCell {
    var textLabel = UILabel()
    var iconImage = UIImageView()
    var timeLabel = UILabel()
    
    override public var message: OZMessage! {
        didSet {
            textLabel.text = message.content
            textLabel.textColor = message.textColor
            textLabel.font = UIFont(name: message.fontName, size: message.fontSize)
            if let aType = message.deviceStatus {
                if message.iconImage.count > 0,
                    let anImg = UIImage(named: message.iconImage) {
                    iconImage.image = anImg
                }
                else if !aType.imageName().hasSuffix("@2x"), let anImg = UIImage(named: "\(aType.imageName())@2x") {
                    iconImage.image = anImg
                }
                else if !aType.imageName().hasSuffix("@3x"), let anImg = UIImage(named: "\(aType.imageName())@3x") {
                    iconImage.image = anImg
                }
                else if let anImg = UIImage(named: aType.imageName()) {
                    iconImage.image = anImg
                }
                
                iconImage.frame.origin = CGPoint(x: 0, y: 0)
                iconImage.frame.size = CGSize(width: message.iconSize, height: message.iconSize)
                iconImage.center.y = textLabel.center.y
            }
            
            timeLabel.textColor = message.timeFontColor
            timeLabel.font = UIFont(name: message.fontName, size: message.timeFontSize)
            if message.timestamp > 0 {
                timeLabel.text = "\(Date.formDateForChat(timestamp: message.timestamp, format: message.timeFontFormat))"
            }
            else {
                #if DEBUG
                timeLabel.text = "3:52 PM"
                #endif
            }
            timeLabel.sizeToFit()
            
            if message.cellOpacity <= 1.0 {
                for x in self.subviews {
                    x.alpha = message.cellOpacity
                }
            }
            // Callback to delegate
            if let dele = delegate {
                dele.cellDidSetMessage(cell: self)
            }
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textLabel.frame = frame
        textLabel.numberOfLines = 2
        addSubview(textLabel)
        iconImage.frame = frame
        addSubview(iconImage)
        timeLabel.frame = frame
        addSubview(timeLabel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        let leftInset = message.cellLeftPadding + 5
        textLabel.frame = bounds.inset(by: UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: 0))
        iconImage.center.y = textLabel.center.y
        iconImage.layer.cornerRadius = iconImage.frame.height / 2
        iconImage.layer.masksToBounds = true
        timeLabel.frame.origin = CGPoint(x: leftInset, y: textLabel.frame.maxY - 12)
        
        /// Call back to delegate
        if let dele = delegate {
            dele.cellLayoutSubviews(cell: self)
        }
    }
}

// MARK: - ImageMessageCell
open class ImageMessageCell: OZMessageCell {
    open var imageView = UIImageView()  /// Set from outsize of cell, eg. `setupDataProvider`
    public var iconImage = UIImageView()
    public var timeLabel = UILabel()
        
    override public var message: OZMessage! {
        didSet {
            if message.type == .emoticon || message.showTimeLabelForImage {
                timeLabel.textColor = message.timeFontColor
                timeLabel.font = UIFont(name: message.fontName, size: message.timeFontSize)
                timeLabel.frame.size = CGSize(width: 50, height: 12)
                if message.timestamp > 0 {
                    timeLabel.text = "\(Date.formDateForChat(timestamp: message.timestamp, format: message.timeFontFormat))"
                }
                else {
                    #if DEBUG
                    timeLabel.text = "3:52 PM"
                    #endif
                }
                timeLabel.isHidden = false
            }
            else {
                timeLabel.isHidden = true
            }

            if message.iconImage.count > 0 {
                iconImage.image = profileImage(path: message.iconImage)
            }
            else {
                iconImage.image = nil
            }

            if message.cellOpacity <= 1.0 {
                for x in self.subviews {
                    x.alpha = message.cellOpacity
                }
            }
            // Callback to delegate
            if let dele = delegate {
                dele.cellDidSetMessage(cell: self)
            }
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFill
        //clipsToBounds = true
        addSubview(imageView)
        iconImage.frame = frame
        addSubview(iconImage)
        timeLabel.frame = frame
        addSubview(timeLabel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        iconImage.layer.cornerRadius = message.iconSize/2
        iconImage.layer.masksToBounds = true

        if iconImage.image != nil {
            iconImage.isHidden = false
        }
        else {
            iconImage.isHidden = true
        }
        if message.alignment == .left {
            let leftInset = message.iconImage.count > 0 ? message.cellLeftPadding : 0
            imageView.frame = bounds.inset(by: UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: 0))
            
            iconImage.frame.origin = CGPoint(x: 0, y: -message.iconSize / 2)
            iconImage.frame.size = CGSize(width: message.iconSize, height: message.iconSize)
        }
        else {
            let rightInset = message.iconImage.count > 0 ? message.cellRightPadding : 0
            imageView.frame = bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: rightInset))
            
            iconImage.frame.origin = CGPoint(x: bounds.maxX-message.iconSize, y: bounds.maxY-message.iconSize/2)
            iconImage.frame.size = CGSize(width: message.iconSize, height: message.iconSize)
        }
        imageView.layer.cornerRadius = message.chatImageCornerRadius
        imageView.layer.masksToBounds = true

        if message.type == .emoticon || message.showTimeLabelForImage {
            let timeLabelOriginY = self.bounds.maxY - timeLabel.font.pointSize * 1.3
            if message.alignment == .right {
                timeLabel.frame.origin = CGPoint(x: self.bounds.minX-55, y: timeLabelOriginY)
                timeLabel.textAlignment = .right
            }
            else {
                timeLabel.frame.origin = CGPoint(x: self.imageView.frame.maxX+5, y: timeLabelOriginY)
                timeLabel.textAlignment = .left
            }
        }

        /// Call back to delegate
        if let dele = delegate {
            dele.cellLayoutSubviews(cell: self)
        }
    }
}

// MARK: - MultipleImageMessageCell
open class MultipleImageMessageCell: OZMessageCell {
    open var imageContainer = UIView()
    open var imageViews: [UIImageView] = []
    public var iconImage = UIImageView()
    public var timeLabel = UILabel()
        
    override public var message: OZMessage! {
        didSet {
            if message.type == .emoticon || message.showTimeLabelForImage {
                timeLabel.textColor = message.timeFontColor
                timeLabel.font = UIFont(name: message.fontName, size: message.timeFontSize)
                timeLabel.frame.size = CGSize(width: 50, height: 12)
                if message.timestamp > 0 {
                    timeLabel.text = "\(Date.formDateForChat(timestamp: message.timestamp, format: message.timeFontFormat))"
                }
                timeLabel.isHidden = false
            }
            else {
                timeLabel.isHidden = true
            }

            if message.iconImage.count > 0 {
                iconImage.image = profileImage(path: message.iconImage)
            }
            else {
                iconImage.image = nil
            }

            if message.cellOpacity <= 1.0 {
                for x in self.subviews {
                    x.alpha = message.cellOpacity
                }
            }
            // Callback to delegate
            if let dele = delegate {
                dele.cellDidSetMessage(cell: self)
            }
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        iconImage.frame = frame
        addSubview(iconImage)
        timeLabel.frame = frame
        addSubview(timeLabel)
        imageContainer.frame = frame
        addSubview(imageContainer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        iconImage.layer.cornerRadius = message.iconSize/2
        iconImage.layer.masksToBounds = true

        if iconImage.image != nil {
            iconImage.isHidden = false
        }
        else {
            iconImage.isHidden = true
        }
        if message.alignment == .left {
            let leftInset = message.iconImage.count > 0 ? message.cellLeftPadding : 0
            imageContainer.frame = bounds.inset(by: UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: 0))
            
            iconImage.frame.origin = CGPoint(x: 0, y: -message.iconSize / 2)
            iconImage.frame.size = CGSize(width: message.iconSize, height: message.iconSize)
        }
        else {
            let rightInset = message.iconImage.count > 0 ? message.cellRightPadding : 0
            imageContainer.frame = bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: rightInset))
            
            iconImage.frame.origin = CGPoint(x: bounds.maxX-message.iconSize, y: bounds.maxY-message.iconSize/2)
            iconImage.frame.size = CGSize(width: message.iconSize, height: message.iconSize)
        }
        imageContainer.layer.cornerRadius = message.chatImageCornerRadius
        imageContainer.layer.masksToBounds = true
        imageContainer.backgroundColor = message.multipleImageBackground
        imageContainer.layer.borderColor = message.multipleImageBackground.cgColor
        imageContainer.layer.borderWidth = message.multipleImageBorderWidth

        if message.type == .emoticon || message.showTimeLabelForImage {
            let timeLabelOriginY = self.bounds.maxY - timeLabel.font.pointSize * 1.3
            if message.alignment == .right {
                timeLabel.frame.origin = CGPoint(x: self.bounds.minX-55, y: timeLabelOriginY)
                timeLabel.textAlignment = .right
            }
            else {
                timeLabel.frame.origin = CGPoint(x: self.imageContainer.frame.maxX+5, y: timeLabelOriginY)
                timeLabel.textAlignment = .left
            }
        }
        
        /// Handling Multiple Images
        resetFrameOfMultipleImages(bounds: imageContainer.bounds, imageContainer: imageContainer, imageViews: imageViews, spacing: message.multipleImageSpacing)

        /// Call back to delegate
        if let dele = delegate {
            dele.cellLayoutSubviews(cell: self)
        }
    }
}

// MARK: - AudioMessageCell
open class AudioMessageCell: OZMessageCell {
    open var pauseImg = UIImage()
    open var playImg = UIImage()
    open var audioPlayer = OZAudioPlayer()
    open var activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 25, height: 25), type: .circleStrokeSpin, color: UIColor.gray.withAlphaComponent(0.5), padding: 0)
    public var textLabel = UILabel()
    public var backView = OZProgressBarView(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
    public var playImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    public var iconImage = UIImageView()
    public var eTimeLabel = UILabel()
    
    open var isPlaying = false {
        didSet {
            if isPlaying {
                self.playImage.image = self.pauseImg
            }
            else {
                self.playImage.image = self.playImg
                self.backView.progress = 0.0
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    override public var message: OZMessage! {
        didSet {
            if message.audioPlayButtonName.count > 0,
                let anImg = UIImage(named: message.audioPlayButtonName) {
                playImg = anImg
            }
            else if #available(iOS 13.0, *) {
                playImg = UIImage(systemName: "play.fill") ?? UIImage()
            }
            if message.audioPauseButtonName.count > 0,
                let anImg = UIImage(named: message.audioPauseButtonName)  {
                pauseImg = anImg
            }
            else if #available(iOS 13.0, *) {
                pauseImg = UIImage(systemName: "pause.fill") ?? UIImage()
            }
            
            if let aDur = message.extra["duration"] as? Int, aDur > 0 { // WTF... by Henry on 2020.05.22
                textLabel.text = String(format: "%02d:%02d", aDur / 60, aDur % 60)
            }
            else if let anUrl = OZAudioPlayer.getUrlFromPath(path: message.content),
                let aPlayer = OZAudioPlayer.getAudioPlayer(fileURL: anUrl) {
                if message.type == .voice {
                    let aDur = OZAudioPlayer.getAmrDuration(fileURL: anUrl)
                    let seconds = Int(aDur) % 60
                    let microSeconds = round(aDur - Double(seconds))
                    textLabel.text = String(format: "%02d:%02d", Int(aDur)/60, Int(Double(seconds) + microSeconds))
                }
                else {
                    textLabel.text = String(format: "%02d:%02d", Int(aPlayer.duration)/60, Int(aPlayer.duration)%60)
                }
            }
            else {
                textLabel.text = ""
            }
            textLabel.textColor = message.textColor
            textLabel.font = UIFont(name: message.fontName, size: message.fontSize)
            textLabel.backgroundColor = .clear
            textLabel.textAlignment = .right
            
            if message.iconImage.count > 0 {
                iconImage.image = profileImage(path: message.iconImage)
            }
            else {
                iconImage.image = nil
            }

            playImage.image = isPlaying ? pauseImg : playImg
            
            backView.progressColor = message.audioProgressColor
            backView.backgroundColor = message.backgroundColor
            self.backgroundColor = .clear
            
            eTimeLabel.textColor = message.timeFontColor
            eTimeLabel.font = UIFont(name: message.fontName, size: message.timeFontSize)
            if message.timestamp > 0 {
                eTimeLabel.text = "\(Date.formDateForChat(timestamp: message.timestamp, format: message.timeFontFormat))"
            }
            else {
                #if DEBUG
                eTimeLabel.text = "3:52 PM"
                #endif
            }
            eTimeLabel.sizeToFit()

            if message.cellOpacity <= 1.0 {
                for x in self.subviews {
                    x.alpha = message.cellOpacity
                }
            }
            // Callback to delegate
            if let dele = delegate {
                dele.cellDidSetMessage(cell: self)
            }
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(backView)
        textLabel.frame = frame
        textLabel.numberOfLines = 1
        backView.addSubview(textLabel)
        iconImage.frame = frame
        addSubview(iconImage)
        eTimeLabel.frame = frame
        addSubview(eTimeLabel)
        backView.addSubview(playImage)
        addSubview(activityIndicator)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        backView.frame = bounds
        if iconImage.image != nil {
            iconImage.isHidden = false
            iconImage.layer.cornerRadius = message.iconSize/2
            iconImage.layer.masksToBounds = true

            if message.alignment == .left {
                backView.frame = bounds.inset(by: UIEdgeInsets(top: 0, left: message.cellLeftPadding, bottom: 0, right: 0))
            }
            else if message.alignment == .right {
                backView.frame = bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: message.cellRightPadding))
            }
            
            if message.alignment == .left {
                iconImage.frame.origin = CGPoint(x: 0, y: 0)
                iconImage.frame.size = CGSize(width: message.iconSize, height: message.iconSize)
            }
            else {
                iconImage.frame.origin = CGPoint(x: bounds.maxX-message.iconSize, y: 0)
                iconImage.frame.size = CGSize(width: message.iconSize, height: message.iconSize)
            }
        }
        else {
            iconImage.isHidden = true
        }

        textLabel.frame = backView.bounds.insetBy(dx: 14, dy: 11)
        
        backView.layer.cornerRadius = message.chatImageCornerRadius
        backView.layer.masksToBounds = true
        
        playImage.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        
        
        if message.alignment == .right {
            eTimeLabel.frame.origin = CGPoint(x: bounds.minX-55, y: bounds.maxY-12)
        }
        else {
            eTimeLabel.frame.origin = CGPoint(x: bounds.maxX + 5, y: bounds.maxY-12)
        }
        activityIndicator.center = CGPoint(x: eTimeLabel.frame.midX, y: eTimeLabel.frame.midY - 20)

        /// Call back to delegate
        if let dele = delegate {
            dele.cellLayoutSubviews(cell: self)
        }
    }
    
    open func preparePlay(file: String) {
        activityIndicator.startAnimating()
    }
    
    open func playOrStop(named: String? = nil) {
        activityIndicator.stopAnimating()
        
        if audioPlayer.status == .playing {
            isPlaying = false
            audioPlayer.pause()
        }
        else if audioPlayer.status == .paused {
            isPlaying = true
            audioPlayer.resume()
        }
        else {
            isPlaying = true
            if let aFile = named,
                FileManager.isFileExist(named: aFile) {
                audioPlayer.play(named: aFile) { (elapse, dur) in
                    if let aDur = self.message.extra["duration"] as? Int, aDur > 0,
                        elapse >= Double(aDur) * 0.96 { // WTF... by Henry on 2020.06.09
                        let finalDur = TimeInterval(aDur)
                        self.playProgress(finalDur, finalDur)
                    }
                    else {
                        self.playProgress(elapse, dur)
                    }
                }
            }
        }
    }
    func playProgress(_ elapsed: TimeInterval, _ duration: TimeInterval) {
        if self.isPlaying {
            let maxDuration: Double = round(duration)
            self.backView.progress = CGFloat(elapsed / maxDuration)
            self.textLabel.text = String(format: "%02d:%02d", Int(elapsed) / 60, Int(elapsed) % 60)
            if elapsed >= duration || Int(maxDuration) == 0 {
                let finalDur: Int = Int(maxDuration)
                self.isPlaying = false
                self.textLabel.text = String(format: "%02d:%02d", finalDur / 60, finalDur % 60)
            }
        }
    }
}


// MARK: - Super OZMessageCell
open class OZMessageCell: DynamicView {
    
    var delegate: OZMessageCellDelegate?
    
    public var message: OZMessage! {
        didSet {
            layer.cornerRadius = message.roundedCornder ? 12 : 0
            
            if message.showShadow {
                layer.shadowOffset = CGSize(width: 0, height: 5)
                layer.shadowOpacity = 0.3
                layer.shadowRadius = 8
                layer.shadowColor = message.shadowColor.cgColor
                layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
            } else {
                layer.shadowOpacity = 0
                layer.shadowColor = nil
            }
            
            backgroundColor = message.backgroundColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        isOpaque = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        if message?.showShadow ?? false {
            // TODO: 여기서 subview들에 shadow를 먹이는 것이 좋겠다. HOW ?!? by Henry on 2020.05.04
            // TOOD: 근데 여기는 superclass 이닷...ㅜ.ㅜ  by Henry on 2020.05.04
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        }
    }
    
    // MARK: - Private methods
    fileprivate func profileImage(path: String) -> UIImage {
        if path.lowercased().hasPrefix("file"),
            let anUrl = URL(string: path),
            FileManager.default.isReadableFile(atPath: anUrl.relativePath),
            let anImage = UIImage(contentsOfFile: anUrl.relativePath) {
            // Local file with fileURL
            return anImage
        }
        else if path.hasPrefix("/"),
            FileManager.default.isReadableFile(atPath: path),
            let anImage = UIImage(contentsOfFile: path) {
            // Local file with relative path
            return anImage
        }
        else if path.count > 0,
            let anImage = UIImage(named: path) {
            return anImage
        }
        else if #available(iOS 13.0, *) {
            return UIImage(systemName: "person.circle.fill") ?? UIImage()
        }
        else {
            return UIImage()
        }
    }
    fileprivate func buttonContainerHandler(message: OZMessage, textLabel: OZBubbleLabel, buttonContainer: UIView) {
        guard let dele = delegate, message.usingFoldingOption else { return }
        
        if OZMessageCell.sizeForText(message.content, fontName: message.fontName,
                                      fontSize: message.fontSize, maxWidth: textLabel.frame.width - 50,
                                      paddingX: leftPadding(message: message),
                                      paddingY: message.cellPadding).height > message.foldingMessageMaxHeight {
            
            for x in buttonContainer.subviews { x.removeFromSuperview() }
            for (button, type) in dele.cellLongMessageFoldingButtons(cell: self) {
                let copiedButton = UIButton(frame: button.frame)
                for x in 0..<4 {
                    let state = UIControl.State(rawValue: UInt(x))
                    copiedButton.setImage(button.image(for: state), for: state)
                    copiedButton.setTitle(button.title(for: state), for: state)
                    copiedButton.setTitleColor(button.titleColor(for: state), for: state)
                    copiedButton.setAttributedTitle(button.attributedTitle(for: state), for: state)
                }
                if let tlf = button.titleLabel {
                    copiedButton.titleLabel?.font = tlf.font
                }
                copiedButton.tag = type.tag()
                copiedButton.isUserInteractionEnabled = false
                buttonContainer.addSubview(copiedButton)
                buttonContainer.frame.size = copiedButton.frame.size
            }
            buttonContainer.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(longMessageFoldingButtonTapped(_:)))
            buttonContainer.addGestureRecognizer(tap)
            buttonContainer.setNeedsLayout()
        }
    }
    @objc fileprivate func longMessageFoldingButtonTapped(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .recognized, let dele = delegate, let aView = gesture.view {
            dele.cellLongMessageButtonTapped(cell: self, view: aView)
        }
    }
    fileprivate func layoutButtonContainer(message: OZMessage, textLabel: OZBubbleLabel, buttonContainer: UIView) {
        buttonContainer.isHidden = true
        textLabel.bottomInset = kBubbleLabelBottomInset

        if message.usingFoldingOption,
            OZMessageCell.sizeForText(message.content, fontName: message.fontName,
                                      fontSize: message.fontSize, maxWidth: textLabel.frame.width,
                                      paddingX: leftPadding(message: message),
                                      paddingY: message.cellPadding).height > message.foldingMessageMaxHeight {
            buttonContainer.isHidden = false
            let height = message.foldingButtonSize.height
            buttonContainer.frame = CGRect(x: textLabel.frame.minX,
                                           y: textLabel.frame.maxY - height - message.cellPadding,
                                           width: textLabel.frame.width - message.cellPadding *  2,
                                           height: height + message.cellPadding)
            if buttonContainer.subviews.count == 0 {
               buttonContainerHandler(message: message, textLabel: textLabel, buttonContainer: buttonContainer)
            }
            for x in buttonContainer.subviews {
                if let button = x as? UIButton {
                    button.isHidden = true
                    button.sizeToFit()
                    button.center = CGPoint(x: buttonContainer.bounds.midX, y: buttonContainer.bounds.midY)
                    
                    var bAlign: OZMessageAlignment = message.foldingButtonAlignment
                    if button.tag == OZMessageFoldState.unfold.tag() {
                        bAlign = message.unfoldingButtonAlignment
                    }
                    switch bAlign {
                    case .left:
                        button.frame.origin.x = buttonContainer.bounds.minX + message.cellPadding
                        break
                    case .right:
                        if let aText = button.title(for: .normal), let anImage = button.imageView,
                            OZMessageCell.sizeForText(message.content, fontName: message.fontName,
                                                      fontSize: message.fontSize, maxWidth: textLabel.frame.width,
                                                      paddingX: leftPadding(message: message),
                                                      paddingY: message.cellPadding).width + anImage.frame.width > button.frame.width {
                            button.frame.origin.x = buttonContainer.bounds.maxX - OZMessageCell.sizeForText(aText).width - anImage.frame.width
                        }
                        else if let anImage = button.imageView {
                            button.frame.origin.x = buttonContainer.bounds.maxX - button.frame.width - anImage.frame.width
                        }
                        else {
                            button.frame.origin.x = buttonContainer.bounds.maxX - button.frame.width
                        }
                        break
                    default: break
                    }
                }
            }
            if message.isFolded {
                buttonContainer.viewWithTag(OZMessageFoldState.unfold.tag())?.isHidden = false
            }
            else {
                buttonContainer.viewWithTag(OZMessageFoldState.fold.tag())?.isHidden = false
            }
            textLabel.bottomInset = height
        }
    }
    fileprivate func leftPadding(message: OZMessage) -> CGFloat {
        var leftPadding = message.cellPadding
        if message.alignment == .left {
            if message.iconImage.count > 0 {
                leftPadding = message.cellLeftPadding
            }
            else {
                leftPadding = message.cellPadding
            }
        }
        return leftPadding
    }
    @objc fileprivate func multipleImageButtonTapped(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .recognized, let dele = delegate,
            let multiCell = self as? MultipleImageMessageCell, let aView = gesture.view as? UIImageView {
            if let index = multiCell.imageViews.firstIndex(of: aView) {
                dele.cellMultipleImageTapped(cell: multiCell, view: aView, index: index)
            }
            else {
                dele.cellMultipleImageTapped(cell: multiCell, view: aView, index: 0)
            }
        }
    }
    fileprivate func resetFrameOfMultipleImages(bounds: CGRect, imageContainer: UIView, imageViews: [UIImageView], spacing: CGFloat = 4) {
        for x in imageContainer.subviews {
            if let gr = x.gestureRecognizers {
                for y in gr { x.removeGestureRecognizer(y) }
            }
            x.removeFromSuperview()
        }
        let count: Int = imageViews.count
        let rows: Int = count / 3 + (count % 3 == 0 ? 0 : 1)
        let maxWidth = bounds.width
        let maxHeight = bounds.height
        let height: CGFloat = (maxHeight / CGFloat(rows))
        let size = CGSize(width: maxWidth / (count < 3 ? CGFloat(count) : 3), height: height)

        var lastFrame = CGRect.zero
        
        for i in 0..<imageViews.count {
            var yHeight: CGFloat = 0
            var xOffset: CGFloat = 0

            if lastFrame.maxX + size.width <= maxWidth + spacing * 2 {
                yHeight = lastFrame.minY
                xOffset = lastFrame.maxX + (lastFrame.maxX > 0 ? spacing : 0)
            } else {
                yHeight = lastFrame.maxY + (lastFrame.maxY > 0 ? spacing : 0)
            }
            imageViews[i].frame.origin.x = xOffset
            imageViews[i].frame.origin.y = yHeight
            imageViews[i].frame.size = size
            
            let leftover = count - (i + 1)
            var threshold = count % 2 == 0 ? 4 : 5
            if count == 8 || count == 14 {
                threshold = 3
            }
            if count % 3 != 0,
                (i >= 3 || count == 4),
                leftover < threshold {
                imageViews[i].frame.size.width = maxWidth / 2
            }
            lastFrame = imageViews[i].frame
            imageViews[i].layer.cornerRadius = 1.5
            imageViews[i].layer.masksToBounds = true
            imageContainer.addSubview(imageViews[i])
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(multipleImageButtonTapped(_:)))
            imageViews[i].addGestureRecognizer(tap)
            imageViews[i].isUserInteractionEnabled = true
        }
    }

    // MARK: - Helpers from MessageKit
    public static func labelRect(for text: String, font: UIFont, considering maxSize: CGSize) -> CGRect {
        let attributedText = NSAttributedString(string: text, attributes: [ NSAttributedString.Key.font: font as Any ])
        let rect = attributedText.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).integral
        return rect
    }
    
    fileprivate static let magifyWidthRatio: CGFloat = 2
    public static func sizeForText(_ text: String, fontName: String = "AppleSDGothicNeo-Medium",
                                   fontSize: CGFloat = 16, maxWidth: CGFloat = UIScreen.main.bounds.width * 0.8,
                            paddingX: CGFloat = 10, paddingY: CGFloat = 2) -> CGSize {
        let maxSize = CGSize(width: maxWidth - paddingX * magifyWidthRatio, height: 0)
        let font = UIFont(name: fontName, size: fontSize) ?? kTextFont ?? UIFont.systemFont(ofSize: 16)
        var rect = OZMessageCell.labelRect(for: text, font: font, considering: maxSize)
        rect.size = CGSize(width: floor(rect.size.width) + magifyWidthRatio * paddingX, height: floor(rect.size.height) + 2 * paddingY)
        return rect.size
    }
        
    public static func frameForMessage(_ message: OZMessage, containerWidth: CGFloat) -> CGRect {
        let aMaxWidth = containerWidth * message.bubbleWidthRatio
        var xOrigin: CGFloat = 0
        if message.alignment == .right {
            xOrigin = containerWidth - (containerWidth * message.bubbleWidthRatio)
        }
        
        if message.chatEmoticonSize != .zero, message.type == .emoticon {
            if message.alignment == .left {
                var eSize = message.chatEmoticonSize
                if message.iconImage.count > 0 { eSize.width += message.cellLeftPadding }
                return CGRect(origin: CGPoint(x: xOrigin, y: 0), size: eSize)
            }
            else {
                var eSize = message.chatEmoticonSize
                if message.iconImage.count > 0 { eSize.width += message.cellRightPadding }
                return CGRect(origin: CGPoint(x: containerWidth - eSize.width, y: 0), size: eSize)
            }
        }
        else if message.type == .multipleImages {
            let count = message.content.components(separatedBy: "|").count
            var size = message.chatImageSize
            size.width = min(size.width * 3, containerWidth * 0.8)
            if count > 6 {
                size.height = max(size.height * 3, message.cellHeight * 2)
            }
            else if count > 3 {
                size.height = max(size.height * 2, message.cellHeight)
            }
            else {
                size.height = max(size.height, message.cellHeight)
            }
            if message.alignment == .left {
                let leftPadding = message.iconImage.count > 0 ? message.cellLeftPadding : message.cellPadding
                let finalSize = CGSize(width: size.width + leftPadding, height: size.height)
                return CGRect(origin: CGPoint(x: 0, y: 0), size: finalSize)
            }
            else if message.alignment == .right {
                let rightPadding = message.iconImage.count > 0 ? message.cellRightPadding : message.cellPadding
                let finalSize = CGSize(width: size.width + rightPadding, height: size.height)
                return CGRect(origin: CGPoint(x: containerWidth - size.width, y: 0), size: finalSize)
            }
        }
        else if (message.type == .image || message.type == .emoticon),
            message.content.count > 0 {
            var imageSize = message.imageSize
            if imageSize == .zero {
                if message.content.lowercased().hasPrefix("file"),
                    let anUrl = URL(string: message.content),
                    FileManager.default.isReadableFile(atPath: anUrl.relativePath),
                    let data = FileManager.default.contents(atPath: anUrl.relativePath),
                    let parsed = try? ImageSizeParser(data: data) {
                    // Local file with fileURL
                    imageSize = parsed.size
                }
                else if message.content.hasPrefix("/"),
                    FileManager.default.isReadableFile(atPath: message.content),
                    let data = FileManager.default.contents(atPath: message.content),
                    let parsed = try? ImageSizeParser(data: data) {
                    // Local file with relative path
                    imageSize = parsed.size
                }
                else if let anImg = UIImage(named: message.content) {
                    // 내장 이미지명
                    imageSize = anImg.size
                }
            }
            
            var maxImageSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: message.cellHeight)
            if message.chatImageSize != .zero,
                message.cellHeight != message.chatImageSize.height {
                maxImageSize = message.chatImageSize
            }
            if message.usingPackedImages, message.usingPackedImagesAsStrictSize {
                imageSize = message.chatImageSize
            }
            else {
                if imageSize.width > maxImageSize.width {
                    imageSize.height /= imageSize.width/maxImageSize.width
                    imageSize.width = maxImageSize.width
                }
                if imageSize.height > maxImageSize.height {
                    imageSize.width /= imageSize.height/maxImageSize.height
                    imageSize.height = maxImageSize.height
                }
                if !message.usingPackedImages, message.cellHeight < imageSize.height {
                    imageSize.height = message.cellHeight
                }
            }
            if message.alignment == .left {
                if message.iconImage.count > 0 { imageSize.width += message.cellLeftPadding }
                return CGRect(origin: CGPoint(x: xOrigin, y: 0), size: imageSize)
            }
            else if message.alignment == .right {
                if message.iconImage.count > 0 { imageSize.width += message.cellRightPadding }
                return CGRect(origin: CGPoint(x: containerWidth - imageSize.width, y: 0), size: imageSize)
            }
        }
        else if message.type == .deviceStatus {
            let size = CGSize(width: containerWidth, height: message.cellHeight)
            return CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        }
        else if message.type == .mp3 || message.type == .voice {
            if message.alignment == .left {
                let leftPadding = message.iconImage.count > 0 ? message.cellLeftPadding : message.cellPadding
                let size = CGSize(width: 120 + leftPadding, height: message.cellHeight)
                return CGRect(origin: CGPoint(x: 0, y: 0), size: size)
            }
            else if message.alignment == .right {
                let rightPadding = message.iconImage.count > 0 ? message.cellRightPadding : message.cellPadding
                let size = CGSize(width: 120 + rightPadding, height: message.cellHeight)
                return CGRect(origin: CGPoint(x: containerWidth - size.width, y: 0), size: size)
            }
        }
        
        // Alignment: left, center,  right
        if message.alignment == .center {
            let size = sizeForText(message.content, fontName: message.fontName,
                                   fontSize: message.fontSize, maxWidth: containerWidth,
                                   paddingX: message.cellPadding, paddingY: message.cellPadding)
            return CGRect(x: (containerWidth - size.width)/2, y: 0, width: size.width + message.cellPadding * 4, height: size.height)
        } else {
            var paddingX = message.cellPadding
            if message.iconImage.count > 0 {
                if message.alignment == .left {
                    paddingX = message.cellLeftPadding
                }
                else if message.alignment == .right {
                    paddingX = message.cellRightPadding
                }
            }
        
            let marginForScreen = (50/375) * UIScreen.main.bounds.width
            var size = sizeForText(message.content, fontName: message.fontName,
                                   fontSize: message.fontSize, maxWidth: aMaxWidth - marginForScreen,
                                   paddingX: paddingX,
                                   paddingY: message.cellPadding)
            if message.usingFoldingOption, size.height > message.foldingMessageMaxHeight {
                if message.isFolded {
                    size.height = message.foldingMessageMaxHeight + message.cellPadding + message.foldingButtonSize.height
                }
                else {
                    size.height += message.foldingButtonSize.height
                }
                if size.width > aMaxWidth - marginForScreen {
                    size.width = aMaxWidth - marginForScreen
                }
                else if size.width < message.foldingButtonSize.width + paddingX {
                    size.width = message.foldingButtonSize.width + paddingX
                }
            }
            let origin: CGPoint = (message.alignment == .left) ? .zero : CGPoint(x: containerWidth - size.width, y: 0)
            return CGRect(origin: origin, size: size)
        }
    }
}
