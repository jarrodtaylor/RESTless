import Foundation
import Network

public typealias RESTless = Server

final public class Server: Sendable {
  public typealias Callback = @Sendable (Request?, Response?, NWError?) -> Void

  let callback: Callback
  let listener: NWListener
  let path: String

  @discardableResult public init(path: String, port: UInt16, callback: @escaping Callback) {
    (self.callback, self.path) = (callback, path)
    self.listener = try! NWListener(using: .tcp, on: NWEndpoint.Port(rawValue: port)!)

    listener.newConnectionHandler = {(_ connection: NWConnection) in
      connection.start(queue: .main)
      self.receive(from: connection)
    }

    listener.start(queue: .main)
  }

  func receive(from connection: NWConnection) {
    connection.receive(
      minimumIncompleteLength: 1,
      maximumLength: connection.maximumDatagramSize
    ) { content, _, complete, error in
      if let error {self.callback(nil, nil, error)}
      else if let content, let request = Request(content)
        {self.respond(on: connection, request: request)}
      if !complete {self.receive(from: connection)}
    }
  }

  func respond(on connection: NWConnection, request: Request) {
    guard request.method == "GET" else {
      let response = Response(.teapot)
      callback(request, response, nil)
      connection.send(content: response.data, completion: .idempotent)
      return
    }

    func findFile(_ filePath: String) -> String? {
      var isDir: ObjCBool = false
      guard let foundPath = [filePath, "\(filePath)/index.html", "\(filePath)/index.htm"]
        .first(where: {FileManager.default.fileExists(atPath: $0, isDirectory: &isDir)
          ? !isDir.boolValue : false})
      else {return nil}
      return foundPath
    }

    guard
      let filePath = findFile(self.path + request.path),
      let response = try? Response(filePath: filePath)
    else {
      let response = Response(.notFound)
      callback(request, response, nil)
      connection.send(content: response.data, completion: .idempotent)
      return
    }

    callback(request, response, nil)
    connection.send(content: response.data, completion: .idempotent)
  }
}
