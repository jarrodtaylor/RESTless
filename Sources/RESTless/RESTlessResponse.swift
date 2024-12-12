import Foundation
import UniformTypeIdentifiers

public struct RESTlessResponse {
  public let status: Status
  public let body: Data
	let headers: [Header: String]
	let httpVersion = "HTTP/1.1"

	enum Header: String {
		case contentLength = "Content-Length"
		case contentType = "Content-Type"
	}

	public enum Status: Int, CustomStringConvertible {
		case ok = 200
		case notFound = 404
		case teapot = 418

		public var description: String {
		  switch self {
				case .ok: return "OK"
				case .notFound: return "Not Found"
				case .teapot: return "I'm a teapot"
			}
		}
	}

	var data: Data {
	  var headerLines = ["\(httpVersion) \(status.rawValue) \(status)"]
		headerLines.append(contentsOf: headers.map({ "\($0.key.rawValue): \($0.value)" }))
		headerLines.append(""); headerLines.append("")
		let header = headerLines.joined(separator: "\r\n").data(using: .utf8)!
		return header + body
	}

	init(_
    status: Status = .ok,
    body: Data = Data(),
    contentType: UTType? = nil,
    headers: [Header: String] = [:])
  {
    self.body = body
    let contentLength = String(body.count)
    let contentType = contentType?.preferredMIMEType
    self.headers = headers.merging(
      [.contentLength: contentLength, .contentType: contentType].compactMapValues { $0 },
      uniquingKeysWith: { _, new in new })
    self.status = status
	}

	init(filePath: String) throws {
		let url = URL(filePath: filePath)
		let data = try Data(contentsOf: url)
		let contentType = try url.resourceValues(forKeys: [.contentTypeKey]).contentType
		self.init(body: data, contentType: contentType)
	}

	init(_ text: String, contentType: UTType = .plainText) {
	  let data = text.data(using: .utf8)!
	  self.init(body: data, contentType: contentType)
	}
}
