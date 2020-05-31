//
//  ExampleViewController.swift
//  OZChatExample
//
//  Created by Henry Kim on 2020/05/07.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit
import OZChattingUI
import ImageViewer


fileprivate let kMicButtonTag = 17172008
fileprivate let kSendButtonTag = kMicButtonTag + 1004

class ExampleViewController: UIViewController {
    
    var chatViewController: OZMessagesViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    fileprivate func testChats(vc: OZMessagesViewController) {
        // Debug
        vc.isEchoMode = true
        vc.userProfilePath = Bundle.main.path(forResource: "TaylorSwift", ofType: "jpg")
        
        // Message send and receive
        vc.send(msg: "\(Date())", type: .announcement)
        vc.receive(msg: "Welcome to OZChattingUI", type: .text, timestamp: 0, profileIconPath: "TaylorSwift.jpg")

        let aTimestamp = Int(Date().timeIntervalSince1970)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            vc.receive(msg: "Sally called with you for 11minutes.", type: .deviceStatus, activeType: .call, timestamp: aTimestamp-600)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            vc.receive(msg: "test.mp3", type: .mp3, activeType: nil, timestamp: aTimestamp-400, profileIconPath: "TaylorSwift.jpg")
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            vc.receive(msg: "Viviana joined special event.", type: .deviceStatus, activeType: .campaign, timestamp: aTimestamp-300)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            vc.receive(msg: "Watch off", type: .deviceStatus, activeType: .watchOff, timestamp: aTimestamp-100)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.6) {
            vc.receive(msg: "Seal walked 1,004 steps, burned 14kcal", type: .deviceStatus, activeType: .step, timestamp: aTimestamp-50)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            vc.send(msg: "Hi... OZChattingUI!", type: .text) { (id, content) in
                vc.send(msg: "Delivered", type: .status, isDeliveredMsg: true)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            vc.send(msg: "You can test it here..., Good luck and have a nice day", type: .text) { (id, content) in
                vc.dataSource.data.removeAll(where: { $0.content == "Delivered" })
                vc.send(msg: "Delivered", type: .status, isDeliveredMsg: true)
            }
        }
    }

    @IBAction func buttonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "OZChattingUI", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "OZChattingUI") as? OZMessagesViewController {
            if chatViewController == nil {
                chatViewController = vc
            }
            vc.delegate = self
            vc.fileChoosePopupDelegate = self
            vc.messagesConfigurations = addMessageConfiguration()

            #if USING_AS_MODAL
            let nc = UINavigationController(rootViewController: vc)
            self.present(nc, animated: true) {
                self.testChats(vc: vc)
                if #available(iOS 13.0, *) {
                    vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.closeChatView))
                } else {
                    vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "ClosE", style: .done, target: self, action: #selector(self.closeChatView))
                }
            }
            #else
            if let nc = self.navigationController {
                nc.pushViewController(vc, animated: true)
                self.testChats(vc: vc)
            }
            #endif
        }
    }
    
    
    @IBAction func testButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "OZChattingUI", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "OZChattingUI") as? OZMessagesViewController {
            if chatViewController == nil {
                chatViewController = vc
            }
            vc.delegate = self
            vc.fileChoosePopupDelegate = self
            if #available(iOS 11.0, *) {
            } else {
//                vc.fileChoosePopup.setButton
            }

            #if USING_AS_MODAL
            self.present(nc, animated: true) {
                let nc = UINavigationController(rootViewController: vc)
                nc.isNavigationBarHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                    vc.setupDataProvider(newDataSource: OZMessageDataProvider.init(data: testMessages))
                    vc.collectionView.reloadData()
                    vc.collectionView.scrollTo(edge: .bottom, animated:true)
                    if #available(iOS 13.0, *) {
                        vc.isModalInPresentation = true
                        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.closeChatView))
                    } else {
                        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "ClosE", style: .done, target: self, action: #selector(self.closeChatView))
                    }
                    // This won't be executed
                    vc.messagesConfigurations = addMessageConfiguration()
                }
            }
            #else
            if let nc = self.navigationController {
                nc.pushViewController(vc, animated: true)
                vc.setupDataProvider(newDataSource: OZMessageDataProvider.init(data: testMessages))
                vc.collectionView.reloadData()
                vc.collectionView.scrollTo(edge: .bottom, animated:true)
                // This won't be executed
                vc.messagesConfigurations = addMessageConfiguration()
            }
            #endif
        }
    }

    
    @objc func closeChatView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func addMessageConfiguration() -> OZMessagesConfigurations {
        return [
            // OZMessageCell
            OZMessagesConfigurationItem.fontSize(16.0, [.text, .deviceStatus]),
            OZMessagesConfigurationItem.roundedCorner(true, [.announcement]),
            OZMessagesConfigurationItem.bubbleBackgroundColor(UIColor.red.withAlphaComponent(0.7), .fromCurrent),
            OZMessagesConfigurationItem.bubbleBackgroundColor(UIColor.blue.withAlphaComponent(0.6), .fromOther),
            OZMessagesConfigurationItem.fontColor(.white, [.text], .fromOther),
            OZMessagesConfigurationItem.emoticonPageIndicatorTintColor(UIColor.cyan.withAlphaComponent(0.3)),
            OZMessagesConfigurationItem.emoticonCurrentPageIndicatorTintColor(UIColor.cyan),
            // OZTextView
            OZMessagesConfigurationItem.inputTextViewFontColor(.blue),
            // OZVoiceRecordViewController
            OZMessagesConfigurationItem.voiceRecordMaxDuration(12.0),
        ]
    }
}


extension ExampleViewController: OZMessagesViewControllerDelegate {
    func messageCellDidSetMessage(cell: OZMessageCell, previousMessage: OZMessage) {
        if cell.message.type == .text || cell.message.type == .image {
            cell.layer.shadowOffset = CGSize(width: 5, height: 5)
            cell.layer.shadowOpacity = 0.05
            cell.layer.shadowRadius = 5
            cell.layer.shadowColor = cell.message.shadowColor.cgColor
            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.layer.cornerRadius).cgPath
        }
    }
    
    func messageCellLayoutSubviews(cell: OZMessageCell, previousMessage: OZMessage) {
//        if cell.message.alignment == .left {
//            switch cell.message.type {
//            case .text:
//                guard let incomingCell = cell as? IncomingTextMessageCell else { return }
//                incomingCell.iconImage.isHidden = true
//                let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//                incomingCell.textLabel.frame = incomingCell.bounds.inset(by: inset)
//            case .image, .emoticon:
//                guard let incomingCell = cell as? ImageMessageCell else { return }
//                incomingCell.iconImage.isHidden = true
//                let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//                incomingCell.imageView.frame = incomingCell.bounds.inset(by: inset)
//            case .voice:
//                guard let incomingCell = cell as? AudioPlusIconMessageCell else { return }
//                incomingCell.iconImage.isHidden = true
//                let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//                incomingCell.backView.frame = incomingCell.bounds.inset(by: inset)
//            default:
//                print(".....\(cell.message.type), prevMsg(\(String(describing: previousMessage))).....")
//            }
//        }
    }
    func messageViewLoaded(isLoaded: Bool) {
        print("messageViewLoaded...!")
    }
    
    func messageCellTapped(cell: OZMessageCell, index: Int, complete: @escaping OZChatTapCompleteBlock) {
        print("messageCellTapped => index(%d), cell(%@)", index, cell)
        
        // Do someting here and callback to OZChattingUI
        if let aCell = cell as? AudioMessageCell {
            if let aPath = aCell.message.extra["filePath"] as? String, aPath.count > 0 {
                complete(true, aPath)
            }
            else {
                aCell.preparePlay(file: "")
                if let aPath = Bundle.main.path(forResource: "test", ofType: "mp3") {
                    DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                        complete(true, aPath)
                    }
                }
            }
        }
    }
    
    func messageAppend(complete: @escaping OZChatFetchCompleteBlock) {
        print("messageAppend...!")
    }
    
    func messageSending(identifier: String, type: OZMessageType, data: OZMessage) {
        print("messageSending(id:\(identifier)):::::Sending(Type: \(type)) ==> contentPath: %@", data.content)
        
        guard let chatVC = chatViewController else { return }
        
        // Delivered message here
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            chatVC.dataSource.data.removeAll(where: { $0.content == "Delivered" })
            chatVC.send(msg: "Delivered", type: .status)
        }
    }
    
    func messageTextViewBeginEditing(textView: UITextView) {
    }
    func messageTextViewDidChanged(textView: UITextView) {
        if let cvc = self.chatViewController {
            cvc.micButton.setImage(UIImage(named: "send"), for: .normal)
            cvc.micButton.tag = kSendButtonTag
        }
    }
    func messageTextViewEndEditing(textView: UITextView) {
        if let cvc = self.chatViewController {
            cvc.micButton.setImage(UIImage(named: "mic"), for: .normal)
            cvc.micButton.tag = kMicButtonTag
        }
    }
    
    func messageMicButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool {
        if let button = sender as? UIButton, button.tag == kSendButtonTag,
            let fullText = viewController.inputTextView.text {
            
            let trimmed = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.count > 0 {
                viewController.send(msg: trimmed)
            }
            
            viewController.inputTextView.text = ""
            viewController.adjustTextViewHeight(viewController.inputTextView)
            
            viewController.micButton.setImage(UIImage(named: "mic"), for: .normal)
            viewController.micButton.tag = kMicButtonTag
            return false
        }
        return true
    }
    func messageEmoticonButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool {
        return true
    }
    func messageConfiguration(viewController: OZMessagesViewController) -> OZMessagesConfigurations {
        
        return addMessageConfiguration()
    }
}

// MARK: - UIDocumentBrowserViewControllerDelegate
// Thanks to https://www.appcoda.com/files-app-integration/
@available(iOS 11.0, *)
extension ExampleViewController: UIDocumentBrowserViewControllerDelegate {
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let newDocumentURL: URL? = nil
        
        if newDocumentURL != nil {
            importHandler(newDocumentURL, .copy)
        } else {
            importHandler(nil, .none)
        }
    }
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        presentDocument(at: sourceURL)
    }
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        presentDocument(at: destinationURL)
    }
    
    func presentDocument(at documentURL: URL) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let documentViewController = storyBoard.instantiateViewController(withIdentifier: "DocumentViewController") as! DocumentViewController
        
        documentViewController.document = Document(fileURL: documentURL)
        
        if let nc = self.navigationController {
            nc.pushViewController(documentViewController, animated: true)
        }
        else {
            present(documentViewController, animated: true, completion: nil)
        }
    }

    @objc func closeDocumentViewController() {
        self.dismiss(animated: true, completion: nil)
    }
}



// MARK: - OZChattingUI choosing image, camera, file here
extension ExampleViewController: OZChoosePopupDelegate {
    func chooseButtonClick(_ sender: Any, type: OZChooseContentType) {
        guard let cvc = chatViewController else { return }
        switch type {
        case .album:
            cvc.showImagePicker(source: .photoLibrary)
        case .camera:
            self.handleCameraPermission()
        case .file:
            if #available(iOS 11.0, *) {
                let aDocVC = UIDocumentBrowserViewController(forOpeningFilesWithContentTypes: ["public.mp3"])
                aDocVC.delegate = self
                aDocVC.allowsPickingMultipleItems = false
                if #available(iOS 13.0, *) {
                    self.present(aDocVC, animated: true)
                }
                else {
                    let nc = UINavigationController(rootViewController: aDocVC)
                    nc.navigationBar.isHidden = false
                    nc.isNavigationBarHidden = false
                    self.present(nc, animated: true) {
                        let aBarButton = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(self.closeDocumentViewController))
                        aBarButton.tintColor = .black
                        aDocVC.navigationItem.setRightBarButton(aBarButton, animated: true)
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        default:
            print("OZChoosePopupDelegate: default choosed")
        }

        cvc.addFileButtonToggle(false)
    }
    
    func handleCameraPermission() {
        guard let cvc = chatViewController else { return }
        func handleRequestCompletion(_ granted: Bool) { if granted { DispatchQueue.main.async { cvc.showCamera() } } }
        
        switch cvc.checkCameraPermission(requestCompletion: handleRequestCompletion) {
        case .denied, .restricted:  showNeedCameraPermissionAlert()
        case .authorized:           cvc.showCamera()
        case .notDetermined:        ()
        @unknown default:           ()
        }
    }
    
    func showNeedCameraPermissionAlert() {
        let alert = UIAlertController(title: nil, message: "Camera(video) access denied", preferredStyle: .alert)
        if let settings = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settings) {
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
                
                UIApplication.shared.open(settings)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
        })
        present(alert, animated: true)
    }
}
