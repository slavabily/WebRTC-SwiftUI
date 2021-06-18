//
//  ContainerView.swift
//  WebRTC-SwiftUI
//
//  Created by slava bily on 18.06.2021.
//

import SwiftUI

struct ContainerView: View {
    var body: some View {
        ZStack {
            VideoViewRepresentable()
            SocketView()
                .frame(width: UIScreen.main.bounds.width / 2, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .leading)
                .position(x: 100, y: 480)
        }
    }
}

struct ContainerView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView()
    }
}
