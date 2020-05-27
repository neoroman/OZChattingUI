import UIKit

let kOZChattingUIBuddleIdentifier = "kr.alterant.OZChattingUI"

extension UIColor {
  static var lightBlue: UIColor {
    return UIColor(red: 0, green: 184/255, blue: 1.0, alpha: 1.0)
  }
}

extension CGFloat {
  func clamp(_ a: CGFloat, _ b: CGFloat) -> CGFloat {
    return self < a ? a : (self > b ? b : self)
  }
}

extension CGPoint {
  func translate(_ dx: CGFloat, dy: CGFloat) -> CGPoint {
    return CGPoint(x: self.x+dx, y: self.y+dy)
  }

  func transform(_ t: CGAffineTransform) -> CGPoint {
    return self.applying(t)
  }

  func distance(_ b: CGPoint) -> CGFloat {
    return sqrt(pow(self.x-b.x, 2)+pow(self.y-b.y, 2))
  }
}
func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}
func += (left: inout CGPoint, right: CGPoint) {
  left.x += right.x
  left.y += right.y
}
func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}
func /(left: CGPoint, right: CGFloat) -> CGPoint {
  return CGPoint(x: left.x/right, y: left.y/right)
}
func *(left: CGPoint, right: CGFloat) -> CGPoint {
  return CGPoint(x: left.x*right, y: left.y*right)
}
func *(left: CGFloat, right: CGPoint) -> CGPoint {
  return right * left
}
func *(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x*right.x, y: left.y*right.y)
}
prefix func -(point: CGPoint) -> CGPoint {
  return CGPoint.zero - point
}
func /(left: CGSize, right: CGFloat) -> CGSize {
  return CGSize(width: left.width/right, height: left.height/right)
}
func -(left: CGPoint, right: CGSize) -> CGPoint {
  return CGPoint(x: left.x - right.width, y: left.y - right.height)
}

prefix func -(inset: UIEdgeInsets) -> UIEdgeInsets {
  return UIEdgeInsets(top: -inset.top, left: -inset.left, bottom: -inset.bottom, right: -inset.right)
}

extension CGRect {
  var center: CGPoint {
    return CGPoint(x: midX, y: midY)
  }
  var bounds: CGRect {
    return CGRect(origin: .zero, size: size)
  }
  init(center: CGPoint, size: CGSize) {
    self.init(origin: center - size / 2, size: size)
  }
}

func delay(_ delay: Double, closure:@escaping ()->Void) {
  DispatchQueue.main.asyncAfter(
    deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

extension String {
  func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
    let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
    let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    
    return boundingBox.width
  }
}

extension UIImage {
    class func frameworkImage(named: String, ofType: String? = nil) -> UIImage? {
        if let imagePath = Bundle.main.path(forResource: named, ofType: ofType ?? "") {
            return UIImage(contentsOfFile: imagePath)!
        }
        else if let fBundle = Bundle(identifier: kOZChattingUIBuddleIdentifier),
            let imagePath = fBundle.path(forResource: named, ofType: ofType ?? "") {
            return UIImage(contentsOfFile: imagePath)!
        }
        return nil
    }
}

extension Bundle {
    class func isFramework() -> Bool {
        guard let _ = Bundle(identifier: kOZChattingUIBuddleIdentifier) else {
            return false
        }
        return true
    }
}

extension FileManager {
    class func isFileExist(named: String) -> Bool {
        var path = named
        if named.lowercased().hasPrefix("file"),
            let url = URL(string: named) {
            path = url.relativePath
        }
        if FileManager.default.isReadableFile(atPath: path) {
            return true
        }
        return false
    }
    
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension String {
    static func randomFileName(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    func fileName() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }
    
    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
    
    var localized: String {
        var localizedString = NSLocalizedString(self, comment: "")
        if self == localizedString, Bundle.isFramework(),
            let bundle = Bundle(identifier: kOZChattingUIBuddleIdentifier) {
            localizedString = NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
        }
        return localizedString
    }
    
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}

extension Date {
    static func formDateForChat(timestamp: Int, format: String = "h:mm a") -> String {
        return Date(timeIntervalSince1970: TimeInterval(timestamp)).toString(DateFormat.custom(format), timeZone: .local)
    }
}

extension UIDevice {
    
    var isIphoneX: Bool {
        if #available(iOS 11.0, *), isIphone {
            if isLandscape {
                if let leftPadding = UIApplication.shared.keyWindow?.safeAreaInsets.left, leftPadding > 0 {
                    return true
                }
                if let rightPadding = UIApplication.shared.keyWindow?.safeAreaInsets.right, rightPadding > 0 {
                    return true
                }
            } else {
                if let topPadding = UIApplication.shared.keyWindow?.safeAreaInsets.top, topPadding > 0 {
                    return true
                }
                if let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom, bottomPadding > 0 {
                    return true
                }
            }
        }
        return false
    }
    
    var isLandscape: Bool {
        return orientation.isLandscape || UIApplication.shared.statusBarOrientation.isLandscape
    }
    
    var isPortrait: Bool {
        return orientation.isPortrait || UIApplication.shared.statusBarOrientation.isPortrait
    }
    
    var isIphone: Bool {
        return self.userInterfaceIdiom == .phone
    }
    
    var isIpad: Bool {
        return self.userInterfaceIdiom == .pad
    }
}

extension String {
    func isHangul() -> Bool {
        let range = NSRange(location: 0, length: self.utf16.count)
        let regex = try! NSRegularExpression(pattern: "[ㄱ-힣]")
        if regex.firstMatch(in: self, options: [], range: range) != nil {
            return true
        }
        return false
    }
}
