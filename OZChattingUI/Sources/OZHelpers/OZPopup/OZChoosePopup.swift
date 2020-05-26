//
//  OZChoosePopup.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/09.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit


public enum OZChooseContentType: Int {
    case camera = 0, album, file, cancel
}

public protocol OZChoosePopupDelegate {
    func chooseButtonClick(_ sender: Any, type: OZChooseContentType)
}

open class OZChoosePopup: UIView {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var galleryView: UIView!
    @IBOutlet weak var fileView: UIView!
    
    var delegate: OZChoosePopupDelegate?
        
    @IBOutlet weak var cameraLabel: UILabel!
    @IBOutlet weak var album: UILabel!
    @IBOutlet weak var fileLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    @IBOutlet weak var popupContainerView: UIView!
    
//    required public init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    class func initialize() -> OZChoosePopup {
        if let aNib = Bundle.main.loadNibNamed("OZChoosePopup", owner: nil, options: nil),
            let firstView = aNib.first as? OZChoosePopup {
            return firstView
        }
        else if Bundle.isFramework(),
            let frameworkBundle = Bundle(identifier: kOZChattingUIBuddleIdentifier),
            let fNib = frameworkBundle.loadNibNamed("OZChoosePopup", owner: nil, options: nil),
            let firstView = fNib.first as? OZChoosePopup {
            return firstView
        }
        return Bundle.main.loadNibNamed("ChoosePopup", owner: nil, options: nil)!.first as! OZChoosePopup
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.frame = UIApplication.shared.keyWindow!.frame
        
        cameraLabel.text = "common_Camera".localized
        cameraLabel.textColor = .black
        album.text = "common_Album".localized
        album.textColor = .black
        fileLabel.text = "common_File".localized
        fileLabel.textColor = .black
        cancelButton.setTitle("common_CANCEL".localized, for: .normal)
        
        cameraView.isHidden = true
        galleryView.isHidden = true
        fileView.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touched(_:)))
        tapGesture.delegate = self
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func touched(_ gesture:UITapGestureRecognizer) {
        self.removeFromSuperview()
    }

    // display 할 버튼을 보여줘야 한다.
    public func setButtons(contents: [OZChooseContentType]) {

        for content in contents {
            switch content {
            case .camera:
                cameraView.isHidden = false
            case .album:
                galleryView.isHidden = false
            case .file:
                fileView.isHidden = false
            default:
                print("")
            }
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    public func show() {
        let window = UIApplication.shared.keyWindow!
        
        window.addSubview(self)
        
        UIView.animate(withDuration: 0.35, animations: {
            
            self.popupContainerView.frame = CGRect(x:self.popupContainerView.frame.origin.x, y:-self.popupContainerView.frame.origin.y, width:self.popupContainerView.frame.width, height:self.popupContainerView.frame.height)
        })
    }
    
    
    @IBAction func cameraButtonClick(_ sender: Any) {
        
        self.removeFromSuperview()
        
        if let aDele = delegate {
            aDele.chooseButtonClick(sender, type: .camera)
        }
    }
    
    
    @IBAction func galleryButtonClick(_ sender: Any) {
        self.removeFromSuperview()
        
        if let aDele = delegate {
            aDele.chooseButtonClick(sender, type: .album)
        }
    }
    
    @IBAction func fileButtonClick(_ sender: Any) {
        self.removeFromSuperview()
        
        if let aDele = delegate {
            aDele.chooseButtonClick(sender, type: .file)
        }
    }
    
    @IBAction func cancelButtonClick(_ sender: Any) {
        self.removeFromSuperview()

        if let aDele = delegate {
            aDele.chooseButtonClick(sender, type: .cancel)
        }
    }
    
}
extension OZChoosePopup: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !self.popupContainerView.frame.contains(touch.location(in: self)) // 터치 영역이 해당 View의 Frame 안에 포함되는지를 파악해 리턴
    }
    
}
