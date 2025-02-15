import Foundation

struct Request {
  let headers:    [String: String]
  let httpVersion: String
  let method:      String
  let path:        String

  init?(_ data: Data) {
    let request = String(data: data, encoding: .utf8)!
      .components(separatedBy: "\r\n")
    guard let requestLine = request.first, request.last!.isEmpty
    else {return nil}

    let components = requestLine.components(separatedBy: " ")
    guard components.count == 3 else {return nil}

    (self.httpVersion, self.method, self.path) =
      (components[2], components[0], components[1])

    self.headers = Dictionary(
      request
        .dropFirst()
        .map {$0.split(separator: ":", maxSplits: 1)}
        .filter {$0.count == 2}
        .map {($0[0].lowercased(), $0[1].trimmingCharacters(in: .whitespaces))},
      uniquingKeysWith: {x, _ in x})
  }
}
