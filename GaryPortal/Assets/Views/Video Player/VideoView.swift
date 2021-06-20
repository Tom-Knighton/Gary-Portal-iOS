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


