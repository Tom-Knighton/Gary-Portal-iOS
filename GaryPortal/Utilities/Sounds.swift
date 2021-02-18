//
//  Sounds.swift
//  GaryPortal
//
//  Created by Tom Knighton on 18/01/2021.
//

import AVFoundation

class Sounds {
    
    static var audioPlayer:AVAudioPlayer?
    
    static func playSounds(soundfile: String) {
        
        if let path = Bundle.main.path(forResource: soundfile, ofType: nil){
            
            do{
                
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                try AVAudioSession.sharedInstance().setCategory(.playback)
                audioPlayer?.volume = 0.3
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                
            } catch {
                print("Error")
            }
        } else {
            print("no path")
        }
    }
}

