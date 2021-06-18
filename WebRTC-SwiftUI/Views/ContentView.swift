//
//  ContentView.swift
//  WebRTC-SwiftUI
//
//  Created by slava bily on 16.06.2021.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isVideoViewAppeared = false
    
    var body: some View {
        ZStack {
            MainViewRepresentable()
            Button("Video") {
                // to trigger transition to VideoView
                isVideoViewAppeared.toggle()
            }
            .font(.callout)
            .position(x: 310, y: 515)
        }
        .sheet(isPresented: $isVideoViewAppeared, content: {
            ContainerView()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
