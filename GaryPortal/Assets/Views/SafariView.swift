//
//  SafariView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 15/01/2021.
//

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: String?

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        guard let url = URL(string: url ?? "https://garyportal.tomk.online") else { return SFSafariViewController(url: URL(string: "https://garyportal.tomk.online")!) }
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {

    }
}
