//
//  SocketView.swift
//  TeaParty_SwiftUI
//
//  Created by slava bily on 03.06.2021.
//

import SwiftUI

struct SocketView: View {
    // 1
    @State var newQuestion: String = ""
    
    // 2
    @ObservedObject var keyboard: Keyboard = .init()
    @ObservedObject var socket: WebSocketController = .init()
    
    init(){
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().tableFooterView = UIView()
    }
    
    var body: some View {
      // 3
      VStack(spacing: 8) {
        Text("Your asked questions:")
        Divider()
        // 4
        List(socket.questions.map { $1 }.sorted(), id: \.id) { q in
          VStack(alignment: .leading) {
            Text(q.content)
            Text("Status: \(q.answered ? "Answered" : "Unanswered")")
              .foregroundColor(q.answered ? .green : .red)
          }
        }
        .frame(height: 200)
        Spacer()
        Divider()
        // 5
        TextField("Ask a new question", text: $newQuestion, onCommit: {
          guard !self.newQuestion.isEmpty else { return }
          self.socket.addQuestion(self.newQuestion)
          self.newQuestion = ""
        })
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .padding(.horizontal)
          .padding(.bottom, keyboard.height * 2)
          .edgesIgnoringSafeArea(keyboard.height > 0 ? .bottom : [])
      }
      .padding(.vertical)
      // 6
      .alert(item: $socket.alertWrapper) { $0.alert }
    }
}

struct SocketView_Previews: PreviewProvider {
    static var previews: some View {
        SocketView()
    }
}
