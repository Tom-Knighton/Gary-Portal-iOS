//
//  Bundle+GaryPortal.swift
//  AlMurray
//
//  Created by Tom Knighton on 24/11/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
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
