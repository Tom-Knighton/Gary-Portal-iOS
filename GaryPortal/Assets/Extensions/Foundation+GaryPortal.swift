//
//  Foundation+GaryPortal.swift
//  GaryPortal
//
//  Created by Tom Knighton on 14/01/2021.
//

import Foundation
import UIKit

extension String {
    
    ///Returns the string without extraneous whitespaces
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    
    ///Returns whether the string contains only whitespaces, or is empty
    func isEmptyOrWhitespace() -> Bool {
        return self.isEmpty ? true : self.trimmingCharacters(in: .whitespaces) == ""
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
