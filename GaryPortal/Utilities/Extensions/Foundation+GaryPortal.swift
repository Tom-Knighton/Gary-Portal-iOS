//
//  Foundation+GaryPortal.swift
//  GaryPortal
//
//  Created by Tom Knighton on 14/01/2021.
//

import Foundation
import UIKit
import SwiftDate
import ImageIO
import AttributedText

extension String: Identifiable {
    
    public var id: String { return self }
    
    ///Returns the string without extraneous whitespaces
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
    
    ///Returns whether the string contains only whitespaces, or is empty
    func isEmptyOrWhitespace() -> Bool {
        return self.isEmpty ? true : self.trimmingCharacters(in: .whitespacesAndNewlines) == ""
    }
    
    ///Returns whether the string matches a valid email pattern
    var isValidEmail: Bool {
        let regex = try? NSRegularExpression(pattern: GaryPortalConstants.EmailRegex, options: .caseInsensitive)
        return regex?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    
    ///Returns whether the string matches a valid password strength
    var isValidPassword: Bool {
        let regex = try? NSRegularExpression(pattern: GaryPortalConstants.PasswordRegex, options: [])
        return regex?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    
    func containsOnlyEmojis() -> Bool {
        if count == 0 {
            return false
        }
        for character in self {
            if !character.isEmoji {
                return false
            }
        }
        return true
    }
    
    func emojiCharacterCount() -> Int {
        guard count > 0 else { return count }
        
        var emojiCount = 0
        for character in self {
            if character.isEmoji {
                emojiCount += 1
            }
        }
        print(emojiCount)
        return emojiCount
    }
    
    func containsEmoji() -> Bool {
        for character in self {
            if character.isEmoji {
                return true
            }
        }
        return false
    }
    
    func getUrls() -> [URL] {
        let types: NSTextCheckingResult.CheckingType = .link

        do {
            let detector = try NSDataDetector(types: types.rawValue)

            let matches = detector.matches(in: self, options: .reportCompletion, range: NSMakeRange(0, self.count))
        
            return matches.compactMap({$0.url})
        } catch let error {
            debugPrint(error.localizedDescription)
        }

        return []
    }
    
    func convertToAttributedHyperlinks() -> NSAttributedString {
        let urls = self.getUrls()
        
        let attributedString = NSMutableAttributedString(string: self)
        for url in urls {
            let range = attributedString.mutableString.range(of: url.absoluteString)
            attributedString.addAttributes([.link: url], range: range)
        }
        
        attributedString.addAttributes([.font: UIFont.preferredFont(forTextStyle: .body)], range: attributedString.mutableString.range(of: self))
        
        return attributedString
    }
}

extension UITextView {
    func makeHyperLinks(originalText: String, hyperLink: String, urlString: String) {
        let style = NSMutableParagraphStyle()
            style.alignment = .left

            let attributedOriginalText = NSMutableAttributedString(string: originalText)
            let linkRange = attributedOriginalText.mutableString.range(of: hyperLink)
            let fullRange = NSMakeRange(0, attributedOriginalText.length)
            attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: urlString, range: linkRange)
            attributedOriginalText.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: fullRange)
            attributedOriginalText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 10), range: fullRange)

            self.linkTextAttributes = [
                kCTForegroundColorAttributeName: UIColor.blue,
                kCTUnderlineStyleAttributeName: NSUnderlineStyle.single.rawValue,
                ] as [NSAttributedString.Key : Any]

            self.attributedText = attributedOriginalText
    }
}

extension Character {
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let aVal, rVal, gVal, bVal: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (aVal, rVal, gVal, bVal) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (aVal, rVal, gVal, bVal) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (aVal, rVal, gVal, bVal) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (aVal, rVal, gVal, bVal) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(rVal) / 255, green: CGFloat(gVal) / 255, blue: CGFloat(bVal) / 255, alpha: CGFloat(aVal) / 255)
    }
}

extension UIImage {
    func imageByCombiningImage(withImage secondImage: UIImage) -> UIImage {
        let newImageWidth  = self.size.width
        let newImageHeight = self.size.height
        let newSize = CGSize(width : newImageWidth, height: newImageHeight)
        
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        
        self.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        secondImage.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        
        return image!
    }
    
    func getDocumentDirectoryPath() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
    }
    
    func saveImageToDocumentsDirectory(withName: String) -> String? {
        let image = self
        if let data = image.jpegData(compressionQuality: 0.7) {
            let dirPath = getDocumentDirectoryPath()
            let imageFileUrl = URL(fileURLWithPath: dirPath.appendingPathComponent(withName) as String)
            do {
                try data.write(to: imageFileUrl)
                return imageFileUrl.absoluteString
            } catch {
                print("Error saving image: \(error)")
            }
        }
        return nil
    }
    
    class func loadImageFromDocumentsDirectory(imageName: String) -> UIImage? {
        let tempDirPath = UIImage().getDocumentDirectoryPath()
        let imageFilePath = tempDirPath.appendingPathComponent(imageName)
        return UIImage(contentsOfFile:imageFilePath)
    }
    
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
        
    }
    
    public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
        guard let bundleURL:URL = URL(string: gifUrl) else {
            print("image named \"\(gifUrl)\" doesn't exist")
            return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif") else {
            print("SwiftGif: This image named \"\(name)\" does not exist")
            return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    private class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        let defaultDelay = 0.032 // 30 fps
        var delay = defaultDelay
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        guard let castedDelay = delayObject as? Double else { return delay }
        
        delay = castedDelay < defaultDelay ? defaultDelay : castedDelay
        
        return delay
    }
    
    private class func gcdForArray(_ array: [Int]) -> Int {
        if array.isEmpty {
            return 1
        }
        
        return array.sorted(by: <).first ?? 1
    }
    
    private class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        let images = (0..<count)
            .compactMap({ CGImageSourceCreateImageAtIndex(source, $0, nil) })
        let delays = images
            .enumerated()
            .map({ Int(UIImage.delayForImageAtIndex($0.offset,source: source) * 1000) })
        
        let duration = delays.reduce(0, +)
        
        let gcd = gcdForArray(delays)
        let frames: [UIImage] = images
            .map({ UIImage(cgImage: $0) })
            .enumerated()
            .map({
                Array(repeating: $0.element, count: Int(delays[$0.offset] / gcd) )
            })
            .flatMap({ $0 })
        
        let animation = UIImage.animatedImage(with: frames, duration: Double(duration) / 1000)
        
        return animation
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
    
    func alphaAtPoint(_ point: CGPoint) -> CGFloat {
        
        var pixel: [UInt8] = [0, 0, 0, 0]
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        let alphaInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        guard let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: alphaInfo) else {
            return 0
        }
        
        context.translateBy(x: -point.x, y: -point.y);
        
        layer.render(in: context)
        
        let floatAlpha = CGFloat(pixel[3])
        
        return floatAlpha
    }
}

extension Date {
    func minutesBetweenDates(_ newDate: Date) -> CGFloat {
        
        let oldDate = self
        //get both times sinces refrenced date and divide by 60 to get minutes
        let newDateMinutes = newDate.timeIntervalSinceReferenceDate/60
        let oldDateMinutes = oldDate.timeIntervalSinceReferenceDate/60
        
        //then return the difference
        return CGFloat(newDateMinutes - oldDateMinutes)
    }
    
    func niceDateAndTime() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.doesRelativeDateFormatting = true
        
        if isToday && self.hour == Date().hour && (CGFloat(Date().minute - self.minute) <= 1.5) {
            return "Now"
        } else if isToday {
            dateFormatterPrint.timeStyle = .short
            dateFormatterPrint.dateStyle = .none
            return "Today at \(dateFormatterPrint.string(from: self))"
        } else if isYesterday {
            dateFormatterPrint.timeStyle = .short
            dateFormatterPrint.dateStyle = .none
            return "Yesterday at \(dateFormatterPrint.string(from: self))"
        } else if self.compareCloseTo(Date(), precision: 6.days.timeInterval) {
            return dateFormatterPrint.weekdaySymbols[weekday - 1]
        } else {
            dateFormatterPrint.timeStyle = .none
            dateFormatterPrint.dateStyle = .short
        }
        return dateFormatterPrint.string(from: self)
    }
    
    func shortDateOrTime() -> String {
        let calendar = Calendar.current
        guard
            let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date()),
            let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date()),
            let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date()),
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())
        else { return "" }

        if minuteAgo < self {
           return "Now"
        } else if hourAgo < self {
           let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
           return "\(diff)m"
        } else if dayAgo < self {
           let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
           return "\(diff)h"
        } else if weekAgo < self {
           let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
           return "\(diff)d"
        }
        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
        return "\(diff)w"
    }
}

extension UIApplication {
    
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.sendResignNotif(_:)))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func sendResignNotif(_ sender: AnyObject? = nil) {
        guard let window = windows.first else { return }
        NotificationCenter.default.post(Notification(name: .shouldEndEditing))
        window.endEditing(true)
    }
        
    class func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        let base = base ?? keyWindow?.rootViewController
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false // set to `false` if you don't want to detect tap during other gestures
    }
}

extension FileManager {
    func clearTmpDirectory() {
        do {
            let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach {[unowned self] file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try self.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
}
