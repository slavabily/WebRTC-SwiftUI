//
//  MainViewRepresentable.swift
//  WebRTC-SwiftUI
//
//  Created by slava bily on 16.06.2021.
//

import SwiftUI
import UIKit

struct MainViewRepresentable: UIViewControllerRepresentable {
    
    private let config = Config.default
    
    func makeUIViewController(context: Context) -> MainViewController {
 
        return buildMainViewController() as! MainViewController
    }
    
    func updateUIViewController(_ mainViewController: MainViewController, context: Context) {
        
        mainViewController.viewWillAppear(true)
    }
    
    private func buildMainViewController() -> UIViewController {
        
        let webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers)
        let signalClient = self.buildSignalingClient()
        let mainViewController = MainViewController(signalClient: signalClient, webRTCClient: webRTCClient)
        
        return mainViewController
    }
    
    private func buildSignalingClient() -> SignalingClient {
        
        // iOS 13 has native websocket support. For iOS 12 or lower we will use 3rd party library.
        let webSocketProvider: WebSocketProvider
        
        if #available(iOS 13.0, *) {
            webSocketProvider = NativeWebSocket(url: self.config.signalingServerUrl)
        } else {
            webSocketProvider = StarscreamWebSocket(url: self.config.signalingServerUrl)
        }
        
        return SignalingClient(webSocket: webSocketProvider)
    }
     
}
