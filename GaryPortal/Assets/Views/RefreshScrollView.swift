//
//  RefreshScrollView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 09/02/2021.
//

import SwiftUI

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
