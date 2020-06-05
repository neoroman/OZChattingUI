//
//  OZViewControllerExtension.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/06/05.
//

import UIKit

extension UIViewController {
    
    func displayActionSheet(_ message: String, actions: [UIAlertAction], cancel: UIAlertAction? = nil, preferredStyle: UIAlertController.Style? = .actionSheet) {
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
    func displayMessage(_ message: String, confirm: UIAlertAction? = nil, cancel: UIAlertAction? = nil, preferredStyle: UIAlertController.Style? = .alert) {

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
                        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                            alert.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                return
            }
        }

        self.present(alert, animated: true) {
            if alert.actions.count == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func displayMessageSingle(_ message: String, title: String? = nil, confirm: UIAlertAction? = nil) {
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
                        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                            alert.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                return
            }
        }
        
        self.present(alert, animated: true) {
            if alert.actions.count == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
