/// Copyright (c) 2020 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import SwiftUI

struct AlertWrapper: Identifiable {
  let id = UUID()
  let alert: Alert
}

final class WebSocketController: ObservableObject {
  @Published var alertWrapper: AlertWrapper?
    
    @Published var questions: [UUID: NewQuestionResponse]
    
  var alert: Alert? {
    didSet {
      guard let a = self.alert else { return }
      DispatchQueue.main.async {
        self.alertWrapper = .init(alert: a)
      }
    }
  }

  private var id: UUID!
  private let session: URLSession
  var socket: URLSessionWebSocketTask!
  private let decoder = JSONDecoder()
  private let encoder = JSONEncoder()
  
  init() {
    self.questions = [:]
    self.alertWrapper = nil
    self.alert = nil
    
    self.session = URLSession(configuration: .default)
    self.connect()
  }
    
  func connect() {
    self.socket = session.webSocketTask(with:
      URL(string: "ws://localhost:8080/socket")!)
    self.listen()
    self.socket.resume()
  }

    func addQuestion(_ content: String) {
        guard let id = self.id else { return }
        // 1
        let message = NewQuestionMessage(id: id, content: content)
        do {
            // 2
            let data = try encoder.encode(message)
            // 3
            self.socket.send(.data(data)) { (err) in
                if err != nil {
                    print(err.debugDescription)
                }
            }
        } catch {
            print(error)
        }
    }

    func handle(_ data: Data) {
        do {
            // 1
            let sinData = try decoder.decode(QnAMessageSinData.self, from: data)
            // 2
            switch sinData.type {
            case .handshake:
                // 3
                print("Shook the hand")
                let message = try decoder.decode(QnAHandshake.self, from: data)
                self.id = message.id
            // 4
            case .questionResponse:
                try self.handleQuestionResponse(data)
            case .questionAnswer:
                try self.handleQuestionAnswer(data)
            default:
                break
            }
        } catch {
            print(error)
        }
    }

  func listen() {
    // 1
    self.socket.receive { [weak self] (result) in
      guard let self = self else { return }
      // 2
      switch result {
      case .failure(let error):
        print(error)
        // 3
        let alert = Alert(
            title: Text("Unable to connect to server!"),
            dismissButton: .default(Text("Retry")) {
              self.alert = nil
              self.socket.cancel(with: .goingAway, reason: nil)
              self.connect()
            }
        )
        self.alert = alert
        return
      case .success(let message):
        // 4
        switch message {
        case .data(let data):
          self.handle(data)
        case .string(let str):
          guard let data = str.data(using: .utf8) else { return }
          self.handle(data)
        @unknown default:
          break
        }
      }
      // 5
      self.listen()
    }
  }

    func handleQuestionAnswer(_ data: Data) throws {
        // 1
        let response = try decoder.decode(QuestionAnsweredMessage.self, from: data)
        DispatchQueue.main.async {
            // 2
            guard let question = self.questions[response.questionId] else { return }
            question.answered = true
            self.questions[response.questionId] = question
        }
    }
  
  func handleQuestionResponse(_ data: Data) throws {
    // 1
    let response = try decoder.decode(NewQuestionResponse.self, from: data)
    DispatchQueue.main.async {
      if response.success, let id = response.id {
        // 2
        self.questions[id] = response
        let alert = Alert(title: Text("New question received!"),
                          message: Text(response.message),
                          dismissButton: .default(Text("OK")) { self.alert = nil })
        self.alert = alert
      } else {
        // 3
        let alert = Alert(title: Text("Something went wrong!"),
                          message: Text(response.message),
                          dismissButton: .default(Text("OK")) { self.alert = nil })
        self.alert = alert
      }
    }
  }
}
