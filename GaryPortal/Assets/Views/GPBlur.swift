//
//  GPBlur.swift
//  GaryPortal
//
//  Created by Tom Knighton on 07/09/2021.
//

import SwiftUI

@available(*, deprecated, message: "This should be replaced with SwiftUI 3.0's material system when ios15 is min requirement")
struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
