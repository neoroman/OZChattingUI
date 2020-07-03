//
//  CollectionViewController.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/06/07.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit
import CollectionKit

open class CollectionViewController: UIViewController {
    public let collectionView = CollectionView()

    var provider: Provider? {
        get { return collectionView.provider }
        set { collectionView.provider = newValue }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Do this in OZMessagesViewController with keyboard show and hide by Henry on 2020.05.05
        //collectionView.frame = view.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 56, right: 0))
    }
}
