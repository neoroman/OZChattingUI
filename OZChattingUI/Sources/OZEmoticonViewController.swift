//
//  OZEmoticonViewController.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/06.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit
import CollectionKit

public var kEmoticonCellSize: CGSize = CGSize(width: 60, height: 60)
public var kEmoticonGridSize: CGSize = CGSize(width: 30, height: 30)
public var kEmoticonCellPaddingX: CGFloat = 20
public var kEmoticonCellPaddingY: CGFloat = 0


open class OZEmoticonLayout: SimpleLayout {
    override open func simpleLayout(context: LayoutContext) -> [CGRect] {
        var frames: [CGRect] = []
        var lastFrame: CGRect?
        let maxWidth: CGFloat = UIScreen.main.bounds.width
        let maxHeight: CGFloat = context.collectionSize.height
        
        for _ in 0..<context.numberOfItems {
            var xWidth: CGFloat = 0
            var yOffset: CGFloat = 0
            var cellFrame = CGRect(origin: .zero, size: kEmoticonCellSize)
            if let lastFrame = lastFrame {
                if lastFrame.maxY + cellFrame.height + kEmoticonGridSize.height < maxHeight {
                    xWidth = lastFrame.minX
                    yOffset = lastFrame.maxY + kEmoticonGridSize.height
                } else {
                    if lastFrame.maxX - kEmoticonCellSize.width/2 < maxWidth,
                        lastFrame.maxX + kEmoticonCellSize.width > maxWidth { // WTF...
                        xWidth = lastFrame.maxX + kEmoticonGridSize.width * 2 + kEmoticonCellPaddingX
                    }
                    else {
                        xWidth = lastFrame.maxX + kEmoticonGridSize.width
                    }
                }
            }
            cellFrame.origin.x = xWidth
            cellFrame.origin.y += yOffset

            lastFrame = cellFrame
            
            frames.append(cellFrame)
        }
        
        return frames
    }
}

open class OZEmoticonViewController: CollectionViewController {
    
    let dataSource = OZEmoticonDataProvider()
    var delegate: Any?
    
    var pageControl: UIPageControl?
    var maxPage: Int = 2
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        view.clipsToBounds = true
        collectionView.frame = view.bounds
        collectionView.contentSize.height = view.bounds.height
        
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.alwaysBounceVertical = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.magenta.withAlphaComponent(0.2)
        
        // Emoticon arrangement
        if UIDevice.current.isIphoneX {
            // isiPhoneX top and bottom padding exist
            collectionView.contentInset = UIEdgeInsets(top: 40, left: kEmoticonGridSize.width,
                                                       bottom: 20, right: kEmoticonGridSize.width)
        }
        else {
            collectionView.contentInset = UIEdgeInsets(top: 25, left: kEmoticonGridSize.width,
                                                       bottom: 25, right: kEmoticonGridSize.width)
        }
        let maxWidth = collectionView.bounds.width - kEmoticonCellPaddingX
        kEmoticonCellSize.width = maxWidth / 4 - kEmoticonGridSize.width
        kEmoticonCellSize.height = kEmoticonCellSize.width
        
        
        // First we make emoticon sort by name on 2020.05.24
        dataSource.data.sort { (a, b) -> Bool in
            return a.name < b.name
        }
        
        let emoticonViewSource = ClosureViewSource(viewUpdater: { (view: OZEmoticonCell, data: OZEmoticon, at: Int) in
            view.emoticon = data
        })
        
        self.provider = BasicProvider(
            identifier: "OZChat2020-Emoticon",
            dataSource: dataSource,
            viewSource: ComposedViewSource(viewSourceSelector: { data in
                return emoticonViewSource
            }),
            sizeSource: { (_, _, size) -> CGSize in
                return kEmoticonCellSize
            },
            layout: OZEmoticonLayout().insetVisibleFrame(by: collectionView.contentInset),
            animator: WobbleAnimator(), //FadeAnimator(), //SimpleAnimator(),
            // MARK: Cell Tap Handler hera
            tapHandler: {  context in
                let anEmoticon = context.data
                print("EMOTICON::::\(anEmoticon)")
                if let dele = self.delegate as? OZMessagesViewController {
                    dele.send(msg: anEmoticon.name, type: .emoticon)
                }
            }
        )
        
        setupPageControl()
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        if let pc = pageControl {
            view.bringSubviewToFront(pc)
            
            let insetWidth = collectionView.contentInset.left + collectionView.contentInset.right
            let maxWidth = collectionView.frame.width - insetWidth
            let maxPage = Int(collectionView.contentSize.width / maxWidth)
            let sizeOfPageControl = pc.size(forNumberOfPages: maxPage)
            let centerOfPageControl = CGPoint(x: view.bounds.midX,
                                              y: view.bounds.maxY - sizeOfPageControl.height / 2)
            pc.frame = CGRect(center: centerOfPageControl, size: sizeOfPageControl)
        }
    }

    // MARK: - PageControl
    fileprivate func setupPageControl() {
        if pageControl == nil {
            pageControl = UIPageControl(frame: CGRect.zero)
            if let dele = delegate as? OZMessagesViewController {
                for case .emoticonCurrentPageIndicatorTintColor(let color) in dele.messagesConfigurations {
                    pageControl?.currentPageIndicatorTintColor = color
                }
                for case .emoticonPageIndicatorTintColor(let color) in dele.messagesConfigurations {
                    pageControl?.pageIndicatorTintColor = color
                }
            }
            pageControl?.backgroundColor = .clear
            pageControl?.isUserInteractionEnabled = false
            pageControl?.currentPage = 0
            pageControl?.numberOfPages = maxPage
            view.addSubview(pageControl!)
        }
    }
}



extension OZEmoticonViewController: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let pc = self.pageControl else { return }
        let insetWidth = collectionView.contentInset.left + collectionView.contentInset.right
        let maxWidth = collectionView.frame.width - insetWidth
        let maxPage = Int(collectionView.contentSize.width / maxWidth)
        pc.numberOfPages = maxPage
        pc.currentPage = Int(scrollView.contentOffset.x) / Int(maxWidth)
        
        // paging offset compansation, WHY?!?
        if scrollView.contentOffset.x < insetWidth {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                scrollView.contentOffset.x = -self.collectionView.contentInset.left
            }, completion: nil)
        }
        else if scrollView.contentOffset.x > maxWidth,
            scrollView.contentOffset.x < maxWidth + insetWidth {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                scrollView.contentOffset.x = +self.collectionView.contentInset.left
            }, completion: nil)
        }
    }
}
