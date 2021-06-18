//
//  VideoViewRepresentable.swift
//  WebRTC-SwiftUI
//
//  Created by slava bily on 18.06.2021.
//

import SwiftUI
import UIKit

struct VideoViewRepresentable: UIViewControllerRepresentable {
    
    private let config = Config.default
    
    func makeUIViewController(context: Context) -> VideoViewController {
        
        let webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers)
        
        return VideoViewController(webRTCClient: webRTCClient)
    }
    
    func updateUIViewController(_ videoViewController: VideoViewController, context: Context) {
        videoViewController.viewWillAppear(true)
    }
    
}
