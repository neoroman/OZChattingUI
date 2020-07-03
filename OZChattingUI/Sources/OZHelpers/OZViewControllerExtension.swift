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
//  OZViewControllerExtension.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/06/05.
//

import UIKit

extension UIViewController {
    
    open func displayActionSheet(_ message: String, actions: [UIAlertAction], cancel: UIAlertAction? = nil, preferredStyle: UIAlertController.Style? = .actionSheet) {
        let alert: UIAlertController = UIAlertController(title: "", message: message, preferredStyle: preferredStyle!)
        var cancelAction: UIAlertAction
        
        for anAct in actions {
            alert.addAction(anAct)
        }
        
        if let cAct = cancel {
            cancelAction = cAct
        }
        else {
            cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel) { (alert) in
                print("Cancel has been choosed...!")
            }
        }
        
        alert.addAction(cancelAction)
        
        if alert.actions.count == 0 {
            if let window = UIApplication.shared.keyWindow,
                let rootVC = window.rootViewController,
                let rootNC = rootVC.navigationController {
                if rootNC.topViewController != self {
                    rootVC.present(alert, animated: true) {
                        //code
                    }
                    return
                }
            }
            self.present(alert, animated: true) {
                // code
            }
        }
    }
    

    // MARK: - display messages..
    open func displayMessage(_ message: String, confirm: UIAlertAction? = nil, cancel: UIAlertAction? = nil, preferredStyle: UIAlertController.Style? = .alert) {

        let alert: UIAlertController = UIAlertController(title: "", message: message, preferredStyle: preferredStyle!)
        var okAction: UIAlertAction
        var cancelAction: UIAlertAction
        
        if let okAct = confirm {
            okAction = okAct
            alert.addAction(okAction)
        }
        
        if let cAct = cancel {
            cancelAction = cAct
            alert.addAction(cancelAction)
        }
                
        // Alert 표시
        if let window = UIApplication.shared.keyWindow,
            let rootVC = window.rootViewController,
            let rootNC = rootVC.navigationController {
            if rootNC.topViewController != self {
                rootVC.present(alert, animated: true) {
                    if alert.actions.count == 0 {
                        delay(2) {
                            alert.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                return
            }
        }

        self.present(alert, animated: true) {
            if alert.actions.count == 0 {
                delay(2) {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    open func displayMessageSingle(_ message: String, title: String? = nil, confirm: UIAlertAction? = nil) {
        var t = ""
        if let aTitle = title,
            aTitle.count > 0 {
            t = aTitle
        }
        
        let alert: UIAlertController = UIAlertController(title: t, message: message, preferredStyle: .alert)
        
        // '확인' 액션
        var okAction: UIAlertAction
        if let okAct = confirm {
            okAction = okAct
            alert.addAction(okAction)
        }
        
        // Alert 표시
        if let window = UIApplication.shared.keyWindow,
            let rootVC = window.rootViewController,
            let rootNC = rootVC.navigationController {
            if rootNC.topViewController != self {
                rootVC.present(alert, animated: true) {
                    if alert.actions.count == 0 {
                        delay(2) {
                            alert.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                return
            }
        }
        
        self.present(alert, animated: true) {
            if alert.actions.count == 0 {
                delay(2) {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
