//
//  MediaRemoteController.swift
//  LosslessSwitcher
//
//  Created by Vincent Neo on 1/5/22.
//

import Cocoa
//import Combine
//import PrivateMediaRemote
import MediaRemoteAdapter

fileprivate let kMusicAppBundle = "com.apple.Music"

class MediaRemoteController {
    
    private let controller: MediaController
    
    init(outputDevices: OutputDevices) {
        
        let controller = MediaController()
        self.controller = controller
        controller.startListening()
        
        controller.onTrackInfoReceived = { [weak outputDevices] trackInfo in
            guard let outputDevices else { return }

            // The adapter hands back nil when the now-playing source is CLEARED (the
            // player quit, or a browser tab playing media closed). Treat that as "no
            // now-playing app" instead of ignoring it: a stale bundle id + isPlaying
            // would otherwise keep gating rate decisions after the source is gone.
            guard let trackInfo else {
                DispatchQueue.main.async { outputDevices.nowPlayingDidClear() }
                return
            }

            print("track \(trackInfo.payload.uniqueIdentifier) \(trackInfo.payload.title ?? "nil")")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                outputDevices.trackDidChange(trackInfo)
            }
        }
        
    }
    
    deinit {
        controller.stopListening()
    }
    
}
