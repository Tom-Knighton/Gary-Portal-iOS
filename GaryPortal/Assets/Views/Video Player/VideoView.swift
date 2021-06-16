//
//  VideoView.swift
//  SwiftUIVideo
//
//  Created by Gray Campbell on 5/2/20.
//  Copyright © 2020 Gray Campbell. All rights reserved.
//

import AVKit
import SwiftUI

struct Video {
    
    // MARK: Properties
    
    static let sintel = Video(
        url: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")
    )
    
    let url: URL?
}

struct VideoView: View {
    @ObservedObject var viewModel = VideoViewModel(video: .sintel)
    
    var body: some View {
        VStack(spacing: 0) {
            if self.viewModel.isExpanded {
                VideoPlayerContainerView(viewModel: self.viewModel)
            }
            else {
                VideoPlayerContainerView(viewModel: self.viewModel)
                    .aspectRatio(1242.0 / 529.0, contentMode: .fit)
            }
        }
        .statusBar(hidden: self.viewModel.isExpanded)
    }
}

struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoView()
    }
}
