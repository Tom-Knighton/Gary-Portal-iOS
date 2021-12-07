//
//  VideoPlayerContainerView.swift
//  SwiftUIVideo
//
//  Created by Gray Campbell on 5/3/20.
//  Copyright © 2020 Gray Campbell. All rights reserved.
//

import AVKit
import SwiftUI

struct VideoPlayerContainerView: View {
    @ObservedObject var viewModel: VideoViewModel
    
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if self.viewModel.isExpanded {
                    Color.black
                        .edgesIgnoringSafeArea(.all)
                }
                else {
                    Color.black
                }
                
                VideoPlayerView(player: self.viewModel.player)
                    .frame(width: geo.size.width, height: geo.size.height)
                
                VideoPlayerControlsView(viewModel: self.viewModel)
                    .opacity(self.viewModel.isShowingControls ? 1 : 0)
                    .animation(.easeInOut)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .onTapGesture(perform: self.toggleControls)
        }
        .fullScreenCover(isPresented: $viewModel.isExpanded) {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VideoPlayerView(player: self.viewModel.player)
                VideoPlayerControlsView(viewModel: self.viewModel)
                    .opacity(self.viewModel.isShowingControls ? 1 : 0)
                    .animation(.easeInOut)
            }
            .onTapGesture {
                self.toggleControls()
            }
        }
    }
    
    private func toggleControls() {
        self.viewModel.isShowingControls.toggle()
        self.viewModel.startControlTimer()
    }
}

