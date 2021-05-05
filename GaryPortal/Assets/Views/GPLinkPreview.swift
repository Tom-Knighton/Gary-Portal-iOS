//
//  GPLinkPreview.swift
//  GaryPortal
//
//  Created by Tom Knighton on 05/05/2021.
//

import SwiftUI
import LinkPresentation

struct GPLinkPreview: UIViewRepresentable {
    
    var previewUrl: URL
    @Binding var redraw: Bool
    
    func makeUIView(context: Context) -> LPLinkView {
        let view = LPLinkView(url: previewUrl)

        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: previewUrl) { (metadata, error) in
           if let md = metadata {
               DispatchQueue.main.async {
                   view.metadata = md
                   view.sizeToFit()
                   self.redraw.toggle()
               }
           }
           else if error != nil
           {
               let md = LPLinkMetadata()
               md.title = "Custom title"
               view.metadata = md
               view.sizeToFit()
               self.redraw.toggle()
           }
        }

        return view
    }
    
    func updateUIView(_ uiView: LPLinkView, context: Context) {
        
    }
}

