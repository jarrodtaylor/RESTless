import Foundation
import UniformTypeIdentifiers

public struct Response {
  public let body:     Data
  public let headers: [Header: String]
  public let status:   Status

  public let httpVersion = "HTTP/1.1"

  public enum Header: String {
    case contentLength = "Content-Length"
    case contentType   = "Content-Type"
  }

  public enum Status: Int, CustomStringConvertible {
    case ok       = 200
    case notFound = 404
    case teapot   = 418

    public var description: String {
      switch self {
        case .ok:       return "OK"
        case .notFound: return "Not Found"
        case .teapot:   return "I'm a teapot"
      }
    }
  }

  public var data: Data {
    var headerLines = ["\(httpVersion) \(status.rawValue) \(status)"]
    headerLines.append(contentsOf:headers.map({"\($0.key.rawValue): \($0.value)"}))
    headerLines.append(""); headerLines.append("")
    return headerLines.joined(separator: "\r\n").data(using: .utf8)! + body
  }

  init(_ status: Status = .ok,
           body: Data = Data(),
    contentType: UTType? = nil,
        headers: [Header: String] = [:])
  {
    (self.status, self.body) = (status, body)
    let _headers: [Header: String?] = [
      .contentLength: String(body.count),
      .contentType: contentType?.preferredMIMEType]
    self.headers = headers.merging(_headers.compactMapValues {$0},
      uniquingKeysWith: {_, x in x})
  }

  init(filePath: String) throws {
    let url = URL(filePath: filePath)
    self.init(
      body: try Data(contentsOf: url),
      contentType: try url.resourceValues(forKeys: [.contentTypeKey]).contentType)
  }

  init(_ text: String, contentType: UTType = .plainText) {
    self.init(body: text.data(using: .utf8)!, contentType: contentType)
  }
}
