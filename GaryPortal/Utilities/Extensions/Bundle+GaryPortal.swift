//
//  Bundle+GaryPortal.swift
//  GaryPortal
//
//  Created by Tom Knighton on 19/02/2021.
//

import Foundation
extension Bundle {

    var appName: String {
        return infoDictionary?["CFBundleName"] as? String ?? "Gary Portal"
    }

    var bundleId: String {
        return bundleIdentifier ?? ""
    }

    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    var buildNumber: String {
        return (infoDictionary?["CFBundleVersion"] as? String ?? "").unicodeScalars.filter { $0.isASCII }
            .map { String(format: "%X", $0.value) }
            .joined()
    }

}
