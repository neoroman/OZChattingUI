//
//  OZMessage.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/03.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit

public enum OZMessageType {
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
    public var isSenderIconHide: Bool = true
    
    public init() {
        self.identifier = ""
        self.type = .UNKNOWN
    }
    
    public init(_ fromCurrentUser: Bool, content: String, timestamp: Int = 0, iconImage: String? = nil) {
        self.fromCurrentUser = fromCurrentUser
        self.type = .text
        self.content = content
        self.initWithUserProfileAndTimestamp(fromCurrentUser, tm: timestamp, img: iconImage)
    }
    public init(_ fromCurrentUser: Bool, emoticon: String, timestamp: Int = 0, iconImage: String? = nil) {
        self.fromCurrentUser = fromCurrentUser
        self.type = .emoticon
        self.content = emoticon
        self.initWithUserProfileAndTimestamp(fromCurrentUser, tm: timestamp, img: iconImage)
    }
    public init(_ fromCurrentUser: Bool, status: String, timestamp: Int = 0, iconImage: String? = nil) {
        self.fromCurrentUser = fromCurrentUser
        self.type = .status
        self.content = status
        self.initWithUserProfileAndTimestamp(fromCurrentUser, tm: timestamp, img: iconImage)
    }
    public init(_ fromCurrentUser: Bool, image: String, timestamp: Int = 0, iconImage: String? = nil) {
        self.fromCurrentUser = fromCurrentUser
        self.type = .image
        self.content = image
        self.initWithUserProfileAndTimestamp(fromCurrentUser, tm: timestamp, img: iconImage)
    }
    public init(_ fromCurrentUser: Bool, voice: String, duration: Int = 0, timestamp: Int = 0, iconImage: String? = nil) {
        self.fromCurrentUser = fromCurrentUser
        self.type = .voice
        self.content = voice
        self.extra["duration"] = duration
        self.initWithUserProfileAndTimestamp(fromCurrentUser, tm: timestamp, img: iconImage)
    }
    public init(_ fromCurrentUser: Bool, mp3: String, duration: Int = 0, timestamp: Int = 0, iconImage: String? = nil) {
        self.fromCurrentUser = fromCurrentUser
        self.type = .mp3
        self.content = mp3
        self.extra["duration"] = duration
        self.initWithUserProfileAndTimestamp(fromCurrentUser, tm: timestamp, img: iconImage)
    }
    public init(announcement: String, timestamp: Int = 0) {
        self.type = .announcement
        self.content = announcement
        if timestamp == 0 { self.timestamp = Int(Date().timeIntervalSince1970) }
        else { self.timestamp = timestamp }
    }
    public init(deviceStatus: String, statusType: OZMessageDeviceType? = .call, iconNamed: String? = "", timestamp: Int = 0) {
        self.type = .deviceStatus
        self.content = deviceStatus
        self.deviceStatus = statusType
        self.iconImage = iconNamed ?? ""
        if timestamp == 0 { self.timestamp = Int(Date().timeIntervalSince1970) }
        else { self.timestamp = timestamp }
    }
    
    private func initWithUserProfileAndTimestamp(_ fromCurrentUser: Bool, tm: Int, img: String?) {
        if !fromCurrentUser {
            if let anImg = img {
                self.isSenderIconHide = false
                self.iconImage = anImg
            }
            else {
                self.isSenderIconHide = true
                self.iconImage = ""
            }
            if tm == 0 { self.timestamp = Int(Date().timeIntervalSince1970) }
            else { self.timestamp = tm }
        }
        else {
            if tm == 0 { self.timestamp = Int(Date().timeIntervalSince1970) }
            else { self.timestamp = tm }
        }
    }
    
    public var fontName: String {
        return "AppleSDGothicNeo-Medium"
    }
    public var fontSize: CGFloat {
        switch type {
        case .text, .deviceStatus: return 16
        default: return 14
        }
    }
    public var timeFontSize: CGFloat {
        return 12
    }
    public var timeFontColor: UIColor {
        return UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
    }
    public var inputTextFieldFontColor: UIColor {
        return UIColor.black
    }
    public var iconSize: CGFloat {
        switch type {
        case .deviceStatus: return 20
        default: return 32
        }
    }
    public var iconPadding: CGFloat {
        return 8
    }
    public var cellPadding: CGFloat {
        switch type {
        case .announcement: return 4
        case .text, .deviceStatus: return 12
        case .status: return 2
        case .image, .mp3, .emoticon, .voice: return 0
        default: return 0
        }
    }
    public var cellLeftPadding: CGFloat {
        switch type {
        case .announcement, .status: return 0
        default: return iconSize + iconPadding
        }
    }
    public var cellHeight: CGFloat {
        switch type {
        case .mp3, .voice: return 40
        default: return 60
        }
    }
    public var bubbleWidthRatio: CGFloat {
        return 0.9 //0.714666 //(375 - 107) / 375
    }
    public var bubbleColor: UIColor {
        if !fromCurrentUser {
            return UIColor(white: 244.0 / 255.0, alpha: 1.0)
        }
        else {
            return UIColor(red: 229.0 / 255.0, green: 21.0 / 255.0, blue: 0.0, alpha: 1.0)
        }
    }
    public var showShadow: Bool {
        switch type {
        case .text, .image: return false //true
        default: return false
        }
    }
    public var roundedCornder: Bool {
        switch type {
        case .announcement: return false
        default: return true
        }
    }
    public var textColor: UIColor {
        switch type {
        case .text:
            if fromCurrentUser {
                return UIColor.white
            } else {
                return UIColor.black
            }
        case .deviceStatus, .mp3, .voice:
            return UIColor.black
        default:
            return UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        }
    }
    public var backgroundColor: UIColor {
        switch type {
        case .text:
            return UIColor.clear
        case .announcement:
            return UIColor.white
        default:
            return UIColor.clear
        }
    }
    public var shadowColor: UIColor {
        switch type {
        case .text:
            if fromCurrentUser {
                //return UIColor(red: 0.1, green: 140/255, blue: 1.0, alpha: 1.0)
                return UIColor(red: 140/255, green: 0.1, blue: 0.1, alpha: 1.0)
            } else {
                return UIColor(white: 0.5, alpha: 1.0)
            }
        case .image:
            return UIColor(white: 0.4, alpha: 1.0)
        default:
            return UIColor.clear
        }
    }
    public var seperatorColor: UIColor {
        switch type {
        case .announcement: return UIColor(white: 238.0 / 255.0, alpha: 1.0)
        default: return UIColor.clear
        }
    }
    public var alignment: OZMessageAlignment {
        switch type {
        case .announcement, .deviceStatus: return .center
        default: return (fromCurrentUser ? .right : .left)
        }
    }
    
    func verticalPaddingBetweenMessage(_ previousMessage: OZMessage) -> CGFloat {
        if type == .image && previousMessage.type == .image {
            return 2 + previousMessage.iconSize / 2
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
            return 25
        }
        return 25
    }
    
    func copy() -> OZMessage {
        switch type {
        case .image:
            return OZMessage(fromCurrentUser, image: content)
        case .announcement:
            return OZMessage(announcement: content)
        case .text:
            return OZMessage(fromCurrentUser, content: content)
        case .emoticon:
            return OZMessage(fromCurrentUser, emoticon: content)
        case .status:
            return OZMessage(fromCurrentUser, status: content)
        case .deviceStatus:
            return OZMessage(deviceStatus: content, statusType: deviceStatus ?? .call)
        case .mp3:
            return OZMessage(fromCurrentUser, mp3: content, duration: 0)
        case .voice:
            return OZMessage(fromCurrentUser, voice: content, duration: 0)
        default:
            return OZMessage()
        }
    }
}

