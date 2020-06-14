//
//  OZMessage.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/03.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit

public enum OZMessageFoldState {
    case fold, unfold, none
    
    func tag() -> Int {
        switch self {
        case .fold:
            return 1004111
        case .unfold:
            return 1004222
        default:
            return 0
        }
    }
    
    static func typeFromTag(_ tag: Int) -> OZMessageFoldState {
        if tag == OZMessageFoldState.fold.tag() {
            return .fold
        }
        else if tag == OZMessageFoldState.unfold.tag() {
            return .unfold
        }
        else {
            return .none
        }
    }
}

public enum OZMessageType: Int {
    case text
    case announcement
    case status
    case image
    case deviceStatus
    case mp3
    case voice
    case emoticon
    case UNKNOWN
    
    func isEchoEnable() -> Bool {
        switch self {
        case .announcement, .status, .deviceStatus: return false
        default: return true
        }
    }
    
    public static let count: Int = {
        var max: Int = 0
        while let _ = OZMessageType(rawValue: max) { max += 1 }
        return max - 1 // get rid of .UNKNOWN
    }()
    
    public static func allTypes() -> [OZMessageType] {
        var types: [OZMessageType] = []
        for i in 0..<OZMessageType.count {
            if let aType = OZMessageType(rawValue: i) {
                types.append(aType)
            }
        }
        return types
    }
}
public enum OZMessageAlignment {
    case left
    case center
    case right
}
public class OZMessage: Equatable {
    public static func == (lhs: OZMessage, rhs: OZMessage) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    public var identifier: String = UUID().uuidString
    public var content = ""
    public var type: OZMessageType
    public var deviceStatus: OZMessageDeviceType?
    public var iconImage = ""
    public var fromCurrentUser = false
    public var timestamp: Int = 0
    public var extra: [String: Any] = [:] // JSON?
    internal var imageSize: CGSize = .zero
    
    public init() {
        self.identifier = ""
        self.type = .UNKNOWN
    }
    
    public init(_ fromCurrentUser: Bool, content: String, timestamp: Int = 0, iconImage: String? = nil, config: [OZMessagesConfigurationItem]? = nil) {
        self.fromCurrentUser = fromCurrentUser
        if fromCurrentUser {
            self.alignment = .right
        }
        else {
            self.alignment = .left
        }
        self.type = .text
        self.content = content

        setupConfigurations(config: config)
        self.initWithUserProfileAndTimestamp(fromCurrentUser, tm: timestamp, img: iconImage)
    }
    public init(_ fromCurrentUser: Bool, emoticon: String, timestamp: Int = 0, iconImage: String? = nil, config: [OZMessagesConfigurationItem]? = nil) {
        self.fromCurrentUser = fromCurrentUser
        if fromCurrentUser {
            self.alignment = .right
        }
        else {
            self.alignment = .left
        }
        self.type = .emoticon
        self.content = emoticon

        setupConfigurations(config: config)
        self.initWithUserProfileAndTimestamp(fromCurrentUser, tm: timestamp, img: iconImage)
    }
    public init(_ fromCurrentUser: Bool, status: String, timestamp: Int = 0, iconImage: String? = nil, config: [OZMessagesConfigurationItem]? = nil) {
        self.fromCurrentUser = fromCurrentUser
        if fromCurrentUser {
            self.alignment = .right
        }
        else {
            self.alignment = .left
        }
        self.type = .status
        self.content = status

        setupConfigurations(config: config)
        self.initWithUserProfileAndTimestamp(fromCurrentUser, tm: timestamp, img: iconImage)
    }
    public init(_ fromCurrentUser: Bool, image: String, timestamp: Int = 0, iconImage: String? = nil, config: [OZMessagesConfigurationItem]? = nil) {
        self.fromCurrentUser = fromCurrentUser
        if fromCurrentUser {
            self.alignment = .right
        }
        else {
            self.alignment = .left
        }
        self.type = .image
        self.content = image
 
        setupConfigurations(config: config)
        self.initWithUserProfileAndTimestamp(fromCurrentUser, tm: timestamp, img: iconImage)
    }
    public init(_ fromCurrentUser: Bool, voice: String, duration: Int = 0, timestamp: Int = 0, iconImage: String? = nil, config: [OZMessagesConfigurationItem]? = nil) {
        self.fromCurrentUser = fromCurrentUser
        if fromCurrentUser {
            self.alignment = .right
        }
        else {
            self.alignment = .left
        }
        self.type = .voice
        self.content = voice
        self.extra["duration"] = duration

        setupConfigurations(config: config)
        self.initWithUserProfileAndTimestamp(fromCurrentUser, tm: timestamp, img: iconImage)
    }
    public init(_ fromCurrentUser: Bool, mp3: String, duration: Int = 0, timestamp: Int = 0, iconImage: String? = nil, config: [OZMessagesConfigurationItem]? = nil) {
        self.fromCurrentUser = fromCurrentUser
        if fromCurrentUser {
            self.alignment = .right
        }
        else {
            self.alignment = .left
        }
        self.type = .mp3
        self.content = mp3
        self.extra["duration"] = duration

        setupConfigurations(config: config)
        self.initWithUserProfileAndTimestamp(fromCurrentUser, tm: timestamp, img: iconImage)
    }
    public init(announcement: String, timestamp: Int = 0, config: [OZMessagesConfigurationItem]? = nil) {
        self.type = .announcement
        self.content = announcement
        if timestamp == 0 { self.timestamp = Int(Date().timeIntervalSince1970) }
        else { self.timestamp = timestamp }

        setupConfigurations(config: config)
    }
    public init(deviceStatus: String, statusType: OZMessageDeviceType? = .call, iconNamed: String? = "", timestamp: Int = 0, config: [OZMessagesConfigurationItem]? = nil) {
        self.type = .deviceStatus
        self.content = deviceStatus
        self.deviceStatus = statusType
        self.iconImage = iconNamed ?? ""
        if timestamp == 0 { self.timestamp = Int(Date().timeIntervalSince1970) }
        else { self.timestamp = timestamp }
        
        setupConfigurations(config: config)
    }
    
    private func initWithUserProfileAndTimestamp(_ fromCurrentUser: Bool, tm: Int, img: String?) {
        self.iconImage = ""
        if let anImg = img {
            self.iconImage = anImg
        }
        if tm == 0 { self.timestamp = Int(Date().timeIntervalSince1970) }
        else { self.timestamp = tm }
    }
    
    private func checkUserType(_ userType: OZMessagesUserSideConfigType) -> Bool {
        if fromCurrentUser, userType == .fromCurrent {
            return true
        }
        else if !fromCurrentUser, userType == .fromOther {
            return true
        }
        else if userType == .none {
            return true
        }
        return false
    }
    
    private func setupConfigurations(config: [OZMessagesConfigurationItem]?) {
        var configItems: [OZMessagesConfigurationItem] = OZChattingDefaultConfiguration.defaulMessageConfiguration()
        if let configList = config {
            configItems.append(contentsOf: configList)
        }
        for item in configItems {
            
            switch item {
            case .alignment(let anAlignment, let types, let userType):
                if types.contains(type), checkUserType(userType) {
                    alignment = anAlignment
                }
                break
            case .audioButtonsName(let play, let pause):
                audioPlayButtonName = play
                audioPauseButtonName = pause
                break
            case .audioProgressColor(let color, let userType):
                if checkUserType(userType) {
                    audioProgressColor = color
                }
                break
            case .autoScrollToBottomBeginTextInput(let yesOrNo, let isScrollToBottom):
                autoScrollToBottom = yesOrNo
                showScrollToBottomButton = isScrollToBottom
            case .bubbleBackgroundColor(let color, let userType):
                if checkUserType(userType)  {
                    bubbleColor = color
                }
                break
            case .canMessageSelectableByLongPressGesture(let yesOrNo):
                canMessageSelectable = yesOrNo
                break
            case .cellBackgroundColor(let color, let types):
                if types.contains(type) {
                    backgroundColor = color
                }
                break
            case .cellHeight(let height, let types):
                if types.contains(type) {
                    cellHeight = height
                }
                break
            case .cellPadding(let padding, let types):
                if types.contains(type) {
                    cellPadding = padding
                }
                break
            case .cellOpacity(let alpha, let types):
                if types.contains(type) {
                    cellOpacity = alpha
                }
                break
            case .chatEmoticonSize(let emoticonSize):
                chatEmoticonSize = emoticonSize
                break
            case .chatImageSize(let displaySize, let radius, _):
                chatImageSize = displaySize
                chatImageCornerRadius = radius
                break
            case .fontColor(let color, let types, let userType):
                if types.contains(type), checkUserType(userType) {
                    textColor = color
                }
                break
            case .fontName(let aFontName, let types):
                if types.contains(type) {
                    fontName = aFontName
                }
                break
            case .fontSize(let fontPoint, let types):
                if types.contains(type) {
                    fontSize = fontPoint
                }
                break
            case .maxWidthRatio(let ratio):
                bubbleWidthRatio = ratio
                break
            case .profileIconName(let name, let types, let userType):
                if types.contains(type), checkUserType(userType) {
                    iconImage = name
                }
                else {
                    iconImage = ""
                }
            case .profileIconPadding(let padding, let types):
                if types.contains(type) {
                    iconPadding = padding
                }
                break
            case .profileIconSize(let height, let types, let paddingX):
                if types.contains(type) {
                    iconSize = height
                    cellRightPadding = height + paddingX
                    cellLeftPadding = height + paddingX
                }
                break
            case .roundedCorner(let yesOrNo, let types):
                if types.contains(type) {
                    roundedCornder = yesOrNo
                }
                break
            case .scrollToBottomButton(let point, let size, let width, let stroke, let fill, let alpha):
                scrollToBottomButtonAlpha = alpha
                scrollToBottomButtonFillColor = fill
                scrollToBottomButtonOrigin = point
                scrollToBottomButtonSize = size
                scrollToBottomButtonStrokeColor = stroke
                scrollToBottomButtonStrokeWidth = width
            case .sepratorColor(let color):
                seperatorColor = color
                break
            case .shadowColor(let color, let types, let userType):
                if types.contains(type), checkUserType(userType) {
                    shadowColor = color
                }
                break
            case .showShadow(let yesOrNo, let types):
                if types.contains(type) {
                    showShadow = yesOrNo
                }
                break
            case .showTimeLabelForImage(let yesOrNo):
                showTimeLabelForImage = yesOrNo
                break
            case .timeFontColor(let color):
                timeFontColor = color
                break
            case .timeFontFormat(let format):
                timeFontFormat = format
                break
            case .timeFontSize(let fontPoint):
                timeFontSize = fontPoint
                break
            case .usingPackedImages(let yesOrNo, let isStrickSized):
                usingPackedImages = yesOrNo
                usingPackedImagesAsStrictSize = isStrickSized
                break
            case .usingLongMessageFolding(let yesOrNo, let maxHeight, let size, let foldAlignment, let unfoldAlignment):
                usingFoldingOption = yesOrNo
                foldingMessageMaxHeight = maxHeight
                foldingButtonSize = size
                foldingButtonAlignment = foldAlignment
                unfoldingButtonAlignment = unfoldAlignment
                if yesOrNo {
                    isFolded = true
                }
                break
            default:
                break
            }
        }
    }
    
    public var alignment: OZMessageAlignment = .center
    public var audioProgressColor: UIColor = UIColor.green.withAlphaComponent(0.9)
    public var audioPlayButtonName: String = ""
    public var audioPauseButtonName: String = ""
    public var autoScrollToBottom: Bool = true
    public var backgroundColor: UIColor = .clear
    public var bubbleColor: UIColor = UIColor.green.withAlphaComponent(0.9)
    public var bubbleWidthRatio: CGFloat = 1
    public var canMessageSelectable: Bool = false
    public var cellHeight: CGFloat = 0
    public var cellLeftPadding: CGFloat = 0
    public var cellPadding: CGFloat = 0
    public var cellRightPadding: CGFloat = 0
    public var cellOpacity: CGFloat = 1.0
    public var chatEmoticonSize: CGSize = .zero
    public var chatImageSize: CGSize = .zero
    public var chatImageCornerRadius: CGFloat = 0
    public var isFolded: Bool = false
    public var foldingMessageMaxHeight: CGFloat = 160
    public var foldingButtonSize: CGSize = .zero
    public var foldingButtonAlignment: OZMessageAlignment = .center
    public var unfoldingButtonAlignment: OZMessageAlignment = .center
    public var fontName: String = "AppleSDGothicNeo-Medium"
    public var fontSize: CGFloat = 0
    public var iconPadding: CGFloat = 0
    public var iconSize: CGFloat = 0
    public var inputTextFieldFontColor: UIColor = .black
    public var roundedCornder: Bool = true
    public var scrollToBottomButtonAlpha: CGFloat = 0
    public var scrollToBottomButtonOrigin: CGPoint = .zero
    public var scrollToBottomButtonSize: CGSize = .zero
    public var scrollToBottomButtonFillColor: UIColor = .clear
    public var scrollToBottomButtonStrokeColor: UIColor = .clear
    public var scrollToBottomButtonStrokeWidth: CGFloat = 0
    public var seperatorColor: UIColor = UIColor(white: 238.0 / 255.0, alpha: 1.0)
    public var shadowColor: UIColor = .black
    public var showScrollToBottomButton: Bool = false
    public var showShadow: Bool = false
    public var showTimeLabelForImage: Bool = false
    public var textColor: UIColor = .black
    public var timeFontColor: UIColor = .gray
    public var timeFontFormat: String = "h:mm a"
    public var timeFontSize: CGFloat = 0
    public var usingFoldingOption: Bool = false
    public var usingPackedImages: Bool = true
    public var usingPackedImagesAsStrictSize: Bool = false

    public func verticalPaddingBetweenMessage(_ previousMessage: OZMessage) -> CGFloat {
        if type == .image && previousMessage.type == .image {
            if iconImage.count > 0 {
                return 2 + previousMessage.iconSize / 2
            }
            else {
                return 2
            }
        }
        if fromCurrentUser {
            if previousMessage.iconImage.count > 0 {
                return previousMessage.iconSize / 2
            }
        }
        if type == .announcement {
            return 38
        }
        if previousMessage.type == .announcement {
            return 27
        }
        if previousMessage.type == .deviceStatus {
            return 27
        }
        if previousMessage.type == .mp3 || previousMessage.type == .voice {
            return 20
        }
        if type == .status {
            return 3
        }
        if type == .mp3 || type == .voice {
            return 20
        }
        if type == .text && type == previousMessage.type && fromCurrentUser == previousMessage.fromCurrentUser {
            return 10
        }
        return 25
    }
    
    public func copy(_ config: [OZMessagesConfigurationItem]? = nil) -> OZMessage {
        switch type {
        case .image:
            return OZMessage(fromCurrentUser, image: content, config: config ?? nil)
        case .announcement:
            return OZMessage(announcement: content, config: config ?? nil)
        case .text:
            return OZMessage(fromCurrentUser, content: content, config: config ?? nil)
        case .emoticon:
            return OZMessage(fromCurrentUser, emoticon: content, config: config ?? nil)
        case .status:
            return OZMessage(fromCurrentUser, status: content, config: config ?? nil)
        case .deviceStatus:
            return OZMessage(deviceStatus: content, statusType: deviceStatus ?? .call, config: config ?? nil)
        case .mp3:
            return OZMessage(fromCurrentUser, mp3: content, duration: 0, config: config ?? nil)
        case .voice:
            return OZMessage(fromCurrentUser, voice: content, duration: 0, config: config ?? nil)
        default:
            return OZMessage()
        }
    }
}

