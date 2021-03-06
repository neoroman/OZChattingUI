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
//  OZMessagesExtension.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/05.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import Foundation
import UIKit
import CollectionKit

public enum OZMessageDeviceType {
    case campaign
    case call
    case watchOff
    case step
    
    func imageName() -> String {
        switch self {
        case .call: return "call"
        case .watchOff: return "campaignWatchOff"
        case .step: return "step"
        default:
            return "campaign"
        }
    }
}

open class OZMessageDataProvider: ArrayDataSource<OZMessage> {
    public init(data: [OZMessage]? = nil) {
        if let data = data {
            super.init(data: data, identifierMapper: { (_, data) in
                return data.identifier
            })
        }
        else {
            super.init(data: [], identifierMapper: { (_, data) in
                return data.identifier
            })
        }
    }
}


open class OZMessageLayout: SimpleLayout {
    override open func simpleLayout(context: LayoutContext) -> [CGRect] {
        var frames: [CGRect] = []
        var lastMessage: OZMessage?
        var lastFrame: CGRect?
        let maxWidth: CGFloat = context.collectionSize.width
        
        for i in 0..<context.numberOfItems {
            let message = context.data(at: i) as! OZMessage
            var yHeight: CGFloat = 0
            var xOffset: CGFloat = 0
            var cellFrame = OZMessageCell.frameForMessage(message, containerWidth: maxWidth)
            if let lastMessage = lastMessage, let lastFrame = lastFrame {
                if message.usingPackedImages && message.type == .image &&
                    lastMessage.type == .image && message.alignment == lastMessage.alignment {
                    
                    if message.alignment == .left && lastFrame.maxX + cellFrame.width + 2 < maxWidth {
                        yHeight = lastFrame.minY
                        xOffset = lastFrame.maxX + 2
                    } else if message.alignment == .right && lastFrame.minX - cellFrame.width - 2 > 0 {
                        yHeight = lastFrame.minY
                        xOffset = lastFrame.minX - 2 - cellFrame.width
                        cellFrame.origin.x = 0
                    } else {
                        yHeight = lastFrame.maxY + message.verticalPaddingBetweenMessage(lastMessage)
                    }                    
                } else {
                    yHeight = lastFrame.maxY + message.verticalPaddingBetweenMessage(lastMessage)
                }
            }
            cellFrame.origin.x += xOffset
            cellFrame.origin.y = yHeight
            
            lastFrame = cellFrame
            lastMessage = message
            
            frames.append(cellFrame)
        }
        
        return frames
    }
}

open class OZMessageAnimator: WobbleAnimator {
    var dataSource: OZMessageDataProvider?
    weak var sourceView: UIView?
    var sendingMessage = false
    public var isNoAnimation = false
    
    override open func insert(collectionView: CollectionView, view: UIView, at index: Int, frame: CGRect) {
        super.insert(collectionView: collectionView, view: view, at: index, frame: frame)
        guard let messages = dataSource?.data,
            let sourceView = sourceView,
            collectionView.hasReloaded,
            collectionView.isReloading, !isNoAnimation else { return }
        if sendingMessage && index == messages.count - 1 {
            // we just sent this message, lets animate it from inputToolbarView to it's position
            view.frame = collectionView.convert(sourceView.bounds, from: sourceView)
            view.alpha = 0
            view.yaal.alpha.animateTo(1.0)
            view.yaal.bounds.animateTo(frame.bounds, stiffness: 400, damping: 40)
        } else if collectionView.visibleFrame.intersects(frame) {
            if messages[index].alignment == .left {
                let center = view.center
                view.center = CGPoint(x: center.x - view.bounds.width, y: center.y)
                view.yaal.center.animateTo(center, stiffness:250, damping: 20)
            } else if messages[index].alignment == .right {
                let center = view.center
                view.center = CGPoint(x: center.x + view.bounds.width, y: center.y)
                view.yaal.center.animateTo(center, stiffness:250, damping: 20)
            } else {
                view.alpha = 0
                view.yaal.scale.from(0).animateTo(1)
                view.yaal.alpha.animateTo(1)
            }
        }
    }
}


// MARK: - for emoticon
open class OZEmoticonDataProvider: ArrayDataSource<OZEmoticon> {
    init() {
        super.init(data: OZEmoticonList().allEmoticons, identifierMapper: { (_, data) in
            return data.identifier
        })
    }
}
