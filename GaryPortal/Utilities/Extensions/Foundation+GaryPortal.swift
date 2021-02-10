//
//  Foundation+GaryPortal.swift
//  GaryPortal
//
//  Created by Tom Knighton on 14/01/2021.
//

import Foundation
import UIKit
import SwiftDate

extension String {
    
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
        
        if isToday {
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
}

extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false // set to `false` if you don't want to detect tap during other gestures
    }
}

